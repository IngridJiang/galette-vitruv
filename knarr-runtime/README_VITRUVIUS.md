# Galette Symbolic Execution with Vitruvius

This directory contains a **completely self-contained** integration of Galette/Knarr symbolic execution with the Vitruvius model transformation framework.

## What This Does

Demonstrates automatic path exploration in Vitruvius model transformations using Galette's symbolic execution:

1. **Tags user input as symbolic** - using `GaletteSymbolicator.makeSymbolicInt()`
2. **Executes Vitruvius reactions naturally** - no hardcoded transformation logic!
3. **Collects path constraints automatically** - from switch statements in reactions
4. **Explores all 5 execution paths** - corresponding to user choices (0-4)

## Setup (One-Time)

### Prerequisites
- Java 17+ (JDK)
- Maven 3.6+
- Python 3 (optional, for visualizations)

### Build Amathea-ASCET Dependency

The Vitruvius VSUM project needs to be installed to your local Maven repository:

```bash
cd C:\Users\10239\Amathea-acset
mvn clean install -DskipTests -Dcheckstyle.skip=true
```

This installs `tools.vitruv.methodologisttemplate.vsum:0.1.0-SNAPSHOT` to `~/.m2/repository/`.

**You only need to do this once!** After that, everything runs from `galette-vitruv/knarr-runtime`.

## Running Symbolic Execution

### Option 1: Simple Script (Recommended)

**Windows:**
```cmd
cd C:\Users\10239\galette-vitruv\knarr-runtime
run-symbolic-execution.bat
```

**Linux/WSL:**
```bash
cd /path/to/galette-vitruv/knarr-runtime
./run-symbolic-execution.sh
```

### Option 2: Direct Maven Command

```bash
cd C:\Users\10239\galette-vitruv\knarr-runtime
mvn exec:java -Dexec.mainClass="edu.neu.ccs.prl.galette.vitruvius.VitruvSymbolicExecutionExample"
```

## Expected Output

### Console Output
```
╔════════════════════════════════════════════════════════════════════════════╗
║     GALETTE/KNARR SYMBOLIC EXECUTION WITH VITRUVIUS FRAMEWORK             ║
║                                                                            ║
║  Pattern: Same as BrakeDisc transformation example                        ║
║  • Tag input as symbolic using Galette                                     ║
║  • Execute business logic naturally                                        ║
║  • Collect path constraints automatically                                  ║
║  • No hardcoded transformation logic!                                      ║
╚════════════════════════════════════════════════════════════════════════════╝

✓ Loaded Vitruvius Test class

================================================================================
SYMBOLIC EXECUTION OF VITRUVIUS MODEL TRANSFORMATION
================================================================================

--------------------------------------------------------------------------------
Exploring Path 1/5: Create InterruptTask
User choice: 0
--------------------------------------------------------------------------------
Created symbolic value: user_choice_0 = 0
  Tag applied: ✓
  ✓ Vitruvius transformation executed
  Path constraints:
    • user_choice == 0
  Execution time: 567 ms

... (4 more paths)

✅ All execution paths explored!
```

### Generated Files

#### 1. Output Directories
```
galette-output-0/    # Path 0: InterruptTask
galette-output-1/    # Path 1: PeriodicTask
galette-output-2/    # Path 2: SoftwareTask
galette-output-3/    # Path 3: TimeTableTask
galette-output-4/    # Path 4: Decide Later
```

Each directory contains:
- `vsum/` - Vitruvius VSUM state
- `consistencymetadata/` - Transformation metadata
- `test_project.marker_vitruv` - Project marker

#### 2. Execution Data
- `execution_paths.json` - Machine-readable results (for visualization)

#### 3. Visualizations (if Python available)
- `execution_tree.png` - Tree diagram showing all 5 paths
- `performance_chart.png` - Bar chart of execution times
- `execution_summary.txt` - Human-readable summary report

## How It Works

### The Pattern (from BrakeDisc Example)

```java
// 1. Create symbolic tag
Tag symbolicTag = GaletteSymbolicator.makeSymbolicInt("user_choice", value);

// 2. Tag the value - THIS IS KEY!
int taggedValue = Tainter.setTag(value, symbolicTag);

// 3. Execute business logic naturally (Vitruvius Test.insertTask)
testInstance.insertTask(workDir, taggedValue);
// ↳ This calls reactions which have switch statements
// ↳ Galette automatically collects path constraints!

// 4. Collect constraints
PathConditionWrapper pc = PathUtils.getCurPC();
```

### No Hardcoded Transformation Logic!

The transformation logic lives in **`templateReactions.reactions`** (in Amathea-acset):
- Lines 37-46: Switch statement on user choice
- Lines 50-102: Transformation routines for each task type

We just tag the input and let it flow through naturally.

## Architecture

```
galette-vitruv/knarr-runtime/
├── pom.xml                                    # Maven config with Vitruvius dependency
├── src/main/java/.../vitruvius/
│   └── VitruvSymbolicExecutionExample.java   # Main symbolic execution wrapper
├── run-symbolic-execution.sh                  # Simple run script (bash)
├── run-symbolic-execution.bat                 # Simple run script (Windows)
└── README_VITRUVIUS.md                        # This file

galette-vitruv/
└── visualize_execution.py                     # Visualization generator
```

### Dependencies (Managed by Maven)

From `pom.xml`:
```xml
<dependency>
    <groupId>edu.neu.ccs.prl.galette</groupId>
    <artifactId>galette-agent</artifactId>
    <!-- Provides: Tainter, Tag, GaletteSymbolicator -->
</dependency>

<dependency>
    <groupId>za.ac.sun.cs.green</groupId>
    <artifactId>green</artifactId>
    <!-- Constraint solver -->
</dependency>

<dependency>
    <groupId>tools.vitruv</groupId>
    <artifactId>tools.vitruv.methodologisttemplate.vsum</artifactId>
    <version>0.1.0-SNAPSHOT</version>
    <!-- Vitruvius VSUM (from Amathea-acset) -->
</dependency>
```

## Troubleshooting

### "Failed to load Vitruvius Test class"

The Vitruvius dependency needs to be in your local Maven repository:

```bash
cd C:\Users\10239\Amathea-acset
mvn clean install -DskipTests -Dcheckstyle.skip=true
```

### "No path constraints collected"

This can happen if:
1. Vitruvius throws exception before reaching switch statement
2. Tags not properly applied (check "Tag applied: ✓")

The current implementation catches exceptions and continues exploring other paths.

### Visualizations Not Generated

Install Python dependencies:
```bash
pip install matplotlib networkx
```

## Key Files to Examine

1. **`VitruvSymbolicExecutionExample.java`** (line 47-101)
   - Method: `executeWithSymbolicInput()` - core symbolic execution logic
   - Pattern: Create tag → Apply tag → Execute → Collect constraints

2. **`pom.xml`** (line 57-62)
   - Vitruvius dependency declaration

3. **Amathea-acset `templateReactions.reactions`** (READ ONLY - don't modify!)
   - Lines 37-46: Switch statement where constraints are collected
   - Lines 50-102: Transformation routines

## Integration with Original Vitruvius Code

This wrapper integrates with the **existing** Vitruvius Test class:

```java
// From Amathea-acset/vsum/.../Test.java
public void insertTask(Path workDir, int userChoice) {
    // Creates ComponentContainer named "MyTask"
    // Calls addComponentContainer which triggers reactions
    // Reactions use switch(userChoice) to transform
}
```

We call this method with a **symbolically-tagged integer**, and Galette does the rest!

## What Makes This Different from BrakeDisc Example?

| Aspect | BrakeDisc Example | Vitruvius Integration |
|--------|-------------------|----------------------|
| Business Logic | Simple arithmetic | Complex model transformation |
| Constraint Source | If/switch in simple method | Switch in Vitruvius reactions |
| Output | Computed values | XMI model files |
| Framework | Plain Java | Vitruvius + EMF + Xtend |
| Transformation Logic | Inline code | Declarative `.reactions` file |

Both follow the **same pattern**: Tag input → Execute naturally → Collect constraints automatically.

## Success Criteria

✅ **Symbolic values tagged** - using Galette
✅ **Vitruvius reactions executed naturally** - no hardcoded logic
✅ **Path constraints collected** - from switch statement
✅ **All 5 paths explored** - corresponding to user choices
✅ **Model transformations saved** - to galette-output-* directories
✅ **Self-contained in galette-vitruv** - no modifications to Amathea-acset

## Next Steps

1. **Analyze collected constraints** - use Green solver to generate test inputs
2. **Add more symbolic inputs** - explore other parameters (task names, properties)
3. **Integrate with test framework** - automatic test case generation
4. **Performance optimization** - reduce VSUM initialization overhead

## References

- Galette documentation: See `galette-vitruv/CLAUDE.md`
- BrakeDisc example: `knarr-runtime/src/main/java/edu/neu/ccs/prl/galette/examples/`
- Vitruvius framework: https://www.vitruv.tools/
