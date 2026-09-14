# Preprocessing and compositional measures

This directory contains the detailed `jefwan37` Mandarin–English walkthrough used in the manuscript. The tutorial retains the reusable Network Canvas batch-import, LHQ merge, linked-data audit, recoding, and compositional-measure workflow.

- Read [`BiNet_preprocessing_tutorial.md`](BiNet_preprocessing_tutorial.md) on GitHub.
- Edit or render [`BiNet_preprocessing_tutorial.qmd`](BiNet_preprocessing_tutorial.qmd) with Quarto.
- Run [`code/reproduce_jefwan37_measures.R`](code/reproduce_jefwan37_measures.R) to link the source files, write the tidy alter and alter-edge visualization inputs, and reproduce the one-row output.
- Inspect [`excel/BiNet_jefwan37_real_data_walkthrough.xlsx`](excel/BiNet_jefwan37_real_data_walkthrough.xlsx) for a spreadsheet version of the same source-to-output trail.

All participant-level examples in the tutorial use the same 15 deidentified alters. The `dataset_overview_*` files are limited to the multi-participant input overview shown in manuscript Figure 4.

The runnable merge example reads `data/jefwan37_lhq.csv`, `data/jefwan37_raw_flags.csv`, and `data/jefwan37_raw_edges.csv`. It writes `data/jefwan37_tidy_alter.csv` and `data/jefwan37_alter_edges.csv` for the visualization tutorial. The tutorial also shows how to apply the same steps to a folder of raw Network Canvas ego, alter, and tie exports.

Expected focal results: `cs_global = 1.53`, `mandarin_global_prop = 0.20`, `prop_l1_homophily = 0.67`, and `prop_l2_homophily = 0.80`.
