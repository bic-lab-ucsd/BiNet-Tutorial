# Reproduce the manuscript's real-data compositional measures.
#
# Run from the repository root:
# Rscript BiNet_preprocessing_compositional_Measures/code/reproduce_jefwan37_measures.R

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
})

args <- commandArgs(trailingOnly = FALSE)
script_arg <- grep("^--file=", args, value = TRUE)
script_path <- if (length(script_arg)) sub("^--file=", "", script_arg[[1]]) else
  "BiNet_preprocessing_compositional_Measures/code/reproduce_jefwan37_measures.R"
project_dir <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)

raw_path <- file.path(project_dir, "data", "jefwan37_raw_flags.csv")
edge_path <- file.path(project_dir, "data", "jefwan37_alter_edges.csv")
lhq_path <- file.path(project_dir, "data", "jefwan37_lhq.csv")
tidy_reference_path <- file.path(project_dir, "data", "jefwan37_tidy_alter.csv")
output_path <- file.path(project_dir, "data", "jefwan37_ego_compositional_wide.csv")

mean_or_na <- function(x) {
  observed <- x[!is.na(x)]
  if (length(observed) == 0L) NA_real_ else mean(observed)
}

# Import the separate source levels and link the public, deidentified example
# with the same participant-ID logic used for full Network Canvas + LHQ data.
data_alter <- read_csv(raw_path, show_col_types = FALSE)
data_edgelist <- read_csv(edge_path, show_col_types = FALSE) |>
  mutate(participant_id = "jefwan37", .before = source)
lhq_df <- read_csv(lhq_path, show_col_types = FALSE)
data_ego <- data_alter |>
  distinct(participant_id)

egoData_linked <- data_ego |>
  left_join(lhq_df, by = "participant_id")
alterData_linked <- data_alter |>
  semi_join(egoData_linked, by = "participant_id")
edgelist_linked <- data_edgelist |>
  semi_join(egoData_linked, by = "participant_id")

stopifnot(
  nrow(egoData_linked) == 1L,
  nrow(alterData_linked) == 15L,
  nrow(edgelist_linked) == 21L,
  !anyDuplicated(alterData_linked$alter_label),
  all(c(edgelist_linked$source, edgelist_linked$target) %in%
        alterData_linked$alter_label),
  !anyNA(egoData_linked[c("ego_l1", "ego_l2")])
)

# Recode the binary Network Canvas indicators into the analysis variables.
alter <- alterData_linked |>
  mutate(
    languageKnownCategory = case_when(
      alter_knows_Mandarin & alter_knows_English ~ "Mandarin-English",
      alter_knows_Mandarin ~ "Mandarin",
      alter_knows_English ~ "English",
      TRUE ~ "Other"
    ),
    languageUsedCategory = case_when(
      ego_uses_Mandarin & ego_uses_English ~ "Mandarin-English",
      ego_uses_Mandarin ~ "Mandarin",
      ego_uses_English ~ "English",
      TRUE ~ "Other"
    ),
    interaction_context = case_when(
      household | extended_family ~ "family",
      community ~ "community",
      school ~ "school",
      work ~ "work",
      social ~ "social",
      TRUE ~ NA_character_
    ),
    # Analytic rule used in the manuscript: a monolingual interaction is a
    # genuine zero for code-switching, while a bilingual interaction keeps
    # the participant's 1--4 response.
    cs_zero_coded = case_when(
      languageUsedCategory %in% c("Mandarin", "English") ~ 0,
      languageUsedCategory == "Mandarin-English" ~ codeswitching_frequency,
      TRUE ~ NA_real_
    )
  )

# Confirm that the reconstructed tidy table matches the published artifact.
tidy_alter <- alter |>
  select(
    participant_id, alter_label, nodeID,
    languageKnownCategory, languageUsedCategory, interaction_context,
    emotional_closeness, interaction_frequency, codeswitching_frequency,
    alter_knows_Mandarin, alter_knows_English,
    ego_uses_Mandarin, ego_uses_English
  )
tidy_reference <- read_csv(tidy_reference_path, show_col_types = FALSE)

stopifnot(
  isTRUE(all.equal(
    as.data.frame(tidy_alter),
    as.data.frame(tidy_reference),
    check.attributes = FALSE
  ))
)

# Use the imported LHQ profile for ego-specific homophily. A bilingual alter
# contributes to both L1 and L2 homophily measures.
ego_profile <- egoData_linked |>
  select(participant_id, ego_l1, ego_l2)

alter <- alter |>
  left_join(ego_profile, by = "participant_id") |>
  mutate(
    l1_match = case_when(
      ego_l1 == "Mandarin" ~ ego_uses_Mandarin,
      ego_l1 == "English" ~ ego_uses_English,
      TRUE ~ NA
    ),
    l2_match = case_when(
      ego_l2 == "Mandarin" ~ ego_uses_Mandarin,
      ego_l2 == "English" ~ ego_uses_English,
      TRUE ~ NA
    )
  )

measure_in_context <- function(values, contexts, target) {
  mean_or_na(values[contexts == target])
}

prop_in_context <- function(flags, contexts, target) {
  mean_or_na(flags[contexts == target])
}

ego <- alter |>
  group_by(participant_id, ego_l1, ego_l2) |>
  summarise(
    cs_global = mean_or_na(cs_zero_coded),
    cs_family = measure_in_context(cs_zero_coded, interaction_context, "family"),
    cs_community = measure_in_context(cs_zero_coded, interaction_context, "community"),
    cs_social = measure_in_context(cs_zero_coded, interaction_context, "social"),
    cs_school = measure_in_context(cs_zero_coded, interaction_context, "school"),
    mandarin_global_prop = mean_or_na(languageUsedCategory == "Mandarin"),
    mandarin_family_prop = prop_in_context(languageUsedCategory == "Mandarin", interaction_context, "family"),
    mandarin_community_prop = prop_in_context(languageUsedCategory == "Mandarin", interaction_context, "community"),
    mandarin_social_prop = prop_in_context(languageUsedCategory == "Mandarin", interaction_context, "social"),
    prop_l1_homophily = mean_or_na(l1_match),
    prop_l2_homophily = mean_or_na(l2_match),
    .groups = "drop"
  ) |>
  select(
    participant_id, cs_global, cs_family, cs_community, cs_social, cs_school,
    mandarin_global_prop, mandarin_family_prop, mandarin_community_prop,
    mandarin_social_prop, ego_l1, ego_l2, prop_l1_homophily,
    prop_l2_homophily
  )

stopifnot(
  nrow(alter) == 15L,
  sum(alter$languageUsedCategory == "Mandarin") == 3L,
  sum(alter$languageUsedCategory == "English") == 5L,
  sum(alter$languageUsedCategory == "Mandarin-English") == 7L,
  isTRUE(all.equal(ego$cs_global, 1.5333333333, tolerance = 1e-9)),
  isTRUE(all.equal(ego$prop_l1_homophily, 10 / 15, tolerance = 1e-9)),
  isTRUE(all.equal(ego$prop_l2_homophily, 12 / 15, tolerance = 1e-9))
)

write_csv(ego, output_path)
print(ego, width = Inf)
