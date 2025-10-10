#!/bin/bash
# Simple script to run Galette symbolic execution with Vitruvius
# This is now completely self-contained - no external Amathea-acset needed!

set -e

echo "================================================================================"
echo "GALETTE SYMBOLIC EXECUTION - VITRUVIUS MODEL TRANSFORMATION"
echo "================================================================================"
echo ""
echo "Running from galette-vitruv/knarr-runtime..."
echo "All dependencies managed by Maven (including Vitruvius vsum)"
echo ""

# Run symbolic execution via Maven
echo "Step 1: Running symbolic execution..."
mvn exec:java -Dexec.mainClass="edu.neu.ccs.prl.galette.vitruvius.VitruvSymbolicExecutionExample"

EXIT_CODE=$?

echo ""
echo "================================================================================"
if [ $EXIT_CODE -eq 0 ]; then
    echo "SUCCESS: Symbolic execution completed!"
else
    echo "ERROR: Symbolic execution failed"
    exit $EXIT_CODE
fi
echo "================================================================================"
echo ""

# Check for outputs
if ls -d galette-output-* >/dev/null 2>&1; then
    echo "Output directories created:"
    for dir in galette-output-*; do
        [ -d "$dir" ] && echo "  - $dir/"
    done
    echo ""
fi

if [ -f "execution_paths.json" ]; then
    echo "JSON results: execution_paths.json"
    echo ""

    # Try to run visualization if Python is available
    PYTHON_CMD=""
    if command -v python3 &> /dev/null; then
        PYTHON_CMD="python3"
    elif command -v python &> /dev/null; then
        PYTHON_CMD="python"
    fi

    if [ -n "$PYTHON_CMD" ]; then
        echo "Step 2: Generating visualizations..."
        echo ""

        # Check if required packages are available
        if $PYTHON_CMD -c "import matplotlib" 2>/dev/null; then
            # Generate workflow diagram
            $PYTHON_CMD visualize_workflow.py

            # Generate results visualizations
            $PYTHON_CMD visualize_results.py execution_paths.json

            echo ""
            echo "Visualizations created:"
            [ -f "workflow_diagram.png" ] && echo "  - workflow_diagram.png (workflow diagram)"
            [ -f "execution_tree.png" ] && echo "  - execution_tree.png (execution tree)"
            [ -f "performance_chart.png" ] && echo "  - performance_chart.png (performance analysis)"
            [ -f "execution_summary.txt" ] && echo "  - execution_summary.txt (text summary)"
        else
            echo "Python matplotlib package missing. Install with:"
            echo "  pip install matplotlib"
        fi
    else
        echo "Python not found - skipping visualizations"
        echo "Install Python to generate charts"
    fi
fi

echo ""
echo "Done! Output in: $(pwd)"
