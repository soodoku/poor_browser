source("R/analysis.R")
set.seed(20091007)
settings <- data.frame(
  scenario = c("null", "political", "near_ceiling"),
  p_old = c(.90, .87, .974), p_other = c(.90, .905, .984),
  n_old = c(1000, 1048, 910), n_other = c(1000, 1260, 1141)
)
replications <- 500L
results <- lapply(seq_len(nrow(settings)), function(i) {
  s <- settings[i, ]
  truth <- s$p_old - s$p_other
  draws <- replicate(replications, {
    y <- c(rbinom(s$n_old, 1, s$p_old), rbinom(s$n_other, 1, s$p_other))
    r <- mean_difference(y, rep(c(TRUE, FALSE), c(s$n_old, s$n_other)))
    c(estimate = r$estimate, se = r$se, covered = r$low <= truth & r$high >= truth)
  })
  data.frame(
    scenario = s$scenario, replications, truth,
    mean_estimate = mean(draws["estimate", ]), bias = mean(draws["estimate", ]) - truth,
    empirical_sd = sd(draws["estimate", ]), mean_se = mean(draws["se", ]),
    coverage = mean(draws["covered", ]),
    coverage_mcse = sqrt(.95 * .05 / replications)
  )
})
write.csv(do.call(rbind, results), "tabs/simulation.csv", row.names = FALSE)
