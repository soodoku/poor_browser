clean_text <- function(x) {
  x <- trimws(as.character(x))
  x[is.na(x) | x %in% c("", "NA", "NULL")] <- NA_character_
  x
}

read_qualtrics_export <- function(path) {
  x <- read.csv(path, check.names = FALSE, colClasses = "character", na.strings = NULL)
  names(x) <- tolower(names(x))
  if (anyDuplicated(names(x))) stop("Duplicate export columns")
  if (nrow(x) >= 2L && grepl("ImportId", x$finished[2], fixed = TRUE)) x <- x[-c(1, 2), ]
  x[] <- lapply(x, clean_text)
  if (!all(tolower(x$finished) %in% c("true", "false"))) stop("Unknown completion coding")
  if (anyNA(x$responseid) || anyDuplicated(x$responseid)) stop("Response key must be unique")
  x
}

resolution_group <- function(x) {
  x <- clean_text(x)
  ok <- !is.na(x) & grepl("^[1-9][0-9]*x[1-9][0-9]*$", x)
  short <- rep(NA_real_, length(x))
  short[ok] <- vapply(strsplit(x[ok], "x", fixed = TRUE), function(z) min(as.numeric(z)), numeric(1))
  ifelse(is.na(short), "Unknown", ifelse(short < 600, "Below 600", "600 or more"))
}

os_group <- function(x) {
  x <- tolower(clean_text(x))
  group <- rep("Unknown", length(x))
  group[grepl("windows|macintosh|mac os|cros|linux|ubuntu|x11", x)] <- "Desktop OS"
  group[grepl("android|iphone|ipad|ipod|windows phone", x)] <- "Mobile OS"
  group
}

ua_family <- function(x) {
  x <- tolower(clean_text(x))
  group <- rep("Unknown", length(x))
  group[grepl("safari/", x)] <- "Safari"
  group[grepl("firefox/|fxios/", x)] <- "Firefox"
  group[grepl("chrome/|crios/", x)] <- "Chrome"
  group[grepl("msie |trident/", x)] <- "IE"
  group[grepl("edge/|edg/|edga/|edgios/", x)] <- "Edge"
  group[grepl("opera|opr/|opios/", x)] <- "Opera"
  group[grepl("samsungbrowser/", x)] <- "Samsung"
  group
}

desktop_chrome_group <- function(browser, version, os, stable_major = 59L) {
  major <- suppressWarnings(as.integer(sub("\\..*", "", clean_text(version))))
  desktop <- grepl("Windows|Macintosh|Linux|Ubuntu|X11", os, ignore.case = TRUE) &
    !grepl("Android|Windows Phone", os, ignore.case = TRUE)
  use <- !is.na(browser) & browser == "Chrome" & desktop & !is.na(major)
  out <- rep("Outside comparison", length(browser))
  out[use & major < stable_major] <- "Earlier major"
  out[use & major == stable_major] <- "Current major"
  out[use & major > stable_major] <- "Above stable major"
  out
}

binary_difference <- function(events, total, reference_events, reference_total) {
  a <- wilson_interval(events, total)
  b <- wilson_interval(reference_events, reference_total)
  p <- events / total
  q <- reference_events / reference_total
  data.frame(
    n = total, reference_n = reference_total, rate = p, reference_rate = q,
    estimate = p - q,
    low = p - q - sqrt((p - a[1])^2 + (b[2] - q)^2),
    high = p - q + sqrt((a[2] - p)^2 + (q - b[1])^2)
  )
}

submitted_items <- function(raw, mapping, study, resolution) {
  if (!all(c("item", "timer", "format") %in% names(mapping))) stop("Incomplete item map")
  if (!all(c(mapping$item, mapping$timer) %in% names(raw))) stop("Mapped field is absent")
  result <- lapply(seq_len(nrow(mapping)), function(j) {
    time <- suppressWarnings(as.numeric(raw[[mapping$timer[j]]]))
    keep <- !is.na(time) & is.finite(time) & time > 0
    answer <- clean_text(raw[[mapping$item[j]]][keep])
    data.frame(
      study,
      person = raw$responseid[keep], item = mapping$item[j],
      format = mapping$format[j], resolution = resolution[keep],
      blank = is.na(answer),
      dont_know = !is.na(answer) & grepl("don.t know|do not know", answer, ignore.case = TRUE),
      completed = tolower(raw$finished[keep]) == "true"
    )
  })
  out <- do.call(rbind, result)
  if (anyDuplicated(out[c("person", "item")])) stop("Repeated respondent-item")
  out
}

duration_summary <- function(study, group, seconds) {
  do.call(rbind, lapply(sort(unique(group)), function(g) {
    x <- seconds[group == g]
    use <- is.finite(x) & x > 0
    q <- if (any(use)) quantile(x[use] / 60, c(.25, .5, .75), names = FALSE) else rep(NA_real_, 3)
    data.frame(study,
      group = g, records = length(x), observed = sum(use),
      excluded = sum(!use), q25 = q[1], median = q[2], q75 = q[3]
    )
  }))
}

text_lengths <- function(x) {
  x <- trimws(as.character(x), whitespace = "[\\h\\v]")
  blank <- is.na(x) | x == ""
  x[blank] <- ""
  data.frame(
    blank,
    characters = nchar(x, type = "chars", keepNA = TRUE),
    words = ifelse(blank, 0L, lengths(strsplit(x, "[[:space:]]+")))
  )
}

length_summary <- function(x, group, dimension, outcome) {
  do.call(rbind, lapply(sort(unique(group)), function(g) {
    y <- x[group == g]
    stopifnot(all(is.finite(y)))
    q <- quantile(y, c(.25, .5, .75), names = FALSE)
    data.frame(dimension,
      group = g, outcome, n = length(y), mean = mean(y),
      variance = if (length(y) > 1) var(y) else NA_real_,
      q25 = q[1], median = q[2], q75 = q[3]
    )
  }))
}

welch_from_summary <- function(a, b) {
  if (a$n < 2 || b$n < 2) stop("Welch comparison needs two observations per group")
  v <- c(a$variance / a$n, b$variance / b$n)
  se <- sqrt(sum(v))
  df <- sum(v)^2 / sum(v^2 / (c(a$n, b$n) - 1))
  if (!is.finite(df) || se <= 0) stop("Welch comparison needs positive variance")
  estimate <- a$mean - b$mean
  data.frame(
    n = a$n, reference_n = b$n, estimate, se, df,
    low = estimate - qt(.975, df) * se, high = estimate + qt(.975, df) * se
  )
}
