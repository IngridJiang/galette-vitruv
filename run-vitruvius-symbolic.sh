#!/bin/bash

# Run symbolic execution with Vitruvius integration
# This script runs from galette-vitruv but executes against Amathea-acset

set -e

echo "================================================================================"
echo "GALETTE SYMBOLIC EXECUTION - VITRUVIUS MODEL TRANSFORMATION"
echo "================================================================================"
echo ""
echo "This script integrates Galette/Knarr symbolic execution with Vitruvius:"
echo "  1. Tag user input as symbolic using Galette"
echo "  2. Pass tagged value to Vitruvius Test.insertTask()"
echo "  3. Let Vitruvius reactions execute naturally"
echo "  4. Galette automatically collects path constraints from switch statement"
echo "  5. No hardcoded transformation logic - all in templateReactions.reactions!"
echo ""

# Check if JAVA_HOME is set
if [ -z "$JAVA_HOME" ]; then
    echo "❌ JAVA_HOME is not set"
    echo "Please set JAVA_HOME to your JDK installation"
    exit 1
fi

echo "✓ JAVA_HOME: $JAVA_HOME"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GALETTE_DIR="$SCRIPT_DIR"
AMATHEA_DIR="C:/Users/10239/Amathea-acset"

echo "✓ Galette directory: $GALETTE_DIR"
echo "✓ Amathea directory: $AMATHEA_DIR"

# Check if Amathea-acset exists
if [ ! -d "$AMATHEA_DIR" ]; then
    echo "❌ Amathea-acset directory not found: $AMATHEA_DIR"
    exit 1
fi

echo ""
echo "Step 1: Building Galette (if needed)..."
cd "$GALETTE_DIR"

# Check if Galette is already built
if [ ! -f "$HOME/.m2/repository/edu/neu/ccs/prl/galette/galette-agent/1.0.0-SNAPSHOT/galette-agent-1.0.0-SNAPSHOT.jar" ]; then
    echo "Building Galette..."
    mvn clean install -DskipTests -Dcheckstyle.skip=true
    if [ $? -ne 0 ]; then
        echo "❌ Galette build failed"
        exit 1
    fi
    echo "✓ Galette built successfully"
else
    echo "✓ Galette already built"
fi

echo ""
echo "Step 2: Building Amathea-acset..."
cd "$AMATHEA_DIR"

mvn clean compile -DskipTests -Dcheckstyle.skip=true
if [ $? -ne 0 ]; then
    echo "❌ Amathea-acset build failed"
    exit 1
fi

echo "✓ Amathea-acset built successfully"

echo ""
echo "Step 3: Building classpath..."

# Get Amathea VSUM classpath - read from file since /dev/stdout doesn't work on Windows
cd "$AMATHEA_DIR/vsum"
# The classpath file was already created during compile phase
if [ ! -f "target/classpath.txt" ]; then
    echo "Generating classpath file..."
    mvn dependency:build-classpath -Dmdep.outputFile=target/classpath.txt -q
fi

VSUM_CLASSPATH=$(cat target/classpath.txt | tr '\\' '/' | tr ';' ':')

if [ -z "$VSUM_CLASSPATH" ]; then
    echo "❌ Failed to read Amathea classpath"
    exit 1
fi

# Add Amathea classes
VSUM_CLASSPATH="$AMATHEA_DIR/vsum/target/classes:$VSUM_CLASSPATH"

# Add consistency module (contains reactions)
VSUM_CLASSPATH="$AMATHEA_DIR/consistency/target/classes:$VSUM_CLASSPATH"

# Add model module
VSUM_CLASSPATH="$AMATHEA_DIR/model/target/classes:$VSUM_CLASSPATH"

# Get Galette knarr-runtime classpath
cd "$GALETTE_DIR/knarr-runtime"
if [ ! -f "target/classpath.txt" ]; then
    echo "Generating Galette classpath file..."
    mvn dependency:build-classpath -Dmdep.outputFile=target/classpath.txt -q
fi

KNARR_CLASSPATH=$(cat target/classpath.txt | tr '\\' '/' | tr ';' ':')

if [ -z "$KNARR_CLASSPATH" ]; then
    echo "❌ Failed to read Galette classpath"
    exit 1
fi

# Add knarr-runtime classes
KNARR_CLASSPATH="$GALETTE_DIR/knarr-runtime/target/classes:$KNARR_CLASSPATH"

# Combine classpaths - Use semicolon on Windows for Java
FULL_CLASSPATH="$KNARR_CLASSPATH;$VSUM_CLASSPATH"

echo "✓ Classpath built"

echo ""
echo "================================================================================"
echo "Running symbolic execution test..."
echo "================================================================================"
echo ""
echo "Executing: VitruvSymbolicExecutionExample"
echo "  - Will explore 5 paths (user choices 0-4)"
echo "  - Each path will be tagged as symbolic"
echo "  - Path constraints will be collected from reactions switch statement"
echo ""

# Navigate to galette-vitruv directory (where output will be created)
cd "$GALETTE_DIR"

# Run with full classpath
java -cp "$FULL_CLASSPATH" \
    edu.neu.ccs.prl.galette.vitruvius.VitruvSymbolicExecutionExample

EXIT_CODE=$?

echo ""
echo "================================================================================"
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Symbolic execution completed successfully!"
else
    echo "❌ Symbolic execution failed (exit code: $EXIT_CODE)"
fi
echo "================================================================================"
echo ""

# Show output directories
if ls -d galette-output-* >/dev/null 2>&1; then
    echo "📁 Output directories created in galette-vitruv:"
    for dir in galette-output-*; do
        if [ -d "$dir" ]; then
            echo "  • $dir/"
            if [ -f "$dir/galette-test-output/vsum-output.xmi" ]; then
                echo "    └─ galette-test-output/vsum-output.xmi (transformed model)"
            fi
        fi
    done
    echo ""
    echo "To examine the transformed models:"
    echo "  cd $GALETTE_DIR"
    echo "  cat galette-output-0/galette-test-output/vsum-output.xmi"
else
    echo "⚠️  No output directories found"
    echo "   Check the output above for errors"
fi

echo ""
echo "Location: Output saved in $GALETTE_DIR"
echo ""

# Generate visualizations if Python is available and JSON exists
if [ -f "execution_paths.json" ] && [ $EXIT_CODE -eq 0 ]; then
    echo "================================================================================"
    echo "Generating visualizations..."
    echo "================================================================================"
    echo ""

    # Check for Python
    PYTHON_CMD=""
    if command -v python3 &> /dev/null; then
        PYTHON_CMD="python3"
    elif command -v python &> /dev/null; then
        PYTHON_CMD="python"
    fi

    if [ -n "$PYTHON_CMD" ]; then
        # Check for required packages
        if $PYTHON_CMD -c "import matplotlib, networkx" 2>/dev/null; then
            echo "Running visualization script..."
            $PYTHON_CMD visualize_execution.py execution_paths.json

            if [ $? -eq 0 ]; then
                echo ""
                echo "📊 Visualizations generated:"
                [ -f "execution_tree.png" ] && echo "  • execution_tree.png"
                [ -f "performance_chart.png" ] && echo "  • performance_chart.png"
                [ -f "execution_summary.txt" ] && echo "  • execution_summary.txt"
                echo ""
                echo "To view:"
                echo "  xdg-open execution_tree.png"
                echo "  xdg-open performance_chart.png"
            fi
        else
            echo "⚠️  Python packages missing. Install with:"
            echo "  pip install matplotlib networkx"
            echo ""
            echo "Or run visualization manually:"
            echo "  python visualize_execution.py execution_paths.json"
        fi
    else
        echo "⚠️  Python not found. Install Python to generate visualizations."
        echo ""
        echo "JSON data available in: execution_paths.json"
    fi
fi

echo ""

exit $EXIT_CODE
