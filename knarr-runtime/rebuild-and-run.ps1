# PowerShell script to rebuild and run Galette/Vitruvius Symbolic Execution
# Usage: .\rebuild-and-run.ps1

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "REBUILD AND RUN - GALETTE/KNARR SYMBOLIC EXECUTION" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

# Set working directory to script location
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

Write-Host "[1/4] Cleaning build..." -ForegroundColor Yellow
mvn clean "-Dcheckstyle.skip=true" -q

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Clean failed!" -ForegroundColor Red
    exit 1
}
Write-Host "      Done." -ForegroundColor Green
Write-Host ""

Write-Host "[2/4] Compiling project..." -ForegroundColor Yellow
mvn compile "-DskipTests" "-Dcheckstyle.skip=true"

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Compilation failed!" -ForegroundColor Red
    exit 1
}
Write-Host "      Done." -ForegroundColor Green
Write-Host ""

Write-Host "[3/4] Running symbolic execution..." -ForegroundColor Yellow
mvn exec:java "-Dcheckstyle.skip=true"

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Symbolic execution failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[4/4] Generating visualizations..." -ForegroundColor Yellow
python visualize_results.py
python visualize_workflow.py

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Green
Write-Host "SUCCESS! Build and execution completed." -ForegroundColor Green
Write-Host "================================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Generated files:" -ForegroundColor Cyan
Write-Host "  - execution_paths.json       (JSON data)" -ForegroundColor White
Write-Host "  - execution_summary.txt      (Text summary)" -ForegroundColor White
Write-Host "  - execution_tree.png         (Execution tree diagram)" -ForegroundColor White
Write-Host "  - performance_chart.png      (Performance charts)" -ForegroundColor White
Write-Host "  - workflow_diagram.png       (Workflow diagram)" -ForegroundColor White
Write-Host "  - galette-output-0/ to galette-output-4/ (Model outputs)" -ForegroundColor White
Write-Host ""
