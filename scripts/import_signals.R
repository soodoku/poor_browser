source("R/signals.R")
source("R/sources.R")
source("R/analysis.R")
source_root <- Sys.getenv("SOURCE_ROOT", "..")
paths <- c(
  "March 2017" = "hidden/data/raw/mturk_march_2017.csv",
  "July 2017" = "waters-of-casablanca/data/raw/mturk_july_2017.csv",
  "Lucid 2024" = "extreme_recall_2023/data/lucid/er2_lucid_jan2023.csv",
  "Stanford A" = "prospect_theory/data/protzko/source/StanfordProspectwithinsubjects2x2.dta",
  "Stanford B" = "prospect_theory/data/protzko/source/StanfordProspectwithinsubjects2x2REPLICATE.dta"
)
paths <- file.path(source_root, paths) |> setNames(names(paths))
long_path <- file.path(source_root, "partisan-gaps/data/mturk1.csv")
jss_path <- Sys.getenv("JSS_UA_SOURCE", "tmp/parseuas.dta")
required <- c(paths, long_path, jss_path, "docs/exposure_items.csv", "docs/text_items.csv")
if (!all(file.exists(required))) {
  stop("Missing source files: ", paste(required[!file.exists(required)], collapse = ", "))
}
exports <- lapply(paths[1:3], read_qualtrics_export)
stanford <- lapply(paths[4:5], haven::read_dta)
save_summary <- function(x, name) {
  if (startsWith(name, "text_")) x$study <- "March 2017"
  if (name == "parser_agreement") x$study <- "Lucid 2024"
  if ("study" %in% names(x)) x <- with_study_year(x, do.call(rbind, manifest))
  write.csv(x, file.path("data/validation", paste0("signal_", name, ".csv")), row.names = FALSE)
}
manifest <- list()
completion <- list()
durations <- list()
coverage <- list()
resolution_counts <- list()
items <- list()
mapping <- read.csv("docs/exposure_items.csv")
frequency <- function(study, dimension, group, completed) {
  a <- as.data.frame(table(group, completed, useNA = "ifany"))
  a <- a[a$Freq > 0, ]
  data.frame(study, dimension, group = a$group, completed = a$completed, n = a$Freq)
}
for (study in names(exports)) {
  raw <- exports[[study]]
  d <- raw
  if (study != "Lucid 2024") {
    keep <- !is.na(d$consent) & d$consent == "I agree" & !is.na(d$ccode) & d$ccode == "US"
    d <- d[keep, ]
  }
  exports[[study]] <- d
  prefix <- if (study == "Lucid 2024") "q7.1_" else "meta_info_"
  browser <- d[[paste0(prefix, "browser")]]
  version <- d[[paste0(prefix, "version")]]
  os <- d[[paste0(prefix, "operating system")]]
  resolution <- d[[paste0(prefix, "resolution")]]
  group <- resolution_group(resolution)
  finished <- tolower(d$finished) == "true"
  coverage[[study]] <- data.frame(
    study,
    status = c("Finished", "Unfinished"),
    n = c(sum(finished), sum(!finished)),
    browser_observed = c(sum(finished & !is.na(browser)), sum(!finished & !is.na(browser))),
    resolution_observed = c(sum(finished & group != "Unknown"), sum(!finished & group != "Unknown"))
  )
  manifest[[study]] <- data.frame(
    study,
    path = paths[[study]], sha256 = digest::digest(file = paths[[study]], algo = "sha256"),
    raw_records = nrow(raw), analysis_records = nrow(d), completed = sum(finished),
    unfinished = sum(!finished), first_date = min(substr(d$startdate, 1, 10)),
    last_date = max(substr(d$startdate, 1, 10)), universe = "Recorded finished responses for duration"
  )
  completion[[study]] <- rbind(
    frequency(study, "resolution", group, finished),
    frequency(study, "browser", ifelse(is.na(browser), "Unknown", browser), finished)
  )
  resolution_counts[[study]] <- frequency(
    study, "recorded_resolution",
    ifelse(is.na(resolution), "Unknown", resolution), finished
  )
  if (study == "July 2017") {
    chrome <- desktop_chrome_group(browser, version, os)
    completion[[study]] <- rbind(completion[[study]], frequency(study, "chrome_recency", chrome, finished))
  }
  seconds <- suppressWarnings(as.numeric(d[["duration (in seconds)"]]))
  durations[[study]] <- rbind(
    transform(duration_summary(study, os_group(os)[finished], seconds[finished]), dimension = "os"),
    transform(duration_summary(study, group[finished], seconds[finished]), dimension = "resolution")
  )
  m <- mapping[mapping$study == study, ]
  if (nrow(m)) items[[study]] <- submitted_items(d, m, study, group)
}
for (study in names(stanford)) {
  d <- stanford[[study]]
  stopifnot(!anyNA(d$v1), !anyDuplicated(d$v1))
  stopifnot(isTRUE(all.equal(as.numeric(d$q_totalduration) / 60, as.numeric(d$duration), tolerance = 1e-6)))
  keep <- is.na(clean_text(d$q_terminateflag))
  dates <- as.Date(d$v8, format = "%m/%d/%Y")
  manifest[[study]] <- data.frame(
    study,
    path = paths[[study]], sha256 = digest::digest(file = paths[[study]], algo = "sha256"),
    raw_records = nrow(d), analysis_records = sum(keep), completed = NA_integer_, unfinished = NA_integer_,
    first_date = as.character(min(dates)), last_date = as.character(max(dates)),
    universe = "Retained records with no screenout flag; completion status unverified"
  )
  durations[[study]] <- rbind(
    transform(
      duration_summary(study, os_group(d$useragent[keep]), d$q_totalduration[keep]),
      dimension = "os"
    ),
    transform(duration_summary(study, os_group(d$useragent), d$q_totalduration), dimension = "os_all_records")
  )
  coverage[[study]] <- data.frame(study,
    status = "Retained; status unverified", n = sum(keep),
    browser_observed = sum(!is.na(clean_text(d$useragent[keep]))), resolution_observed = NA_integer_
  )
}
save_summary(do.call(rbind, manifest), "sources")
save_summary(do.call(rbind, completion), "completion_cells")
save_summary(do.call(rbind, durations), "duration")
save_summary(do.call(rbind, coverage), "coverage")
save_summary(do.call(rbind, resolution_counts), "resolution_counts")

long <- read.csv(long_path, colClasses = "character")
stopifnot(all(table(long$responseid) == 9L))
stopifnot(all(long$responseid %in% exports[["July 2017"]]$responseid))
overlap <- data.frame(
  comparison = c(
    "MTurk long file: rows", "MTurk long file: response IDs", "MTurk long IDs outside July",
    "Stanford A: repeated panel-ID records", "Stanford cross-file panel-ID overlap"
  ),
  n = c(
    nrow(long), length(unique(long$responseid)),
    sum(!unique(long$responseid) %in% exports[["July 2017"]]$responseid),
    sum(duplicated(stanford[[1]]$psid)), length(intersect(stanford[[1]]$psid, stanford[[2]]$psid))
  )
)
save_summary(overlap, "overlap")

item_data <- do.call(rbind, items)
parts <- split(item_data, interaction(item_data$study, item_data$format, item_data$resolution, drop = TRUE))
item_summary <- lapply(parts, function(d) {
  person <- aggregate(cbind(blank, dont_know) ~ person, d, sum)
  data.frame(
    study = d$study[1], format = d$format[1], resolution = d$resolution[1],
    respondents = nrow(person), submitted_item_records = nrow(d), blanks = sum(d$blank),
    explicit_dk = sum(d$dont_know), any_blank = sum(person$blank > 0),
    unfinished_respondents = length(unique(d$person[!d$completed]))
  )
})
save_summary(do.call(rbind, item_summary), "items")

lucid <- exports[["Lucid 2024"]]
reported <- sub(" (iPhone|iPad)$", "", lucid$q7.1_browser)
reported[reported == "MSIE"] <- "IE"
parsed <- ua_family(lucid$useragent)
comparison <- ifelse(is.na(reported), "Reported metadata missing",
  ifelse(parsed == "Unknown", "Raw string unresolved",
    ifelse(reported == parsed, "Agreement", "Different family labels")
  )
)
save_summary(as.data.frame(table(comparison)), "parser_agreement")

jss <- haven::read_dta(jss_path)
stopifnot(identical(names(jss), c("wave", "useragent")))
save_summary(as.data.frame(table(family = ua_family(jss$useragent))), "parser_coverage")
save_summary(data.frame(
  source = required,
  sha256 = vapply(required, function(p) {
    digest::digest(file = p, algo = "sha256")
  }, character(1))
), "provenance")
march <- exports[["March 2017"]]
text_map <- read.csv("docs/text_items.csv")
text_items <- lapply(seq_len(nrow(text_map)), function(j) {
  timer <- as.numeric(march[[text_map$timer[j]]])
  submitted <- is.finite(timer) & timer > 0
  data.frame(
    person = march$responseid, question = text_map$question[j], submitted,
    text_lengths(march[[text_map$item[j]]])
  )
})
text_pages <- do.call(rbind, text_items)
stopifnot(!anyDuplicated(text_pages[c("person", "question")]))
save_summary(do.call(rbind, lapply(text_items, function(d) {
  use <- d$submitted
  data.frame(
    question = d$question[1], records = nrow(d), submitted = sum(use),
    blanks = sum(d$blank[use]), nonblank = sum(!d$blank[use]),
    mean_characters_nonblank = mean(d$characters[use & !d$blank]),
    mean_words_nonblank = mean(d$words[use & !d$blank])
  )
})), "text_coverage")
complete <- Reduce(`&`, lapply(text_items, function(d) d$submitted))
person_chars <- Reduce(`+`, lapply(text_items, function(d) d$characters))[complete] / nrow(text_map)
person_words <- Reduce(`+`, lapply(text_items, function(d) d$words))[complete] / nrow(text_map)
browser <- sub(" (iPhone|iPad)$", "", march$meta_info_browser[complete])
browser[browser == "MSIE"] <- "IE"
browser[is.na(browser)] <- "Unknown"
os <- os_group(march[["meta_info_operating system"]][complete])
text_groups <- list()
for (outcome in c("characters", "words", "log_characters")) {
  x <- switch(outcome,
    characters = person_chars,
    words = person_words,
    log_characters = log1p(person_chars)
  )
  text_groups[[outcome]] <- rbind(
    length_summary(x, browser, "browser", outcome),
    length_summary(x, os, "os", outcome),
    length_summary(x[os == "Desktop OS"], browser[os == "Desktop OS"], "desktop_browser", outcome)
  )
}
save_summary(do.call(rbind, text_groups), "text_groups")
page_groups <- lapply(text_items, function(d) {
  use <- d$submitted
  groups <- sub(" (iPhone|iPad)$", "", march$meta_info_browser[use])
  groups[groups == "MSIE"] <- "IE"
  groups[is.na(groups)] <- "Unknown"
  rbind(
    transform(length_summary(d$characters[use], groups, "browser", "characters"), question = d$question[1]),
    transform(length_summary(
      d$characters[use], os_group(march[["meta_info_operating system"]][use]),
      "os", "characters"
    ), question = d$question[1])
  )
})
save_summary(do.call(rbind, page_groups), "text_questions")
x <- person_chars[os == "Mobile OS"]
y <- person_chars[os == "Desktop OS"]
deleted <- c(
  (sum(x) - x) / (length(x) - 1) - mean(y),
  mean(x) - (sum(y) - y) / (length(y) - 1)
)
save_summary(data.frame(
  contrast = "Mobile minus desktop: mean characters",
  estimate = mean(x) - mean(y), deletion_low = min(deleted), deletion_high = max(deleted)
), "text_influence")
message("Imported signals: aggregate summaries only; no respondent records written.")
