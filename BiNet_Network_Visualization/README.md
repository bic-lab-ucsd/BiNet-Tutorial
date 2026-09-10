# Network visualization

This directory reproduces manuscript Figure 8A/B for the same `jefwan37` network used in the preprocessing tutorial.

- Read [`BiNet_network_visualization.md`](BiNet_network_visualization.md) on GitHub.
- Edit or render [`BiNet_network_visualization.qmd`](BiNet_network_visualization.qmd) with Quarto.
- Run [`code/generate_jefwan37_network.R`](code/generate_jefwan37_network.R) to regenerate the combined network figure.

The base-R script reads the 15-node alter table and 21-edge alter–alter tie table from `../BiNet_preprocessing_compositional_Measures/data/`. Panel A is a circular view with constant node size. Panel B places alters by interaction context and scales node size by emotional closeness. No Python installation or additional R package is required.
