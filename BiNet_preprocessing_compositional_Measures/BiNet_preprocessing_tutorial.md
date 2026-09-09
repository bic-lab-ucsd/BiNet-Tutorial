# BiNet Preprocessing Tutorial
Monica Shen
2026-05-05

-   [Introduction](#introduction)
    -   [**Core Concepts**](#core-concepts)
-   [Understanding the Data
    Structure](#understanding-the-data-structure)
    -   [Three Levels](#three-levels)
    -   [Ego-level Data — `*_ego.csv`](#ego)
    -   [Alter-level Data — `*_attributeList_People.csv`](#alter)
    -   [Tie-level data — `*_edgeList_tie.csv`](#ties)
    -   [Linking the Pieces: Connect Multilevel Network
        Data](#linking-the-pieces-connect-multilevel-network-data)
    -   [References](#references)
    -   [0.Setup](#setup)
-   [Demo Script](#demo-script)
    -   [1. Load and Merge Raw Data](#load-and-merge-raw-data)
        -   [1.1 Load LHQ Data](#load-lhq-data)
        -   [1.2 Build Linked Datasets](#build-linked-datasets)
        -   [1.3 Sanity Checks for Linked
            Datasets](#sanity-checks-for-linked-datasets)
    -   [2. Alter-Level Preprocessing](#alter-level-preprocessing)
        -   [2.1 Interaction Context: Dummy Columns → Single
            Variable](#interaction-context-dummy-columns-single-variable)
        -   [2.2 Language Columns: String →
            Logical](#language-columns-string-logical)
        -   [2.3 Codeswitching (CS) Frequency: Empty String → NA →
            Numeric](#codeswitching-cs-frequency-empty-string-na-numeric)
        -   [2.4 Ordinal Columns to
            Numeric](#ordinal-columns-to-numeric)
        -   [2.5 Language Categorization](#language-categorization)
        -   [2.6 Sanity Checks for Preprocessed
            Variables](#sanity-checks-for-preprocessed-variables)
    -   [3. Tidy Alter-Level Dataset](#tidy-alter-level-dataset)
    -   [4. Build `egor` Object](#build-egor-object)
    -   [5. Compositional Measures](#compositional-measures)
        -   [5.1 Global CS Frequency Mean](#global-cs-frequency-mean)
        -   [5.2 Global Interaction Frequency
            Mean](#global-interaction-frequency-mean)
        -   [5.3 Emotional Closeness](#emotional-closeness)
        -   [5.4 Alter Language
            Composition](#alter-language-composition)
        -   [5.5 CS Frequency by Interaction
            Context](#cs-frequency-by-interaction-context)
        -   [5.6 Language Homophily](#language-homophily)
        -   [5.7 Sanity Checks for Compositional
            Variables](#sanity-checks-for-compositional-variables)
    -   [6. Save Data Outputs](#save-data-outputs)

# Introduction

The *Bilingual Interactional Network Survey* (BiNet) extends traditional
language background questionnaires (LHQs) by shifting the unit of
analysis from the **individual** to the **relationship**. BiNet retains
the individual-level measures while adding a relational layer:
participants nominate the 15 people they interact with regularly, the
language practices that characterize each relationship, and the ties
among those nominees. This yields a multi-level dataset that can support
both standard individual-differences analyses and network-based measures
of bilingual language experience.

This tutorial script shows how to transform raw BiNet data exported from
Network Canvas into analysis-ready datasets using R. The workflow is
organized into the following stages:

1.  Load and merge Network Canvas export files with Language History
    Questionnaire (LHQ) data (`demo_lhq.csv`)
2.  Preprocess alter-level variables (recode, classify, and tidy)
3.  Build the `egor` object for egocentric network analysis
4.  Derive compositional measures describing network composition
5.  Save outputs for use in downstream analyses

Network visualization is covered in the companion script
`../BiNet_Network_Visualization/BiNet_network_visualization.qmd`, which
loads the output files saved in Step 5.

> **Note on demo data.** The Network Canvas export files and LHQ data
> used in this tutorial are fully simulated datasets created for
> instructional purposes. They do not contain real participant
> information.

> **Note on column names.** Column names in `demo_lhq.csv` will vary
> across studies depending on questionnaire design and data-collection
> platform. Customize the import and merge steps so that the participant
> identifier in your questionnaire (e.g., `participant_id`) matches the
> `ego_id` field in the Network Canvas export.

## **Core Concepts**

-   **ego:** the participant

-   **alters:** the people nominated by the participant

-   **ties:** the relationships among those alters

# Understanding the Data Structure

This script processes data exported from the **BiNet** Network Canvas
protocol (`NetworkCanvasProtocol_BiNet_20260417`). Network Canvas
exports **one set of three CSV files per participant**, all placed in a
single folder (**Network Canvas Export**). All files for all
participants are placed in a single folder. The script reads all
matching files at once using `list.files()` + `lapply()` +
`bind_rows()`.

### Three Levels

1.  [Ego-level Data](#ego): {ego_id}\_{networkCanvasSessionID}`_ego.csv`
2.  [Alter-level Data](#alter):
    {ego_id}\_{networkCanvasSessionID}`_attributeList_People.csv`
3.  [Tie-level Data](#ties):
    {ego_id}\_{networkCanvasSessionID}`_edgeList_tie.csv`

### Ego-level Data — `*_ego.csv`

One file per participant; one row per file.

<table style="width:99%;">
<colgroup>
<col style="width: 20%" />
<col style="width: 9%" />
<col style="width: 69%" />
</colgroup>
<thead>
<tr>
<th>Variable</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>networkCanvasEgoUUID</code></td>
<td>character</td>
<td>Primary link variable that links <code>*_ego.csv</code>,
<code>*_attributeList_People.csv</code>,
<code>*_edgeList_tie.csv</code></td>
</tr>
<tr>
<td><code>networkCanvasCaseID</code></td>
<td>character</td>
<td>case ID (same as <code>ego_id</code>)</td>
</tr>
<tr>
<td><code>networkCanvasSessionID</code></td>
<td>character</td>
<td>Session identifier</td>
</tr>
<tr>
<td><code>networkCanvasProtocolName</code></td>
<td>character</td>
<td>Protocol filename
(<code>NetworkCanvasProtocol_BiNet_20260417</code>)</td>
</tr>
<tr>
<td><code>sessionStart</code></td>
<td>datetime</td>
<td>Session start timestamp (ISO 8601)</td>
</tr>
<tr>
<td><code>sessionFinish</code></td>
<td>datetime</td>
<td>Session end timestamp</td>
</tr>
<tr>
<td><code>sessionExported</code></td>
<td>datetime</td>
<td>Export timestamp</td>
</tr>
<tr>
<td><code>ego_id</code></td>
<td>character</td>
<td>8-character participant id (e.g., <code>annbea01</code>) that links
<code>*_ego.csv</code> and <code>lhq.csv</code></td>
</tr>
</tbody>
</table>

**Notes**: `networkCanvasCaseID` and `ego_id` columns should be
identical

### Alter-level Data — `*_attributeList_People.csv`

One file per participant; 15 rows per file.

#### System columns

<table style="width:99%;">
<colgroup>
<col style="width: 19%" />
<col style="width: 9%" />
<col style="width: 70%" />
</colgroup>
<thead>
<tr>
<th>Variable</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>nodeID</code></td>
<td>integer</td>
<td>Within-participant alter index (1–15)</td>
</tr>
<tr>
<td><code>networkCanvasEgoUUID</code></td>
<td>character</td>
<td>Primary link variable that joins
<code>*_attributeList_People.csv</code> back to
<code>*_ego.csv</code></td>
</tr>
<tr>
<td><code>networkCanvasUUID</code></td>
<td>character</td>
<td>Unique alter identifier that links
<code>*_attributeList_People.csv</code> and
<code>*_edgeList_tie.csv</code></td>
</tr>
</tbody>
</table>

#### Alter-level attributes

1.  **Alter demographics**

<table style="width:98%;">
<colgroup>
<col style="width: 13%" />
<col style="width: 9%" />
<col style="width: 58%" />
<col style="width: 16%" />
</colgroup>
<thead>
<tr>
<th>Variable</th>
<th>Type</th>
<th>Values</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>name</code></td>
<td>character</td>
<td>Free text</td>
<td>Alter name</td>
</tr>
<tr>
<td><code>alter_gender</code></td>
<td>character</td>
<td><code>female</code>, <code>male</code>, <code>other</code></td>
<td>Alter’s gender</td>
</tr>
<tr>
<td><code>alter_age</code></td>
<td>character</td>
<td><code>0_9</code>, <code>10_17</code>, <code>18_25</code>,
<code>26_35</code>, <code>36_45</code>, <code>46_55</code>,
<code>56_65</code>, <code>65_99</code></td>
<td>Alter’s age group</td>
</tr>
</tbody>
</table>

1.  **Ego-alter Interactional attributes**

<table style="width:99%;">
<colgroup>
<col style="width: 21%" />
<col style="width: 6%" />
<col style="width: 9%" />
<col style="width: 61%" />
</colgroup>
<thead>
<tr>
<th>Variable</th>
<th>Type</th>
<th>Values</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>ego_alter_interaction_frequency</code></td>
<td>ordinal</td>
<td>1–5</td>
<td>1 = at least once a year; 5 = at least once a day</td>
</tr>
<tr>
<td><code>ego_alter_emotional_closeness</code></td>
<td>ordinal</td>
<td>1–5</td>
<td>1 = not close at all; 5 = extremely close</td>
</tr>
<tr>
<td><code>ego_alter_cs_frequency</code></td>
<td>ordinal</td>
<td>1–4, or <code>""</code></td>
<td><p>1 = rarely; 4 = always.</p>
<p><strong>Empty string when ego uses only one language with this
alter</strong> (stage skipped by protocol filter)</p></td>
</tr>
</tbody>
</table>

**Interaction context** (dummy-coded, 5 columns)

**Format:** `ego_alter_interaction_context_{context}` | **Type:**
logical (`true`/`false`) | **Note:** Exactly one column is `true` per
alter (single-select CategoricalBin)

<table>
<colgroup>
<col style="width: 41%" />
<col style="width: 58%" />
</colgroup>
<thead>
<tr>
<th>Column</th>
<th>Context</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>ego_alter_interaction_context_family</code></td>
<td>Family (people you live with or close relatives)</td>
</tr>
<tr>
<td><code>ego_alter_interaction_context_community</code></td>
<td>Non-relatives sharing living spaces (housemates, neighbors)</td>
</tr>
<tr>
<td><code>ego_alter_interaction_context_school</code></td>
<td>Classmates, professors</td>
</tr>
<tr>
<td><code>ego_alter_interaction_context_work</code></td>
<td>Coworkers, supervisors, clients</td>
</tr>
<tr>
<td><code>ego_alter_interaction_context_social</code></td>
<td>Recreational / hobby contexts outside school or work</td>
</tr>
</tbody>
</table>

3\. Alter language repertoire (10 columns)

-   Format: `alter_language_{language}` | Type: logical (`true`/`false`)

4\. Ego-alter language use (10 columns)

-   Format: `ego_alter_language_{language}` | Type: logical
    (`true`/`false`)

Note: Language options included in the protocol: `english`, `spanish`,
`mandarin`, `cantonese`, `filipino`, `vietnamese`, `arabic`, `korean`,
`japanese`, `other`

### Tie-level data — `*_edgeList_tie.csv`

One file per participant; variable number of rows per file.

<table style="width:99%;">
<colgroup>
<col style="width: 21%" />
<col style="width: 9%" />
<col style="width: 68%" />
</colgroup>
<thead>
<tr>
<th>Variable</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>edgeID</code></td>
<td>integer</td>
<td>Within-participant edge index</td>
</tr>
<tr>
<td><code>from</code></td>
<td>integer</td>
<td><code>nodeID</code> of source alter</td>
</tr>
<tr>
<td><code>to</code></td>
<td>integer</td>
<td><code>nodeID</code> of target alter</td>
</tr>
<tr>
<td><code>networkCanvasEgoUUID</code></td>
<td>character</td>
<td>Primary link variable that joins <code>*_edgeList_tie.csv</code>
back to <code>*_ego.csv</code></td>
</tr>
<tr>
<td><code>networkCanvasUUID</code></td>
<td>character</td>
<td>Unique alter identifier that links
<code>*_attributeList_People.csv</code> and
<code>*_edgeList_tie.csv</code></td>
</tr>
<tr>
<td><code>networkCanvasSourceUUID</code></td>
<td>character</td>
<td><code>networkCanvasUUID</code> of source alter</td>
</tr>
<tr>
<td><code>networkCanvasTargetUUID</code></td>
<td>character</td>
<td><code>networkCanvasUUID</code> of target alter</td>
</tr>
</tbody>
</table>

**Notes:** `edgeID`, `from`, and `to` are unique only within a
participant. Ties are undirected; source/target assignment is arbitrary.

## Linking the Pieces: Connect Multilevel Network Data

A key takeaway from the data structure above is that BiNet data are
stored across **multiple levels** (ego, alter, and tie), but these files
are not independent. They are connected through a small set of **linking
variables** that allow researchers to reconstruct each participant’s
personal network and merge information across files.

-   **`ego_id`**: participant ID (e.g., `annbea01`) used to link BiNet
    data with external datasets such as language history questionnaires,
    behavioral tasks, or demographic records

-   **`networkCanvasEgoUUID`**: identifies each participant (**ego**)
    within the Network Canvas system and links all three exported files

-   `networkCanvasUUID`: identifies each nominated person (**alter**)
    within an ego’s network

-   `networkCanvasSourceUUID` / `networkCanvasTargetUUID`: define tie
    endpoints to specify the two alters involved in each tie

In short, although BiNet exports multiple files, the linking variables
ensure they function as **one coherent relational dataset**.

## References

Network Canvas Documentation: https://documentation.networkcanvas.com/

`egor` package: https://cran.r-project.org/package=egor

## 0.Setup

``` r
packages <- c("dplyr", "tidyr", "stringr", "readr", "egor",
              "janitor", "scales", "purrr")

installed_packages <- packages %in% rownames(installed.packages())
if (any(!installed_packages)) {
  install.packages(packages[!installed_packages])
}

invisible(lapply(packages, library, character.only = TRUE))
```

# Demo Script

## 1. Load and Merge Raw Data

Set `data_dir` to the folder containing all participant Network Canvas
export files (`Network Canvas Export`). The `list.files()` → `lapply()`
→ `bind_rows()` pipeline reads all files matching each pattern and
stacks them into a single data frame.

``` r
# Set to the folder containing all Network Canvas export files
data_dir <- "./Network Canvas Export" 

data_alter <- data_dir |>
  list.files(full.names = TRUE, pattern = "attributeList_People\\.csv$") |>
  lapply(readr::read_csv, show_col_types = FALSE) |>
  dplyr::bind_rows()

data_ego <- data_dir |>
  list.files(full.names = TRUE, pattern = "_ego\\.csv$") |>
  lapply(readr::read_csv, show_col_types = FALSE) |>
  dplyr::bind_rows()

data_edgelist <- data_dir |>
  list.files(full.names = TRUE, pattern = "edgeList_tie\\.csv$") |>
  lapply(readr::read_csv, show_col_types = FALSE) |>
  dplyr::bind_rows()

cat("Loaded", nrow(data_ego), "egos,",
    nrow(data_alter), "alters,",
    nrow(data_edgelist), "edges\n")
```

Before moving on, it is good practice to verify that the raw Network
Canvas exports contain all the columns listed in the data dictionary
above. The code below checks each of the three data frames (`data_ego`,
`data_alter`, `data_edgelist`) against the expected column names. This
check is designed to help ensure data quality and to make it easier to
use this package and the accompanying script. **For the code to run
smoothly end-to-end, the column names in your exports should match the
ones specified in the data dictionary**. If your protocol uses different
column names (e.g., a different set of focal languages, or added/removed
attributes), update the `expected_*_cols` vectors below accordingly
before running the rest of the script.

``` r
# Expected columns per the BiNet data dictionary
expected_ego_cols <- c(
  "networkCanvasEgoUUID", "networkCanvasCaseID", "networkCanvasSessionID",
  "networkCanvasProtocolName", "sessionStart", "sessionFinish",
  "sessionExported", "ego_id"
)

expected_alter_cols <- c(
  # System columns
  "nodeID", "networkCanvasEgoUUID", "networkCanvasUUID",
  # Alter demographics
  "name", "alter_gender", "alter_age",
  # Ego–alter interactional attributes
  "ego_alter_interaction_frequency", "ego_alter_emotional_closeness",
  "ego_alter_cs_frequency",
  # Interaction context (5 dummy columns)
  "ego_alter_interaction_context_family",
  "ego_alter_interaction_context_community",
  "ego_alter_interaction_context_school",
  "ego_alter_interaction_context_work",
  "ego_alter_interaction_context_social",
  # Alter language repertoire (10 columns)
  paste0("alter_language_",
         c("english","spanish","mandarin","cantonese","filipino",
           "vietnamese","arabic","korean","japanese","other")),
  # Ego–alter language use (10 columns)
  paste0("ego_alter_language_",
         c("english","spanish","mandarin","cantonese","filipino",
           "vietnamese","arabic","korean","japanese","other"))
)

expected_edge_cols <- c(
  "edgeID", "from", "to",
  "networkCanvasEgoUUID", "networkCanvasUUID",
  "networkCanvasSourceUUID", "networkCanvasTargetUUID"
)

check_columns <- function(df, expected, label) {
  missing_cols <- setdiff(expected, names(df))
  extra_cols   <- setdiff(names(df), expected)

  cat("---", label, "---\n")
  cat("Rows:", nrow(df), "| Columns:", ncol(df), "\n")

  if (length(missing_cols) == 0) {
    cat("[OK] All expected columns present.\n")
  } else {
    cat("[MISSING] ", length(missing_cols), " column(s):\n", sep = "")
    cat(paste(" -", missing_cols), sep = "\n"); cat("\n")
  }

  if (length(extra_cols) > 0) {
    cat("[INFO] ", length(extra_cols), " extra column(s) not in spec:\n", sep = "")
    cat(paste(" -", extra_cols), sep = "\n"); cat("\n")
  }
  cat("\n")
  invisible(list(missing = missing_cols, extra = extra_cols))
}

check_columns(data_ego,      expected_ego_cols,   "Ego-level data (*_ego.csv)")
```

    --- Ego-level data (*_ego.csv) ---
    Rows: 9 | Columns: 8 
    [OK] All expected columns present.

``` r
check_columns(data_alter,    expected_alter_cols, "Alter-level data (*_attributeList_People.csv)")
```

    --- Alter-level data (*_attributeList_People.csv) ---
    Rows: 135 | Columns: 34 
    [OK] All expected columns present.

``` r
check_columns(data_edgelist, expected_edge_cols,  "Tie-level data (*_edgeList_tie.csv)")
```

    --- Tie-level data (*_edgeList_tie.csv) ---
    Rows: 247 | Columns: 7 
    [OK] All expected columns present.

``` r
stopifnot(
  all(expected_ego_cols   %in% names(data_ego)),
  all(expected_alter_cols %in% names(data_alter)),
  all(expected_edge_cols  %in% names(data_edgelist))
)
```

### 1.1 Load LHQ Data

The LHQ file contains ego-level self-report variables (demographics,
language background) collected separately from Network Canvas. It is
linked to the network data via `ego_id`.

``` r
# Set to the folder containing the LHQ file
lhq_dir <- "./"

lhq_df <- readr::read_csv(
  file.path(lhq_dir, "demo_lhq.csv"),
  show_col_types = FALSE
) |>
  dplyr::mutate(
    # Parse the comma-separated language string into a list column.
    # Used later when computing language homophily (§5.6).
    ego_lang_list = stringr::str_split(tolower(ego_lang), ",\\s*")
  )

dplyr::glimpse(lhq_df)
```

    Rows: 9
    Columns: 5
    $ ego_id        <chr> "annbea01", "carrod02", "josmar03", "luiher04", "marsan0…
    $ ego_gender    <chr> "female", "male", "non_binary", "male", "female", "femal…
    $ ego_age       <dbl> 28, 34, 26, 31, 23, 29, 38, 22, 45
    $ ego_lang      <chr> "English,Spanish", "English,Spanish", "English,Spanish",…
    $ ego_lang_list <list> <"english", "spanish">, <"english", "spanish">, <"englis…

### 1.2 Build Linked Datasets

Three linked datasets are constructed here and used throughout the
script:

-   **`egoData_linked`**: one row per participant; network session
    variables joined to LHQ variables via `ego_id`
-   **`alterData_linked`**: one row per alter; restricted to
    participants present in the ego file
-   **`edgelist_linked`**: one row per tie; restricted to participants
    present in the ego file

``` r
# join LHQ variables to ego.csv
egoData_linked <- data_ego |>
  dplyr::select(networkCanvasEgoUUID, ego_id, sessionStart, sessionFinish) |>
  dplyr::left_join(
    lhq_df |> dplyr::select(ego_id, ego_gender, ego_age, ego_lang),
    by = "ego_id"
  )

alterData_linked <- data_alter |>
  dplyr::semi_join(data_ego |> dplyr::select(networkCanvasEgoUUID),
                   by = "networkCanvasEgoUUID")

edgelist_linked <- data_edgelist |>
  dplyr::semi_join(data_ego |> dplyr::select(networkCanvasEgoUUID),
                   by = "networkCanvasEgoUUID")
```

### 1.3 Sanity Checks for Linked Datasets

Before preprocessing, it is useful to verify that the three linked
datasets have the expected number of rows, unique IDs, and merge
behavior. These checks help catch mismatched IDs, missing joins, or
duplicate participant records early.

``` r
# 1. egoData_linked should have one row per ego
cat("Rows in egoData_linked:", nrow(egoData_linked), "\n")
```

    Rows in egoData_linked: 9 

``` r
cat("Unique egos in egoData_linked:", dplyr::n_distinct(egoData_linked$networkCanvasEgoUUID), "\n\n")
```

    Unique egos in egoData_linked: 9 

``` r
stopifnot(
  nrow(egoData_linked) == dplyr::n_distinct(egoData_linked$networkCanvasEgoUUID)
)

# 2. alterData_linked should contain only egos present in egoData_linked
cat("Rows in alterData_linked:", nrow(alterData_linked), "\n")
```

    Rows in alterData_linked: 135 

``` r
cat("Unique egos in alterData_linked:", dplyr::n_distinct(alterData_linked$networkCanvasEgoUUID), "\n\n")
```

    Unique egos in alterData_linked: 9 

``` r
stopifnot(
  all(alterData_linked$networkCanvasEgoUUID %in% egoData_linked$networkCanvasEgoUUID)
)

# 3. edgelist_linked should contain only egos present in egoData_linked
cat("Rows in edgelist_linked:", nrow(edgelist_linked), "\n")
```

    Rows in edgelist_linked: 247 

``` r
cat("Unique egos in edgelist_linked:", dplyr::n_distinct(edgelist_linked$networkCanvasEgoUUID), "\n\n")
```

    Unique egos in edgelist_linked: 9 

``` r
stopifnot(
  all(edgelist_linked$networkCanvasEgoUUID %in% egoData_linked$networkCanvasEgoUUID)
)

# 4. check whether each ego has 15 alters (expected in this protocol)
alter_counts <- alterData_linked |>
  dplyr::count(networkCanvasEgoUUID, name = "n_alters")

print(alter_counts)
```

    # A tibble: 9 × 2
      networkCanvasEgoUUID                 n_alters
      <chr>                                   <int>
    1 06029b97-694c-41b8-807e-4cb07dca16a8       15
    2 22e0f2c8-ddde-4271-bb6b-e9ec7fa6da6b       15
    3 28202870-0e8a-4600-9434-c280eff762cd       15
    4 4bc7e51b-a8af-4881-982e-12cfb2b1e9e3       15
    5 82d2ef44-8636-4214-ba7b-4694793321d2       15
    6 96f49992-a293-45b1-bd84-ccedf42d66fc       15
    7 aff41946-2537-401a-a542-d53d6c177529       15
    8 f68dccfc-29d6-47ab-ab7e-93b5ace9c226       15
    9 fe801e88-5207-4550-a877-b072e25bebf4       15

``` r
if (any(alter_counts$n_alters != 15)) {
  warning("Some egos do not have exactly 15 alters. Check protocol completion/export.")
}

# 5. check for duplicated alter UUIDs within ego
dup_alters <- alterData_linked |>
  dplyr::count(networkCanvasEgoUUID, networkCanvasUUID) |>
  dplyr::filter(n > 1)

if (nrow(dup_alters) > 0) {
  warning("Duplicated networkCanvasUUID values found within ego-level alter data.")
  print(dup_alters)
} else {
  cat("No duplicated alter UUIDs within ego.\n")
}
```

    No duplicated alter UUIDs within ego.

``` r
# missing ego_id in ego-level file
ego_id_issues <- data_ego |>
  dplyr::filter(is.na(ego_id) | trimws(ego_id) == "") |>
  dplyr::distinct(networkCanvasEgoUUID, ego_id) |>
  dplyr::mutate(issue = "Missing ego_id")

# check alter counts
alter_count_issues <- alterData_linked |>
  dplyr::count(networkCanvasEgoUUID, name = "n_alters") |>
  dplyr::filter(n_alters != 15) |>
  dplyr::left_join(
    data_ego |>
      dplyr::select(networkCanvasEgoUUID, ego_id),
    by = "networkCanvasEgoUUID"
  ) |>
  dplyr::mutate(
    issue = dplyr::case_when(
      n_alters < 15 ~ "Fewer than 15 alters",
      n_alters > 15 ~ "More than 15 alters"
    )
  )

# flags
ego_flags <- dplyr::bind_rows(
  ego_id_issues |>
    dplyr::mutate(n_alters = NA_integer_),
  alter_count_issues |>
    dplyr::select(networkCanvasEgoUUID, ego_id, n_alters, issue)
) |>
  dplyr::arrange(networkCanvasEgoUUID)

if (nrow(ego_flags) == 0) {
  cat("[OK] All egos have valid ego_id and exactly 15 alters.\n")
} else {
  warning("Some egos failed sanity checks.")
  print(ego_flags)
}
```

    [OK] All egos have valid ego_id and exactly 15 alters.

## 2. Alter-Level Preprocessing

This section recodes variables from their raw Network Canvas export
format into analysis-ready form. These steps must be completed before
constructing compositional measures or network visualizations.

### 2.1 Interaction Context: Dummy Columns → Single Variable

Network Canvas exports the single-select interaction context question as
five separate boolean columns (one per option). We collapse them into a
single character variable for analysis.

``` r
context_cols <- c(
  "ego_alter_interaction_context_family",
  "ego_alter_interaction_context_community",
  "ego_alter_interaction_context_school",
  "ego_alter_interaction_context_work",
  "ego_alter_interaction_context_social"
)

alterData_linked <- alterData_linked %>%
  dplyr::mutate(
    across(all_of(context_cols), ~ . == "true" | . == TRUE)
  ) %>%
  dplyr::mutate(
    ego_alter_interaction_context = dplyr::case_when(
      ego_alter_interaction_context_family       ~ "family",
      ego_alter_interaction_context_community       ~ "community",
      ego_alter_interaction_context_school          ~ "school",
      ego_alter_interaction_context_work            ~ "work",
      ego_alter_interaction_context_social          ~ "social",
      TRUE                                          ~ NA_character_
    )
  )
```

### 2.2 Language Columns: String → Logical

All `alter_language_*` and `ego_alter_language_*` columns are exported
as the strings `"true"` or `"false"`. Convert to R logical for
arithmetic operations downstream.

``` r
lang_cols <- c(
  paste0("alter_language_",
         c("english","spanish","mandarin","cantonese","filipino",
           "vietnamese","arabic","korean","japanese","other")),
  paste0("ego_alter_language_",
         c("english","spanish","mandarin","cantonese","filipino",
           "vietnamese","arabic","korean","japanese","other"))
)

alterData_linked <- alterData_linked |>
  dplyr::mutate(across(all_of(lang_cols), ~ . == "true" | . == TRUE))
```

### 2.3 Codeswitching (CS) Frequency: Empty String → NA → Numeric

Monolingual dyads skip the codeswitching stage; Network Canvas records
this as an empty string rather than `NA`. Convert to numeric so that
`mean(..., na.rm = TRUE)` correctly ignores these dyads when computing
compositional measures.

``` r
alterData_linked <- alterData_linked |>
  dplyr::mutate(
    ego_alter_cs_frequency =
      dplyr::na_if(as.character(ego_alter_cs_frequency), "") |>
      as.numeric()
  )
```

### 2.4 Ordinal Columns to Numeric

``` r
alterData_linked <- alterData_linked |>
  dplyr::mutate(
    ego_alter_interaction_frequency = as.numeric(ego_alter_interaction_frequency),
    ego_alter_emotional_closeness   = as.numeric(ego_alter_emotional_closeness)
  )
```

### 2.5 Language Categorization

Before constructing compositional measures, binary language indicator
columns must be combined into a single analytically meaningful category
variable. We do this twice: once from the `languageUsedCategory` (what
language(s) does the ego use with this alter?), and once from the
`languageKnownCategory` (what language(s) does the alter know overall?).

Both functions follow the same four-level logic. Any alter who uses
neither focal language falls into `"Other"`. The functions are
**language-agnostic**: they detect language columns via a shared prefix
(`ego_alter_language_` or `alter_language_`) and assign categories based
solely on the two focal language flags supplied as arguments. Any
non-focal language is treated as `"Other"`. This means the same function
works for any bilingual sample by changing `lang1_col` and `lang2_col`.

<table>
<thead>
<tr>
<th>lang1 (Spanish)</th>
<th>lang2 (English)</th>
<th>Category</th>
</tr>
</thead>
<tbody>
<tr>
<td>TRUE</td>
<td>FALSE</td>
<td><code>"Spanish"</code></td>
</tr>
<tr>
<td>FALSE</td>
<td>TRUE</td>
<td><code>"English"</code></td>
</tr>
<tr>
<td>TRUE</td>
<td>TRUE</td>
<td><code>"Spanish-English"</code></td>
</tr>
<tr>
<td>FALSE</td>
<td>FALSE</td>
<td><code>"Other"</code></td>
</tr>
</tbody>
</table>

#### 2.5.1 `languageKnownCategory` — alter’s own language repertoire

*What language(s) does the alter know overall?*

Derived from `alter_language_*`. This variable defines language
communities among alters.

``` r
classifyLanguageKnownCategory <- function(df,
                                          lang1_col   = "alter_language_spanish",
                                          lang2_col   = "alter_language_english",
                                          lang1_label = "Spanish",
                                          lang2_label = "English",
                                          none_label  = "Other") {
  miss <- setdiff(c(lang1_col, lang2_col), names(df))
  if (length(miss) > 0) stop("Missing columns: ", paste(miss, collapse = ", "))

  to_lgl <- function(x) {
    if (is.logical(x))   return(x)
    if (is.numeric(x))   return(x == 1)
    if (is.character(x)) return(tolower(x) %in% c("true","t","1","yes","y"))
    as.logical(x)
  }

  l1 <- to_lgl(df[[lang1_col]]); l1[is.na(l1)] <- FALSE
  l2 <- to_lgl(df[[lang2_col]]); l2[is.na(l2)] <- FALSE

  dplyr::case_when(
    l1 &  l2 ~ paste0(lang1_label, "-", lang2_label),
    l1 & !l2 ~ lang1_label,
   !l1 &  l2 ~ lang2_label,
    TRUE      ~ none_label
  )
}

alterData_linked <- alterData_linked |>
  dplyr::mutate(languageKnownCategory = classifyLanguageKnownCategory(alterData_linked))

janitor::tabyl(alterData_linked$languageKnownCategory)
```

     alterData_linked$languageKnownCategory  n   percent
                                    English 46 0.3407407
                                    Spanish 31 0.2296296
                            Spanish-English 58 0.4296296

#### 2.5.2 `languageUsedCategory` — ego’s language use with each alter

*(What language(s) does the ego speak with this alter?)*

Derived from `ego_alter_language_*`. This variable is the basis for
compositional measures of codeswitching context (§5.5).

``` r
classifyLanguageUseCategory <- function(df,
                                        lang1_col   = "ego_alter_language_spanish",
                                        lang2_col   = "ego_alter_language_english",
                                        lang1_label = "Spanish",
                                        lang2_label = "English",
                                        none_label  = "Other") {
  miss <- setdiff(c(lang1_col, lang2_col), names(df))
  if (length(miss) > 0) stop("Missing columns: ", paste(miss, collapse = ", "))

  to_lgl <- function(x) {
    if (is.logical(x))   return(x)
    if (is.numeric(x))   return(x == 1)
    if (is.character(x)) return(tolower(x) %in% c("true","t","1","yes","y"))
    as.logical(x)
  }

  l1 <- to_lgl(df[[lang1_col]]); l1[is.na(l1)] <- FALSE
  l2 <- to_lgl(df[[lang2_col]]); l2[is.na(l2)] <- FALSE

  dplyr::case_when(
    l1 &  l2 ~ paste0(lang1_label, "-", lang2_label),
    l1 & !l2 ~ lang1_label,
   !l1 &  l2 ~ lang2_label,
    TRUE      ~ none_label
  )
}

alterData_linked <- alterData_linked |>
  dplyr::mutate(languageUsedCategory = classifyLanguageUseCategory(alterData_linked))

janitor::tabyl(alterData_linked$languageUsedCategory)
```

     alterData_linked$languageUsedCategory  n   percent
                                   English 46 0.3407407
                                   Spanish 31 0.2296296
                           Spanish-English 58 0.4296296

### 2.6 Sanity Checks for Preprocessed Variables

Verify that the key derived variables should exist and have the expected
formats

``` r
required_vars <- c(
  "ego_alter_interaction_context",
  "ego_alter_interaction_frequency",
  "ego_alter_emotional_closeness",
  "ego_alter_cs_frequency",
  "languageUsedCategory",
  "languageKnownCategory"
)

missing_required_vars <- setdiff(required_vars, names(alterData_linked))

if (length(missing_required_vars) > 0) {
  stop("Missing required preprocessed variables: ",
       paste(missing_required_vars, collapse = ", "))
} else {
  cat("[OK] All required preprocessed variables are present.\n")
}
```

    [OK] All required preprocessed variables are present.

``` r
# Check allowed context values
valid_contexts <- c("family", "community", "school", "work", "social")
observed_contexts <- sort(unique(stats::na.omit(alterData_linked$ego_alter_interaction_context)))
cat("Observed interaction contexts:\n")
```

    Observed interaction contexts:

``` r
print(observed_contexts)
```

    [1] "community" "family"    "school"    "social"    "work"     

``` r
if (!all(observed_contexts %in% valid_contexts)) {
  warning("Unexpected values found in ego_alter_interaction_context.")
}

# Check numeric ranges
cat("\nRange checks:\n")
```


    Range checks:

``` r
cat("ego_alter_interaction_frequency:\n")
```

    ego_alter_interaction_frequency:

``` r
print(range(alterData_linked$ego_alter_interaction_frequency, na.rm = TRUE))
```

    [1] 1 5

``` r
cat("ego_alter_emotional_closeness:\n")
```

    ego_alter_emotional_closeness:

``` r
print(range(alterData_linked$ego_alter_emotional_closeness, na.rm = TRUE))
```

    [1] 1 5

``` r
cat("ego_alter_cs_frequency:\n")
```

    ego_alter_cs_frequency:

``` r
print(range(alterData_linked$ego_alter_cs_frequency, na.rm = TRUE))
```

    [1] 1 4

``` r
# Check category values
valid_lang_cats <- c("Spanish", "English", "Spanish-English", "Other")

observed_used <- sort(unique(stats::na.omit(alterData_linked$languageUsedCategory)))
observed_known <- sort(unique(stats::na.omit(alterData_linked$languageKnownCategory)))

cat("\nlanguageUsedCategory:\n")
```


    languageUsedCategory:

``` r
print(observed_used)
```

    [1] "English"         "Spanish"         "Spanish-English"

``` r
cat("\nlanguageKnownCategory:\n")
```


    languageKnownCategory:

``` r
print(observed_known)
```

    [1] "English"         "Spanish"         "Spanish-English"

``` r
if (!all(observed_used %in% valid_lang_cats)) {
  warning("Unexpected values found in languageUsedCategory.")
}
if (!all(observed_known %in% valid_lang_cats)) {
  warning("Unexpected values found in languageKnownCategory.")
}
```

All preprocessing is complete. We now save the three preprocessed
datasets (`egoData_linked`, `alterData_linked`, `edgelist_linked`) to a
new `preprocessed_data/` folder as a clean checkpoint, so you can reload
them in future sessions without rerunning Sections 1–2. With the data
cleaned and saved, we are ready to compute language-related variables
(**link**).

``` r
# Create output folder (does nothing if it already exists)
output_dir <- "./preprocessed_data"
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# Write the three linked/preprocessed datasets to CSV
readr::write_csv(
  egoData_linked,
  file.path(output_dir, "egoData_linked.csv")
)

readr::write_csv(
  alterData_linked,
  file.path(output_dir, "alterData_linked.csv")
)

readr::write_csv(
  edgelist_linked,
  file.path(output_dir, "edgelist_linked.csv")
)

cat("Saved preprocessed data to:", normalizePath(output_dir), "\n")
```

    Saved preprocessed data to: /Users/monica/Downloads/BiNet-Tutorial/BiNet_preprocessing_compositional_Measures/preprocessed_data 

``` r
cat(" - egoData_linked.csv   (", nrow(egoData_linked),   "rows )\n")
```

     - egoData_linked.csv   ( 9 rows )

``` r
cat(" - alterData_linked.csv (", nrow(alterData_linked), "rows )\n")
```

     - alterData_linked.csv ( 135 rows )

``` r
cat(" - edgelist_linked.csv  (", nrow(edgelist_linked),  "rows )\n")
```

     - edgelist_linked.csv  ( 247 rows )

## 3. Tidy Alter-Level Dataset

The tidy alter dataset (one row per ego-alter dyad) is the analytic base
for all compositional measures and network visualizations. It retains
only the columns needed for downstream analysis.

``` r
tidy_alter <- alterData_linked |>
  dplyr::select(
    networkCanvasEgoUUID, networkCanvasUUID, nodeID,   # linking variables
    name, alter_gender, alter_age,                     # alter attributes
    ego_alter_interaction_frequency,                   # ego-alter attributes
    ego_alter_emotional_closeness,
    ego_alter_interaction_context,
    languageUsedCategory,                              # derived language categories
    languageKnownCategory,
    ego_alter_cs_frequency                             # outcome (NA = monolingual dyad)
  )

dplyr::glimpse(tidy_alter)
```

    Rows: 135
    Columns: 12
    $ networkCanvasEgoUUID            <chr> "4bc7e51b-a8af-4881-982e-12cfb2b1e9e3"…
    $ networkCanvasUUID               <chr> "e3b6a145-be19-4e17-b323-49cd77ae0411"…
    $ nodeID                          <dbl> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,…
    $ name                            <chr> "alter1", "alter2", "alter3", "alter4"…
    $ alter_gender                    <chr> "male", "female", "other", "male", "ot…
    $ alter_age                       <chr> "65_99", "0_9", "10_17", "65_99", "18_…
    $ ego_alter_interaction_frequency <dbl> 3, 4, 4, 1, 4, 1, 4, 3, 2, 2, 2, 5, 1,…
    $ ego_alter_emotional_closeness   <dbl> 1, 3, 2, 2, 2, 1, 4, 1, 4, 3, 4, 2, 1,…
    $ ego_alter_interaction_context   <chr> "family", "school", "social", "social"…
    $ languageUsedCategory            <chr> "Spanish-English", "Spanish-English", …
    $ languageKnownCategory           <chr> "Spanish-English", "Spanish-English", …
    $ ego_alter_cs_frequency          <dbl> 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,…

## 4. Build `egor` Object

The `egor` package provides a unified data structure for egocentric
network data that keeps all three levels linked. We use
`threefiles_to_egor()`, which stores alter data and alter-alter ties as
nested list columns (`.alts` and `.aaties`) within a single object.

This object is required for `egor::composition()` (§5.4) and
`egor::as_igraph()` (in `BiNet_network_visualization.qmd`).

``` r
# Color scheme for ego-alter language use categories
# Update labels to match your participant population's focal languages
lang_colors <- c(
  "Spanish"              = "#D73027",
  "English"              = "#2C5F8A",
  "Spanish-English"      = "#A8C8E8",
  "Other"                = "gray"
)
```

``` r
alter_for_egor <- alterData_linked |>
  dplyr::mutate(
    languageKnownCategory = factor(languageKnownCategory,
                                   levels = names(lang_colors))
  )

egor_obj <- egor::threefiles_to_egor(
  egos      = egoData_linked,
  alters.df = alter_for_egor,
  edges     = edgelist_linked,
  ID.vars   = list(
    ego    = "networkCanvasEgoUUID",
    alter  = "networkCanvasUUID",
    source = "networkCanvasSourceUUID",
    target = "networkCanvasTargetUUID"
  )
)
```

## 5. Compositional Measures

Compositional measures summarize *what* an ego’s network is made of by
aggregating alter-level variables up to the ego level. They are
constructed following a four-step pipeline:

1.  **Define a grouping variable** (an alter attribute, an ego-alter
    attribute, or a combination)
2.  **Compute a summary statistic** (mean or proportion) within each
    group for each ego
3.  **Pivot wide** so that each group becomes a separate ego-level
    column
4.  **Join** the result back to `egoData_linked` via
    `networkCanvasEgoUUID`

When no grouping variable is used (§5.1–§5.3), this reduces to a single
per-ego mean, which is structurally equivalent to a global self-report
item on a standard LHQ. Introducing grouping variables (§5.5 onward)
produces context-specific summaries that capture within-ego variation
invisible to a single global item.

### 5.1 Global CS Frequency Mean

*The simplest compositional measure: a single per-ego mean across all
alters.*

When based on a single alter attribute with no grouping, this is
structurally equivalent to a global CS frequency item from a standard
LHQ, which summarizes the ego’s average CS tendency across their whole
network.

``` r
# Note: na.rm = TRUE because monolingual dyads have NA cs_frequency by design
global_cs <- tidy_alter |>
  dplyr::group_by(networkCanvasEgoUUID) |>
  dplyr::summarise(
    mean_cs_global = mean(ego_alter_cs_frequency, na.rm = TRUE),
    n_cs_dyads     = sum(!is.na(ego_alter_cs_frequency)),
    .groups = "drop"
  )

egoData_linked <- egoData_linked |>
  dplyr::left_join(global_cs, by = "networkCanvasEgoUUID")

global_cs
```

    # A tibble: 9 × 3
      networkCanvasEgoUUID                 mean_cs_global n_cs_dyads
      <chr>                                         <dbl>      <int>
    1 06029b97-694c-41b8-807e-4cb07dca16a8           2.07         15
    2 22e0f2c8-ddde-4271-bb6b-e9ec7fa6da6b         NaN             0
    3 28202870-0e8a-4600-9434-c280eff762cd           4            15
    4 4bc7e51b-a8af-4881-982e-12cfb2b1e9e3           4            15
    5 82d2ef44-8636-4214-ba7b-4694793321d2           3.4           5
    6 96f49992-a293-45b1-bd84-ccedf42d66fc           3.4           5
    7 aff41946-2537-401a-a542-d53d6c177529         NaN             0
    8 f68dccfc-29d6-47ab-ab7e-93b5ace9c226           2.33          3
    9 fe801e88-5207-4550-a877-b072e25bebf4         NaN             0

### 5.2 Global Interaction Frequency Mean

A parallel global measure can be created for interaction frequency by
averaging how often the ego interacts with all nominated alters.

``` r
global_interaction <- tidy_alter |>
  dplyr::group_by(networkCanvasEgoUUID) |>
  dplyr::summarise(
    mean_interaction_global =
      mean(ego_alter_interaction_frequency, na.rm = TRUE),
    .groups = "drop"
  )

egoData_linked <- egoData_linked |>
  dplyr::left_join(global_interaction, by = "networkCanvasEgoUUID")

global_interaction
```

    # A tibble: 9 × 2
      networkCanvasEgoUUID                 mean_interaction_global
      <chr>                                                  <dbl>
    1 06029b97-694c-41b8-807e-4cb07dca16a8                    3.53
    2 22e0f2c8-ddde-4271-bb6b-e9ec7fa6da6b                    3.07
    3 28202870-0e8a-4600-9434-c280eff762cd                    3.2 
    4 4bc7e51b-a8af-4881-982e-12cfb2b1e9e3                    2.87
    5 82d2ef44-8636-4214-ba7b-4694793321d2                    2.8 
    6 96f49992-a293-45b1-bd84-ccedf42d66fc                    3.4 
    7 aff41946-2537-401a-a542-d53d6c177529                    2.6 
    8 f68dccfc-29d6-47ab-ab7e-93b5ace9c226                    3.27
    9 fe801e88-5207-4550-a877-b072e25bebf4                    2.47

### 5.3 Emotional Closeness

Another global compositional measure is emotional closeness, computed as
the mean closeness rating across all alters.

``` r
global_closeness <- tidy_alter |>
  dplyr::group_by(networkCanvasEgoUUID) |>
  dplyr::summarise(
    mean_closeness_global =
      mean(ego_alter_emotional_closeness, na.rm = TRUE),
    .groups = "drop"
  )

egoData_linked <- egoData_linked |>
  dplyr::left_join(global_closeness, by = "networkCanvasEgoUUID")

global_closeness
```

    # A tibble: 9 × 2
      networkCanvasEgoUUID                 mean_closeness_global
      <chr>                                                <dbl>
    1 06029b97-694c-41b8-807e-4cb07dca16a8                  3.47
    2 22e0f2c8-ddde-4271-bb6b-e9ec7fa6da6b                  2.47
    3 28202870-0e8a-4600-9434-c280eff762cd                  3.27
    4 4bc7e51b-a8af-4881-982e-12cfb2b1e9e3                  2.53
    5 82d2ef44-8636-4214-ba7b-4694793321d2                  2.87
    6 96f49992-a293-45b1-bd84-ccedf42d66fc                  3.33
    7 aff41946-2537-401a-a542-d53d6c177529                  3.07
    8 f68dccfc-29d6-47ab-ab7e-93b5ace9c226                  2.87
    9 fe801e88-5207-4550-a877-b072e25bebf4                  2.8 

### 5.4 Alter Language Composition

*What proportion of each ego’s alters belong to each language category?*

`egor::composition()` computes proportional frequencies of a categorical
alter attribute for every ego in one call, returning a wide ego-level
tibble. This is equivalent to the manual
`group_by → summarise → pivot_wider` pipeline but more concise.

``` r
lang_comp_ego <- egor::composition(egor_obj, alt.attr = "languageKnownCategory")
lang_comp_ego
```

    # A tibble: 9 × 4
      .egoID                               Spanish English `Spanish-English`
      <chr>                                  <dbl>   <dbl>             <dbl>
    1 06029b97-694c-41b8-807e-4cb07dca16a8  NA      NA                 1    
    2 22e0f2c8-ddde-4271-bb6b-e9ec7fa6da6b   0.467   0.533            NA    
    3 28202870-0e8a-4600-9434-c280eff762cd  NA      NA                 1    
    4 4bc7e51b-a8af-4881-982e-12cfb2b1e9e3  NA      NA                 1    
    5 82d2ef44-8636-4214-ba7b-4694793321d2   0.333   0.333             0.333
    6 96f49992-a293-45b1-bd84-ccedf42d66fc   0.333   0.333             0.333
    7 aff41946-2537-401a-a542-d53d6c177529   0.467   0.533            NA    
    8 f68dccfc-29d6-47ab-ab7e-93b5ace9c226  NA       0.8               0.2  
    9 fe801e88-5207-4550-a877-b072e25bebf4   0.467   0.533            NA    

``` r
egoData_linked <- egoData_linked |>
  dplyr::left_join(
    lang_comp_ego |> dplyr::rename(networkCanvasEgoUUID = .egoID),
    by = "networkCanvasEgoUUID"
  )
```

### 5.5 CS Frequency by Interaction Context

*Does the ego codeswitch more in one context than another?*

**Mean CS frequency grouped by the primary context of interaction.**
When grouped by context, the same CS mean reveals within-ego contextual
variation.

***Note on missing contexts.***  
Not all egos will have alters in every context. For example,
undergraduate participants may have no alters in the “work” context. In
such cases:  
- `n_context_* = 0` indicates that the ego has no alters in that
context  
- `cs_context_* = NA` indicates that the mean cannot be computed due to
no observations  
`0` reflects absence of ties, whereas `NA` reflects an undefined summary
statistic.

``` r
# Step 1: compute per-ego × context summaries
comp_context_long <- tidy_alter |>
  dplyr::group_by(
    networkCanvasEgoUUID,
    ego_alter_interaction_context
  ) |>
  dplyr::summarise(
    mean_cs       = mean(ego_alter_cs_frequency, na.rm = TRUE),
    n_per_context = dplyr::n(),
    .groups = "drop"
  )

# Step 2a: pivot mean CS wide
comp_context_mean <- comp_context_long |>
  tidyr::pivot_wider(
    id_cols      = networkCanvasEgoUUID,
    names_from   = ego_alter_interaction_context,
    values_from  = mean_cs,
    names_prefix = "cs_context_"
  )

# Step 2b: pivot counts wide
comp_context_n <- comp_context_long |>
  tidyr::pivot_wider(
    id_cols      = networkCanvasEgoUUID,
    names_from   = ego_alter_interaction_context,
    values_from  = n_per_context,
    names_prefix = "n_context_"
  )

# Step 2c: combine means + counts
comp_context_wide <- comp_context_mean |>
  dplyr::left_join(
    comp_context_n,
    by = "networkCanvasEgoUUID"
  )

# Step 3: join to egoData_linked
egoData_linked <- egoData_linked |>
  dplyr::left_join(
    comp_context_wide,
    by = "networkCanvasEgoUUID"
  )

comp_context_wide
```

    # A tibble: 9 × 11
      networkCanvasEgoUUID  cs_context_community cs_context_family cs_context_school
      <chr>                                <dbl>             <dbl>             <dbl>
    1 06029b97-694c-41b8-8…                  3                   4                 1
    2 22e0f2c8-ddde-4271-b…                NaN                 NaN               NaN
    3 28202870-0e8a-4600-9…                  4                   4                 4
    4 4bc7e51b-a8af-4881-9…                  4                   4                 4
    5 82d2ef44-8636-4214-b…                NaN                  NA                 4
    6 96f49992-a293-45b1-b…                  3.5               NaN               NaN
    7 aff41946-2537-401a-a…                NaN                 NaN               NaN
    8 f68dccfc-29d6-47ab-a…                  2                 NaN                 3
    9 fe801e88-5207-4550-a…                NaN                 NaN               NaN
    # ℹ 7 more variables: cs_context_social <dbl>, cs_context_work <dbl>,
    #   n_context_community <int>, n_context_family <int>, n_context_school <int>,
    #   n_context_social <int>, n_context_work <int>

### 5.6 Language Homophily

Language homophily captures how much of the ego’s network is associated
with each focal language in actual ego–alter communication. Following
Iniesta et al. (2024), each ego–alter tie is coded separately for each
language: TRUE if the ego uses that language with the alter, and FALSE
otherwise. An alter can count toward more than one language if the ego
uses multiple languages with that person. For example, an alter with
whom the ego uses both Spanish and English contributes to both Spanish
homophily and English homophily.  
For each ego, language homophily is calculated as the proportion of
nominated alters with whom the ego uses each focal language. Values
range from 0 to 1. Higher values indicate that a larger share of the
ego’s network uses that language in interaction.

``` r
# For each ego, compute the proportion of alters with whom the ego uses
# each focal language. An alter can contribute to both language proportions

lang_homophily <- alterData_linked |>
  dplyr::group_by(networkCanvasEgoUUID) |>
  dplyr::summarise(
    n_alters_lang_homophily = dplyr::n(),

    prop_spanish_homophily = mean(ego_alter_language_spanish, na.rm = TRUE),
    prop_english_homophily = mean(ego_alter_language_english, na.rm = TRUE),

    n_spanish_homophily = sum(ego_alter_language_spanish, na.rm = TRUE),
    n_english_homophily = sum(ego_alter_language_english, na.rm = TRUE),

    .groups = "drop"
  )

egoData_linked <- egoData_linked |>
  dplyr::left_join(lang_homophily, by = "networkCanvasEgoUUID")

lang_homophily
```

    # A tibble: 9 × 6
      networkCanvasEgoUUID             n_alters_lang_homoph…¹ prop_spanish_homophily
      <chr>                                             <int>                  <dbl>
    1 06029b97-694c-41b8-807e-4cb07dc…                     15                  1    
    2 22e0f2c8-ddde-4271-bb6b-e9ec7fa…                     15                  0.467
    3 28202870-0e8a-4600-9434-c280eff…                     15                  1    
    4 4bc7e51b-a8af-4881-982e-12cfb2b…                     15                  1    
    5 82d2ef44-8636-4214-ba7b-4694793…                     15                  0.667
    6 96f49992-a293-45b1-bd84-ccedf42…                     15                  0.667
    7 aff41946-2537-401a-a542-d53d6c1…                     15                  0.467
    8 f68dccfc-29d6-47ab-ab7e-93b5ace…                     15                  0.2  
    9 fe801e88-5207-4550-a877-b072e25…                     15                  0.467
    # ℹ abbreviated name: ¹​n_alters_lang_homophily
    # ℹ 3 more variables: prop_english_homophily <dbl>, n_spanish_homophily <int>,
    #   n_english_homophily <int>

### 5.7 Sanity Checks for Compositional Variables

Check compositional variables were successfully created and attached to
egoData_linked

``` r
expected_comp_vars <- c(
  "mean_cs_global",
  "n_cs_dyads",
  "mean_interaction_global",
  "mean_closeness_global",
  "Spanish",
  "English",
  "Spanish-English",
  "Other",
  "cs_context_family",
  "cs_context_community",
  "cs_context_school",
  "cs_context_work",
  "cs_context_social",
  "n_alters_lang_homophily",
  "prop_spanish_homophily",
  "prop_english_homophily",
  "n_spanish_homophily",
  "n_english_homophily"
)

existing_comp_vars <- intersect(expected_comp_vars, names(egoData_linked))
missing_comp_vars  <- setdiff(expected_comp_vars, names(egoData_linked))

cat("Existing compositional variables:\n")
```

    Existing compositional variables:

``` r
print(existing_comp_vars)
```

     [1] "mean_cs_global"          "n_cs_dyads"             
     [3] "mean_interaction_global" "mean_closeness_global"  
     [5] "Spanish"                 "English"                
     [7] "Spanish-English"         "cs_context_family"      
     [9] "cs_context_community"    "cs_context_school"      
    [11] "cs_context_work"         "cs_context_social"      
    [13] "n_alters_lang_homophily" "prop_spanish_homophily" 
    [15] "prop_english_homophily"  "n_spanish_homophily"    
    [17] "n_english_homophily"    

``` r
if (length(missing_comp_vars) > 0) {
  cat("\nMissing compositional variables (may be absent if no such alters/categories exist in this dataset):\n")
  print(missing_comp_vars)
}
```


    Missing compositional variables (may be absent if no such alters/categories exist in this dataset):
    [1] "Other"

``` r
egoData_linked |>
  dplyr::select(networkCanvasEgoUUID, dplyr::any_of(existing_comp_vars)) |>
  dplyr::glimpse()
```

    Rows: 9
    Columns: 18
    $ networkCanvasEgoUUID    <chr> "4bc7e51b-a8af-4881-982e-12cfb2b1e9e3", "fe801…
    $ mean_cs_global          <dbl> 4.000000, NaN, 2.333333, 3.400000, NaN, 3.4000…
    $ n_cs_dyads              <int> 15, 0, 3, 5, 0, 5, 15, 15, 0
    $ mean_interaction_global <dbl> 2.866667, 2.466667, 3.266667, 3.400000, 3.0666…
    $ mean_closeness_global   <dbl> 2.533333, 2.800000, 2.866667, 3.333333, 2.4666…
    $ Spanish                 <dbl> NA, 0.4666667, NA, 0.3333333, 0.4666667, 0.333…
    $ English                 <dbl> NA, 0.5333333, 0.8000000, 0.3333333, 0.5333333…
    $ `Spanish-English`       <dbl> 1.0000000, NA, 0.2000000, 0.3333333, NA, 0.333…
    $ cs_context_family       <dbl> 4, NaN, NaN, NaN, NaN, NaN, 4, 4, NaN
    $ cs_context_community    <dbl> 4.0, NaN, 2.0, 3.5, NaN, NaN, 4.0, 3.0, NaN
    $ cs_context_school       <dbl> 4, NaN, 3, NaN, NaN, 4, 4, 1, NaN
    $ cs_context_work         <dbl> 4.000000, NaN, NaN, 3.333333, NaN, NaN, 4.0000…
    $ cs_context_social       <dbl> 4.0, NaN, 2.0, NaN, NaN, 2.5, 4.0, 2.0, NaN
    $ n_alters_lang_homophily <int> 15, 15, 15, 15, 15, 15, 15, 15, 15
    $ prop_spanish_homophily  <dbl> 1.0000000, 0.4666667, 0.2000000, 0.6666667, 0.…
    $ prop_english_homophily  <dbl> 1.0000000, 0.5333333, 1.0000000, 0.6666667, 0.…
    $ n_spanish_homophily     <int> 15, 7, 3, 10, 7, 10, 15, 15, 7
    $ n_english_homophily     <int> 15, 8, 15, 10, 8, 10, 15, 15, 8

## 6. Save Data Outputs

``` r
output_dir <- "./Compositional measures"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

# Save tidy alter-level data
readr::write_csv(
  tidy_alter,
  file.path(output_dir, "binet_tidy_alter.csv")
)

# Save the full linked ego-level dataset
readr::write_csv(
  egoData_linked,
  file.path(output_dir, "binet_egoData_linked.csv")
)

# Save a clean ego-level compositional dataset containing only variables that exist
comp_vars_to_save <- c(
  "networkCanvasEgoUUID",
  "ego_id",
  "ego_gender",
  "ego_age",
  "ego_lang",
  "mean_cs_global",
  "n_cs_dyads",
  "mean_interaction_global",
  "mean_closeness_global",
  "Spanish",
  "English",
  "Spanish-English",
  "Other",
  "cs_context_family",
  "cs_context_community",
  "cs_context_school",
  "cs_context_work",
  "cs_context_social",
  "n_alters_lang_homophily",
  "prop_spanish_homophily",
  "prop_english_homophily",
  "n_spanish_homophily",
  "n_english_homophily"
  )

ego_compositional <- egoData_linked |>
  dplyr::select(dplyr::any_of(comp_vars_to_save))

readr::write_csv(
  ego_compositional,
  file.path(output_dir, "binet_ego_compositional.csv")
)

cat("Saved to:", normalizePath(output_dir), "\n")
```

    Saved to: /Users/monica/Downloads/BiNet-Tutorial/BiNet_preprocessing_compositional_Measures/Compositional measures 

``` r
cat("  binet_tidy_alter.csv         —", nrow(tidy_alter), "rows\n")
```

      binet_tidy_alter.csv         — 135 rows

``` r
cat("  binet_egoData_linked.csv     —", nrow(egoData_linked), "rows,", ncol(egoData_linked), "columns\n")
```

      binet_egoData_linked.csv     — 9 rows, 29 columns

``` r
cat("  binet_ego_compositional.csv  —", nrow(ego_compositional), "rows,", ncol(ego_compositional), "columns\n\n")
```

      binet_ego_compositional.csv  — 9 rows, 22 columns

``` r
cat("Columns in binet_ego_compositional.csv:\n")
```

    Columns in binet_ego_compositional.csv:

``` r
cat(paste0("  ", names(ego_compositional)), sep = "\n")
```

      networkCanvasEgoUUID
      ego_id
      ego_gender
      ego_age
      ego_lang
      mean_cs_global
      n_cs_dyads
      mean_interaction_global
      mean_closeness_global
      Spanish
      English
      Spanish-English
      cs_context_family
      cs_context_community
      cs_context_school
      cs_context_work
      cs_context_social
      n_alters_lang_homophily
      prop_spanish_homophily
      prop_english_homophily
      n_spanish_homophily
      n_english_homophily
