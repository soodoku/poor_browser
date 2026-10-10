source("R/browser.R")
source("R/sources.R")
source("R/analysis.R")
source("R/historical.R")

dir.create("tabs", showWarnings = FALSE)
write_result <- function(data, name) {
  if ("survey" %in% names(data)) {
    years <- vapply(components, function(d) fieldwork_year(min(d$start_date), max(d$start_date)), integer(1))
    data$year <- unname(years[data$survey])
    if (anyNA(data$year)) stop("Survey lacks verified fieldwork dates")
  }
  write.csv(data, file.path("tabs", paste0(name, ".csv")), row.names = FALSE, na = "")
}
raw <- read_study()
items <- read.csv("docs/items.csv")
components <- list(
  Demographic = component_data(raw, "x", items$column[items$survey == "Demographic"]),
  Political = component_data(raw, "y", items$column[items$survey == "Political"])
)
combine <- function(fun) do.call(rbind, lapply(components, fun))
write_result(combine(completion_specs), "completion")
write_result(combine(browser_counts), "browser_counts")
write_result(combine(completion_checks), "completion_checks")
write_result(combine(leave_one_out_range), "influence")
write_result(combine(unknown_browser_bounds), "unknown_browser_bounds")
write_result(historical_results(raw), "historical")
write_result(combine(function(d) {
  data.frame(
    survey = d$survey[1], n = nrow(d), completed = sum(d$completed),
    dropout = sum(d$completed == 0), unknown_browser = sum(is.na(d$old)),
    compatibility = sum(d$compatibility), width_limit = sum(d$at_width_limit),
    controls_observed = sum(d$controls_observed),
    dropouts_with_controls = sum(d$controls_observed & d$completed == 0),
    first_date = min(d$start_date), last_date = max(d$start_date)
  )
}), "samples")
write_result(combine(function(d) {
  d <- d[d$completed == 1, ]
  data.frame(
    survey = d$survey[1], items = d$items[1],
    mean_difference(d$blanks, d$old)
  )
}), "blank_fields")
write_result(combine(function(d) {
  do.call(rbind, lapply(c(FALSE, TRUE), function(complete_controls) {
    a <- d[d$controls_observed == complete_controls, ]
    data.frame(
      survey = d$survey[1], controls_observed = complete_controls,
      n = nrow(a), completed = sum(a$completed), dropout = sum(a$completed == 0)
    )
  }))
}), "selection")
write_result(combine(function(d) {
  old <- ifelse(d$historical_old, "Legacy regex", "Other regex")
  new <- ifelse(is.na(d$old), "Unknown", ifelse(d$old, "Legacy token", "Other recognized"))
  tab <- as.data.frame(table(old, new))
  data.frame(survey = d$survey[1], tab)
}), "reclassification")
write_result(data.frame(
  metric = c(
    "merged_rows", "merged_columns", "experiment_completed", "both_components",
    "same_agent_both", "under_18_birth_codes", "constant_missing_columns",
    "stored_missing_equals_recomputed"
  ),
  value = c(
    nrow(raw), ncol(raw), sum(raw$complete == "COMPLETED"),
    sum(!is.na(raw$status.x) & !is.na(raw$status.y)),
    sum(trimws(as.character(raw$agent.x)) == trimws(as.character(raw$agent.y)), na.rm = TRUE),
    sum(raw$ppage - 1 < 18, na.rm = TRUE), sum(colSums(is.na(raw)) == nrow(raw)),
    all(raw$na == rowSums(is.na(raw)))
  )
), "integrity")
capture.output(sessionInfo(), file = "tabs/session-info.txt")
