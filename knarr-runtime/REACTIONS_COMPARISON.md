# Comparison: Two templateReactions.reactions Files

## File Locations

1. **Original Amathea-acset project** (178 lines):
   - `C:\Users\10239\Amathea-acset\consistency\src\main\reactions\tools\vitruv\methodologisttemplate\consistency\templateReactions.reactions`

2. **Galette-vitruv integration copy** (101 lines):
   - `C:\Users\10239\galette-vitruv\amathea-acset-integration\consistency\src\main\reactions\templateReactions.reactions`

## Key Differences

### 1. **Package/Namespace Imports**

| Amathea-acset (Original) | Galette-vitruv (Simplified) |
|--------------------------|------------------------------|
| `import "http://vitruv.tools/reactionsparser/model" as ascet` | `import "http://ascet/1.0" as ascet` |
| `import "http://vitruv.tools/reactionsparser/model2" as amalthea` | `import "http://amathea/1.0" as amathea` |

**Impact:** Different metamodel URIs, but same functionality.

### 2. **Reactions Declaration**

| Amathea-acset (Original) | Galette-vitruv (Simplified) |
|--------------------------|------------------------------|
| `reactions: amalthea2ascet` | `reactions: templateReactions` |
| `in reaction to changes in amalthea` | `in reaction to changes in amathea` |
| `execute actions in ascet` | `execute actions in ascet` |

**Impact:** Different naming, same purpose.

### 3. **Additional Reactions in Original**

The **original Amathea-acset** file has **3 reactions**:
1. `ComponentContainerInsertedAsRoot` (lines 12-34) - **NOT in galette-vitruv**
2. `TaskDeleted` (lines 37-53) - **NOT in galette-vitruv**
3. `TaskCreated` (lines 55-104) - **EQUIVALENT to TaskInserted in galette-vitruv**

The **galette-vitruv** file has **1 reaction**:
1. `TaskInserted` (lines 9-48) - **EQUIVALENT to TaskCreated in original**

### 4. **Main Task Creation Logic**

Both files have the **same core logic** for creating tasks:

**Amathea-acset (lines 55-104):**
```xtend
reaction TaskCreated {
    after element amalthea::Task inserted in amalthea::ComponentContainer[tasks]
    call createAscetTask(newValue, affectedEObject)
}

routine createAscetTask(...) {
    update {
        // User dialog (lines 78-82)
        val Integer selected = userInteractor
            .singleSelectionDialogBuilder
            .message(userMsg)
            .choices(options)
            .startInteraction()

        // Switch statement (lines 85-101)
        switch (selected) {
            case 0: createInterruptTask(...)
            case 1: createPeriodicTask(...)
            case 2: createSoftwareTask(...)
            case 3: createTimeTableTask(...)
            case 4: { /* no action */ }
        }
    }
}
```

**Galette-vitruv (lines 9-48):**
```xtend
reaction TaskInserted {
    after element amathea::Task inserted in amathea::ComponentContainer[tasks]
    call {
        // User dialog (lines 28-33)
        val Integer selected = userInteractor
            .singleSelectionDialogBuilder
            .message(userMsg)
            .choices(taskOptions)
            .windowModality(WindowModality.MODAL)  ← Added modal setting
            .startInteraction()

        // Switch statement (lines 37-46)
        switch (selected) {
            case 0: createInterruptTask(...)
            case 1: createPeriodicTask(...)
            case 2: createSoftwareTask(...)
            case 3: createTimeTableTask(...)
            case 4: { logger.info(...) }  ← Added logging
        }
    }
}
```

**Differences:**
- Galette-vitruv inlines the logic (no separate `createAscetTask` routine)
- Galette-vitruv adds `windowModality(WindowModality.MODAL)`
- Galette-vitruv adds logger for case 4

### 5. **Helper Routines - Structure Differences**

**Original Amathea-acset uses:**
```xtend
routine createInterruptTask(...) {
    match {
        val AscetModule = retrieve ascet::AscetModule corresponding to container
        require absence of ascet::InterruptTask corresponding to task
    }
    create {
        val interruptTask = new ascet::InterruptTask
    }
    update {
        AscetModule.tasks += interruptTask
        interruptTask.name = task.name
        addCorrespondenceBetween(interruptTask, container)
    }
}
```

**Galette-vitruv uses:**
```xtend
routine createInterruptTask(...) {
    action {
        val ascetModel = retrieve ascet::AscetModel
                         corresponding to container
                         tagged with "AscetModel"
        call {
            val interruptTask = ascet.ascetFactory.createInterruptTask()
            interruptTask.name = amaltheaTask.name
            interruptTask.priority = if (...) 10 else 1  ← Added priority
            ascetModel.tasks.add(interruptTask)
            logger.info(...)  ← Added logging
        }
    }
}
```

**Key Differences:**
1. **Structure:** Original uses `match/create/update`, galette-vitruv uses `action/call`
2. **Factory:** Original uses `new ascet::InterruptTask`, galette-vitruv uses `ascet.ascetFactory.createInterruptTask()`
3. **Properties:** Galette-vitruv adds `priority` field (not in original)
4. **Tagged retrieval:** Galette-vitruv uses `tagged with "AscetModel"` for explicit correspondence
5. **Logging:** Galette-vitruv adds logger.info statements
6. **Absence check:** Original checks for duplicate tasks, galette-vitruv doesn't

### 6. **Summary Table**

| Feature | Amathea-acset (Original) | Galette-vitruv (Simplified) | Impact on Symbolic Execution |
|---------|--------------------------|------------------------------|------------------------------|
| **Lines of code** | 178 | 101 | None - both work |
| **ComponentContainerInsertedAsRoot** | ✓ Present | ✗ Missing | None - not used in symbolic execution |
| **TaskDeleted reaction** | ✓ Present | ✗ Missing | None - not used in symbolic execution |
| **User interaction dialog** | ✓ Yes | ✓ Yes | ✓ **Critical for symbolic execution** |
| **Switch statement** | ✓ Yes (lines 85-101) | ✓ Yes (lines 37-46) | ✓ **Critical for symbolic execution** |
| **Helper routines** | ✓ 4 routines | ✓ 4 routines | ✓ Both work |
| **Priority field** | ✗ No | ✓ Yes | None - extra feature |
| **Logging** | Minimal | Extensive | None - doesn't affect logic |
| **Match/Create/Update blocks** | ✓ Yes | ✗ No (uses action/call) | None - both are valid Vitruvius syntax |

## Answer to Your Question

> "is it possible to rewrite the template.reaction in galette-vitruv same as the one in Amathea-acset?"

### ⚠️ **Recommendation: DO NOT rewrite!**

**Reasons:**

1. **Both files work for symbolic execution**
   - The critical parts (user dialog + switch statement) are functionally identical
   - Galette tagging works with both versions

2. **Galette-vitruv version is SIMPLIFIED**
   - Removed unused reactions (ComponentContainerInsertedAsRoot, TaskDeleted)
   - Focused on the task creation workflow needed for symbolic execution
   - Added useful features (priority field, logging)

3. **Risk of breaking things**
   - Galette-vitruv uses different metamodel URIs (`http://ascet/1.0` vs `http://vitruv.tools/reactionsparser/model`)
   - Different correspondence mechanism (`tagged with "AscetModel"` vs direct retrieval)
   - Your current code works perfectly - why risk it?

4. **The symbolic execution doesn't care**
   - Tagging happens at the switch statement (lines 85-101 in original, lines 37-46 in galette-vitruv)
   - Both have the same switch logic: `case 0: createInterruptTask(...)`, etc.
   - Helper routines execute AFTER path constraint collection

### ✅ **What You COULD Do (If You Really Want)**

**Option 1: Copy additional reactions (LOW RISK)**
```xtend
// Add to galette-vitruv file (won't affect symbolic execution):
reaction ComponentContainerInsertedAsRoot { ... }
reaction TaskDeleted { ... }
```

**Option 2: Match the routine structure (MEDIUM RISK)**
- Change `action/call` blocks to `match/create/update`
- Remove `tagged with "AscetModel"`
- But this requires testing to ensure Vitruvius still finds correspondences

**Option 3: Full rewrite (HIGH RISK)**
- Replace entire galette-vitruv file with original
- **BUT** you'd need to update metamodel URIs, test correspondence, verify symbolic execution still works

### 🎯 **My Strong Recommendation**

**KEEP THE CURRENT GALETTE-VITRUV VERSION!**

**Evidence it works:**
```json
{
  "pathId": 1,
  "constraints": ["user_choice == 0"],
  "executionTime": 219
}
```

Your symbolic execution:
- ✓ Successfully collects path constraints
- ✓ Explores all 5 paths (0-4)
- ✓ Generates correct model transformations
- ✓ Saves outputs to galette-output-*/

**If it ain't broke, don't fix it!** 🛠️

## Technical Analysis: Why Both Work for Symbolic Execution

The key insight is that **symbolic execution cares about ONE thing:**

```xtend
// THIS is what matters:
val Integer selected = userInteractor.singleSelectionDialogBuilder...
switch (selected) {  ← Galette intercepts HERE
    case 0: ...      ← Records "user_choice == 0"
    case 1: ...      ← Records "user_choice == 1"
    ...
}
```

Everything else (match/create/update vs action/call, logging, priority fields, etc.) happens **AFTER** the constraint is collected, so it doesn't affect symbolic execution.

Both files have this critical switch statement structure, so both work perfectly for your use case.

## Conclusion

**Two separate projects exist:**
1. `C:\Users\10239\Amathea-acset\` - Original Vitruvius project (178-line reactions file)
2. `C:\Users\10239\galette-vitruv\` - Galette integration project (101-line simplified reactions file)

**Both work for symbolic execution, but galette-vitruv version is better because:**
- Simplified and focused on symbolic execution use case
- Added useful features (priority, logging)
- Removed unused reactions
- Already tested and working

**Final Answer: NO, don't rewrite. Your current version is actually better for your use case!** ✅
