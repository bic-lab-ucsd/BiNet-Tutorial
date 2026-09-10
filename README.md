# BiNet Tutorial

BiNet (Bilingual Interactional Network) combines language-experience measures with personal network methods. This repository contains the survey protocol and a reproducible, real-data walkthrough accompanying the BiNet manuscript.

The code, data, numerical examples, and figures now use one consistent deidentified Mandarin–English respondent, `jefwan37`, throughout. The walkthrough follows the same 15 alters and 21 alter–alter ties from binary survey indicators to compositional measures and network visualization.

## Start here

1. [Preprocessing and compositional measures](BiNet_preprocessing_compositional_Measures/BiNet_preprocessing_tutorial.md)
2. [Network visualization](BiNet_Network_Visualization/BiNet_network_visualization.md)
3. [BiNet questionnaire](BiNet_Questionnaire/)
4. [Structural measures (archived)](https://github.com/bic-lab-ucsd/BiNet-Tutorial/tree/archive/structural-measures-before-removal-2026-09-09/BiNet_Structural_Measures)

The main worked-example results are:

| Quantity | Result |
|---|---:|
| Alters | 15 |
| Alter–alter ties | 21 |
| Mandarin-only interaction dyads | 3 |
| English-only interaction dyads | 5 |
| Mandarin–English interaction dyads | 7 |
| `cs_global` | 1.53 |
| `mandarin_global_prop` | 0.20 |
| `prop_l1_homophily` | 0.67 |
| `prop_l2_homophily` | 0.80 |

For this respondent, L1 is Mandarin and L2 is English. A bilingual dyad contributes to both L1 and L2 homophily.

## Repository structure

```text
BiNet_Questionnaire/
  NetworkCanvasProtocol_BiNet_20260417 Protocol Summary.pdf
  NetworkCanvasProtocol_BiNet_20260417.netcanvas

BiNet_preprocessing_compositional_Measures/
  BiNet_preprocessing_tutorial.qmd
  BiNet_preprocessing_tutorial.md
  BiNet_preprocessing_tutorial.html
  code/reproduce_jefwan37_measures.R
  data/
    jefwan37_raw_flags.csv
    jefwan37_tidy_alter.csv
    jefwan37_alter_edges.csv
    jefwan37_ego_compositional_wide.csv
    jefwan37_quality_checks.json
  figures/
    fig04_real_input_overview_all_data.png
    fig05_real_language_recode_jefwan37.png
    fig06_real_context_recode_jefwan37.png
    fig07_real_composition_jefwan37.png
  excel/BiNet_jefwan37_real_data_walkthrough.xlsx

BiNet_Network_Visualization/
  BiNet_network_visualization.qmd
  BiNet_network_visualization.md
  BiNet_network_visualization.html
  code/generate_jefwan37_network.R
  figures/fig08_network_views_jefwan37.png
```

The `dataset_overview_*` files in the preprocessing data directory provide the deidentified multi-participant samples displayed in manuscript Figure 4. All participant-level calculations after that overview use `jefwan37`.

## Reproduce the analysis

The R script reads the included tidy alter table, applies the manuscript's analytic decisions, writes the wide ego-level output, and checks the expected values.

```bash
Rscript BiNet_preprocessing_compositional_Measures/code/reproduce_jefwan37_measures.R
```

Important coding decisions:

- Mandarin-only and English-only dyads contribute `0` to code-switching means.
- Mandarin–English dyads retain their reported 1–4 code-switching rating.
- A context-specific measure is `NA` only when the ego has no alters in that context; if alters are present but none meet a binary criterion, the proportion is `0`.
- Count-based composition measures use proportion names such as `mandarin_global_prop` and `mandarin_family_prop`.
- Homophily is mapped to each ego's L1/L2 profile and reported as `prop_l1_homophily` and `prop_l2_homophily`.

## Reproduce the network figure

```bash
Rscript BiNet_Network_Visualization/code/generate_jefwan37_network.R
```

The network figure uses base R and does not require additional packages.

The generated Figure 8 contains two views of the same observed network:

- Panel A: circular layout, language-use color, constant alter-node size.
- Panel B: context-organized layout, language-use color, and emotional-closeness node size.

## Questionnaire

The editable Network Canvas protocol and its PDF summary are in [`BiNet_Questionnaire/`](BiNet_Questionnaire/). Open the `.netcanvas` file with [Network Canvas Architect](https://networkcanvas.com/).

## Structural measures (archived)

Compositional measures describe who is in a personal network, whereas structural measures describe how relationships are organized within it. Structural measures can characterize, for example, whether language groups are separated or integrated and whether particular alters bridge them.

Structural measures are outside the scope of the current manuscript walkthrough, so they are not included on `main`. The earlier structural-measures tutorial, R code, custom `egoLangBetweenness` package, example data, and supporting files remain available in the [`archive/structural-measures-before-removal-2026-09-09` branch](https://github.com/bic-lab-ucsd/BiNet-Tutorial/tree/archive/structural-measures-before-removal-2026-09-09/BiNet_Structural_Measures). The archived materials can be restored or updated later without reconstructing them.

## Citation

> Li, J., Shen, Y., Maximous, C., & Beatty-Martínez, A. L. (2026). *Bilingual Interactional Network (BiNet) Tutorial: Quantifying bilingual language experience using network science tools* [Tutorial]. https://github.com/bic-lab-ucsd/BiNet-Tutorial

## Contact

Bilingualism in Context Lab, UC San Diego

https://github.com/bic-lab-ucsd

- Jiaze Li — jil472@ucsd.edu
- Yumeng Shen — yus099@ucsd.edu
- Catherine Maximous — cmaximous@ucsd.edu
- Anne L. Beatty-Martínez — abeattymartinez@ucsd.edu
