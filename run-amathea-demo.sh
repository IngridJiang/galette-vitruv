#!/bin/bash

# Vitruvius + Galette Symbolic Execution Demo
# Shows symbolic execution with real Vitruvius components

set -e

echo "🚀 Vitruvius + Galette Symbolic Execution Demo"
echo "=============================================="
echo

echo "Welcome to the Vitruvius Integration Demo!"
echo
echo "This demo showcases Vitruvius components:"
echo "  1. EMF metamodels (.ecore files) instead of custom Java classes"
echo "  2. Vitruvius reactions (.reactions files) instead of Java switch statements"
echo "  3. userInteractor.singleSelectionDialogBuilder"
echo "  4. ViewType-based model transformations"
echo "  5. VSUM integration with symbolic execution"
echo "  6. Multi-module project structure (model/viewtype/vsum/consistency)"
echo

# Run the Vitruvius integration demo
echo "📦 Running Vitruvius VSUM + Galette Symbolic Execution..."
echo "   (Shows EMF metamodels, reactions, ViewType, VSUM integration)"
echo

cd amathea-acset-integration/vsum
mvn exec:java -Dcheckstyle.skip=true -Dexec.mainClass="tools.vitruv.methodologisttemplate.vsum.GaletteSymbolicTest"

echo
echo "✅ Demo completed!"
echo
echo "🎯 Vitruvius Integration Features Demonstrated:"
echo
echo "1. EMF Metamodels:"
echo "   - model.ecore: Amathea metamodel (ComponentContainer, Task, PreemptionType)"
echo "   - model2.ecore: ASCET metamodel (AscetModel, InterruptTask, PeriodicTask, etc.)"
echo
echo "2. Vitruvius Reactions:"
echo "   - templateReactions.reactions: Transformation rules with userInteractor"
echo "   - Lines 78-82: Key integration point for symbolic execution"
echo
echo "3. ViewType Implementation:"
echo "   - ChangeTransformingViewType.java: View-based model transformations"
echo "   - Symbolic execution wrapper integration in transformation logic"
echo
echo "4. VSUM Integration:"
echo "   - GaletteSymbolicTest.java: Complete VSUM + symbolic execution integration"
echo "   - Multi-path exploration of all 5 user choice options (0-4)"
echo "   - userInteractor.singleSelectionDialogBuilder simulation"
echo
echo "5. Maintained Symbolic Execution:"
echo "   - SymbolicExecutionWrapper.makeSymbolicInt() calls preserved"
echo "   - Path constraint collection in switch statements"
echo "   - SMT solver integration for constraint analysis"
echo
echo "For more information:"
echo "  - CLAUDE.md: Project overview and build instructions"
echo "  - amathea-acset-integration/: Vitruvius project structure"
echo
echo "Thank you for trying the Vitruvius + Galette Integration Demo!"