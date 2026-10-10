source(file.path(root, "R/signals.R"))

testthat::test_that("fieldwork years follow timestamps and joins preserve study identity", {
  s <- data.frame(
    study = c("filename_2023", "Stanford"),
    first_date = c("2024-01-06", "2018-02-14"), last_date = c("2024-01-07", "2018-03-25")
  )
  x <- data.frame(study = c("Stanford", "filename_2023", "Stanford"), n = c(2, 4, 3))
  out <- with_study_year(x, s)
  testthat::expect_equal(out$year, c(2018L, 2024L, 2018L))
  testthat::expect_equal(out[c("study", "n")], x)
  testthat::expect_error(with_study_year(data.frame(study = "Unknown"), s), "lacks verified")
  testthat::expect_error(with_study_year(x, rbind(s, s[1, ])), "unique")
  testthat::expect_error(with_study_year(transform(x, year = 2023L), s), "disagrees")
  testthat::expect_error(fieldwork_year("2017-12-31", "2018-01-01"), "spans years")
  testthat::expect_error(fieldwork_year(NA_character_, "2018-01-01"), "Invalid")
})

testthat::test_that("sparse binomial contrasts retain uncertainty at zero failures", {
  x <- binary_difference(10, 10, 20, 20)
  testthat::expect_equal(x$estimate, 0)
  testthat::expect_lt(x$low, 0)
  testthat::expect_gt(x$high, 0)
  y <- binary_difference(20, 20, 10, 10)
  testthat::expect_equal(x$low, -y$high)
  testthat::expect_equal(x$high, -y$low)
  testthat::expect_error(binary_difference(1, 0, 2, 3), "Invalid")
})

testthat::test_that("resolution and browser comparisons preserve unknowns and channels", {
  testthat::expect_equal(
    resolution_group(c("375x812", "812x375", "1366x768", "0x0", "NA")),
    c("Below 600", "Below 600", "600 or more", "Unknown", "Unknown")
  )
  testthat::expect_equal(desktop_chrome_group(
    rep("Chrome", 5), c("58.0", "59.0", "60.0", "59.0", "59.0"),
    c("Windows NT 10.0", "Macintosh", "Linux", "Android 10", "CrOS")
  ), c("Earlier major", "Current major", "Above stable major", "Outside comparison", "Outside comparison"))
  testthat::expect_equal(ua_family(c(
    "Mozilla AppleWebKit Chrome/120 Safari/537 Edg/120", "Mozilla CriOS/120 Safari/604",
    "Mozilla Chrome/120 Safari/537 OPR/106", "Mozilla Trident/7.0 rv:11.0", NA
  )), c("Edge", "Chrome", "Opera", "IE", "Unknown"))
  testthat::expect_equal(
    os_group(c("Linux Android 10", "Macintosh", "", "iPhone")),
    c("Mobile OS", "Desktop OS", "Unknown", "Mobile OS")
  )
})

testthat::test_that("item blanks require exposure and do not turn DKs into nonresponse", {
  d <- data.frame(
    responseid = letters[1:5], finished = c("True", "False", "False", "True", "True"),
    answer = c("", "", "", "Don't know", "yes"), timer = c("4", "0", NA, "3", "1")
  )
  m <- data.frame(item = "answer", timer = "timer", format = "MC")
  a <- submitted_items(d, m, "Example", rep("Below 600", 5))
  testthat::expect_equal(a$person, c("a", "d", "e"))
  testthat::expect_equal(a$blank, c(TRUE, FALSE, FALSE))
  testthat::expect_equal(a$dont_know, c(FALSE, TRUE, FALSE))
  testthat::expect_error(submitted_items(d, rbind(m, m), "Example", rep("Unknown", 5)), "Repeated")
})

testthat::test_that("Qualtrics imports retain unfinished records and reject duplicate response keys", {
  p <- tempfile(fileext = ".csv")
  on.exit(unlink(p))
  d <- data.frame(
    ResponseId = c("Response ID", '{"ImportId":"responseId"}', "a", "b"),
    Finished = c("Finished", '{"ImportId":"finished"}', "True", "False"),
    Meta = c("Metadata", '{"ImportId":"meta"}', "NA", "Chrome")
  )
  write.csv(d, p, row.names = FALSE)
  x <- read_qualtrics_export(p)
  testthat::expect_equal(nrow(x), 2)
  testthat::expect_equal(x$finished, c("True", "False"))
  testthat::expect_true(is.na(x$meta[1]))
  d$ResponseId[4] <- "a"
  write.csv(d, p, row.names = FALSE)
  testthat::expect_error(read_qualtrics_export(p), "unique")
})

testthat::test_that("new source counts and item denominators are conserved", {
  read_signal <- function(n) read.csv(file.path(root, "data/validation", paste0("signal_", n, ".csv")))
  s <- read_signal("sources")
  testthat::expect_true(all(s$analysis_records <= s$raw_records))
  c <- read_signal("completion_cells")
  j <- c[c$study == "July 2017", ]
  testthat::expect_equal(as.numeric(tapply(j$n, j$dimension, sum)), rep(1264, 3))
  testthat::expect_equal(sum(j$n[j$dimension == "resolution" & !j$completed]), 11)
  i <- read_signal("items")
  testthat::expect_true(all(i$any_blank <= i$respondents))
  testthat::expect_true(all(i$blanks + i$explicit_dk <= i$submitted_item_records))
  testthat::expect_true(all(i$respondents <= i$submitted_item_records))
  coverage <- read_signal("coverage")
  counts <- aggregate(n ~ study, coverage, sum)
  testthat::expect_equal(counts$n, s$analysis_records[match(counts$study, s$study)])
  agreement <- read_signal("parser_agreement")
  testthat::expect_equal(sum(agreement$Freq), s$analysis_records[s$study == "Lucid 2024"])
  duration <- read_signal("duration")
  testthat::expect_equal(duration$observed + duration$excluded, duration$records)
  p <- read_signal("provenance")
  testthat::expect_equal(
    digest::digest(file = file.path(root, "docs/exposure_items.csv"), algo = "sha256"),
    p$sha256[p$source == "docs/exposure_items.csv"]
  )
})

testthat::test_that("response lengths count characters rather than bytes or choice labels", {
  d <- text_lengths(c("  café  ", "two\nwords", "", NA, "na", "n/a", "Don't know"))
  testthat::expect_equal(d$characters, c(4, 9, 0, 0, 2, 3, 10))
  testthat::expect_equal(d$words, c(1, 2, 0, 0, 1, 1, 2))
  testthat::expect_equal(d$blank, c(FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, FALSE))
})

testthat::test_that("aggregate Welch intervals reproduce individual-data inference", {
  x <- c(1, 3, 4, 20, 8)
  y <- c(2, 4, 6, 3, 2, 5, 7)
  a <- length_summary(x, rep("A", length(x)), "test", "characters")
  b <- length_summary(y, rep("B", length(y)), "test", "characters")
  r <- welch_from_summary(a, b)
  ref <- t.test(x, y, var.equal = FALSE, paired = FALSE, conf.level = .95)
  testthat::expect_equal(c(r$low, r$high), as.numeric(ref$conf.int))
  testthat::expect_equal(r$df, unname(ref$parameter))
  testthat::expect_error(welch_from_summary(transform(a, n = 1), b), "two observations")
})

testthat::test_that("common narrative questions and person-level groups preserve their denominators", {
  coverage <- read.csv(file.path(root, "data/validation/signal_text_coverage.csv"))
  groups <- read.csv(file.path(root, "data/validation/signal_text_groups.csv"))
  testthat::expect_equal(coverage$submitted, coverage$nonblank + coverage$blanks)
  testthat::expect_equal(coverage$submitted, rep(1060, 2))
  for (dimension in c("os", "browser")) {
    d <- groups[groups$dimension == dimension & groups$outcome == "characters", ]
    testthat::expect_equal(sum(d$n), 1060)
    testthat::expect_equal(weighted.mean(d$mean, d$n), mean(coverage$mean_characters_nonblank))
  }
  mapping <- read.csv(file.path(root, "docs/text_items.csv"))
  testthat::expect_equal(mapping$item, c("open_imm", "open_climate"))
  provenance <- read.csv(file.path(root, "data/validation/signal_provenance.csv"))
  testthat::expect_equal(
    digest::digest(file = file.path(root, "docs/text_items.csv"), algo = "sha256"),
    provenance$sha256[provenance$source == "docs/text_items.csv"]
  )
})
