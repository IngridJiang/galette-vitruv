package edu.neu.ccs.prl.galette.examples.transformation;

import java.util.Scanner;

/**
 * Model transformation logic for Amathea-ASCET model transformations with symbolic execution support.
 *
 * This class contains business logic for transforming Amathea ComponentContainer tasks to
 * corresponding ASCET tasks. The transformation mimics the Vitruvius reactions framework
 * logic but keeps it focused on business rules while enabling automatic path constraint
 * collection when symbolic values are present.
 *
 * The key decision point is the user selection for task type transformation:
 * - 0: Create InterruptTask
 * - 1: Create PeriodicTask
 * - 2: Create SoftwareTask
 * - 3: Create TimeTableTask
 * - 4: Decide Later (no action)
 *
 * @author [Anne Koziolek](https://github.com/AnneKoziolek)
 */
public class AmathaeaAscetTransformation {

    /**
     * Task type constants matching Vitruvius reactions options.
     */
    public static final int INTERRUPT_TASK = 0;

    public static final int PERIODIC_TASK = 1;
    public static final int SOFTWARE_TASK = 2;
    public static final int TIMETABLE_TASK = 3;
    public static final int DECIDE_LATER = 4;

    /**
     * Amathea source model representation.
     */
    public static class AmathaeaTask {
        private String name;
        private String preemption = "cooperative";
        private int multipleTaskActivationLimit = 0;

        public AmathaeaTask(String name) {
            this.name = name;
        }

        // Getters and setters
        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getPreemption() {
            return preemption;
        }

        public void setPreemption(String preemption) {
            this.preemption = preemption;
        }

        public int getMultipleTaskActivationLimit() {
            return multipleTaskActivationLimit;
        }

        public void setMultipleTaskActivationLimit(int limit) {
            this.multipleTaskActivationLimit = limit;
        }

        @Override
        public String toString() {
            return String.format(
                    "AmathaeaTask{name='%s', preemption='%s', limit=%d}",
                    name, preemption, multipleTaskActivationLimit);
        }
    }

    /**
     * ASCET target model representation.
     */
    public abstract static class AscetTask {
        protected String name;
        protected int priority = 0;

        public AscetTask(String name) {
            this.name = name;
        }

        // Getters and setters
        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public int getPriority() {
            return priority;
        }

        public void setPriority(int priority) {
            this.priority = priority;
        }

        @Override
        public String toString() {
            return String.format("%s{name='%s', priority=%d}", getClass().getSimpleName(), name, priority);
        }
    }

    /**
     * ASCET task type implementations.
     */
    public static class InterruptTask extends AscetTask {
        public InterruptTask(String name) {
            super(name);
        }
    }

    public static class PeriodicTask extends AscetTask {
        private double period = 0.0;
        private double delay = 0.0;

        public PeriodicTask(String name) {
            super(name);
        }

        public double getPeriod() {
            return period;
        }

        public void setPeriod(double period) {
            this.period = period;
        }

        public double getDelay() {
            return delay;
        }

        public void setDelay(double delay) {
            this.delay = delay;
        }

        @Override
        public String toString() {
            return String.format(
                    "PeriodicTask{name='%s', priority=%d, period=%.2f, delay=%.2f}", name, priority, period, delay);
        }
    }

    public static class SoftwareTask extends AscetTask {
        public SoftwareTask(String name) {
            super(name);
        }
    }

    public static class TimeTableTask extends AscetTask {
        public TimeTableTask(String name) {
            super(name);
        }
    }

    /**
     * Transformation result container.
     */
    public static class TransformationResult {
        private final AscetTask ascetTask;
        private final int selectedOption;
        private final String transformationType;

        public TransformationResult(AscetTask ascetTask, int selectedOption, String transformationType) {
            this.ascetTask = ascetTask;
            this.selectedOption = selectedOption;
            this.transformationType = transformationType;
        }

        public AscetTask getAscetTask() {
            return ascetTask;
        }

        public int getSelectedOption() {
            return selectedOption;
        }

        public String getTransformationType() {
            return transformationType;
        }

        @Override
        public String toString() {
            return String.format(
                    "TransformationResult{option=%d, type='%s', result=%s}",
                    selectedOption, transformationType, ascetTask);
        }
    }

    /**
     * Transform an Amathaea task to an ASCET task based on user selection.
     *
     * This method contains business logic with integrated symbolic execution support.
     * When userSelection values are tagged with Galette, path constraints are automatically
     * collected during switch statement evaluation for concolic execution analysis.
     *
     * @param amathaeaTask The source Amathaea task model
     * @param userSelection The user choice (0-4) for task type (may be Galette-tagged)
     * @return Transformation result with created ASCET task or null if no action
     */
    public static TransformationResult transform(AmathaeaTask amathaeaTask, int userSelection) {
        // Apply transformation logic based on user selection
        // This switch statement is where path constraints are collected when userSelection is symbolic
        AscetTask result = applyTransformationRules(amathaeaTask, userSelection);

        if (result != null) {
            // Copy common properties
            result.setName(amathaeaTask.getName());

            // Apply specific transformations based on type
            applyTaskSpecificLogic(result, amathaeaTask);
        }

        return new TransformationResult(result, userSelection, getTransformationType(userSelection));
    }

    /**
     * Apply transformation rules based on user selection using symbolic execution wrapper.
     */
    private static AscetTask applyTransformationRules(AmathaeaTask source, int userSelection) {
        // Use symbolic comparison to enable path constraint collection
        switch (userSelection) {
            case INTERRUPT_TASK:
                return new InterruptTask(source.getName());
            case PERIODIC_TASK:
                return new PeriodicTask(source.getName());
            case SOFTWARE_TASK:
                return new SoftwareTask(source.getName());
            case TIMETABLE_TASK:
                return new TimeTableTask(source.getName());
            case DECIDE_LATER:
                return null; // No action
            default:
                System.err.println("Invalid user selection: " + userSelection);
                return null;
        }
    }

    /**
     * Apply task-specific transformations.
     */
    private static void applyTaskSpecificLogic(AscetTask ascetTask, AmathaeaTask amathaeaTask) {
        // For PeriodicTask, set default timing values
        if (ascetTask instanceof PeriodicTask) {
            PeriodicTask periodicTask = (PeriodicTask) ascetTask;
            periodicTask.setPeriod(10.0); // Default 10ms period
            periodicTask.setDelay(0.0); // No delay
        }

        // Set priority based on preemption mode
        if ("preemptive".equals(amathaeaTask.getPreemption())) {
            ascetTask.setPriority(10); // Higher priority for preemptive tasks
        } else {
            ascetTask.setPriority(1); // Lower priority for cooperative tasks
        }
    }

    /**
     * Get transformation type description.
     */
    private static String getTransformationType(int userSelection) {
        switch (userSelection) {
            case INTERRUPT_TASK:
                return "Interrupt Task Creation";
            case PERIODIC_TASK:
                return "Periodic Task Creation";
            case SOFTWARE_TASK:
                return "Software Task Creation";
            case TIMETABLE_TASK:
                return "TimeTable Task Creation";
            case DECIDE_LATER:
                return "Deferred Decision";
            default:
                return "Invalid Selection";
        }
    }

    /**
     * Interactive transformation that prompts user for selection.
     */
    public static TransformationResult transformInteractive(AmathaeaTask amathaeaTask) {
        Scanner scanner = new Scanner(System.in);

        System.out.println("\n=== Amathaea-ASCET Model Transformation ===");
        System.out.println("Source Amathaea task: " + amathaeaTask);
        System.out.println("\nPlease select the target ASCET task type:");
        System.out.println("0: Create InterruptTask");
        System.out.println("1: Create PeriodicTask");
        System.out.println("2: Create SoftwareTask");
        System.out.println("3: Create TimeTableTask");
        System.out.println("4: Decide Later");
        System.out.print("Enter your choice (0-4): ");

        int selection = scanner.nextInt();

        System.out.println("Transforming with user selection: " + selection);
        TransformationResult result = transform(amathaeaTask, selection);

        System.out.println("Transformation complete.");
        if (result.getAscetTask() != null) {
            System.out.println("Created: " + result.getAscetTask());
        } else {
            System.out.println("No task created (decision deferred)");
        }

        scanner.close();
        return result;
    }

    /**
     * Batch transformation for testing multiple selections.
     */
    public static TransformationResult[] transformBatch(AmathaeaTask amathaeaTask, int[] selections) {
        TransformationResult[] results = new TransformationResult[selections.length];

        for (int i = 0; i < selections.length; i++) {
            results[i] = transform(amathaeaTask, selections[i]);
        }

        return results;
    }

    /**
     * Validate transformation inputs.
     */
    public static boolean isValidSelection(int selection) {
        return selection >= 0 && selection <= 4;
    }

    /**
     * Get a summary of the transformation results.
     */
    public static String getTransformationSummary(AmathaeaTask source, TransformationResult result) {
        return String.format(
                "Amathaea-ASCET Transformation Summary:\n" + "  Input: %s\n"
                        + "  User Selection: %d (%s)\n"
                        + "  Output: %s\n"
                        + "  Transformation Applied: %s",
                source.toString(),
                result.getSelectedOption(),
                getTransformationType(result.getSelectedOption()),
                result.getAscetTask() != null ? result.getAscetTask().toString() : "No task created",
                result.getTransformationType());
    }

    /**
     * Simulate the Vitruvius userInteractor dialog selection.
     * This method mimics the behavior from templateReactions.reactions.
     */
    public static class UserInteractionSimulator {

        public static String[] getTaskOptions() {
            return new String[] {
                "Create InterruptTask",
                "Create PeriodicTask",
                "Create SoftwareTask",
                "Create TimeTableTask",
                "Decide Later"
            };
        }

        public static int simulateUserSelection(String message, String[] options) {
            System.out.println("\n" + message);
            for (int i = 0; i < options.length; i++) {
                System.out.println(i + ": " + options[i]);
            }

            // In real Vitruvius, this would be:
            // userInteractor.singleSelectionDialogBuilder.message(message).choices(options).startInteraction()

            Scanner scanner = new Scanner(System.in);
            System.out.print("Enter your selection: ");
            return scanner.nextInt();
        }
    }
}
