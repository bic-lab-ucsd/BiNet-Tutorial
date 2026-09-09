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

input_path <- file.path(project_dir, "data", "jefwan37_tidy_alter.csv")
output_path <- file.path(project_dir, "data", "jefwan37_ego_compositional_wide.csv")

mean_or_na <- function(x) {
  observed <- x[!is.na(x)]
  if (length(observed) == 0L) NA_real_ else mean(observed)
}

alter <- read_csv(input_path, show_col_types = FALSE) |>
  mutate(
    # Analytic rule used in the manuscript: a monolingual interaction is a
    # genuine zero for code-switching, while a bilingual interaction keeps
    # the participant's 1--4 response.
    cs_zero_coded = case_when(
      languageUsedCategory %in% c("Mandarin", "English") ~ 0,
      languageUsedCategory == "Mandarin-English" ~ codeswitching_frequency,
      TRUE ~ NA_real_
    ),
    uses_mandarin = ego_uses_Mandarin,
    uses_english = ego_uses_English
  )

# In this worked example, L1 = Mandarin and L2 = English. A bilingual alter
# contributes to both homophily measures.
ego_profile <- tibble(
  participant_id = "jefwan37",
  ego_l1 = "Mandarin",
  ego_l2 = "English"
)

alter <- alter |>
  left_join(ego_profile, by = "participant_id") |>
  mutate(
    l1_match = case_when(
      ego_l1 == "Mandarin" ~ uses_mandarin,
      ego_l1 == "English" ~ uses_english,
      TRUE ~ NA
    ),
    l2_match = case_when(
      ego_l2 == "Mandarin" ~ uses_mandarin,
      ego_l2 == "English" ~ uses_english,
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
