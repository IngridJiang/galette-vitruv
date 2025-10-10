# Amathea-ASCET templateReactions.reactions Analysis

## Overview

**File Location:** `amathea-acset-integration/consistency/src/main/reactions/templateReactions.reactions`

**Language:** Xtend (Vitruvius DSL)

**Purpose:** Define model transformation rules between Amathea and ASCET metamodels

---

## Structure

### 1. **Main Reaction** (Entry Point)

```xtend
reaction TaskInserted {
    after element amathea::Task inserted in amathea::ComponentContainer[tasks]
    call { ... }
}
```

**Trigger:** When an Amathea Task is inserted into a ComponentContainer

**What it does:**
1. Shows user dialog with 5 choices (lines 28-33)
2. Gets integer selection (0-4)
3. Switch on selection to call appropriate helper routine (lines 37-46)

---

### 2. **Helper Methods/Routines** (Lines 50-102)

These are the **4 transformation routines** called from the switch statement:

| Routine | Lines | Purpose | Switch Case |
|---------|-------|---------|-------------|
| `createInterruptTask` | 50-61 | Transform to ASCET InterruptTask | case 0 |
| `createPeriodicTask` | 63-76 | Transform to ASCET PeriodicTask | case 1 |
| `createSoftwareTask` | 78-89 | Transform to ASCET SoftwareTask | case 2 |
| `createTimeTableTask` | 91-101 | Transform to ASCET TimeTableTask | case 3 |

**Case 4** ("Decide Later") has no helper - just logs a message.

---

## How Symbolic Execution Works With This File

### Without Symbolic Execution (Normal Flow)

```
User inserts Amathea Task
    ↓
reaction TaskInserted triggers (line 9)
    ↓
Dialog shows asking user to choose 0-4 (lines 28-33)
    ↓
User clicks button → returns 0, 1, 2, 3, or 4
    ↓
switch (selected) executes (line 37)
    ↓
Calls ONE helper routine based on selection
    ↓
Creates corresponding ASCET task
```

### With Symbolic Execution (Our Approach)

```
VitruvSymbolicExecutionExample.java runs
    ↓
Tag integer value: Tainter.setTag(0, symbolicTag)  ← GALETTE TAINTING
    ↓
Pass tagged value to Test.insertTask(workDir, taggedValue)
    ↓
Test.insertTask() internally uses templateReactions.reactions
    ↓
Vitruvius executes switch (selected) with TAGGED value (line 37)
    ↓
Galette intercepts switch comparison:
    - Concrete execution: Takes case 0 (or 1, 2, 3, 4)
    - Symbolic tracking: Records constraint "user_choice == 0"
    ↓
Calls helper routine: createInterruptTask(...) or createPeriodicTask(...)
    ↓
PathUtils.getCurPC() contains: "user_choice == 0"
    ↓
Repeat with values 1, 2, 3, 4 to explore all paths
```

---

## Detailed Analysis of Helper Routines

### Common Pattern (All 4 Routines Follow This)

```xtend
routine createXXXTask(amathea::Task amaltheaTask, amathea::ComponentContainer container) {
    action {
        // 1. Retrieve corresponding ASCET model using Vitruvius correspondence
        val ascetModel = retrieve ascet::AscetModel
                         corresponding to container
                         tagged with "AscetModel"  ← Vitruvius tagging, NOT Galette!

        call {
            // 2. Create ASCET task of specific type
            val xxxTask = ascet.ascetFactory.createXXXTask()

            // 3. Copy properties from Amathea task
            xxxTask.name = amaltheaTask.name
            xxxTask.priority = if (amaltheaTask.preemption?.toString == "preemptive") 10 else 1

            // 4. Add specific properties (varies by task type)
            // e.g., periodicTask.period = 10.0

            // 5. Add to ASCET model
            ascetModel.tasks.add(xxxTask)

            // 6. Log
            logger.info('''Created XXXTask «xxxTask.name» from Amathea task''')
        }
    }
}
```

---

### Routine 1: createInterruptTask (Lines 50-61)

```xtend
routine createInterruptTask(amathea::Task amaltheaTask, amathea::ComponentContainer container) {
    action {
        val ascetModel = retrieve ascet::AscetModel corresponding to container tagged with "AscetModel"
        call {
            val interruptTask = ascet.ascetFactory.createInterruptTask()
            interruptTask.name = amaltheaTask.name
            interruptTask.priority = if (amaltheaTask.preemption?.toString == "preemptive") 10 else 1
            ascetModel.tasks.add(interruptTask)
            logger.info('''Created InterruptTask «interruptTask.name» from Amathea task''')
        }
    }
}
```

**Properties Set:**
- `name` - copied from Amathea task
- `priority` - 10 if preemptive, 1 otherwise

**Called when:** switch case 0 (user_choice == 0)

---

### Routine 2: createPeriodicTask (Lines 63-76)

```xtend
routine createPeriodicTask(amathea::Task amaltheaTask, amathea::ComponentContainer container) {
    action {
        val ascetModel = retrieve ascet::AscetModel corresponding to container tagged with "AscetModel"
        call {
            val periodicTask = ascet.ascetFactory.createPeriodicTask()
            periodicTask.name = amaltheaTask.name
            periodicTask.priority = if (amaltheaTask.preemption?.toString == "preemptive") 10 else 1
            periodicTask.period = 10.0 // Default 10ms period
            periodicTask.delay = 0.0   // No delay
            ascetModel.tasks.add(periodicTask)
            logger.info('''Created PeriodicTask «periodicTask.name» from Amathea task''')
        }
    }
}
```

**Properties Set:**
- `name` - copied from Amathea task
- `priority` - 10 if preemptive, 1 otherwise
- `period` - **10.0 ms** (hardcoded default)
- `delay` - **0.0 ms** (hardcoded default)

**Called when:** switch case 1 (user_choice == 1)

---

### Routine 3: createSoftwareTask (Lines 78-89)

```xtend
routine createSoftwareTask(amathea::Task amaltheaTask, amathea::ComponentContainer container) {
    action {
        val ascetModel = retrieve ascet::AscetModel corresponding to container tagged with "AscetModel"
        call {
            val softwareTask = ascet.ascetFactory.createSoftwareTask()
            softwareTask.name = amaltheaTask.name
            softwareTask.priority = if (amaltheaTask.preemption?.toString == "preemptive") 10 else 1
            ascetModel.tasks.add(softwareTask)
            logger.info('''Created SoftwareTask «softwareTask.name» from Amathea task''')
        }
    }
}
```

**Properties Set:**
- `name` - copied from Amathea task
- `priority` - 10 if preemptive, 1 otherwise

**Called when:** switch case 2 (user_choice == 2)

---

### Routine 4: createTimeTableTask (Lines 91-101)

```xtend
routine createTimeTableTask(amathea::Task amaltheaTask, amathea::ComponentContainer container) {
    action {
        val ascetModel = retrieve ascet::AscetModel corresponding to container tagged with "AscetModel"
        call {
            val timeTableTask = ascet.ascetFactory.createTimeTableTask()
            timeTableTask.name = amaltheaTask.name
            timeTableTask.priority = if (amaltheaTask.preemption?.toString == "preemptive") 10 else 1
            ascetModel.tasks.add(timeTableTask)
            logger.info('''Created TimeTableTask «timeTableTask.name» from Amathea task''')
        }
    }
}
```

**Properties Set:**
- `name` - copied from Amathea task
- `priority` - 10 if preemptive, 1 otherwise

**Called when:** switch case 3 (user_choice == 3)

---

## Key Insights for Symbolic Execution

### 1. **The Switch Statement is the Symbolic Execution Point**

```xtend
// Lines 37-46
switch (selected) {
    case 0: createInterruptTask(newValue, newValue.eContainer as amathea::ComponentContainer)
    case 1: createPeriodicTask(newValue, newValue.eContainer as amathea::ComponentContainer)
    case 2: createSoftwareTask(newValue, newValue.eContainer as amathea::ComponentContainer)
    case 3: createTimeTableTask(newValue, newValue.eContainer as amathea::ComponentContainer)
    case 4: {
        // Decide Later - no immediate action
        logger.info('''Task «newValue.name» transformation deferred''')
    }
}
```

**When `selected` is tagged with Galette:**
- Galette intercepts each `case` comparison
- Records constraint: `user_choice == 0`, `user_choice == 1`, etc.
- Concrete execution still works normally (takes one path)
- Symbolic tracking identifies all alternative paths

### 2. **Helper Routines Work Transparently**

The helper routines (`createInterruptTask`, etc.) **do NOT need any modification** for symbolic execution because:

- They are called AFTER the switch statement
- By the time they execute, the symbolic constraint is already recorded
- They just perform normal model transformation
- No special handling needed for tagging

### 3. **Two Types of "Tagging" (Don't Confuse!)**

| Galette Tagging | Vitruvius Tagging |
|-----------------|-------------------|
| `Tainter.setTag(value, symbolicTag)` | `tagged with "AscetModel"` |
| Used in: VitruvSymbolicExecutionExample.java | Used in: templateReactions.reactions |
| Purpose: Mark value as symbolic | Purpose: Model element correspondence |
| Example: Tag `selected` for path exploration | Example: Link ComponentContainer ↔ AscetModel |

**In the reactions file, "tagged with" appears 4 times (lines 52, 65, 80, 95):**
```xtend
retrieve ascet::AscetModel corresponding to container tagged with "AscetModel"
```

This is **Vitruvius correspondence tagging** - it's how Vitruvius finds related model elements across different metamodels. It has **nothing to do** with Galette symbolic execution tagging!

### 4. **Why This Design Works Perfectly**

```
VitruvSymbolicExecutionExample.java:
  - Tags the user choice with Galette (makeSymbolicInt)
  - Passes tagged value to Test.insertTask()
        ↓
Test.insertTask():
  - Creates Amathea task
  - Triggers TaskInserted reaction
        ↓
templateReactions.reactions:
  - Receives tagged value in switch statement
  - Galette automatically records constraints
  - Calls appropriate helper routine
  - Helper routines work normally (no modification needed!)
        ↓
Result:
  - Path constraints collected: "user_choice == 0"
  - Model transformation completed
  - Output saved to galette-output-*/
```

**The beauty:** Helper routines are **completely unaware** of symbolic execution! They just do their job, while Galette tracks the path taken.

---

## Does This Work for Symbolic Execution?

### ✅ **YES, it works perfectly!**

**Reasons:**

1. **Switch statement is intercepted:** Line 37 `switch (selected)` is where Galette collects constraints
2. **Helper routines are transparent:** They execute normally after path choice is made
3. **No modifications needed:** Current reactions file works as-is
4. **All 5 paths explorable:** Each case (0-4) represents a distinct execution path
5. **Constraints are clear:** `user_choice == 0`, `== 1`, etc.

**Evidence from your execution:**
```json
{
  "pathId": 1,
  "symbolicInputs": { "user_choice": 0 },
  "constraints": [ "user_choice == 0" ],
  "executionTime": 219
}
```

This shows:
- Symbolic input: user_choice = 0
- Constraint collected: user_choice == 0 (from switch statement)
- Helper routine executed: createInterruptTask (case 0)
- Output generated: galette-output-0/

---

## Conclusion

The `templateReactions.reactions` file is **perfectly designed** for symbolic execution:

1. **Main reaction** (`TaskInserted`) contains the symbolic decision point (switch statement)
2. **Helper routines** (create*Task) are normal transformation logic that works with or without symbolic execution
3. **Vitruvius tagging** ("tagged with") is for model correspondence, separate from Galette tagging
4. **No changes needed** - symbolic execution works by tagging the input value externally

**The separation of concerns is excellent:**
- Symbolic execution logic → `VitruvSymbolicExecutionExample.java`
- Business logic → `templateReactions.reactions`
- No coupling between them!

---

## Summary Table

| Component | Role in Symbolic Execution | Needs Modification? |
|-----------|---------------------------|---------------------|
| **reaction TaskInserted** | Entry point, contains switch statement | ❌ No |
| **switch (selected)** | Decision point where constraints are collected | ❌ No |
| **createInterruptTask routine** | Transformation logic for case 0 | ❌ No |
| **createPeriodicTask routine** | Transformation logic for case 1 | ❌ No |
| **createSoftwareTask routine** | Transformation logic for case 2 | ❌ No |
| **createTimeTableTask routine** | Transformation logic for case 3 | ❌ No |
| **case 4 (Decide Later)** | No-op path for case 4 | ❌ No |
| **Vitruvius "tagged with"** | Model correspondence (unrelated to symbolic execution) | ❌ No |

**Everything works as-is!** 🎉
