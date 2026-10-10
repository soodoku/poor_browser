source_dir <- Sys.getenv("LUTH_SOURCE_DIR", "../prospect_theory/data/luth/source")
mturk_path <- Sys.getenv("MTURK_SOURCE", "../hidden/data/raw/mturk_march_2017.csv")
source("R/sources.R")
source("R/browser.R")
raw <- read_study()
dir.create("data/validation", showWarnings = FALSE, recursive = TRUE)
checks <- list()
dictionary <- list()
for (s in c("x", "y")) {
  file <- if (s == "x") "dem.luth.sav" else "party.luth.sav"
  path <- file.path(source_dir, file)
  if (!file.exists(path)) stop("Missing source: ", path, "; set LUTH_SOURCE_DIR")
  original <- haven::read_sav(path)
  names(original) <- tolower(names(original))
  stopifnot(!anyNA(original$identifier), !anyDuplicated(original$identifier))
  index <- match(as.character(raw$uniq), trimws(original$identifier))
  matched <- !is.na(index)
  stopifnot(sum(matched) == nrow(original))
  if (s == "x") {
    stopifnot(
      isTRUE(all.equal(raw$ppage[matched], as.numeric(original$qd7y[index[matched]]))),
      isTRUE(all.equal(raw$ppeduc[matched], as.numeric(original$qd11[index[matched]])))
    )
  }
  for (field in c("agent", "status")) {
    stopifnot(identical(
      trimws(as.character(raw[[paste0(field, ".", s)]][matched])),
      trimws(as.character(original[[field]][index[matched]]))
    ))
  }
  checks[[s]] <- data.frame(
    source = file, sha256 = digest::digest(file = path, algo = "sha256"),
    rows = nrow(original), matched = sum(matched),
    status_disagreements = 0L, agent_disagreements = 0L,
    first_date = as.Date(min(original$starttime)), last_date = as.Date(max(original$starttime))
  )
  wanted <- if (s == "x") c("qd7y", "qd11", "qd8") else paste0("qk", 1:5)
  dictionary[[s]] <- do.call(rbind, lapply(wanted, function(name) {
    labels <- attr(original[[name]], "labels")
    data.frame(
      source = file, variable = name, label = attr(original[[name]], "label"),
      values = paste(names(labels), labels, sep = " = ", collapse = "; ")
    )
  }))
}
write.csv(do.call(rbind, checks), "data/validation/source_checks.csv", row.names = FALSE)
write.csv(do.call(rbind, dictionary), "data/validation/variable_labels.csv", row.names = FALSE)
if (!file.exists(mturk_path)) stop("Missing MTurk export; set MTURK_SOURCE")
mturk <- read.csv(mturk_path, check.names = FALSE, stringsAsFactors = FALSE)
stopifnot(grepl("ImportId", mturk$Finished[2]))
mturk <- mturk[-c(1, 2), ]
stopifnot(all(mturk$Finished %in% c("True", "False")))
counts <- as.data.frame(table(browser = mturk$meta_info_Browser, finished = mturk$Finished))
write.csv(counts, "data/validation/mturk_browser_counts.csv", row.names = FALSE)
write.csv(
  data.frame(
    source = basename(mturk_path),
    sha256 = digest::digest(file = mturk_path, algo = "sha256"),
    records = nrow(mturk), incomplete = sum(mturk$Finished == "False")
  ),
  "data/validation/mturk_source.csv",
  row.names = FALSE
)
message("Source checks passed; only aggregate counts and variable labels exported.")
