@echo off
REM Simple script to run Galette symbolic execution with Vitruvius
REM This is now completely self-contained - no external Amathea-acset needed!

echo ================================================================================
echo GALETTE SYMBOLIC EXECUTION - VITRUVIUS MODEL TRANSFORMATION
echo ================================================================================
echo.
echo Running from galette-vitruv/knarr-runtime...
echo All dependencies managed by Maven (including Vitruvius vsum)
echo.

REM Run symbolic execution via Maven
echo Step 1: Running symbolic execution...
call mvn exec:java -Dexec.mainClass="edu.neu.ccs.prl.galette.vitruvius.VitruvSymbolicExecutionExample"

if errorlevel 1 (
    echo.
    echo ERROR: Symbolic execution failed
    exit /b 1
)

echo.
echo ================================================================================
echo SUCCESS: Symbolic execution completed!
echo ================================================================================
echo.

REM Check for outputs
if exist galette-output-0 (
    echo Output directories created:
    for /d %%d in (galette-output-*) do echo   - %%d\
    echo.
)

if exist execution_paths.json (
    echo JSON results: execution_paths.json
    echo.

    REM Try to run visualization if Python is available
    where python >nul 2>&1
    if %ERRORLEVEL% == 0 (
        echo Step 2: Generating visualizations...
        echo.

        REM Generate workflow diagram
        python visualize_workflow.py

        REM Generate results visualizations
        python visualize_results.py execution_paths.json

        echo.
        echo Visualizations created:
        if exist workflow_diagram.png echo   - workflow_diagram.png (workflow diagram)
        if exist execution_tree.png echo   - execution_tree.png (execution tree)
        if exist performance_chart.png echo   - performance_chart.png (performance analysis)
        if exist execution_summary.txt echo   - execution_summary.txt (text summary)
    ) else (
        echo Python not found - skipping visualizations
        echo Install Python and matplotlib to generate charts
    )
)

echo.
echo Done! Output in: %CD%
