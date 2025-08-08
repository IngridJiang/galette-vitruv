# Vitruvius + Galette Symbolic Execution Demo (PowerShell)
# Shows symbolic execution with Vitruvius components instead of custom mocks

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "    Vitruvius + Galette Symbolic Execution Demo"            -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Set JAVA_HOME if needed
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"

Write-Host "Welcome to the Vitruvius Integration Demo!" -ForegroundColor Green
Write-Host ""
Write-Host "This demo showcases Vitruvius components:" -ForegroundColor Yellow
Write-Host "  1. EMF metamodels (.ecore files) instead of custom Java classes" -ForegroundColor Gray
Write-Host "  2. Vitruvius reactions (.reactions files) instead of Java switch statements" -ForegroundColor Gray
Write-Host "  3. userInteractor.singleSelectionDialogBuilder" -ForegroundColor Gray
Write-Host "  4. ViewType-based model transformations" -ForegroundColor Gray
Write-Host "  5. VSUM integration with symbolic execution" -ForegroundColor Gray
Write-Host "  6. Multi-module project structure (model/viewtype/vsum/consistency)" -ForegroundColor Gray
Write-Host ""

# Show technical details
Write-Host "Vitruvius Architecture:" -ForegroundColor Yellow
Write-Host "  - EMF metamodels: model.ecore (Amathea) + model2.ecore (ASCET)" -ForegroundColor Gray
Write-Host "  - Vitruvius reactions: templateReactions.reactions" -ForegroundColor Gray
Write-Host "  - ViewType: ChangeTransformingViewType.java" -ForegroundColor Gray
Write-Host "  - VSUM integration: GaletteSymbolicTest.java" -ForegroundColor Gray
Write-Host "  - Galette symbolic execution: Path constraint collection" -ForegroundColor Gray
Write-Host ""

Write-Host "Starting Vitruvius demo..." -ForegroundColor Green
Write-Host "Running VSUM integration with symbolic execution..." -ForegroundColor Gray
Write-Host ""

# Change to the Vitruvius project directory
Set-Location amathea-acset-integration\vsum

Write-Host "Launching Vitruvius + Galette integration..." -ForegroundColor Cyan
Write-Host ""

# Run the Vitruvius VSUM integration
cmd /c 'mvn exec:java -Dcheckstyle.skip=true -Dexec.mainClass="tools.vitruv.methodologisttemplate.vsum.GaletteSymbolicTest"'

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "                    Demo Session Complete!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Vitruvius Integration Features Demonstrated:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. EMF Metamodels:" -ForegroundColor White
Write-Host "   - model.ecore: Amathea metamodel (ComponentContainer, Task, PreemptionType)" -ForegroundColor Gray
Write-Host "   - model2.ecore: ASCET metamodel (AscetModel, InterruptTask, PeriodicTask, etc.)" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Vitruvius Reactions:" -ForegroundColor White
Write-Host "   - templateReactions.reactions: Transformation rules with userInteractor" -ForegroundColor Gray
Write-Host "   - Lines 78-82: Key integration point for symbolic execution" -ForegroundColor Gray
Write-Host ""
Write-Host "3. ViewType Implementation:" -ForegroundColor White
Write-Host "   - ChangeTransformingViewType.java: View-based model transformations" -ForegroundColor Gray
Write-Host "   - Symbolic execution wrapper integration in transformation logic" -ForegroundColor Gray
Write-Host ""
Write-Host "4. VSUM Integration:" -ForegroundColor White
Write-Host "   - GaletteSymbolicTest.java: Complete VSUM + symbolic execution integration" -ForegroundColor Gray
Write-Host "   - Multi-path exploration of all 5 user choice options (0-4)" -ForegroundColor Gray
Write-Host "   - userInteractor.singleSelectionDialogBuilder simulation" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Maintained Symbolic Execution:" -ForegroundColor White
Write-Host "   - SymbolicExecutionWrapper.makeSymbolicInt() calls preserved" -ForegroundColor Gray
Write-Host "   - Path constraint collection in switch statements" -ForegroundColor Gray
Write-Host "   - SMT solver integration for constraint analysis" -ForegroundColor Gray
Write-Host ""

Write-Host "For more information:" -ForegroundColor Cyan
Write-Host "  - CLAUDE.md: Project overview and build instructions" -ForegroundColor Gray
Write-Host "  - amathea-acset-integration/: Vitruvius project structure" -ForegroundColor Gray
Write-Host ""
Write-Host "Thank you for trying the Vitruvius + Galette Integration Demo!" -ForegroundColor Green