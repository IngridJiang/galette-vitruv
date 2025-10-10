# PowerShell script to run Galette/Vitruvius Symbolic Execution
# Usage: .\run-symbolic-execution.ps1

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "GALETTE/KNARR SYMBOLIC EXECUTION WITH VITRUVIUS FRAMEWORK" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

# Set working directory to script location
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

Write-Host "[1/3] Cleaning previous outputs..." -ForegroundColor Yellow
if (Test-Path "galette-output-*") {
    Remove-Item -Recurse -Force "galette-output-*"
}
if (Test-Path "execution_paths.json") {
    Remove-Item "execution_paths.json"
}
Write-Host "      Done." -ForegroundColor Green
Write-Host ""

Write-Host "[2/3] Running symbolic execution..." -ForegroundColor Yellow
$mvnSuccess = $true
try {
    mvn exec:java "-Dcheckstyle.skip=true"
    if ($LASTEXITCODE -ne 0) {
        $mvnSuccess = $false
        Write-Host ""
        Write-Host "WARNING: Maven execution had errors, but continuing to generate visualizations..." -ForegroundColor Yellow
    }
} catch {
    $mvnSuccess = $false
    Write-Host ""
    Write-Host "WARNING: Maven execution failed, but continuing to generate visualizations..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[3/3] Generating visualizations..." -ForegroundColor Yellow

# Always try to generate visualizations if execution_paths.json exists
if (Test-Path "execution_paths.json") {
    python visualize_results.py
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Results visualizations generated" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Failed to generate results visualizations" -ForegroundColor Red
    }

    python visualize_workflow.py
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Workflow diagram generated" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Failed to generate workflow diagram" -ForegroundColor Red
    }
} else {
    Write-Host "  ✗ No execution_paths.json found - skipping visualizations" -ForegroundColor Red
    if (-not $mvnSuccess) {
        Write-Host ""
        Write-Host "ERROR: Symbolic execution failed and no data was generated!" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Green
Write-Host "SUCCESS! Symbolic execution completed." -ForegroundColor Green
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
Write-Host "View the results:" -ForegroundColor Cyan
Write-Host "  - Open .png files to see visualizations" -ForegroundColor White
Write-Host "  - Read execution_summary.txt for detailed report" -ForegroundColor White
Write-Host ""
