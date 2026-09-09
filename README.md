# BiNet-Tutorial
 
Tutorial for quantifying bilingual language experience using personal network science methods, including the BiNet (Bilingual Interactional Network) Survey, preprocessing pipeline, compositional measures, and network visualization.
 
**[Preprocessing & Compositional Measures Tutorial](https://github.com/bic-lab-ucsd/BiNet-Tutorial/blob/main/BiNet_preprocessing_compositional_Measures/BiNet_preprocessing_tutorial.md)** | **[Network Visualization Tutorial](https://github.com/bic-lab-ucsd/BiNet-Tutorial/blob/main/BiNet_Network_Visualization/BiNet_network_visualization.md)**
 
This project is developed in **R**. It covers the BiNet survey, preprocessing of raw [Network Canvas](https://networkcanvas.com/) exports, ego-level compositional measures of bilingual language experience, and network visualization, accompanying the manuscript on the BiNet survey methodology.
 
## Quick start
 
The tutorial is organized into three components, mirroring the structure of the manuscript.
 
### 1. BiNet: Bilingual Interactional Network Survey

The data collection instrument — a Network Canvas protocol that elicits an ego's social network and language use with each alter. 
The protocol files (both an editable `.netcanvas` version and a PDF summary) are available in [`BiNet_Questionnaire/`](https://github.com/bic-lab-ucsd/BiNet-Tutorial/tree/main/BiNet_Questionnaire)

```
BiNet_Questionnaire/
├── NetworkCanvasProtocol_BiNet_20260417 Protocol Summary.pdf  # PDF reference version
└── NetworkCanvasProtocol_BiNet_20260417.netcanvas             # Editable Network Canvas protocol
```
 
To view or edit the `.netcanvas` file, open it with the [Network Canvas Architect](https://networkcanvas.com/) desktop application.
 
### 2. Compositional Measures: What Makes Up the Network?
 
Clean raw Network Canvas exports, link them with Language History Questionnaire (LHQ) data, and compute ego-level compositional summaries (e.g., proportion of L1/L2 alters, language diversity). 

**[Open the preprocessing & compositional measures tutorial](https://github.com/bic-lab-ucsd/BiNet-Tutorial/blob/main/BiNet_preprocessing_compositional_Measures/BiNet_preprocessing_tutorial.md)**
 
- **Step 1.** Collapsing binary indicator columns into categorical variables
- **Step 2.** Constructing ego-level compositional measures

All the cleaning, linking, and compositional analysis of Network Canvas data are available in [`BiNet_preprocessing_compositional_Measures/`](https://github.com/bic-lab-ucsd/BiNet-Tutorial/tree/main/BiNet_preprocessing_compositional_Measures)

```
BiNet_preprocessing_compositional_Measures/
├── Network Canvas Export/                  # Raw exports from Network Canvas (demo dataset)
│   ├── *_ego.csv                           # ego-level data
│   ├── *_attributeList_People.csv          # alter-level data
│   └── *_edgeList_tie.csv                  # alter-alter ties
├── preprocessed_data/                      # Cleaned and linked analysis-ready files
│   ├── egoData_linked.csv                  # ego-level data joined with LHQ variables
│   ├── alterData_linked.csv                # cleaned alter-level attributes linked to ego IDs
│   └── edgelist_linked.csv                 # cleaned alter-alter edge list linked to ego IDs
├── Compositional measures/                 # Derived ego-level summaries of network composition
│   ├── binet_ego_compositional.csv         # Final ego-level compositional measures
│   ├── binet_egoData_linked.csv            # Ego-level dataset joined with compositional variables
│   └── binet_tidy_alter.csv                # Long-format alter dataset used for aggregation
├── demo_lhq.csv                            # demo LHQ dataset
└── BiNet_preprocessing_tutorial.qmd        # Main tutorial (Quarto source)
```

 
### 3. Network Visualization: What does the Network Look Like?

Visualize each ego's network with node color encoding language use and node size encoding ego-alter-level attributes (e.g., emotional closeness,
interaction frequency). Two visualization approaches are provided: a **Basic Network Plot** for quick inspection, and a **Contextualized Network Plot** that spatially groups alters by interaction context (Family, Community, Work, Social, School).
- **Step 1.** Build ego-centered `igraph` objects from preprocessed alter and edge data
- **Step 2.** Generate basic network plots (uniform circle layout, language color encoding)
- **Step 3.** Generate contextualized network plots (dynamic sector layout grouping alters by interaction context)
- **Step 4.** Export PNG files for all egos

All visualization functions and export scripts are available in [`BiNet_Network_Visualization/`](https://github.com/bic-lab-ucsd/BiNet-Tutorial/tree/main/BiNet_Network_Visualization)

```
BiNet_Network_Visualization/
├── figures_ego_networks/               # Exported network plots
│   ├── basic/                          # Basic circle-layout sociograms (one PNG per participant)
│   └── sector/                         # Context-sector sociograms (one PNG per participant)
└── BiNet_network_visualization.qmd     # Visualization tutorial (Quarto source)
```
> **Prerequisites.** This script loads output files produced by the preprocessing tutorial. Run `BiNet_preprocessing_compositional_Measures/BiNet_preprocessing_tutorial.qmd` first and confirm that `preprocessed_data/` and `Compositional measures/` are populated before running this script.


## Citation
 
If you use these materials in your research, please cite:
 
> [Li, J., Shen, Y., Maximous, C. & Beatty-Martínez, A. L. (2026). Bilingual Interactional Network (BiNet) Tutorial: Quantifying bilingual language experience using network science tools [Tutorial]. GitHub. https://github.com/bic-lab-ucsd/BiNet-Tutorial]
 
## Contact
Bilingualism in Context Lab, UC San Diego
[https://github.com/bic-lab-ucsd](https://github.com/bic-lab-ucsd)

For questions about this tutorial, please contact:
- **Jiaze Li** — [jil472@ucsd.edu]
- **Yumeng Shen** — [yus099@ucsd.edu]
- **Catherine Maximous** — [cmaximous@ucsd.edu]
- **Anne L. Beatty-Martínez** — [abeattymartinez@ucsd.edu]
