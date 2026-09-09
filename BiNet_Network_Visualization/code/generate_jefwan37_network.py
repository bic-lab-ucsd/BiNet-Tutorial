#!/usr/bin/env python3
"""Reproduce manuscript Figure 8 from the included jefwan37 data."""

from pathlib import Path
import math

import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
import pandas as pd


HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]
DATA_DIR = REPO / "BiNet_preprocessing_compositional_Measures" / "data"
OUT_DIR = HERE.parent / "figures"

LANGUAGE_COLORS = {
    "Mandarin": "#E43D30",
    "English": "#2E628E",
    "Mandarin-English": "#A9CBE8",
}
CONTEXT_RANGES = {
    "family": (100, 178),
    "social": (12, 80),
    "community": (205, 255),
    "school": (285, 335),
}


def circle_positions(labels, radius=0.83):
    return {
        label: (
            radius * math.cos(math.pi / 2 + 2 * math.pi * i / len(labels)),
            radius * math.sin(math.pi / 2 + 2 * math.pi * i / len(labels)),
        )
        for i, label in enumerate(labels)
    }


def context_positions(alters):
    positions = {}
    for context, (low, high) in CONTEXT_RANGES.items():
        labels = alters.loc[alters.interaction_context == context, "alter_label"].tolist()
        degrees = [(low + high) / 2] if len(labels) == 1 else [
            low + (high - low) * i / (len(labels) - 1) for i in range(len(labels))
        ]
        for i, (label, degree) in enumerate(zip(labels, degrees)):
            radius = 0.76 if i % 2 == 0 else 1.05
            angle = math.radians(degree)
            positions[label] = (radius * math.cos(angle), radius * math.sin(angle))
    return positions


def draw_panel(ax, alters, edges, positions, scale_closeness, show_contexts=False):
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_xlim(-1.25, 1.25)
    ax.set_ylim(-1.18, 1.18)

    if show_contexts:
        ax.axhline(0, color="#D4D4D4", linewidth=1.2, zorder=0)
        ax.axvline(0, color="#D4D4D4", linewidth=1.2, zorder=0)
        ax.text(-0.88, 1.08, "FAMILY", ha="center", weight="bold")
        ax.text(0.88, 1.08, "SOCIAL", ha="center", weight="bold")
        ax.text(-0.88, -1.08, "COMMUNITY", ha="center", weight="bold")
        ax.text(0.88, -1.08, "SCHOOL", ha="center", weight="bold")

    for row in edges.itertuples(index=False):
        x1, y1 = positions[row.source]
        x2, y2 = positions[row.target]
        ax.plot([x1, x2], [y1, y2], color="#A0A0A0", linewidth=1.2,
                linestyle=(0, (4, 4)), zorder=1)

    for row in alters.itertuples(index=False):
        x, y = positions[row.alter_label]
        ax.plot([0, x], [0, y], color="#303030", linewidth=1.1, zorder=1)
        size = 120 + 115 * row.emotional_closeness if scale_closeness else 360
        ax.scatter(x, y, s=size, color=LANGUAGE_COLORS[row.languageUsedCategory],
                   edgecolor="#202020", linewidth=1.1, zorder=3)

    ax.scatter(0, 0, s=400, color="white", edgecolor="#202020", linewidth=1.4, zorder=4)
    ax.text(0, 0, "Ego", ha="center", va="center", fontsize=9, zorder=5)


def main():
    alters = pd.read_csv(DATA_DIR / "jefwan37_tidy_alter.csv")
    edges = pd.read_csv(DATA_DIR / "jefwan37_alter_edges.csv")
    assert len(alters) == 15 and len(edges) == 21

    fig, (left, right) = plt.subplots(1, 2, figsize=(11.6, 6.8), facecolor="white")
    draw_panel(left, alters, edges, circle_positions(alters.alter_label.tolist()), False)
    draw_panel(right, alters, edges, context_positions(alters), True, True)
    left.set_title("A", loc="left", weight="bold", fontsize=15)
    right.set_title("B", loc="left", weight="bold", fontsize=15)

    language_handles = [
        Line2D([0], [0], marker="o", linestyle="", markerfacecolor=color,
               markeredgecolor="#202020", markersize=10, label=label)
        for label, color in LANGUAGE_COLORS.items()
    ]
    tie_handles = [
        Line2D([0, 1], [0, 0], color="#303030", label="Ego-alter tie"),
        Line2D([0, 1], [0, 0], color="#A0A0A0", linestyle=(0, (4, 4)),
               label="Alter-alter tie"),
    ]
    first_legend = fig.legend(handles=language_handles, loc="lower center", ncol=3,
                              frameon=False, bbox_to_anchor=(0.5, 0.075))
    fig.add_artist(first_legend)
    fig.legend(handles=tie_handles, loc="lower center", ncol=2, frameon=False,
               bbox_to_anchor=(0.5, 0.025))
    fig.subplots_adjust(left=0.03, right=0.97, top=0.95, bottom=0.18, wspace=0.08)

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    output = OUT_DIR / "fig08_network_views_jefwan37.png"
    fig.savefig(output, dpi=300, facecolor="white")
    plt.close(fig)
    print(output)


if __name__ == "__main__":
    main()
