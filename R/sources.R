fieldwork_year <- function(first_date, last_date) {
  first <- as.Date(first_date)
  last <- as.Date(last_date)
  if (anyNA(first) || anyNA(last) || any(first > last)) stop("Invalid fieldwork dates")
  first_year <- as.integer(format(first, "%Y"))
  last_year <- as.integer(format(last, "%Y"))
  if (any(first_year != last_year)) stop("Fieldwork spans years; report a year range")
  first_year
}

with_study_year <- function(x, sources) {
  if (anyNA(sources$study) || anyDuplicated(sources$study)) stop("Study key must be unique")
  index <- match(x$study, sources$study)
  if (anyNA(index)) stop("Study lacks verified fieldwork dates")
  year <- fieldwork_year(sources$first_date[index], sources$last_date[index])
  if ("year" %in% names(x) && !identical(as.integer(x$year), year)) stop("Study year disagrees with dates")
  x$year <- year
  x
}

read_study <- function(path = "data/raw/luth2.rdata") {
  env <- new.env(parent = emptyenv())
  objects <- load(path, envir = env)
  if (!identical(objects, "luth2") || !is.data.frame(env$luth2)) {
    stop("Expected one data frame named luth2")
  }
  data <- env$luth2
  required <- c(
    "uniq", "complete", "ppage", "ppeduc", "race2", "ppgender",
    unlist(lapply(c("x", "y"), function(s) {
      paste0(c("status.", "agent.", "cleanag", "pcid.", "starttime."), s)
    }))
  )
  if (!all(required %in% names(data))) stop("Study schema is incomplete")
  if (anyNA(data$uniq) || anyDuplicated(data$uniq)) stop("Respondent key must be unique and observed")
  for (s in c("x", "y")) {
    status <- trimws(as.character(data[[paste0("status.", s)]]))
    if (any(!is.na(status) & !status %in% c("COMPLETED", "DROPOUT"))) {
      stop("Unrecognized survey status")
    }
    if (!identical(!is.na(status), !is.na(data[[paste0("pcid.", s)]]))) {
      stop("Status and participation marker disagree")
    }
  }
  data
}

blank_fields <- function(data, items) {
  if (
    !is.character(items) || !length(items) || anyDuplicated(items) ||
      !all(items %in% names(data))
  ) {
    stop("items must name distinct existing columns")
  }
  missing <- lapply(data[items], function(x) is.na(x) | trimws(as.character(x)) == "")
  rowSums(as.data.frame(missing))
}

component_data <- function(data, suffix, items) {
  if (length(suffix) != 1L || !suffix %in% c("x", "y")) stop("suffix must be x or y")
  status <- trimws(as.character(data[[paste0("status.", suffix)]]))
  started <- !is.na(status)
  browser <- browser_tokens(as.character(data[[paste0("agent.", suffix)]]))
  start_date <- as.Date(as.POSIXct(data[[paste0("starttime.", suffix)]],
    origin = "1582-10-14", tz = "UTC"
  ))
  # qd7y is coded 1 = 2009, 2 = 2008, ...; ppage copies that code.
  age <- as.integer(format(start_date, "%Y")) - (2010 - data$ppage)
  age[!is.na(age) & (age < 18 | age > 110)] <- NA_real_
  education <- cut(data$ppeduc, c(0, 7, 8, 11, 12, 15),
    labels = c(
      "Below high school", "High school", "Some college",
      "Bachelor", "Postgraduate"
    )
  )
  result <- data.frame(
    person = seq_len(nrow(data)),
    survey = if (suffix == "x") "Demographic" else "Political",
    completed = as.integer(status == "COMPLETED"), start_date,
    year = as.integer(format(start_date, "%Y")),
    historical_old = historical_browser(data[[paste0("cleanag", suffix)]]),
    age, education, race = factor(data$race2), female = data$ppgender,
    blanks = blank_fields(data, items), items = length(items), browser
  )
  result$controls_observed <- complete.cases(result[c("age", "education", "race", "female")])
  result[started, , drop = FALSE]
}
