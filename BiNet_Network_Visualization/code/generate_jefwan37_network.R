# Reproduce manuscript Figure 8 from the included jefwan37 data.
#
# Run from the repository root:
# Rscript BiNet_Network_Visualization/code/generate_jefwan37_network.R

args <- commandArgs(trailingOnly = FALSE)
script_arg <- grep("^--file=", args, value = TRUE)
script_path <- if (length(script_arg)) sub("^--file=", "", script_arg[[1]]) else
  "BiNet_Network_Visualization/code/generate_jefwan37_network.R"
script_dir <- normalizePath(dirname(script_path), mustWork = TRUE)
repo_dir <- normalizePath(file.path(script_dir, "..", ".."), mustWork = TRUE)
data_dir <- file.path(repo_dir, "BiNet_preprocessing_compositional_Measures", "data")
output_dir <- file.path(repo_dir, "BiNet_Network_Visualization", "figures")

alters <- read.csv(
  file.path(data_dir, "jefwan37_tidy_alter.csv"),
  stringsAsFactors = FALSE,
  check.names = FALSE
)
edges <- read.csv(
  file.path(data_dir, "jefwan37_alter_edges.csv"),
  stringsAsFactors = FALSE,
  check.names = FALSE
)

stopifnot(
  nrow(alters) == 15L,
  nrow(edges) == 21L,
  all(c("source", "target") %in% names(edges)),
  all(c(
    "alter_label", "languageUsedCategory", "interaction_context",
    "emotional_closeness"
  ) %in% names(alters)),
  all(c(edges$source, edges$target) %in% alters$alter_label)
)

language_colors <- c(
  "Mandarin" = "#E43D30",
  "English" = "#2E628E",
  "Mandarin-English" = "#A9CBE8"
)

circle_positions <- function(labels, radius = 0.83) {
  angles <- pi / 2 + 2 * pi * (seq_along(labels) - 1) / length(labels)
  data.frame(
    alter_label = labels,
    x = radius * cos(angles),
    y = radius * sin(angles),
    stringsAsFactors = FALSE
  )
}

context_positions <- function(alter_data) {
  ranges <- list(
    family = c(100, 178),
    social = c(12, 80),
    community = c(205, 255),
    school = c(285, 335)
  )
  placed <- lapply(names(ranges), function(context) {
    labels <- alter_data$alter_label[alter_data$interaction_context == context]
    if (!length(labels)) return(NULL)
    limits <- ranges[[context]]
    degrees <- if (length(labels) == 1L) mean(limits) else
      seq(limits[1], limits[2], length.out = length(labels))
    radius <- rep(c(0.76, 1.05), length.out = length(labels))
    angles <- degrees * pi / 180
    data.frame(
      alter_label = labels,
      x = radius * cos(angles),
      y = radius * sin(angles),
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, placed)
}

draw_panel <- function(alter_data, edge_data, positions,
                       scale_closeness = FALSE, show_contexts = FALSE,
                       panel_label = "A") {
  plot(
    NA, NA,
    xlim = c(-1.25, 1.25), ylim = c(-1.18, 1.18), asp = 1,
    axes = FALSE, xlab = "", ylab = "", bty = "n"
  )

  if (show_contexts) {
    abline(h = 0, v = 0, col = "#D4D4D4", lwd = 1.2)
    text(-0.88, 1.08, "FAMILY", font = 2)
    text(0.88, 1.08, "SOCIAL", font = 2)
    text(-0.88, -1.08, "COMMUNITY", font = 2)
    text(0.88, -1.08, "SCHOOL", font = 2)
  }

  pos <- positions[match(alter_data$alter_label, positions$alter_label), ]
  rownames(pos) <- alter_data$alter_label

  for (i in seq_len(nrow(edge_data))) {
    from <- pos[edge_data$source[i], ]
    to <- pos[edge_data$target[i], ]
    segments(from$x, from$y, to$x, to$y, col = "#A0A0A0", lwd = 1.2, lty = 2)
  }

  segments(0, 0, pos$x, pos$y, col = "#303030", lwd = 1.1)
  node_cex <- if (scale_closeness) {
    1.15 + 0.32 * alter_data$emotional_closeness
  } else {
    rep(2.15, nrow(alter_data))
  }
  points(
    pos$x, pos$y,
    pch = 21, cex = node_cex,
    bg = unname(language_colors[alter_data$languageUsedCategory]),
    col = "#202020", lwd = 1.1
  )
  points(0, 0, pch = 21, cex = 2.25, bg = "white", col = "#202020", lwd = 1.4)
  text(0, 0, "Ego", cex = 0.9)
  mtext(panel_label, side = 3, adj = 0, line = 0.3, font = 2, cex = 1.35)
}

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
output_path <- file.path(output_dir, "fig08_network_views_jefwan37.png")
png(output_path, width = 3480, height = 2040, res = 300, bg = "white")
layout(matrix(c(1, 2, 3, 3), nrow = 2, byrow = TRUE), heights = c(5.1, 0.9))
par(mar = c(0.2, 0.2, 1.2, 0.2))
draw_panel(
  alters, edges, circle_positions(alters$alter_label),
  scale_closeness = FALSE, panel_label = "A"
)
draw_panel(
  alters, edges, context_positions(alters),
  scale_closeness = TRUE, show_contexts = TRUE, panel_label = "B"
)

par(mar = rep(0, 4))
plot.new()
plot.window(xlim = c(0, 1), ylim = c(0, 1))
legend(
  x = 0.05, y = 0.88,
  legend = c("Ego", names(language_colors)),
  pt.bg = c("white", unname(language_colors)),
  pch = 21, pt.cex = 1.5,
  col = "#202020", horiz = TRUE, bty = "n", xpd = NA,
  x.intersp = 0.8
)
legend(
  x = 0.08, y = 0.38,
  legend = c("Ego-alter tie", "Alter-alter tie"),
  col = c("#303030", "#A0A0A0"), lty = c(1, 2), lwd = 1.2,
  horiz = TRUE, bty = "n", xpd = NA, seg.len = 2.2
)
text(0.78, 0.64, "Panel B emotional closeness", cex = 0.9)
closeness_values <- c(1, 3, 5)
closeness_x <- c(0.70, 0.80, 0.90)
points(
  closeness_x, rep(0.28, 3), pch = 21,
  cex = 1.15 + 0.32 * closeness_values,
  bg = "#D9D9D9", col = "#202020"
)
text(closeness_x + 0.035, rep(0.28, 3), labels = closeness_values, adj = 0)
dev.off()

message(output_path)
