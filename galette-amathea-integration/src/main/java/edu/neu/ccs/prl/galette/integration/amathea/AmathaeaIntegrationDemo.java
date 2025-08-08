package edu.neu.ccs.prl.galette.integration.amathea;

import java.util.Scanner;

/**
 * Main entry point for the Galette-Amathea integration demonstration.
 *
 * This class serves as the primary interface for demonstrating the integration
 * between Galette symbolic execution and Amathea-ASCET model transformations.
 *
 * @author Claude Code Assistant
 */
public class AmathaeaIntegrationDemo {

    public static void main(String[] args) {
        System.out.println("=== Galette-Amathea Integration Demo ===");
        System.out.println("This module demonstrates symbolic execution for model transformations");
        System.out.println();

        showMainMenu();
    }

    private static void showMainMenu() {
        Scanner scanner = new Scanner(System.in);

        while (true) {
            System.out.println("🎯 Galette-Amathea Integration Options:");
            System.out.println("1. Run Model Transformation Examples");
            System.out.println("2. Test Symbolic Execution Integration");
            System.out.println("3. Demonstrate Path Discovery");
            System.out.println("4. Show Integration Architecture");
            System.out.println("0. Exit");
            System.out.print("Enter your choice (0-4): ");

            try {
                int choice = scanner.nextInt();
                System.out.println();

                switch (choice) {
                    case 1:
                        runModelTransformationExamples();
                        break;
                    case 2:
                        testSymbolicExecutionIntegration();
                        break;
                    case 3:
                        demonstratePathDiscovery();
                        break;
                    case 4:
                        showIntegrationArchitecture();
                        break;
                    case 0:
                        System.out.println("👋 Goodbye!");
                        scanner.close();
                        return;
                    default:
                        System.out.println("❌ Invalid choice. Please select 0-4.");
                }

                System.out.println();
            } catch (Exception e) {
                System.out.println("❌ Invalid input. Please enter a number 0-4.");
                scanner.nextLine(); // Clear invalid input
            }
        }
    }

    private static void runModelTransformationExamples() {
        System.out.println("🔄 Running Model Transformation Examples...");
        System.out.println("This demonstrates Amathea ComponentContainer → ASCET task transformations");

        // Integration with the existing examples
        System.out.println("Delegating to knarr-runtime examples...");
        try {
            // Call the existing demo
            edu.neu.ccs.prl.galette.examples.AmathaeaModelTransformationExample.main(new String[] {});
        } catch (Exception e) {
            System.out.println("⚠️ Examples require knarr-runtime module to be properly built");
            System.out.println("Run 'mvn clean install' from the project root first");
        }
    }

    private static void testSymbolicExecutionIntegration() {
        System.out.println("🧪 Testing Symbolic Execution Integration...");
        System.out.println("This tests the integration between Galette and Amathea transformations");

        ModelTransformationService service = new ModelTransformationService();
        service.testSymbolicIntegration();
    }

    private static void demonstratePathDiscovery() {
        System.out.println("🔍 Demonstrating Automatic Path Discovery...");
        System.out.println("This shows how the tool automatically finds all transformation paths");

        PathDiscoveryService discovery = new PathDiscoveryService();
        discovery.demonstrateAutomaticDiscovery();
    }

    private static void showIntegrationArchitecture() {
        System.out.println("🏗️ Galette-Amathea Integration Architecture");
        System.out.println("===========================================");
        System.out.println();
        System.out.println("📦 Components:");
        System.out.println("  ├── galette-agent: JVM instrumentation");
        System.out.println("  ├── galette-instrument: Bytecode transformation");
        System.out.println("  ├── knarr-runtime: Symbolic execution engine");
        System.out.println("  ├── galette-amathea-integration: This module");
        System.out.println("  └── Green solver: Constraint solving");
        System.out.println();
        System.out.println("🔄 Data Flow:");
        System.out.println("  Amathea Model → User Selection → Symbolic Execution → ASCET Model");
        System.out.println();
        System.out.println("🎯 Key Features:");
        System.out.println("  • Automatic path discovery");
        System.out.println("  • Constraint collection");
        System.out.println("  • Test case generation");
        System.out.println("  • Real-time model transformations");
    }
}
