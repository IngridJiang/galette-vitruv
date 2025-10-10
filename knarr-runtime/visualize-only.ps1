# PowerShell script to regenerate visualizations only
# Usage: .\visualize-only.ps1

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "REGENERATE VISUALIZATIONS - GALETTE/KNARR SYMBOLIC EXECUTION" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

# Set working directory to script location
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

# Check if execution data exists
if (-not (Test-Path "execution_paths.json")) {
    Write-Host "ERROR: execution_paths.json not found!" -ForegroundColor Red
    Write-Host "Please run symbolic execution first:" -ForegroundColor Yellow
    Write-Host "  .\run-symbolic-execution.ps1" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host "Generating visualizations from existing data..." -ForegroundColor Yellow
Write-Host ""

Write-Host "  [1/2] Creating execution tree and performance charts..." -ForegroundColor Cyan
python visualize_results.py

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: visualize_results.py failed!" -ForegroundColor Red
    exit 1
}

Write-Host "  [2/2] Creating workflow diagram..." -ForegroundColor Cyan
python visualize_workflow.py

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: visualize_workflow.py failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Green
Write-Host "SUCCESS! Visualizations regenerated." -ForegroundColor Green
Write-Host "================================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Updated files:" -ForegroundColor Cyan
Write-Host "  - execution_tree.png         (Execution tree diagram)" -ForegroundColor White
Write-Host "  - performance_chart.png      (Performance charts)" -ForegroundColor White
Write-Host "  - workflow_diagram.png       (Workflow diagram)" -ForegroundColor White
Write-Host "  - execution_summary.txt      (Text summary)" -ForegroundColor White
Write-Host ""
