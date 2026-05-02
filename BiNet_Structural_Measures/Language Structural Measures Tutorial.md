# BiNet Structural Measures Guideline
Zoey Li
2026-04-30

- [Language Structural Measures
  Guideline](#language-structural-measures-guideline)
  - [Package dependencies and version
    requirements](#package-dependencies-and-version-requirements)
- [1. egoLangBetweenness](#1-egolangbetweenness)
  - [1.1 Overview](#11-overview)
  - [1.2 Installation](#12-installation)
  - [1.3 Usage](#13-usage)
    - [Example data](#example-data)
    - [Step 1: load preprocessed dataset and
      package](#step-1-load-preprocessed-dataset-and-package)
    - [Step 2: Compute ego language
      betweenness](#step-2-compute-ego-language-betweenness)
    - [Step 3: Inspect the output](#step-3-inspect-the-output)
- [2. Language E-I Index](#2-language-e-i-index)
  - [2.1 Overview](#21-overview)
  - [2.2 Usage](#22-usage)
    - [Example data](#example-data-1)
    - [Step 1: load preprocessed
      dataset](#step-1-load-preprocessed-dataset)
    - [Step 2: Build the egor object](#step-2-build-the-egor-object)
    - [Step 3: Compute E-I Index](#step-3-compute-e-i-index)
  - [Combine and Save the Results](#combine-and-save-the-results)

# Language Structural Measures Guideline

## Package dependencies and version requirements

This guideline relies on the R packages \`egor\` and \`igraph\` for
network construction and computation.  
  
To ensure reproducibility and consistency of results, we recommend using
the following versions:  
- egor (\>= 1.25.10)  
- igraph (\>= 2.3.0)  
  
For full reproducibility, it is strongly recommended to use the exact
versions:  
- egor (= 1.25.10)  
- igraph (= 2.3.0)

Users can check their installed package versions using:
packageVersion(“egor”) packageVersion(“igraph”)

``` r
packageVersion("egor") 
```

    [1] '1.25.10'

``` r
packageVersion("igraph")
```

    [1] '2.3.0'

# 1. egoLangBetweenness

Compute ego language betweenness from personal network data.

This package provides tools to quantify how often an ego serves as a
bridge between alters from different language communities within an ego
network.

------------------------------------------------------------------------

## 1.1 Overview

In bilingualism research, language use is often embedded in social
networks. Individuals interact with people who may differ in their
language preferences, and these patterns shape opportunities for
code-switching and language control.

**Ego language betweenness** (Tiv et al., 2022) captures the extent to
which an individual (ego) connects otherwise separated language
communities in their personal network.

Conceptually, this measure answers:

> *How often does the ego lie on shortest paths between alters from
> different language communities?*

- A value of **0** indicates that the ego does not bridge across
  language communities

- Higher values indicate that the ego is a central connector across
  communities

  [**Try the interactive
  example**](https://bic-lab-ucsd.github.io/PNS-Tutorial/BiNet_Structural_Measures/ego_betweenness_interactive_example.html) —
  play with the network to see how the score is computed step by step.

This measure complements existing indices such as language entropy by
focusing on **network structure rather than usage proportions**.

------------------------------------------------------------------------

## 1.2 Installation

To use the package, you need to install the development version from
GitHub on R:

``` r
# Install devtools package if you never installed this before
if(!"devtools" %in% rownames(installed.packages())) install.packages("devtools")

# Install the development version from github
devtools::install_github("bic-lab-ucsd/BiNet-Tutorial", 
                         subdir = "BiNet_Structural_Measures/betweenness_package",
                         force = TRUE)
```

    rlang    (1.1.7 -> 1.2.0) [CRAN]
    glue     (1.8.0 -> 1.8.1) [CRAN]
    cli      (3.6.5 -> 3.6.6) [CRAN]
    magrittr (2.0.3 -> 2.0.5) [CRAN]
    tibble   (3.3.0 -> 3.3.1) [CRAN]
    purrr    (1.1.0 -> 1.2.2) [CRAN]

    package 'rlang' successfully unpacked and MD5 sums checked

    package 'glue' successfully unpacked and MD5 sums checked

    package 'cli' successfully unpacked and MD5 sums checked

    package 'magrittr' successfully unpacked and MD5 sums checked

    package 'tibble' successfully unpacked and MD5 sums checked

    package 'purrr' successfully unpacked and MD5 sums checked


    The downloaded binary packages are in
        C:\Users\Zoey\AppData\Local\Temp\RtmpqOeNaf\downloaded_packages
    ── R CMD build ─────────────────────────────────────────────────────────────────

    * checking for file 'C:\Users\Zoey\AppData\Local\Temp\RtmpqOeNaf\remotes8c381114bbf\bic-lab-ucsd-PNS-Tutorial-0bb9768\BiNet_Structural_Measures\betweenness_package/DESCRIPTION' ... OK
    * preparing 'egoLangBetweenness':
    * checking DESCRIPTION meta-information ... OK
    * checking for LF line-endings in source and make files and shell scripts
    * checking for empty or unneeded directories
    * building 'egoLangBetweenness_0.0.0.9000.tar.gz'

## 1.3 Usage

This package works on ego-network data. It assumes that the input data
have been preprocessed, such that each alter is already assigned to a
language category (e.g., `languageUsedCategory`). For example, users can
refer to[preprocessing
pipeline](https://github.com/bic-lab-ucsd/PNS-Tutorial/blob/main/BiNet_preprocessing_compositional_Measures/BiNet_preprocessing_tutorial.md)
for a workflow

The input typically consists of:

- `ego` → defines **who the participants are**
- `alter` → defines **who is in each ego’s network + their attributes**
- `edges` → defines **how alters are connected to each other**

To compute ego language betweenness, the dataset must minimally include
the variables listed in the table below:

| Dataset | Variable | Description | Role in analysis |
|----|----|----|----|
| **ego** | `networkCanvasEgoUUID` | Unique identifier for each ego | Used to define and iterate over ego networks |
| **ego** | `ego_id` | Unique participant identifier | Unique identifier for each participant, used to integrate network science questionnaire data with additional questionnaires and experimental data. |
| **alter** | `networkCanvasEgoUUID` | Ego ID for each alter | Links alters to their ego |
| **alter** | `networkCanvasUUID` | Unique identifier for each alter | Node identifier in the network |
| **alter** | `languageUsedCategory` | Language community (e.g., English, Spanish, Bilingual) | Defines community membership for betweenness |
| **edges** | `networkCanvasEgoUUID` | Ego ID for each edge | Ensures edges are within the same network |
| **edges** | `networkCanvasSourceUUID` | Source alter ID | Defines edge (node–node connection) |
| **edges** | `networkCanvasTargetUUID` | Target alter ID | Defines edge (node–node connection) |

### Example data

Below is an example using demo data included in the package. Suppose we
have ten ego networks, where alters are categorized as `"English"`,
`"Spanish"`, or `"Spanish-English"`.

### Step 1: load preprocessed dataset and package

``` r
# Folder where the preprocessed CSVs are stored
input_dir <- "./preprocessed_data"

egoData_linked <- readr::read_csv(
  file.path(input_dir, "egoData_linked.csv"),
  show_col_types = FALSE
)

alterData_linked <- readr::read_csv(
  file.path(input_dir, "alterData_linked.csv"),
  show_col_types = FALSE
)

edgelist_linked <- readr::read_csv(
  file.path(input_dir, "edgelist_linked.csv"),
  show_col_types = FALSE
)

cat("Reloaded preprocessed data from:", normalizePath(input_dir), "\n")
```

    Reloaded preprocessed data from: C:\Users\Zoey\OneDrive - UC San Diego (1)\Documents - Bilingualism in Context Lab\PNS Tutorial\BiNet_Structural_Measures\preprocessed_data 

``` r
cat(" - egoData_linked   (", nrow(egoData_linked),   "rows )\n")
```

     - egoData_linked   ( 9 rows )

``` r
cat(" - alterData_linked (", nrow(alterData_linked), "rows )\n")
```

     - alterData_linked ( 135 rows )

``` r
cat(" - edgelist_linked  (", nrow(edgelist_linked),  "rows )\n")
```

     - edgelist_linked  ( 247 rows )

Load the necessary packages. This includes the core network analysis
package <u>**igraph, egor**</u> and the **egoLangBetweenness** package.

``` r
# Install egor package if you never installed this before
if(!"egor" %in% rownames(installed.packages())) install.packages("egor")
if(!"igraph" %in% rownames(installed.packages())) install.packages("egor")

library(igraph)
library(egor)
library(egoLangBetweenness)
```

### Step 2: Compute ego language betweenness

We compute ego language betweenness for each ego network using the
function  
`ego_language_betweenness_dataset()`.

This function takes three dataframes as input:

- `ego_df`: ego-level data (participants)

- `alter_df`: alter-level data (network members + language category)

- `edge_df`: edge-level data (connections between alters)

``` r
betweenness_df <- ego_language_betweenness_dataset(
  ego_df = egoData_linked,
  alter_df = alterData_linked,
  edge_df = edgelist_linked
)
```

This step automatically:

- Constructs an ego network for each participant

- Identifies language communities based on `languageUsedCategory`

- Computes shortest paths between alters

- Calculates how often the ego lies on shortest paths **between alters
  from different language communities**

### Step 3: Inspect the output

The resulting dataframe contains one row per ego:

``` r
print(betweenness_df)
```

                      networkCanvasEgoUUID language_betweenness n_valid_pairs
    1 06029b97-694c-41b8-807e-4cb07dca16a8              0.00000             0
    2 22e0f2c8-ddde-4271-bb6b-e9ec7fa6da6b             23.20000            56
    3 28202870-0e8a-4600-9434-c280eff762cd              0.00000             0
    4 4bc7e51b-a8af-4881-982e-12cfb2b1e9e3              0.00000             0
    5 82d2ef44-8636-4214-ba7b-4694793321d2             39.75000            75
    6 96f49992-a293-45b1-bd84-ccedf42d66fc             41.41667            75
    7 aff41946-2537-401a-a542-d53d6c177529             56.00000            56
    8 f68dccfc-29d6-47ab-ab7e-93b5ace9c226             16.08333            36
    9 fe801e88-5207-4550-a877-b072e25bebf4             56.00000            56
        ego_id
    1 sofrom06
    2 josmar03
    3 marsan05
    4 annbea01
    5 luiher04
    6 isaben08
    7 tomgar09
    8 davlop07
    9 carrod02

The output dataframe contains one row per ego, along with variables
capturing both network identifiers and key quantities involved in the
computation of ego language betweenness:

| Column name | Description |
|----|----|
| `networkCanvasEgoUUID` | Unique identifier for each ego network |
| `ego_id` | Participant ID (can be used to merge with other datasets) |
| `ego_language_betweenness` | The computed betweenness value for the ego |
| `n_valid_pairs` | Total number of alter pairs from different language communities considered in the computation |

# 2. Language E-I Index

## 2.1 Overview

*The extent to which alter-alter ties cross language group boundaries
versus stay within them.*

To quantify whether an ego’s network is organized into language-based
clusters, we use the **E–I index** from social network analysis. The
index compares the number of ties between alters in different language
groups (**external ties**) with the number of ties between alters in the
same language group (**internal ties**):

$$\text{E-I} = \frac{E - I}{E + I}$$

where $E$ is the number of ties between alters in **different** language
groups and $I$ is the number of ties between alters in the **same**
language group. The index ranges from **−1**.

- **−1** = all ties are internal, indicating strong **language
  compartmentalization**

- **+1** = all ties are external, indicating strong **language
  integration**

- **0** = equal numbers of internal and external ties

Here, groups are defined by `languageKnownCategory` (the alter’s own
language repertoire). A negative E-I index means the ego’s network is
organized into language-homogeneous clusters; a positive value means
alters regularly interact across language boundaries. When only one
language group is present (e.g., a fully bilingual network), the index
is `NA`.

The standard E-I index uses raw tie counts, which makes it sensitive to
group size imbalance — a group with more members has more possible
within-group pairs. We therefore compute a **density-weighted** version:
$E$ and $I$ are replaced by between-group and within-group tie
*densities* ($d_{\text{between}}$ and $d_{\text{within}}$), correcting
for the number of possible ties in each stratum. Both the raw and
density-weighted versions are returned.

------------------------------------------------------------------------

## 2.2 Usage

### Example data

| Dataset | Variable | Description | Role in analysis |
|----|----|----|----|
| ego | `networkCanvasEgoUUID` | Unique identifier for each ego | Used to define and iterate over ego networks |
| ego | `ego_id` | Unique participant identifier | Used to merge with external datasets (e.g., questionnaires, behavioral data) |
| alter | `networkCanvasEgoUUID` | Ego ID for each alter | Links alters to their corresponding ego |
| alter | `networkCanvasUUID` | Unique identifier for each alter | Node identifier in the network |
| alter | `languageKnownCategory` | Language group (e.g., English, Spanish, Bilingual) | Defines group membership for computing internal vs external ties |
| edges | `networkCanvasEgoUUID` | Ego ID for each edge | Ensures edges are within the same ego network |
| edges | `networkCanvasSourceUUID` | Source alter ID | Defines edge (node–node connection) |
| edges | `networkCanvasTargetUUID` | Target alter ID | Defines edge (node–node connection) |

This function works on **ego-network data**, using the similar data
structure as ego language betweenness but here we focus on the
`languageKnownCategory`

Below is an example using demo data included in the demo. Suppose we
have ten ego networks, where alters are categorized as `"English"`,
`"Spanish"`, or `"Spanish-English"`in their `languageKnownCategory`

### Step 1: load preprocessed dataset

``` r
# Folder where the preprocessed CSVs are stored
input_dir <- "./preprocessed_data"

egoData_linked <- readr::read_csv(
  file.path(input_dir, "egoData_linked.csv"),
  show_col_types = FALSE
)

alterData_linked <- readr::read_csv(
  file.path(input_dir, "alterData_linked.csv"),
  show_col_types = FALSE
)

edgelist_linked <- readr::read_csv(
  file.path(input_dir, "edgelist_linked.csv"),
  show_col_types = FALSE
)

cat("Reloaded preprocessed data from:", normalizePath(input_dir), "\n")
```

    Reloaded preprocessed data from: C:\Users\Zoey\OneDrive - UC San Diego (1)\Documents - Bilingualism in Context Lab\PNS Tutorial\BiNet_Structural_Measures\preprocessed_data 

``` r
cat(" - egoData_linked   (", nrow(egoData_linked),   "rows )\n")
```

     - egoData_linked   ( 9 rows )

``` r
cat(" - alterData_linked (", nrow(alterData_linked), "rows )\n")
```

     - alterData_linked ( 135 rows )

``` r
cat(" - edgelist_linked  (", nrow(edgelist_linked),  "rows )\n")
```

     - edgelist_linked  ( 247 rows )

Load the necessary packages. This includes the core network analysis
package <u>**egor**</u> and the <u>**dplyr**</u> package.

We use `egor` because `egor` provides a built-in function `EI()` that
directly computes the E–I index. This avoids:

- manually counting internal/external ties

- manually computing densities

- writing custom graph traversal code

In other words: `egor` handles the **network construction + EI
computation internally**

``` r
# Install egor package if you never installed this before
if(!"egor" %in% rownames(installed.packages())) install.packages("egor")
library(egor)
library(dplyr)
```

### Step 2: Build the egor object

This step converts the three data tables into a single **egor object**,
storing:

- ego attributes

- alter attributes

- alter–alter connections

This is necessary because the `EI()` function **requires an egor
object** as input. It also ensures that each ego network is **properly
separated** and standardizes the structure for network computations

``` r
egor_obj <- egor::threefiles_to_egor(
  egos      = egoData_linked,
  alters.df = alterData_linked,
  edges     = edgelist_linked,
  ID.vars = list(
    ego    = "networkCanvasEgoUUID",
    alter  = "networkCanvasUUID",
    source = "networkCanvasSourceUUID",
    target = "networkCanvasTargetUUID"
  )
)
```

### Step 3: Compute E-I Index

We compute two versions of the E–I index:

- **Raw E–I index**: based on the number of ties, defined as ( (E - I) /
  (E + I) ) where (E) and (I) are the numbers of between-group and
  within-group ties. This follows the standard definition but is
  sensitive to group size imbalance.

- **Density-rescaled E–I index**: replaces tie counts with tie densities
  (i.e., adjusts for the number of possible ties), providing a measure
  that is less affected by differences in group size.

Both versions are reported to capture complementary aspects of network
structure.

``` r
# Density-rescaled EI (ei_index_density)
ei_density <- egor::EI(
  egor_obj,
  alt.attr    = "languageKnownCategory",
  include.ego = FALSE,
  rescale     = TRUE
) |>
  dplyr::select(.egoID, ei_index_density = ei)

# Raw (tie-count based) EI 
ei_raw <- egor::EI(
  egor_obj,
  alt.attr    = "languageKnownCategory",
  include.ego = FALSE,
  rescale     = FALSE
) |>
  dplyr::select(.egoID, ei_index_raw = ei)

ego_data <- as_tibble(egor_obj$ego)

ei_df <- ei_density |>
  dplyr::left_join(ei_raw, by = ".egoID") |>
  dplyr::rename(networkCanvasEgoUUID = .egoID) |>
  dplyr::left_join(
    ego_data |> dplyr::select(.egoID, ego_id),  
    by = c("networkCanvasEgoUUID" = ".egoID")
  )
```

``` r
print(ei_df)
```

    # A tibble: 9 × 4
      networkCanvasEgoUUID                 ei_index_density ei_index_raw ego_id  
      <chr>                                           <dbl>        <dbl> <chr>   
    1 4bc7e51b-a8af-4881-982e-12cfb2b1e9e3         NaN           -1      annbea01
    2 fe801e88-5207-4550-a877-b072e25bebf4          -1           -1      carrod02
    3 f68dccfc-29d6-47ab-ab7e-93b5ace9c226          -0.336       -0.317  davlop07
    4 96f49992-a293-45b1-bd84-ccedf42d66fc          -0.0526       0.636  isaben08
    5 22e0f2c8-ddde-4271-bb6b-e9ec7fa6da6b          -0.410       -0.0222 josmar03
    6 82d2ef44-8636-4214-ba7b-4694793321d2          -0.264        0.488  luiher04
    7 28202870-0e8a-4600-9434-c280eff762cd         NaN           -1      marsan05
    8 06029b97-694c-41b8-807e-4cb07dca16a8         NaN           -1      sofrom06
    9 aff41946-2537-401a-a542-d53d6c177529          -1           -1      tomgar09

The output dataframe contains one row per ego, along with variables
capturing both network identifiers and key quantities involved in the
computation of EI index:

<table>
<colgroup>
<col style="width: 17%" />
<col style="width: 82%" />
</colgroup>
<thead>
<tr>
<th>Column name</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>networkCanvasEgoUUID</code></td>
<td>Unique identifier for each ego network</td>
</tr>
<tr>
<td><code>ego_id</code></td>
<td>Participant ID (can be used to merge with other datasets)</td>
</tr>
<tr>
<td><code>ei_index_density</code></td>
<td><p>EI index normalized by network density;</p>
<p>NaN indicates ego’s network is fully homophilous (all alters share
the same language), making normalization undefined.</p></td>
</tr>
<tr>
<td><code>ei_index_raw</code></td>
<td>Raw EI index defined as (external ties − internal ties) / total
ties</td>
</tr>
</tbody>
</table>

## Combine and Save the Results

``` r
# Merge the two dataframes by networkCanvasEgoUUID
networkscience_structural_measures <- merge(betweenness_df, ei_df, 
                                            by = "networkCanvasEgoUUID")

# Save as CSV
write.csv(networkscience_structural_measures, 
          "networkscience_structural_measures.csv", 
          row.names = FALSE)
```
