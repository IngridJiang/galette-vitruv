package edu.neu.ccs.prl.galette.examples;

import edu.neu.ccs.prl.galette.concolic.knarr.runtime.PathConditionWrapper;
import edu.neu.ccs.prl.galette.concolic.knarr.runtime.PathUtils;
import edu.neu.ccs.prl.galette.examples.transformation.AmathaeaAscetTransformation;
import edu.neu.ccs.prl.galette.examples.transformation.AmathaeaAscetTransformation.AmathaeaTask;
import edu.neu.ccs.prl.galette.examples.transformation.AmathaeaAscetTransformation.TransformationResult;
import edu.neu.ccs.prl.galette.examples.transformation.AmathaeaAscetTransformation.UserInteractionSimulator;
import edu.neu.ccs.prl.galette.examples.transformation.SymbolicExecutionWrapper;
import edu.neu.ccs.prl.galette.examples.transformation.SymbolicExecutionWrapper.SymbolicValue;
import java.util.Scanner;

/**
 * Example demonstrating Amathaea-ASCET model transformation with symbolic execution.
 *
 * This example replaces the brake disc transformation with a more realistic
 * model-driven engineering scenario where:
 * - Amathaea ComponentContainer tasks are transformed to ASCET tasks
 * - User selections (0-4) determine which type of ASCET task to create
 * - Symbolic execution tracks the decision paths for test generation
 *
 * The symbolic execution enables:
 * - Automatic exploration of all transformation paths
 * - Path constraint collection for test case generation
 * - Impact analysis of user decisions on model transformations
 *
 * @author [Anne Koziolek](https://github.com/AnneKoziolek)
 */
public class AmathaeaModelTransformationExample {

    public static void main(String[] args) {
        System.out.println("=== Amathaea-ASCET Model Transformation with Symbolic Execution ===\n");

        // Interactive menu for users to choose execution mode
        showUserMenu();
    }

    /**
     * Interactive menu allowing users to choose execution mode
     */
    private static void showUserMenu() {
        Scanner scanner = new Scanner(System.in);

        while (true) {
            System.out.println("\n🎯 Choose your execution mode:");
            System.out.println("1. Concrete Transformation (single path with known values)");
            System.out.println("2. Symbolic Transformation (explore with symbolic values)");
            System.out.println("3. Automatic Path Discovery (let tool find all paths)");
            System.out.println("4. Interactive Dialog Simulation");
            System.out.println("5. Run All Examples");
            System.out.println("0. Exit");
            System.out.print("\nEnter your choice (0-5): ");

            try {
                int choice = scanner.nextInt();
                System.out.println();

                switch (choice) {
                    case 1:
                        runConcreteTransformation();
                        break;
                    case 2:
                        runSymbolicTransformation();
                        break;
                    case 3:
                        runAutomaticPathDiscovery();
                        break;
                    case 4:
                        runUserInteractionExample();
                        break;
                    case 5:
                        runAllExamples();
                        break;
                    case 0:
                        System.out.println("👋 Goodbye!");
                        scanner.close();
                        return;
                    default:
                        System.out.println("❌ Invalid choice. Please select 0-5.");
                }

                System.out.println("\n" + new String(new char[50]).replace('\0', '='));

            } catch (Exception e) {
                System.out.println("❌ Invalid input. Please enter a number 0-5.");
                scanner.nextLine(); // Clear the invalid input
            }
        }
    }

    /**
     * Run all examples in sequence
     */
    private static void runAllExamples() {
        System.out.println("🚀 Running All Examples:");
        System.out.println(new String(new char[25]).replace('\0', '='));

        runConcreteTransformation();
        runSymbolicTransformation();
        runAutomaticPathDiscovery();
        runUserInteractionExample();

        System.out.println("✅ All examples completed!");
    }

    /**
     * Example 1: Interactive concrete transformation with user input.
     */
    private static void runConcreteTransformation() {
        System.out.println("1. INTERACTIVE CONCRETE TRANSFORMATION");
        System.out.println("-------------------------------------");
        System.out.println("💡 Enter your own values for concrete transformation\n");

        Scanner scanner = new Scanner(System.in);

        // Get task name from user
        System.out.print("Enter task name (e.g., EngineControlTask): ");
        String taskName = scanner.nextLine().trim();
        if (taskName.isEmpty()) {
            taskName = "UserDefinedTask";
        }

        // Get preemption mode from user
        System.out.print("Enter preemption mode (preemptive/cooperative) [cooperative]: ");
        String preemption = scanner.nextLine().trim();
        if (preemption.isEmpty() || (!preemption.equals("preemptive") && !preemption.equals("cooperative"))) {
            preemption = "cooperative";
        }

        // Get activation limit from user
        System.out.print("Enter multiple task activation limit (0-10) [0]: ");
        int activationLimit = 0;
        try {
            String limitInput = scanner.nextLine().trim();
            if (!limitInput.isEmpty()) {
                activationLimit = Integer.parseInt(limitInput);
                if (activationLimit < 0 || activationLimit > 10) {
                    activationLimit = 0;
                }
            }
        } catch (NumberFormatException e) {
            activationLimit = 0;
        }

        // Get user choice for transformation
        System.out.println("\nTransformation choices:");
        System.out.println("  0: Create InterruptTask");
        System.out.println("  1: Create PeriodicTask");
        System.out.println("  2: Create SoftwareTask");
        System.out.println("  3: Create TimeTableTask");
        System.out.println("  4: Decide Later");
        System.out.print("Enter your transformation choice (0-4): ");

        int userChoice = 1; // Default
        try {
            String choiceInput = scanner.nextLine().trim();
            if (!choiceInput.isEmpty()) {
                userChoice = Integer.parseInt(choiceInput);
                if (userChoice < 0 || userChoice > 4) {
                    userChoice = 1;
                    System.out.println("⚠️  Invalid choice, using default: 1 (PeriodicTask)");
                }
            }
        } catch (NumberFormatException e) {
            userChoice = 1;
            System.out.println("⚠️  Invalid input, using default: 1 (PeriodicTask)");
        }

        // Create source model with user input
        AmathaeaTask sourceTask = new AmathaeaTask(taskName);
        sourceTask.setPreemption(preemption);
        sourceTask.setMultipleTaskActivationLimit(activationLimit);

        System.out.println("\n📊 Transformation Details:");
        System.out.println("==========================");
        System.out.println("Source Task: " + sourceTask);
        System.out.println("User Choice: " + userChoice + " (" + getChoiceDescription(userChoice) + ")");

        // Transform with user's concrete selection
        TransformationResult result = AmathaeaAscetTransformation.transform(sourceTask, userChoice);

        System.out.println("\n✅ Transformation Result:");
        System.out.println("Result: " + result);

        if (result.getAscetTask() != null) {
            System.out.println(
                    "Created Task Type: " + result.getAscetTask().getClass().getSimpleName());
            System.out.println("Task Details: " + result.getAscetTask());
        } else {
            System.out.println("No task created (decision deferred)");
        }

        System.out.println("\n💡 This was a concrete transformation with your specific input values!");
        System.out.println();
    }

    /**
     * Helper method to get choice description
     */
    private static String getChoiceDescription(int choice) {
        switch (choice) {
            case 0:
                return "InterruptTask";
            case 1:
                return "PeriodicTask";
            case 2:
                return "SoftwareTask";
            case 3:
                return "TimeTableTask";
            case 4:
                return "Decide Later";
            default:
                return "Unknown";
        }
    }

    /**
     * Example 2: Symbolic transformation (with symbolic execution).
     */
    private static void runSymbolicTransformation() {
        System.out.println("2. SYMBOLIC TRANSFORMATION");
        System.out.println("--------------------------");

        // Create source model
        AmathaeaTask sourceTask = new AmathaeaTask("BrakeControlTask");
        sourceTask.setPreemption("cooperative");

        // Create symbolic user selection
        SymbolicValue<Integer> symbolicSelection = SymbolicExecutionWrapper.makeSymbolicInt("user_choice", 2);

        System.out.println("Source: " + sourceTask);
        System.out.println("Symbolic Selection: " + symbolicSelection);

        // Transform with symbolic value
        TransformationResult result = transformWithSymbolicSelection(sourceTask, symbolicSelection);

        System.out.println("Result: " + result);

        // Analyze path constraints
        analyzePathConstraints("Symbolic Transformation");
        System.out.println();
    }

    /**
     * Example 3: Automatic path discovery - tool finds all paths automatically.
     */
    private static void runAutomaticPathDiscovery() {
        System.out.println("3. AUTOMATIC PATH DISCOVERY");
        System.out.println("---------------------------");
        System.out.println("🔍 Let the tool automatically discover all possible transformation paths...\n");

        AmathaeaTask sourceTask = new AmathaeaTask("AutoDiscoveryTask");
        System.out.println("Source: " + sourceTask);

        // Automatic discovery: tool finds all valid paths by testing incrementally
        System.out.println("🤖 Tool is discovering paths automatically:");
        System.out.println("   Starting from choice 0 and exploring until no more valid paths...\n");

        java.util.List<TransformationResult> discoveredPaths = discoverAllPaths(sourceTask);

        System.out.println("✅ Discovery complete! Found " + discoveredPaths.size() + " transformation paths:");
        System.out.println(new String(new char[60]).replace('\0', '-'));

        for (int i = 0; i < discoveredPaths.size(); i++) {
            TransformationResult result = discoveredPaths.get(i);
            System.out.printf(
                    "🔗 Path %d (choice %d): %s\n", i + 1, result.getSelectedOption(), result.getTransformationType());
            if (result.getAscetTask() != null) {
                System.out.printf(
                        "   → Creates: %s\n", result.getAscetTask().getClass().getSimpleName());
            } else {
                System.out.println("   → No task created (deferred decision)");
            }
        }

        System.out.println("\n💡 Key insight: Tool automatically discovered " + discoveredPaths.size()
                + " paths without needing to know the upper bound!");
        System.out.println();
    }

    /**
     * Automatically discover all valid transformation paths by testing incrementally.
     * This simulates how symbolic execution would explore paths without knowing bounds.
     */
    private static java.util.List<TransformationResult> discoverAllPaths(AmathaeaTask sourceTask) {
        java.util.List<TransformationResult> discoveredPaths = new java.util.ArrayList<>();

        int choice = 0;
        int consecutiveFailures = 0;
        final int MAX_CONSECUTIVE_FAILURES = 3; // Stop after 3 consecutive invalid choices

        while (consecutiveFailures < MAX_CONSECUTIVE_FAILURES) {
            try {
                System.out.printf("   Testing choice %d... ", choice);

                // Test if this choice is valid by attempting transformation
                TransformationResult result = AmathaeaAscetTransformation.transform(sourceTask, choice);

                if (AmathaeaAscetTransformation.isValidSelection(choice)) {
                    System.out.println("✅ Valid path found!");
                    discoveredPaths.add(result);
                    consecutiveFailures = 0; // Reset failure counter
                } else {
                    System.out.println("❌ Invalid choice");
                    consecutiveFailures++;
                }

            } catch (Exception e) {
                System.out.println("❌ Exception occurred: " + e.getMessage());
                consecutiveFailures++;
            }

            choice++;

            // Safety limit to prevent infinite loops
            if (choice > 20) {
                System.out.println("🛑 Reached safety limit (20 choices tested)");
                break;
            }
        }

        System.out.println("🔍 Discovery finished. Tested up to choice " + (choice - 1));
        return discoveredPaths;
    }

    /**
     * Example 4: Batch transformation exploring all paths (legacy method).
     */
    private static void runBatchTransformation() {
        System.out.println("BATCH TRANSFORMATION (All Known Paths)");
        System.out.println("--------------------------------------");

        AmathaeaTask sourceTask = new AmathaeaTask("MultiModalTask");
        int[] allSelections = {0, 1, 2, 3, 4}; // All possible user choices

        System.out.println("Source: " + sourceTask);
        System.out.println("Exploring all transformation paths...\n");

        TransformationResult[] results = AmathaeaAscetTransformation.transformBatch(sourceTask, allSelections);

        for (int i = 0; i < results.length; i++) {
            System.out.printf("Path %d: %s\n", i, results[i]);
        }
        System.out.println();
    }

    /**
     * Example 5: User interaction simulation.
     */
    private static void runUserInteractionExample() {
        System.out.println("5. USER INTERACTION SIMULATION");
        System.out.println("------------------------------");

        AmathaeaTask sourceTask = new AmathaeaTask("InteractiveTask");

        // Simulate multiple user choices with symbolic execution
        String message = "A Task has been created. Please decide which ASCET Task should be created.";
        String[] options = UserInteractionSimulator.getTaskOptions();

        System.out.println("Simulating user interaction dialog:");
        System.out.println("Message: " + message);
        System.out.println("Options: " + java.util.Arrays.toString(options));

        // Test with different symbolic selections
        int[] testSelections = {0, 1, 4}; // InterruptTask, PeriodicTask, Decide Later

        for (int selection : testSelections) {
            SymbolicValue<Integer> symbolicChoice =
                    SymbolicExecutionWrapper.makeSymbolicInt("user_dialog_choice", selection);

            TransformationResult result = transformWithSymbolicSelection(sourceTask, symbolicChoice);
            System.out.printf("Choice %d → %s\n", selection, result.getTransformationType());
        }

        analyzePathConstraints("User Interaction Simulation");
        System.out.println();
    }

    /**
     * Transform with symbolic selection and constraint collection.
     */
    private static TransformationResult transformWithSymbolicSelection(
            AmathaeaTask sourceTask, SymbolicValue<Integer> symbolicSelection) {
        // This is where the magic happens - the symbolic value flows through the transformation
        // and path constraints are collected automatically by Galette
        return AmathaeaAscetTransformation.transform(sourceTask, symbolicSelection.getValue());
    }

    /**
     * Analyze and display collected path constraints.
     */
    private static void analyzePathConstraints(String context) {
        PathConditionWrapper pathCondition = PathUtils.getCurPC();

        if (pathCondition != null && pathCondition.size() > 0) {
            System.out.println("Path Constraints Collected (" + context + "):");
            System.out.println("  Number of constraints: " + pathCondition.size());
            System.out.println("  Constraints: " + pathCondition);
        } else {
            System.out.println("No path constraints collected (" + context + ")");
            System.out.println("  Note: Constraints are only collected with proper Galette instrumentation");
        }
    }

    /**
     * Demonstrate symbolic execution benefits for model transformations.
     */
    public static void demonstrateSymbolicExecutionBenefits() {
        System.out.println("SYMBOLIC EXECUTION BENEFITS FOR MODEL TRANSFORMATIONS");
        System.out.println("===================================================");

        System.out.println("1. AUTOMATIC PATH EXPLORATION:");
        System.out.println("   - Explores all possible user selection paths (0-4)");
        System.out.println("   - Discovers edge cases and boundary conditions");
        System.out.println("   - Validates transformation completeness");

        System.out.println("\n2. TEST CASE GENERATION:");
        System.out.println("   - Collects path constraints for each transformation path");
        System.out.println("   - Enables solver-based test input generation");
        System.out.println("   - Automates validation test creation");

        System.out.println("\n3. IMPACT ANALYSIS:");
        System.out.println("   - Tracks how user decisions affect model properties");
        System.out.println("   - Identifies transformation dependencies");
        System.out.println("   - Supports model evolution analysis");

        System.out.println("\n4. VITRUVIUS INTEGRATION:");
        System.out.println("   - Plugs into existing Vitruvius reactions");
        System.out.println("   - Preserves original transformation logic");
        System.out.println("   - Adds analysis capabilities transparently");
    }
}
