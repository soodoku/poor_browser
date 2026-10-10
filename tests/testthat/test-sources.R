testthat::test_that("source keys, denominators and component labels are explicit", {
  testthat::expect_equal(dim(study), c(2330L, 479L))
  testthat::expect_equal(nrow(demographic), 2065L)
  testthat::expect_equal(nrow(political), 2327L)
  testthat::expect_equal(sum(demographic$completed), 2023L)
  testthat::expect_equal(sum(political$completed), 2069L)
  testthat::expect_equal(sum(political$completed == 0 & political$controls_observed), 0L)
  testthat::expect_equal(range(demographic$start_date), as.Date(c("2009-10-07", "2009-10-14")))
  testthat::expect_true(all(study$complete == "COMPLETED"))
  testthat::expect_equal(length(unique(na.omit(study$pcid.x))), 1L)
  controls <- complete.cases(study[c("ppage", "ppeduc", "race2", "ppgender")])
  testthat::expect_identical(which(controls & !is.na(study$pcid.x)), which(controls & !is.na(study$pcid.y)))
  testthat::expect_true(all(political$completed[political$person %in% demographic$person] == 1L))
  manifest <- read.csv(file.path(root, "data/raw/manifest.csv"))
  testthat::expect_identical(
    digest::digest(file = file.path(root, "data/raw/luth2.rdata"), algo = "sha256"),
    manifest$sha256
  )
})

testthat::test_that("age is derived from birth year rather than its response code", {
  d <- study[1:3, ]
  d$ppage <- c(60, 1, NA)
  testthat::expect_equal(component_data(d, "x", "qd1")$age, c(59, NA, NA))
  testthat::expect_error(component_data(d, c("x", "y"), "qd1"), "suffix")
  testthat::expect_error(component_data(d, character(), "qd1"), "suffix")
})

testthat::test_that("blank counts ignore unrelated fields and count empty strings", {
  d <- data.frame(a = c(NA, "", " ", "don't know", "0"), b = 1:5)
  expected <- c(1, 1, 1, 0, 0)
  testthat::expect_equal(blank_fields(d, "a"), expected)
  d$unrelated <- NA_real_
  testthat::expect_equal(blank_fields(d, "a"), expected)
  testthat::expect_equal(blank_fields(d[c(5, 1, 4, 2, 3), ], "a"), expected[c(5, 1, 4, 2, 3)])
  testthat::expect_error(blank_fields(d, c("a", "a")), "distinct")
  testthat::expect_error(blank_fields(d, "absent"), "existing")
  testthat::expect_error(blank_fields(d, character()), "distinct")
})

testthat::test_that("loading is isolated and malformed keys fail", {
  path <- tempfile(fileext = ".rdata")
  on.exit(unlink(path))
  luth2 <- study
  luth2$uniq[1] <- luth2$uniq[2]
  save(luth2, file = path)
  testthat::expect_error(read_study(path), "unique")
  luth2 <- study
  luth2$status.x <- as.character(luth2$status.x)
  luth2$status.x[1] <- "unrecognized"
  save(luth2, file = path)
  testthat::expect_error(read_study(path), "Unrecognized")
})
