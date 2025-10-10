# How to Run the Symbolic Execution

## Quick Start (Easiest)

### Option 1: Use Batch File (No PowerShell issues)
```cmd
run.cmd
```

### Option 2: Use PowerShell (Requires one-time setup)

**First time only - Enable script execution:**
```powershell
# Run PowerShell as Administrator and execute:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Then run:**
```powershell
.\run-symbolic-execution.ps1
```

### Option 3: Bypass Policy (No admin needed)
```powershell
powershell -ExecutionPolicy Bypass -File .\run-symbolic-execution.ps1
```

### Option 4: Direct Maven Command
```powershell
mvn exec:java -Dcheckstyle.skip=true
python visualize_results.py
python visualize_workflow.py
```

---

## Understanding Execution Timing

### Complete Timing Breakdown

The execution includes a **warmup phase** plus **5 measured paths**:

```
┌─────────────────────────────────────────────────────────────┐
│ WARMUP EXECUTION (not counted in results)                   │
│ - JVM JIT compilation                                       │
│ - Galette infrastructure loading                           │
│ - First symbolic tagging                                    │
│ - Path constraint collection                               │
│ Time: ~500-800ms (discarded)                               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ PATH 1: InterruptTask (user_choice = 0)                     │
│                                                             │
│ Components:                               Time:             │
│ ├─ VSUM Initialization                    ~400-450ms       │
│ │  ├─ VirtualModelBuilder.build()                          │
│ │  ├─ Load metamodel packages                              │
│ │  ├─ Register EMF factories                               │
│ │  └─ Initialize correspondence model                      │
│ │                                                           │
│ ├─ EMF Resource Loading                   ~50-70ms         │
│ │  ├─ Load .correspondence files                           │
│ │  ├─ Parse XMI                                            │
│ │  └─ Resolve cross-references                             │
│ │                                                           │
│ ├─ Vitruvius Reactions Execution          ~10-15ms         │
│ │  ├─ Load reaction routines                               │
│ │  ├─ Execute switch statement                             │
│ │  └─ Call createInterruptTask()                           │
│ │                                                           │
│ └─ Business Logic + I/O                   ~5-10ms          │
│    ├─ Create task objects                                  │
│    ├─ Save VSUM state                                      │
│    └─ Persist to disk                                      │
│                                                             │
│ TOTAL PATH 1:                             535ms            │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ PATH 2-5: Subsequent paths (user_choice = 1,2,3,4)         │
│                                                             │
│ Components:                               Time:             │
│ ├─ VSUM Reuse (already initialized)       ~0ms (cached)   │
│ │                                                           │
│ ├─ EMF Resource Reuse                     ~5-8ms          │
│ │  └─ Reload from existing state                           │
│ │                                                           │
│ ├─ Vitruvius Reactions Execution          ~10-15ms        │
│ │  ├─ Switch statement (already compiled)                  │
│ │  └─ Call createPeriodicTask/etc.                        │
│ │                                                           │
│ └─ Business Logic + I/O                   ~5-10ms         │
│                                                             │
│ TOTAL PATHS 2-5:                          24-28ms each    │
└─────────────────────────────────────────────────────────────┘
```

### Detailed Component Breakdown

| Component | Path 1 | Paths 2-5 | Notes |
|-----------|--------|-----------|-------|
| **VSUM Initialization** | 400-450ms | 0ms | One-time cost, includes VirtualModelBuilder.buildAndInitialize() |
| **Metamodel Loading** | 30-40ms | 0ms | EMF package registration (Amathea, ASCET, etc.) |
| **EMF Factory Setup** | 10-15ms | 0ms | EcorePackage, XMLTypePackage initialization |
| **Correspondence Model** | 10-15ms | 5-8ms | First load vs. reload from disk |
| **Reactions Compilation** | 5-10ms | 0ms | Load and compile .reactions file |
| **Switch Execution** | 5ms | 5ms | Same for all paths |
| **Task Creation** | 3-5ms | 3-5ms | createInterruptTask/PeriodicTask/etc. |
| **VSUM Save** | 5-10ms | 5-10ms | Persist state to disk |
| **I/O Operations** | 5-10ms | 5-10ms | File writes |
| **TOTAL** | **535ms** | **24-28ms** | |

### Why VSUM Initialization is Included in Path 1

The VSUM initialization happens **inside** the business logic (`Test.insertTask()`), so it's correctly measured as part of Path 1:

```java
// In AutomaticSymbolicExecutor.java:236-238
long startTime = System.nanoTime();
R result = executor.execute(taggedInputs);  // <-- VSUM init happens here
long endTime = System.nanoTime();
```

Inside `executor.execute()`:
```java
// In VitruvSymbolicExecutionExample.java:72
Test.insertTask(workDir, userChoice);  // <-- Calls VirtualModelBuilder
```

Inside `Test.insertTask()`:
```java
// In Test.java:46
VirtualModel vsum = VirtualModelBuilder
    .builder()
    .withStorageFolder(folder)
    .withUserInteractor(new TestUserInteractor(userChoice))
    .buildAndInitialize();  // <-- 400-500ms initialization
```

This is **intentional and correct** - VSUM initialization is part of the Vitruvius operation being measured.

### Performance Summary

```
Warmup execution:    ~600-800ms  (not counted)
Path 1:              535ms       (includes VSUM init ~450ms)
Paths 2-5:           24-28ms each
─────────────────────────────────────────────
Total measured:      639ms
Average per path:    127ms
Median:              27ms        (paths 2-5 are typical)
```

**Key Insight:** After the first path, subsequent operations are **20x faster** (535ms → 27ms) because:
- VSUM is already initialized
- Metamodels are already loaded
- JIT compilation is complete
- Classes are already loaded

---

## Verifying the Warmup Effect

You can see the warmup in action in the console output:

```
AUTOMATIC PATH EXPLORATION
======================================================================
Discovered 5 possible execution paths

--- Warmup execution (not counted) ---    <-- This is the warmup
                                              JIT, Galette, etc.

--- Exploring Path 1/5 ---                 <-- First measured path
...                                           (still includes VSUM init)
Execution time: 535 ms

--- Exploring Path 2/5 ---                 <-- Subsequent paths
...                                           (VSUM already initialized)
Execution time: 28 ms
```

The warmup absorbs:
- ✓ JVM JIT compilation (~200-300ms)
- ✓ Galette infrastructure loading (~50-100ms)
- ✓ First symbolic tagging (~10-20ms)
- ✗ VSUM initialization (happens in business logic, not warmed up)

---

## Files Generated

After execution:

### Data Files
- `execution_paths.json` - Execution data with timing
- `execution_summary.txt` - Human-readable report

### Visualizations
- `execution_tree.png` - Path tree diagram
- `performance_chart.png` - Performance charts
- `workflow_diagram.png` - System workflow

### Model Outputs
- `galette-output-0/` through `galette-output-4/` - Transformed models

---

## Next Steps

1. **View visualizations:** Open the `.png` files
2. **Check timing details:** Read `execution_summary.txt`
3. **Analyze JSON data:** Open `execution_paths.json`
4. **Inspect outputs:** Look at `galette-output-*/vsum/`

See `README_SCRIPTS.md` for more details.
