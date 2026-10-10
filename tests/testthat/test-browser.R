testthat::test_that("version tokens are distinct from unrelated digits and appended tokens", {
  ua <- c(
    "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; build 98)",
    "Mozilla/4.0 (compatible; MSIE 8.0; MSIE 6.0)",
    "Mozilla/5.0 Firefox/2.0.0.20", "Mozilla/5.0 Firefox/3.0.14",
    "Mozilla/5.0 Firefox/3.5.3", "Mozilla/5.0 Firefox/30.0",
    "Mozilla/5.0 Firefox/3", "Mozilla/5.0 Firefox/", "unknown", NA_character_, "",
    "Mozilla/5.0 (iPhone) AppleWebKit/528.18", "Opera/9.80 MSIE 6.0"
  )
  expected <- c(FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, NA, NA, NA, NA, NA, FALSE, FALSE)
  testthat::expect_identical(browser_tokens(ua)$old, expected)
  testthat::expect_equal(browser_tokens(toupper(ua)), browser_tokens(ua))
  testthat::expect_equal(
    browser_tokens(paste0("  ", ua[1], "  ")),
    browser_tokens(ua[1])
  )
  testthat::expect_error(browser_tokens(factor(ua)), "character")
  testthat::expect_equal(nrow(browser_tokens(character())), 0L)
})

testthat::test_that("IE8 compatibility is retained as a separate measurement choice", {
  parsed <- browser_tokens(c(
    "Mozilla/4.0 (compatible; MSIE 7.0; Trident/4.0)",
    "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1)"
  ))
  testthat::expect_identical(parsed$old, c(TRUE, TRUE))
  testthat::expect_identical(parsed$installed_old, c(FALSE, TRUE))
  testthat::expect_identical(parsed$compatibility, c(TRUE, FALSE))
})

testthat::test_that("the historical regex changes valid observed classifications", {
  testthat::expect_equal(sum(political$historical_old != political$old, na.rm = TRUE), 67)
  testthat::expect_equal(sum(political$compatibility), 262)
  testthat::expect_equal(sum(is.na(political$old)), 19)
})
