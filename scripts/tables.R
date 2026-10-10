source("R/paper.R")
samples <- read_result("samples")
completion <- read_result("completion")
blanks <- read_result("blank_fields")
historical <- read_result("historical")
integrity <- read_result("integrity")
counts <- read_result("browser_counts")
mturk <- read.csv("data/validation/mturk_source.csv")
macros <- new.env(parent = emptyenv())
add_macro <- function(name, value) {
  assign(name, sprintf("\\newcommand{\\%s}{%s}", name, value), envir = macros)
}
add_macro("MergedN", integrity$value[integrity$metric == "merged_rows"])
add_macro("MergedColumns", integrity$value[integrity$metric == "merged_columns"])
add_macro("BothN", integrity$value[integrity$metric == "both_components"])
add_macro("UnderAgeN", integrity$value[integrity$metric == "under_18_birth_codes"])
add_macro("MturkN", mturk$records)
add_macro("MturkIncompleteN", mturk$incomplete)
july <- read.csv("data/validation/july_support.csv")
july_macros <- c(
  JulyExportN = "export_records", JulyN = "us_consented_records",
  JulyCompleted = "us_completed", JulyUnfinished = "us_unfinished",
  JulyMissingAge = "unfinished_age_missing", JulyMissingParty = "unfinished_party_id_missing"
)
for (name in names(july_macros)) {
  add_macro(name, july$value[july$metric == july_macros[[name]]])
}
jss <- read.csv("data/validation/jss_source.csv")
add_macro("JssN", format(jss$records, big.mark = ",", trim = TRUE))
add_macro("JssSurveys", jss$surveys)
add_macro("FieldDates", paste(
  format(as.Date(samples$first_date[1]), "%B %d"),
  "to", format(as.Date(samples$last_date[1]), "%B %d, %Y")
))
for (survey in samples$survey) {
  prefix <- if (survey == "Demographic") "Dem" else "Pol"
  s <- samples[samples$survey == survey, ]
  for (field in c("n", "completed", "dropout", "unknown_browser", "compatibility", "width_limit")) {
    suffix <- c(
      n = "N", completed = "Completed", dropout = "Dropout", unknown_browser = "Unknown",
      compatibility = "Compatibility", width_limit = "Truncated"
    )[[field]]
    add_macro(paste0(prefix, suffix), s[[field]])
  }
  for (spec in c("token", "installed", "no_compatibility")) {
    r <- completion[completion$survey == survey & completion$specification == spec, ]
    suffix <- c(token = "Token", installed = "Installed", no_compatibility = "Excluded")[[spec]]
    add_macro(paste0(prefix, suffix, "Gap"), sprintf("%.2f", 100 * r$estimate))
    add_macro(paste0(prefix, suffix, "CI"), sprintf("[%.2f, %.2f]", 100 * r$low, 100 * r$high))
    add_macro(paste0(prefix, suffix, "OldRate"), sprintf("%.1f", 100 * r$mean_old))
    add_macro(paste0(prefix, suffix, "OtherRate"), sprintf("%.1f", 100 * r$mean_other))
  }
  h <- historical[historical$survey == survey, ]
  add_macro(paste0(prefix, "OldP"), sprintf("%.3f", h$p_value[h$model == "completion_2023"]))
  add_macro(paste0(prefix, "NoteP"), sprintf("%.4f", h$p_value[h$model == "completion_2011"]))
  add_macro(paste0(prefix, "MissingP"), sprintf("%.3f", h$p_value[h$model == "missing_2023"]))
  compat <- counts[counts$survey == survey & counts$category == "IE8 compatibility", ]
  add_macro(paste0(prefix, "CompatibilityRate"), sprintf("%.1f", 100 * compat$rate))
}
add_macro("HistoricalMissingN", historical$n[historical$model == "missing_2023"][1])
add_macro("HistoricalMissingGap", sprintf("%.3f", historical$estimate[historical$model == "missing_2023"][1]))
writeLines(unlist(mget(sort(ls(macros)), envir = macros)), "tabs/macros.tex")

write_table(
  c("Survey", "Year", "Started", "Completed", "Dropout", "Unknown browser"),
  samples[c("survey", "year", "n", "completed", "dropout", "unknown_browser")],
  "lrrrrr", "tabs/samples.tex"
)
labels <- c(
  historical = "Historical regex", token = "Advertised version", installed = "Installed-version proxy",
  ie_firefox = "IE / Firefox only", no_compatibility = "Exclude compatibility"
)
rows <- data.frame(
  Survey = paste(completion$survey, completion$year),
  Coding = unname(labels[completion$specification]), N = completion$n,
  Gap = interval_text(completion$estimate, completion$low, completion$high, scale = 100)
)
write_table(
  c("Survey", "Browser coding", "$N$", "Gap in points [95\\% CI]"),
  rows, "llrr", "tabs/completion.tex"
)
rows <- data.frame(
  Survey = blanks$survey, Year = blanks$year, Items = blanks$items, N = blanks$n,
  Old = sprintf("%.3f", blanks$mean_old), Other = sprintf("%.3f", blanks$mean_other),
  Gap = interval_text(blanks$estimate, blanks$low, blanks$high, digits = 3)
)
write_table(
  c("Survey", "Year", "Fields", "$N$", "Legacy", "Other", "Difference [95\\% CI]"),
  rows, "lrrrrrr", "tabs/blank_fields.tex"
)
