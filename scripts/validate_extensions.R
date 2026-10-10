paths <- c(
  "../hidden/data/raw/mturk_march_2017.csv",
  "../waters-of-casablanca/data/raw/mturk_july_2017.csv",
  "../waters-of-casablanca/data/raw/mturk_march_2017.csv",
  "../partisan-gaps/data/turk/mam_mturk_070917.csv",
  "../partisan-gaps/scripts/mam_mturk_070917.csv",
  "../misinformation/data/raw/mturk_july_2017.csv",
  "../partisan-gaps/data/turk/mturk-recoded.csv",
  "../partisan-gaps/data/turk/mturk-recoded-greaterthan7.csv",
  "../partisan-gaps/data/mturk_hk/hidden_knowledge_March 28, 2017_20.29.csv",
  "../partisan-gaps/data/mturk_hk/hidden_knowledge_March 27, 2017_14.38.csv",
  "../partisan-gaps/data/mturk_hk/mturk_hk_recoded.csv",
  "../partisan-gaps/data/mturk1.csv",
  "../extreme_recall_2023/data/lucid/er2_lucid_jan2023.csv",
  "../prospect_theory/data/protzko/source/StanfordProspectwithinsubjects2x2.dta",
  "../prospect_theory/data/protzko/source/StanfordProspectwithinsubjects2x2REPLICATE.dta"
)
read_candidate <- function(path) {
  if (!file.exists(path)) stop("Missing candidate: ", path)
  if (grepl("\\.dta$", path)) {
    return(haven::read_dta(path))
  }
  x <- read.csv(path, check.names = FALSE, colClasses = "character", na.strings = NULL)
  names(x) <- tolower(names(x))
  if (nrow(x) >= 2 && grepl("ImportId", x$finished[2], fixed = TRUE)) x <- x[-c(1, 2), ]
  if (!all(tolower(x$finished) %in% c("true", "false"))) stop("Unknown completion coding")
  x
}
count_observed <- function(x, pattern) {
  field <- grep(pattern, names(x), value = TRUE)
  if (!length(field)) {
    return(NA_integer_)
  }
  sum(!is.na(x[[field[1]]]) & nzchar(trimws(as.character(x[[field[1]]]))))
}
summary <- lapply(paths, function(path) {
  x <- read_candidate(path)
  has_completion <- "finished" %in% names(x)
  data.frame(
    path = path, sha256 = digest::digest(file = path, algo = "sha256"),
    records = nrow(x), completion_field = has_completion,
    completed = if (has_completion) sum(tolower(x$finished) == "true") else NA_integer_,
    unfinished = if (has_completion) sum(tolower(x$finished) == "false") else NA_integer_,
    browser_observed = count_observed(x, "browser|useragent"),
    version_observed = count_observed(x, "version")
  )
})
dir.create("data/validation", showWarnings = FALSE, recursive = TRUE)
write.csv(do.call(rbind, summary), "data/validation/local_candidates.csv", row.names = FALSE)

july <- read_candidate(paths[2])
stopifnot(!anyDuplicated(july$responseid), all(nzchar(july$responseid)))
sample <- july[july$consent == "I agree" & july$ccode == "US", ]
stopifnot(all(nzchar(sample$meta_info_browser)), all(nzchar(sample$meta_info_version)))
counts <- as.data.frame(table(browser = sample$meta_info_browser, finished = sample$finished))
counts <- counts[counts$Freq > 0, ]
write.csv(counts, "data/validation/july_browser_completion.csv", row.names = FALSE)
metrics <- c(
  export_records = nrow(july), export_unfinished = sum(july$finished == "False"),
  us_consented_records = nrow(sample), us_completed = sum(sample$finished == "True"),
  us_unfinished = sum(sample$finished == "False"),
  unfinished_browser_observed = sum(sample$finished == "False" & nzchar(sample$meta_info_browser)),
  unfinished_age_missing = sum(sample$finished == "False" & !nzchar(sample$age)),
  unfinished_party_id_missing = sum(sample$finished == "False" & !nzchar(sample$pid)),
  us_spam_flag = sum(sample$status == "Spam"),
  us_unfinished_without_spam = sum(sample$finished == "False" & sample$status != "Spam")
)
write.csv(
  data.frame(metric = names(metrics), value = unname(metrics)),
  "data/validation/july_support.csv",
  row.names = FALSE
)

jss_path <- Sys.getenv("JSS_UA_SOURCE")
if (nzchar(jss_path)) {
  x <- haven::read_dta(jss_path)
  stopifnot(identical(names(x), c("wave", "useragent")))
  write.csv(
    data.frame(
      source = "https://www.jstatsoft.org/article/download/v092c01/3903",
      sha256 = digest::digest(file = jss_path, algo = "sha256"),
      records = nrow(x), surveys = length(unique(x$wave)),
      fields = paste(names(x), collapse = "; "),
      nonblank_useragent = sum(!is.na(x$useragent) & nzchar(trimws(x$useragent)))
    ),
    "data/validation/jss_source.csv",
    row.names = FALSE
  )
}
message("Extension sources checked; only aggregate metadata exported.")
