# Amathea-ASCET Model Transformation Demo (PowerShell) - Interactive Version
# Shows symbolic execution with model transformations and user choice

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "    Amathea-ASCET Model Transformation Demo (Interactive)"   -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Set JAVA_HOME if needed
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"

Write-Host "Welcome to the Interactive Symbolic Execution Demo!" -ForegroundColor Green
Write-Host ""
Write-Host "This demo showcases:" -ForegroundColor Yellow
Write-Host "  1. Concrete transformations with known values" -ForegroundColor Gray
Write-Host "  2. Symbolic transformations with symbolic values" -ForegroundColor Gray
Write-Host "  3. Automatic path discovery (NEW!) - tool finds all paths" -ForegroundColor Gray
Write-Host "  4. Interactive dialog simulations" -ForegroundColor Gray
Write-Host "  5. Complete exploration of all transformation scenarios" -ForegroundColor Gray
Write-Host ""

# Show technical details
Write-Host "Technical Architecture:" -ForegroundColor Yellow
Write-Host "  - Galette JVM instrumentation for taint tracking" -ForegroundColor Gray
Write-Host "  - Knarr symbolic execution engine" -ForegroundColor Gray
Write-Host "  - Amathea-ASCET model transformation logic" -ForegroundColor Gray
Write-Host "  - Path constraint collection for test generation" -ForegroundColor Gray
Write-Host ""

Write-Host "Starting interactive demo..." -ForegroundColor Green
Write-Host "You will see a menu to choose your execution mode." -ForegroundColor Gray
Write-Host ""

# Change to knarr-runtime directory
Set-Location knarr-runtime

Write-Host "Launching interactive menu..." -ForegroundColor Cyan
Write-Host ""

# Run the interactive demo
cmd /c 'mvn exec:java -Dexec.mainClass="edu.neu.ccs.prl.galette.examples.AmathaeaModelTransformationExample"'

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "                    Demo Session Complete!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Key Features Demonstrated:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Interactive User Choice:" -ForegroundColor White
Write-Host "   - Menu-driven execution modes" -ForegroundColor Gray
Write-Host "   - User can select specific scenarios" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Automatic Path Discovery:" -ForegroundColor White
Write-Host "   - Tool automatically finds all transformation paths" -ForegroundColor Gray
Write-Host "   - No need to know upper bounds in advance" -ForegroundColor Gray
Write-Host "   - Smart exploration with stopping criteria" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Symbolic Execution Integration:" -ForegroundColor White
Write-Host "   - Amathea ComponentContainer -> ASCET task transformations" -ForegroundColor Gray
Write-Host "   - User selections (0-N) drive transformation paths" -ForegroundColor Gray
Write-Host "   - Framework ready for constraint collection" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Model-Driven Engineering:" -ForegroundColor White
Write-Host "   - Real model transformation scenarios" -ForegroundColor Gray
Write-Host "   - Multiple task types: Interrupt, Periodic, Software, TimeTable" -ForegroundColor Gray
Write-Host "   - Clean separation of business logic and symbolic execution" -ForegroundColor Gray
Write-Host ""

Write-Host "For more information, check the CLAUDE.md file in the project root." -ForegroundColor Cyan
Write-Host "Thank you for trying the Amathea-ASCET Symbolic Execution Demo!" -ForegroundColor Green