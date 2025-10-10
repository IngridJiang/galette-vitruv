# Vitruvius Symbolic Execution Integration

This demonstrates how to use Galette/Knarr symbolic execution with Vitruvius model transformations, following the BrakeDisc example pattern.

## Quick Start

```bash
cd C:/Users/10239/galette-vitruv
bash run-vitruvius-symbolic.sh
```

That's it! The script will:
1. ✅ Build Galette (if needed)
2. ✅ Build Amathea-acset
3. ✅ Run symbolic execution for all 5 paths
4. ✅ Save results to `Amathea-acset/galette-output-*` directories

## What This Does

### The Pattern (from BrakeDisc Example)

```java
// 1. Create symbolic tag
Tag symbolicTag = GaletteSymbolicator.makeSymbolicInt(label, userChoice);

// 2. Tag the value (CRITICAL!)
int taggedUserChoice = Tainter.setTag(userChoice, symbolicTag);

// 3. Execute Vitruvius with tagged value
Test test = new Test();
test.insertTask(workDir, taggedUserChoice);  // ← Vitruvius handles the rest!

// 4. Collect constraints (automatic!)
PathConditionWrapper pc = PathUtils.getCurPC();
// Contains: (user_choice_0 == 0), (user_choice_1 == 1), etc.
```

### Where Things Happen

1. **`VitruvSymbolicExecutionExample.java`** (in galette-vitruv)
   - Tags user input as symbolic
   - Calls Vitruvius `Test.insertTask()`
   - Collects path constraints

2. **`Test.java`** (in Amathea-acset - UNCHANGED)
   - Receives symbolic value
   - Passes to `TestUserInteraction`
   - Triggers Vitruvius reactions

3. **`templateReactions.reactions`** (in Amathea-acset - UNCHANGED)
   - Switch statement executes (lines 37-46)
   - Galette intercepts and collects constraints
   - Transformation routines execute (lines 50-102)

**NO hardcoded transformation logic!** It's all in the `.reactions` file.

## Expected Output

```
╔════════════════════════════════════════════════════════════════════════════╗
║     GALETTE/KNARR SYMBOLIC EXECUTION WITH VITRUVIUS FRAMEWORK             ║
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
    • (user_choice_0 == 0)
  Execution time: 150 ms

... (4 more paths)

================================================================================
SYMBOLIC EXECUTION SUMMARY
================================================================================
Total paths explored: 5

Path details:
  Path 1: Create InterruptTask
    • User choice: 0
    • Constraint: (user_choice_0 == 0)
    • Time: 150 ms
  ... (4 more)

✅ All execution paths explored!

📁 Output directories created in galette-vitruv:
  • galette-output-0/
  • galette-output-1/
  • galette-output-2/
  • galette-output-3/
  • galette-output-4/
```

## Key Files

### In galette-vitruv (New)
- **`knarr-runtime/.../VitruvSymbolicExecutionExample.java`** - Symbolic execution wrapper
- **`run-vitruvius-symbolic.sh`** - Convenience script
- **`VITRUVIUS_INTEGRATION.md`** - This file

### In Amathea-acset (Unchanged)
- **`vsum/src/main/java/.../Test.java`** - Vitruvius integration
- **`consistency/src/main/reactions/templateReactions.reactions`** - Transformation logic

### Output (Created in galette-vitruv)
- **`galette-output-0/` to `galette-output-4/`** - Transformed models

## How It Works

### Execution Flow

```
run-vitruvius-symbolic.sh
    ↓ [Build Galette & Amathea]
VitruvSymbolicExecutionExample.main()
    ↓ [Tag input as symbolic]
    Tag symbolicTag = GaletteSymbolicator.makeSymbolicInt("user_choice", 0);
    int taggedUserChoice = Tainter.setTag(userChoice, symbolicTag);
    ↓ [Call Vitruvius]
Test.insertTask(workDir, taggedUserChoice)
    ↓ [TestUserInteraction]
Vitruvius Framework
    ↓ [Executes reactions]
templateReactions.reactions:37-46
    switch (selected) {  // ← Galette collects constraints here!
        case 0: createInterruptTask(...)
        case 1: createPeriodicTask(...)
        ...
    }
    ↓ [Constraints collected automatically]
PathUtils.getCurPC()
    → Returns: (user_choice_0 == 0), etc.
```

### Why This Works

1. **Galette tags propagate** through the JVM
2. **TestUserInteraction** preserves the tag
3. **Vitruvius reactions** execute with tagged value
4. **Switch statement bytecode** is instrumented by Galette
5. **Path constraints** collected automatically

No manual intervention needed!

## Troubleshooting

### "Failed to load Vitruvius Test class"
**Cause**: Amathea-acset not in classpath

**Fix**: The script handles this automatically. If you see this error, make sure:
- Amathea-acset is at `C:/Users/10239/Amathea-acset`
- Run the script, don't run Java directly

### "No path constraints collected"
**Cause**: Galette agent not properly loaded

**Fix**: The script uses classpath approach (not javaagent), so this should work automatically. If you still see this, try:
```bash
cd C:/Users/10239/galette-vitruv
mvn clean install -DskipTests
```

### Build errors
```bash
# Rebuild everything
cd C:/Users/10239/galette-vitruv
mvn clean install -DskipTests

cd C:/Users/10239/Amathea-acset
mvn clean compile
```

## Manual Execution

If you want to run without the script:

```bash
# 1. Build Galette
cd C:/Users/10239/galette-vitruv
mvn clean install -DskipTests

# 2. Build Amathea
cd C:/Users/10239/Amathea-acset
mvn clean compile

# 3. Get classpaths and run
# (This is complex - use the script instead!)
```

## Comparison: BrakeDisc vs Vitruvius

| Aspect | BrakeDisc | Vitruvius |
|--------|-----------|-----------|
| Input | `double thickness` | `int userChoice` |
| Tagging | `Tainter.setTag(thickness, tag)` | `Tainter.setTag(userChoice, tag)` |
| Logic | `BrakeDiscTransformation.transform()` | `templateReactions.reactions` |
| Constraints | `SymbolicExecutionWrapper.compare()` | Galette bytecode instrumentation |
| Output | `BrakeDiscTarget` model | VSUM with transformed models |

Both follow the same pattern: **Tag input → Execute naturally → Collect constraints**

## Key Takeaways

1. ✅ **No changes to Amathea-acset** - all integration in galette-vitruv
2. ✅ **No hardcoded logic** - transformation in `.reactions` file
3. ✅ **Follows BrakeDisc pattern** - tag, execute, collect
4. ✅ **Automatic constraint collection** - Galette handles it
5. ✅ **Simple to run** - one script does everything

## Next Steps

1. Run the script: `bash run-vitruvius-symbolic.sh`
2. Examine results in `Amathea-acset/galette-output-*`
3. Check path constraints in the output
4. Use Green solver for further analysis
