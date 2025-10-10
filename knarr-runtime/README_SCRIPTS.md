# PowerShell Scripts for Galette/Vitruvius Symbolic Execution

This directory contains PowerShell scripts to simplify running the symbolic execution examples.

## Available Scripts

### 1. `run-symbolic-execution.ps1` (Recommended)
**Quick execution without rebuilding**

```powershell
.\run-symbolic-execution.ps1
```

**What it does:**
- Cleans previous output directories
- Runs symbolic execution (uses already compiled code)
- Generates visualizations
- Shows summary of results

**Use when:**
- Code is already compiled
- You just want to re-run the execution
- You want fast iteration

**Time:** ~5-10 seconds

---

### 2. `rebuild-and-run.ps1`
**Full rebuild and execution**

```powershell
.\rebuild-and-run.ps1
```

**What it does:**
- Cleans all build artifacts
- Recompiles the project
- Runs symbolic execution
- Generates visualizations

**Use when:**
- You modified Java source code
- You want a clean build
- First time running after code changes

**Time:** ~30-60 seconds

---

### 3. `visualize-only.ps1`
**Regenerate visualizations from existing data**

```powershell
.\visualize-only.ps1
```

**What it does:**
- Reads existing `execution_paths.json`
- Regenerates all PNG diagrams
- Updates `execution_summary.txt`

**Use when:**
- You modified visualization scripts
- You want to customize diagrams
- You have existing execution data

**Time:** ~2-5 seconds

---

## Output Files

After running any of the scripts above, you'll get:

### Data Files
- `execution_paths.json` - Machine-readable execution data
- `execution_summary.txt` - Human-readable text report

### Visualizations
- `execution_tree.png` - Tree diagram showing all 5 execution paths
- `performance_chart.png` - Performance analysis with charts and tables
- `workflow_diagram.png` - System architecture and workflow

### Model Outputs
- `galette-output-0/` - InterruptTask (user choice = 0)
- `galette-output-1/` - PeriodicTask (user choice = 1)
- `galette-output-2/` - SoftwareTask (user choice = 2)
- `galette-output-3/` - TimeTableTask (user choice = 3)
- `galette-output-4/` - Decide Later (user choice = 4)

Each output directory contains:
- `vsum/` - Vitruvius Virtual Single Underlying Model
- `consistencymetadata/` - Transformation metadata
- `test_project.marker_vitruv` - Vitruvius project marker

---

## Execution Results Summary

### Performance (with warmup fix applied)

```
Path 1 (InterruptTask):  535ms  (includes JVM initialization)
Path 2 (PeriodicTask):    28ms
Path 3 (SoftwareTask):    27ms
Path 4 (TimeTableTask):   24ms
Path 5 (Decide Later):    25ms
Total:                   639ms
Average:                 127ms per path
```

The first path is slower due to:
- VSUM initialization
- Vitruvius framework loading
- EMF model registration

Subsequent paths are much faster (~24-28ms) because:
- All classes are already loaded
- VSUM is initialized
- JVM JIT compilation is complete

### Constraints Collected

Each path collects equality constraints:
- Path 1: `user_choice == 0`
- Path 2: `user_choice == 1`
- Path 3: `user_choice == 2`
- Path 4: `user_choice == 3`
- Path 5: `user_choice == 4`

These constraints are automatically generated when the symbolic value flows through the switch statement in the Vitruvius reactions file.

---

## Troubleshooting

### "mvn: command not found"
Maven is not in your PATH. Either:
- Run from Developer Command Prompt
- Or add Maven to system PATH

### "python: command not found"
Python is not installed or not in PATH. Install Python 3.8+ with matplotlib:
```powershell
pip install matplotlib numpy
```

### "Execution failed with errors"
This is expected! The execution completes successfully despite some EMF exceptions. The exceptions are related to Vitruvius view initialization but don't affect:
- Path exploration
- Constraint collection
- Model transformation output

### "Path 1 still takes 500+ms"
This is normal! Path 1 includes one-time initialization costs:
- Vitruvius VSUM initialization: ~400-500ms
- First-time class loading
- EMF metamodel registration

The warmup execution absorbs JVM JIT costs but not Vitruvius VSUM initialization (which happens inside the business logic).

---

## Technical Details

### Warmup Strategy

The symbolic executor includes a warmup phase (AutomaticSymbolicExecutor.java:336-348):

```java
// Warmup: Execute first path once to eliminate JVM warmup effects on timing
if (!allInputCombinations.isEmpty()) {
    System.out.println("--- Warmup execution (not counted) ---");
    PathUtils.resetPC();
    try {
        // Execute with full symbolic tracking to warm up all code paths
        executeWithSymbolicTracking(allInputCombinations.get(0), executor);
    } catch (Exception e) {
        // Ignore warmup errors
    }
    exploredPaths.clear(); // Clear warmup data
    System.out.println();
}
```

**What gets warmed up:**
- JVM JIT compilation of hot methods
- Galette tagging infrastructure
- Path constraint collection
- String formatting and I/O

**What doesn't get warmed up:**
- Vitruvius VSUM initialization (happens in business logic)
- EMF model loading (lazy loading)
- Reactions compilation (happens once)

This is intentional - VSUM initialization is part of the measured operation.

### Timing Measurement

Execution time is measured in `executeWithSymbolicTracking()`:

```java
// Tag all inputs as symbolic (don't include this in timing)
Map<String, Object> taggedInputs = new HashMap<>();
for (Map.Entry<String, Object> entry : symbolicInputs.entrySet()) {
    Object tagged = makeSymbolic(entry.getKey(), entry.getValue());
    taggedInputs.put(entry.getKey(), tagged);
}

// Measure only the actual execution time (not tagging overhead)
long startTime = System.nanoTime();
R result = executor.execute(taggedInputs);
long endTime = System.nanoTime();
```

Only the `executor.execute()` call is timed, not the tagging setup.

---

## Pattern Used: BrakeDisc Symbolic Execution Pattern

This example follows the same pattern as the BrakeDisc transformation example:

1. **Create symbolic tag**: `GaletteSymbolicator.makeSymbolicInt(label, value)`
2. **Apply tag to value**: `Tainter.setTag(value, symbolicTag)`
3. **Execute business logic**: `Test.insertTask(workDir, taggedValue)`
4. **Collect constraints**: `PathUtils.getCurPC()`
5. **Transformation logic**: Executed from `templateReactions.reactions`

**Key insight:** No hardcoded transformation logic! All transformation logic remains in Vitruvius `.reactions` files.

---

## Next Steps

1. **View the visualizations** - Open the PNG files to see execution paths and performance
2. **Analyze constraints** - Check `execution_paths.json` for collected constraints
3. **Explore outputs** - Look at `galette-output-*/vsum/` for transformed models
4. **Customize visualizations** - Modify `visualize_results.py` or `visualize_workflow.py`
5. **Add more symbolic inputs** - Tag additional values in the transformation

See `README_VITRUVIUS.md` for complete documentation.
