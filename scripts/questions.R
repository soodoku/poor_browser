source("R/analysis.R")
source("R/signals.R")
source("R/sources.R")
read_signal <- function(name) read.csv(file.path("data/validation", paste0("signal_", name, ".csv")))
write_question <- function(x, name) {
  if ("study" %in% names(x)) x <- with_study_year(x, sources)
  write.csv(x, file.path("tabs", paste0(name, ".csv")), row.names = FALSE)
}
sources <- read_signal("sources")
write_question(sources, "q1_study_coverage")
historical_samples <- read.csv("tabs/samples.csv")
study_years <- rbind(
  data.frame(
    study = historical_samples$survey, year = historical_samples$year,
    first_date = historical_samples$first_date, last_date = historical_samples$last_date,
    basis = "Recorded start dates"
  ),
  data.frame(
    study = sources$study, year = sources$year,
    first_date = sources$first_date, last_date = sources$last_date,
    basis = "Recorded start dates"
  ),
  data.frame(
    study = "JSS user-agent corpus", year = NA_integer_, first_date = NA_character_,
    last_date = NA_character_, basis = "Fieldwork dates unverified; 2020 is publication year"
  )
)
write.csv(study_years, "tabs/study_years.csv", row.names = FALSE, na = "")
write_question(read_signal("coverage"), "q2_metadata_coverage")
cells <- read_signal("completion_cells")
contrasts <- data.frame(
  dimension = c("chrome_recency", "resolution"),
  exposed = c("Earlier major", "Below 600"), reference = c("Current major", "600 or more")
)
results <- lapply(seq_len(nrow(contrasts)), function(i) {
  a <- cells[cells$study == "July 2017" & cells$dimension == contrasts$dimension[i], ]
  counts <- function(g) {
    d <- a[a$group == g, ]
    c(events = sum(d$n[d$completed]), n = sum(d$n))
  }
  x <- counts(contrasts$exposed[i])
  y <- counts(contrasts$reference[i])
  data.frame(study = "July 2017", contrasts[i, ], binary_difference(x[1], x[2], y[1], y[2]))
})
write_question(do.call(rbind, results), "q3_completion")
write_question(read_signal("duration"), "q3_duration")
items <- read_signal("items")
intervals <- t(vapply(seq_len(nrow(items)), function(i) {
  wilson_interval(items$any_blank[i], items$respondents[i])
}, numeric(2)))
items$any_blank_rate <- items$any_blank / items$respondents
items$low <- intervals[, 1]
items$high <- intervals[, 2]
items$blank_item_rate <- items$blanks / items$submitted_item_records
write_question(items, "q3_answer_provision")
overall_items <- aggregate(
  cbind(respondents, submitted_item_records, blanks, explicit_dk, any_blank) ~ study + format,
  data = items, FUN = sum
)
overall_items$blank_item_rate <- overall_items$blanks / overall_items$submitted_item_records
overall_items$dk_item_rate <- overall_items$explicit_dk / overall_items$submitted_item_records
study_order <- match(overall_items$study, c("March 2017", "July 2017"))
overall_items <- overall_items[order(study_order, overall_items$format), ]
write_question(overall_items, "q3_answer_formats")
write_question(data.frame(
  question = c("Adjusted completion", "Added predictive information", "Composition", "Interface remedy"),
  status = c(
    "Not identified in current local data", "Awaiting eligible panel data",
    "Pre-participation profiles required", "Awaiting randomized-layout microdata"
  ),
  reason = c(
    "Late demographics exclude unfinished cases; completer-only files have no outcome variation",
    "No verified baseline profiles plus prior history and an independent survey/wave evaluation",
    "Observed completer demographics do not recover starter composition",
    "Observational gaps do not estimate the benefit of changing the interface"
  )
), "q4_q5_status")
text_groups <- read_signal("text_groups")
write_question(text_groups, "q3_text_length")
write_question(read_signal("text_coverage"), "q3_text_coverage")
write_question(read_signal("text_questions"), "q3_text_questions")
write_question(read_signal("text_influence"), "q3_text_influence")
text_contrasts <- list()
for (dimension in unique(text_groups$dimension)) {
  reference <- if (dimension == "os") "Desktop OS" else "Chrome"
  groups <- setdiff(unique(text_groups$group[text_groups$dimension == dimension]), c(reference, "Unknown"))
  for (outcome in unique(text_groups$outcome)) {
    d <- text_groups[text_groups$dimension == dimension & text_groups$outcome == outcome, ]
    b <- d[d$group == reference, ]
    for (group in groups) {
      a <- d[d$group == group, ]
      if (a$n < 2 || b$n < 2) next
      text_contrasts[[length(text_contrasts) + 1L]] <- data.frame(
        study = "March 2017", dimension, outcome, group, reference, welch_from_summary(a, b)
      )
    }
  }
}
write_question(do.call(rbind, text_contrasts), "q3_text_comparisons")
