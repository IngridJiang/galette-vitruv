#!/usr/bin/env python3
"""
Visualize the Galette/Vitruvius symbolic execution workflow.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
import sys

def create_workflow_diagram(output_file='workflow_diagram.png'):
    """Create a visual diagram of the symbolic execution workflow."""

    fig, ax = plt.subplots(1, 1, figsize=(14, 10))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 12)
    ax.axis('off')

    # Colors
    color_galette = '#FF6B6B'      # Red - Galette components
    color_vitruvius = '#4ECDC4'    # Teal - Vitruvius components
    color_output = '#95E1D3'       # Light teal - Outputs
    color_flow = '#333333'         # Dark - Flow arrows

    # Title
    ax.text(5, 11.5, 'Galette/Knarr Symbolic Execution with Vitruvius',
            ha='center', va='center', fontsize=18, fontweight='bold')
    ax.text(5, 11, 'Model Transformation Framework Integration',
            ha='center', va='center', fontsize=12, style='italic')

    # Step 1: Initialize
    box1 = FancyBboxPatch((0.5, 9.5), 4, 1,
                          boxstyle="round,pad=0.1",
                          edgecolor=color_galette,
                          facecolor=color_galette,
                          alpha=0.3, linewidth=2)
    ax.add_patch(box1)
    ax.text(2.5, 10, '1. Initialize Galette Symbolic Execution',
            ha='center', va='center', fontsize=10, fontweight='bold')
    ax.text(2.5, 9.7, 'GaletteSymbolicator.reset()',
            ha='center', va='center', fontsize=8, family='monospace')

    # Step 2: Create symbolic tag
    box2 = FancyBboxPatch((0.5, 8), 4, 1,
                          boxstyle="round,pad=0.1",
                          edgecolor=color_galette,
                          facecolor=color_galette,
                          alpha=0.3, linewidth=2)
    ax.add_patch(box2)
    ax.text(2.5, 8.5, '2. Create Symbolic Tag',
            ha='center', va='center', fontsize=10, fontweight='bold')
    ax.text(2.5, 8.25, 'makeSymbolicInt("user_choice", value)',
            ha='center', va='center', fontsize=8, family='monospace')

    # Arrow 1->2
    arrow1 = FancyArrowPatch((2.5, 9.5), (2.5, 9.0),
                            arrowstyle='->', mutation_scale=20,
                            linewidth=2, color=color_flow)
    ax.add_patch(arrow1)

    # Step 3: Tag the value
    box3 = FancyBboxPatch((0.5, 6.5), 4, 1,
                          boxstyle="round,pad=0.1",
                          edgecolor=color_galette,
                          facecolor=color_galette,
                          alpha=0.3, linewidth=2)
    ax.add_patch(box3)
    ax.text(2.5, 7, '3. Apply Tag to Value (KEY STEP!)',
            ha='center', va='center', fontsize=10, fontweight='bold')
    ax.text(2.5, 6.75, 'Tainter.setTag(value, symbolicTag)',
            ha='center', va='center', fontsize=8, family='monospace')

    # Arrow 2->3
    arrow2 = FancyArrowPatch((2.5, 8.0), (2.5, 7.5),
                            arrowstyle='->', mutation_scale=20,
                            linewidth=2, color=color_flow)
    ax.add_patch(arrow2)

    # Step 4: Pass to Vitruvius
    box4 = FancyBboxPatch((5.5, 9), 4, 1.5,
                          boxstyle="round,pad=0.1",
                          edgecolor=color_vitruvius,
                          facecolor=color_vitruvius,
                          alpha=0.3, linewidth=2)
    ax.add_patch(box4)
    ax.text(7.5, 9.9, '4. Execute Vitruvius Transformation',
            ha='center', va='center', fontsize=10, fontweight='bold')
    ax.text(7.5, 9.5, 'Test.insertTask(workDir, taggedValue)',
            ha='center', va='center', fontsize=8, family='monospace')
    ax.text(7.5, 9.2, 'Tagged value flows through naturally!',
            ha='center', va='center', fontsize=7, style='italic')

    # Arrow 3->4
    arrow3 = FancyArrowPatch((4.5, 7.0), (5.5, 9.5),
                            arrowstyle='->', mutation_scale=20,
                            linewidth=2, color=color_flow)
    ax.add_patch(arrow3)

    # Step 5: Reactions switch statement
    box5 = FancyBboxPatch((5.5, 7), 4, 1.5,
                          boxstyle="round,pad=0.1",
                          edgecolor=color_vitruvius,
                          facecolor=color_vitruvius,
                          alpha=0.3, linewidth=2)
    ax.add_patch(box5)
    ax.text(7.5, 8.0, '5. Reactions Switch Statement',
            ha='center', va='center', fontsize=10, fontweight='bold')
    ax.text(7.5, 7.6, 'switch(userChoice) { ... }',
            ha='center', va='center', fontsize=8, family='monospace')
    ax.text(7.5, 7.3, 'Galette automatically collects constraints!',
            ha='center', va='center', fontsize=7, style='italic')

    # Arrow 4->5
    arrow4 = FancyArrowPatch((7.5, 9.0), (7.5, 8.5),
                            arrowstyle='->', mutation_scale=20,
                            linewidth=2, color=color_flow)
    ax.add_patch(arrow4)

    # Step 6: Path constraints
    box6 = FancyBboxPatch((0.5, 5), 4, 1,
                          boxstyle="round,pad=0.1",
                          edgecolor=color_galette,
                          facecolor=color_galette,
                          alpha=0.3, linewidth=2)
    ax.add_patch(box6)
    ax.text(2.5, 5.5, '6. Collect Path Constraints',
            ha='center', va='center', fontsize=10, fontweight='bold')
    ax.text(2.5, 5.25, 'PathUtils.getCurPC()',
            ha='center', va='center', fontsize=8, family='monospace')

    # Arrow 5->6
    arrow5 = FancyArrowPatch((5.5, 7.5), (4.5, 5.5),
                            arrowstyle='->', mutation_scale=20,
                            linewidth=2, color=color_flow)
    ax.add_patch(arrow5)

    # Step 7: Model transformation
    box7 = FancyBboxPatch((5.5, 5), 4, 1,
                          boxstyle="round,pad=0.1",
                          edgecolor=color_vitruvius,
                          facecolor=color_vitruvius,
                          alpha=0.3, linewidth=2)
    ax.add_patch(box7)
    ax.text(7.5, 5.5, '7. Generate Model Transformation',
            ha='center', va='center', fontsize=10, fontweight='bold')
    ax.text(7.5, 5.25, 'VSUM.save() -> vsum-output.xmi',
            ha='center', va='center', fontsize=8, family='monospace')

    # Arrow 5->7
    arrow6 = FancyArrowPatch((7.5, 7.0), (7.5, 6.0),
                            arrowstyle='->', mutation_scale=20,
                            linewidth=2, color=color_flow)
    ax.add_patch(arrow6)

    # Outputs section
    ax.text(5, 3.8, 'OUTPUTS', ha='center', va='center',
            fontsize=12, fontweight='bold')

    # Output boxes
    output_boxes = [
        ('galette-output-0/', 'InterruptTask', 0.5),
        ('galette-output-1/', 'PeriodicTask', 2.2),
        ('galette-output-2/', 'SoftwareTask', 3.9),
        ('galette-output-3/', 'TimeTableTask', 5.6),
        ('galette-output-4/', 'Decide Later', 7.3),
    ]

    y_pos = 2.5
    for folder, task_type, x_pos in output_boxes:
        box = FancyBboxPatch((x_pos, y_pos), 1.5, 0.8,
                             boxstyle="round,pad=0.05",
                             edgecolor=color_output,
                             facecolor=color_output,
                             alpha=0.5, linewidth=1.5)
        ax.add_patch(box)
        ax.text(x_pos + 0.75, y_pos + 0.55, folder,
                ha='center', va='center', fontsize=7, fontweight='bold')
        ax.text(x_pos + 0.75, y_pos + 0.25, task_type,
                ha='center', va='center', fontsize=6, style='italic')

    # Arrows to outputs
    for i, (_, _, x_pos) in enumerate(output_boxes):
        arrow = FancyArrowPatch((2.5 if i < 3 else 7.5, 5.0),
                               (x_pos + 0.75, 3.3),
                               arrowstyle='->', mutation_scale=15,
                               linewidth=1, color=color_flow, alpha=0.5)
        ax.add_patch(arrow)

    # Legend
    legend_y = 1.5
    ax.text(1, legend_y + 0.5, 'KEY CONCEPTS:', fontsize=10, fontweight='bold')

    # Galette legend
    legend_box1 = mpatches.Rectangle((0.5, legend_y), 0.3, 0.3,
                                     facecolor=color_galette, alpha=0.3,
                                     edgecolor=color_galette, linewidth=2)
    ax.add_patch(legend_box1)
    ax.text(1.0, legend_y + 0.15, 'Galette/Knarr Components',
            ha='left', va='center', fontsize=8)

    # Vitruvius legend
    legend_box2 = mpatches.Rectangle((0.5, legend_y - 0.5), 0.3, 0.3,
                                     facecolor=color_vitruvius, alpha=0.3,
                                     edgecolor=color_vitruvius, linewidth=2)
    ax.add_patch(legend_box2)
    ax.text(1.0, legend_y - 0.35, 'Vitruvius Framework',
            ha='left', va='center', fontsize=8)

    # Output legend
    legend_box3 = mpatches.Rectangle((0.5, legend_y - 1.0), 0.3, 0.3,
                                     facecolor=color_output, alpha=0.5,
                                     edgecolor=color_output, linewidth=1.5)
    ax.add_patch(legend_box3)
    ax.text(1.0, legend_y - 0.85, 'Generated Outputs',
            ha='left', va='center', fontsize=8)

    # Key insight box
    insight_box = FancyBboxPatch((5, 0.2), 4.5, 1,
                                boxstyle="round,pad=0.1",
                                edgecolor='#FFD700',
                                facecolor='#FFFACD',
                                alpha=0.8, linewidth=2)
    ax.add_patch(insight_box)
    ax.text(7.25, 0.9, 'NO HARDCODED TRANSFORMATION LOGIC!',
            ha='center', va='center', fontsize=9, fontweight='bold', color='#8B4513')
    ax.text(7.25, 0.6, 'All transformation logic in templateReactions.reactions',
            ha='center', va='center', fontsize=7, style='italic')
    ax.text(7.25, 0.35, 'Galette tags flow through, constraints auto-collected',
            ha='center', va='center', fontsize=7, style='italic')

    plt.tight_layout()
    plt.savefig(output_file, dpi=300, bbox_inches='tight', facecolor='white')
    print(f"Workflow diagram saved to: {output_file}")

    return fig

if __name__ == '__main__':
    create_workflow_diagram()
