testthat::test_that("estimates and HC2 uncertainty equal independent group arithmetic", {
  y <- c(1, 1, 0, 1, 0, 0, 1, 0)
  g <- rep(c(TRUE, FALSE), each = 4)
  result <- mean_difference(y, g)
  testthat::expect_equal(result$estimate, .5)
  testthat::expect_equal(result$se, sqrt(var(y[g]) / 4 + var(y[!g]) / 4))
  testthat::expect_equal(mean_difference(rev(y), rev(g)), result)
  testthat::expect_equal(mean_difference(c(y, NA, 1), c(g, TRUE, NA)), result)
  testthat::expect_equal(mean_difference(y, !g)$estimate, -result$estimate)
  testthat::expect_error(mean_difference(y, rep(TRUE, 8)), "two observations")
  testthat::expect_error(mean_difference(c(Inf, y[-1]), g), "finite")
  testthat::expect_error(mean_difference(y, as.integer(g)), "logical")
  testthat::expect_error(mean_difference(y, g[-1]), "equal lengths")
})

testthat::test_that("historical results reproduce both dated specifications", {
  result <- historical_results(study)
  testthat::expect_equal(result$n, c(2065L, 2013L, 2013L, 1778L, 2327L, 2013L, 2327L, 1764L))
  testthat::expect_equal(
    result$estimate[c(1, 2, 5, 6)],
    c(-.0115681574381852, .410839429110968, -.0346109020184244, .410839429110968)
  )
  testthat::expect_true(all(result$p_value[result$model == "completion_2011"] < .05))
})

testthat::test_that("political gap depends on treatment of compatibility mode", {
  result <- completion_specs(political)
  testthat::expect_equal(result$estimate[result$specification == "token"], -.0334181509754)
  testthat::expect_equal(result$estimate[result$specification == "installed"], -.00740789038128)
  counts <- browser_counts(political)
  testthat::expect_equal(sum(counts$n), nrow(political))
  testthat::expect_equal(sum(counts$dropout), 258L)
  testthat::expect_true(all(counts$low >= 0 & counts$high <= 1))
})

testthat::test_that("influence bounds equal explicit leave-one-out estimation", {
  d <- demographic[!is.na(demographic$old), ]
  check <- unique(c(
    which(d$completed == 0 & d$old)[1], which(d$completed == 1 & d$old)[1],
    which(d$completed == 0 & !d$old)[1], which(d$completed == 1 & !d$old)[1]
  ))
  values <- vapply(check, function(i) mean_difference(d$completed[-i], d$old[-i])$estimate, numeric(1))
  bounds <- leave_one_out_range(d)
  testthat::expect_equal(c(bounds$minimum, bounds$maximum), range(values))
})

testthat::test_that("Wilson intervals handle endpoint counts and invalid arguments", {
  testthat::expect_equal(unname(wilson_interval(0, 10)[1]), 0, tolerance = 1e-12)
  testthat::expect_equal(unname(wilson_interval(10, 10)[2]), 1, tolerance = 1e-12)
  for (args in list(c(-1, 10), c(11, 10), c(0, 0), c(NA, 10), c(.5, 10), c(2, Inf))) {
    testthat::expect_error(wilson_interval(args[1], args[2]), "Invalid")
  }
})

testthat::test_that("unknown-browser bounds exhaust every assignment on a small example", {
  d <- data.frame(
    survey = "toy", old = c(TRUE, TRUE, FALSE, FALSE, NA, NA, NA),
    completed = c(1, 0, 1, 1, 1, 0, 1)
  )
  assignments <- expand.grid(a = c(FALSE, TRUE), b = c(FALSE, TRUE), c = c(FALSE, TRUE))
  estimates <- apply(assignments, 1, function(assignment) {
    group <- c(d$old[1:4], assignment)
    mean(d$completed[group]) - mean(d$completed[!group])
  })
  bounds <- unknown_browser_bounds(d)
  testthat::expect_equal(c(bounds$low, bounds$high), range(estimates))
})
