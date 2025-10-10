# Tainting in Concolic Testing - Explained

## The Problem Without Tainting

```java
// Regular execution - no symbolic tracking
void testTransformation(int userChoice) {
    switch (userChoice) {
        case 0: createInterruptTask(); break;
        case 1: createPeriodicTask(); break;
        // ...
    }
}

testTransformation(0);  // Runs with 0, but HOW do we discover other paths?
```

**Problem**: The JVM just executes with concrete value 0. There's no record that this value:
- Represents a user input
- Could have been different
- Should be explored with other values

## The Solution With Tainting

### Step 1: Mark the Value as Symbolic

```java
// Create symbolic tag - associates concrete value with symbolic variable
Tag symbolicTag = GaletteSymbolicator.makeSymbolicInt("user_choice", 0);
//                                                      ^^^^^^^^^^^  ^
//                                                      symbolic     concrete
//                                                      variable     value
//                                                      name

// Tag the value - attach metadata
int taggedChoice = Tainter.setTag(0, symbolicTag);
//                                  ^  ^^^^^^^^^^^^
//                                  |  metadata: "this is user_choice"
//                                  concrete value
```

### Step 2: Galette Intercepts Operations

When tagged values are used in operations, Galette's bytecode instrumentation intercepts them:

```java
switch (taggedChoice) {  // Galette intercepts this comparison
    case 0:
        // Galette records: "user_choice == 0" (path constraint)
        createInterruptTask();
        break;
    case 1:
        // Not taken, but Galette knows: "user_choice == 1" is alternative
        createPeriodicTask();
        break;
}
```

**Behind the scenes (Galette's instrumentation):**

```java
// Original code:
if (taggedChoice == 0) { ... }

// What Galette actually executes (simplified):
if (taggedChoice == 0) {
    // Check if value has a tag
    Tag tag = Tainter.getTag(taggedChoice);
    if (tag != null) {
        // Record constraint: user_choice == 0
        PathUtils.getCurPC().addConstraint(
            new Equals(
                new Variable("user_choice"),  // from tag
                new IntConstant(0)            // from comparison
            )
        );
    }
    // Continue with original code...
}
```

### Step 3: Collect Path Constraints

```java
// After execution, retrieve constraints
PathConditionWrapper pc = PathUtils.getCurPC();

// Print collected constraints
for (Expression expr : pc.getConstraints()) {
    System.out.println(expr);
    // Output: user_choice == 0
}
```

### Step 4: Generate New Test Inputs

```java
// Solve constraints for alternative paths
// Path 1 took: user_choice == 0
// Alternative paths:
//   - user_choice == 1  (case 1)
//   - user_choice == 2  (case 2)
//   - user_choice == 3  (case 3)
//   - user_choice == 4  (case 4)

// Run again with user_choice = 1, 2, 3, 4...
```

## Where Are the Results?

### 1. In Console Output

```
Created symbolic value: user_choice_0 = 0
  Tag applied: ✓
  Path constraints:
    • user_choice == 0
```

### 2. In JSON File (execution_paths.json)

```json
{
  "pathId": 1,
  "symbolicInputs": {
    "user_choice": 0      ← Concrete input used
  },
  "constraints": [
    "user_choice == 0"     ← Collected from tainting!
  ]
}
```

### 3. In Visualizations

The constraints are used to generate:
- Execution tree showing all paths
- Path condition labels on each branch
- Coverage analysis

## Why Tainting is Essential

| Without Tainting | With Tainting |
|------------------|---------------|
| `int x = 0;` executes as just 0 | `int x = 0;` + metadata "this is symbolic" |
| No record of decisions made | Records: "x == 0", "x > 5", etc. |
| Can't discover alternative paths | Generates inputs for all paths |
| Manual testing required | Automatic path exploration |

## Real Example from Vitruvius

```java
// VitruvSymbolicExecutionExample.java:59-63

// WITHOUT tainting:
int userChoice = 0;
Test.insertTask(workDir, userChoice);
// Just runs once, no path discovery

// WITH tainting:
Tag symbolicTag = GaletteSymbolicator.makeSymbolicInt("user_choice", 0);
int taggedUserChoice = Tainter.setTag(userChoice, symbolicTag);
Test.insertTask(workDir, taggedUserChoice);
// Runs once BUT records constraints for all 5 paths!
```

Inside `Test.insertTask()`, the Vitruvius reactions file has:

```xtend
// templateReactions.reactions:78-82
switch (userInteractor.singleSelectionDialog(...)) {
    case 0: createInterruptTask(...)   // Constraint: user_choice == 0
    case 1: createPeriodicTask(...)    // Constraint: user_choice == 1
    case 2: createSoftwareTask(...)    // Constraint: user_choice == 2
    case 3: createTimeTableTask(...)   // Constraint: user_choice == 3
    case 4: decideLater(...)           // Constraint: user_choice == 4
}
```

**The tag on `userChoice` propagates into the switch statement**, and Galette automatically records which path was taken and what constraints would lead to other paths.

## The Key Insight

**Tainting is the bridge between concrete execution and symbolic reasoning.**

```
Concrete Value    +    Tag Metadata    =    Symbolic Execution
     (0)               ("user_choice")       (user_choice == 0)
      ↓                       ↓                      ↓
  Actual run          Symbolic variable      Path constraints
  with value 0        name tracking          for analysis
```

Without tagging, you have just concrete execution.
With tagging, you enable automatic path exploration and test generation!

## Summary

**Q: Why do we need to tag user choices?**
A: To mark them as symbolic variables so Galette can track how they're used in decisions.

**Q: How does it support concolic testing?**
A: It enables **concrete** execution with real values PLUS **symbolic** constraint collection for path exploration.

**Q: Where is the result of taint?**
A: In the **path constraints** (e.g., "user_choice == 0") collected in `execution_paths.json` and used for alternative path generation.

**Q: Why need to taint?**
A: Without tainting, the JVM just sees `0` - a number. With tainting, Galette sees "user_choice with current value 0" - a symbolic variable that could explore other values.
