#!/bin/bash

# Amathea-ASCET Model Transformation Demo
# Shows symbolic execution with model transformations

set -e

echo "🚀 Amathea-ASCET Model Transformation Demo"
echo "========================================="
echo

# Run the working demo
echo "📦 Running Amathea-ASCET Transformation Example..."
echo "   (Shows 4 scenarios: Concrete, Symbolic, Batch, User Interaction)"
echo

cd knarr-runtime
mvn exec:java -Dexec.mainClass="edu.neu.ccs.prl.galette.examples.AmathaeaModelTransformationExample"

echo
echo "✅ Demo completed!"
echo
echo "🎯 What was demonstrated:"
echo "   1. Concrete transformation: EngineControlTask → PeriodicTask"
echo "   2. Symbolic transformation: BrakeControlTask with symbolic user choice"
echo "   3. Batch transformation: All 5 possible transformation paths"
echo "   4. User interaction: Dialog-based transformations"
echo
echo "🔧 Technical details:"
echo "   - Amathea ComponentContainer tasks → ASCET tasks"
echo "   - User selections (0-4) drive transformation logic"  
echo "   - Framework ready for path constraint collection"
echo "   - Clean separation of business logic and symbolic execution"