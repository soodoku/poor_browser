mean_difference <- function(outcome, old) {
  if (!is.numeric(outcome) || !is.logical(old) || length(outcome) != length(old)) {
    stop("outcome must be numeric and old logical, with equal lengths")
  }
  if (any(!is.finite(outcome) & !is.na(outcome))) stop("outcome must be finite or missing")
  keep <- complete.cases(outcome, old)
  y <- outcome[keep]
  group <- old[keep]
  n_old <- sum(group)
  n_other <- sum(!group)
  if (min(n_old, n_other) < 2L) stop("Each group needs at least two observations")
  fit <- lm(y ~ group)
  estimate <- unname(coef(fit)[2])
  se <- sqrt(sandwich::vcovHC(fit, type = "HC2")[2, 2])
  data.frame(
    n = length(y), n_old, n_other, mean_old = mean(y[group]),
    mean_other = mean(y[!group]), estimate, se,
    low = estimate - qnorm(.975) * se, high = estimate + qnorm(.975) * se
  )
}

completion_specs <- function(data) {
  specifications <- list(
    historical = data$historical_old,
    token = data$old,
    installed = data$installed_old,
    ie_firefox = ifelse(data$family %in% c("IE", "Firefox"), data$old, NA),
    no_compatibility = ifelse(data$compatibility, NA, data$old)
  )
  do.call(rbind, lapply(names(specifications), function(spec) {
    result <- mean_difference(data$completed, specifications[[spec]])
    data.frame(survey = data$survey[1], specification = spec, result)
  }))
}

wilson_interval <- function(events, n) {
  if (
    length(events) != 1L || length(n) != 1L || !is.finite(n) ||
      !is.finite(events) || n <= 0 || events < 0 || events > n ||
      n != floor(n) || events != floor(events)
  ) {
    stop("Invalid binomial counts")
  }
  z <- qnorm(.975)
  p <- events / n
  centre <- (p + z^2 / (2 * n)) / (1 + z^2 / n)
  half <- z * sqrt(p * (1 - p) / n + z^2 / (4 * n^2)) / (1 + z^2 / n)
  c(low = centre - half, high = centre + half)
}

browser_counts <- function(data) {
  do.call(rbind, lapply(sort(unique(data$category)), function(category) {
    d <- data[data$category == category, ]
    events <- sum(d$completed)
    interval <- wilson_interval(events, nrow(d))
    data.frame(
      survey = d$survey[1], category, n = nrow(d), completed = events,
      dropout = nrow(d) - events, rate = events / nrow(d),
      low = interval[1], high = interval[2]
    )
  }))
}

leave_one_out_range <- function(data) {
  d <- data[!is.na(data$old), ]
  group <- d$old
  estimate <- mean(d$completed[group]) - mean(d$completed[!group])
  # With two groups the deletion effect has a closed form for each row.
  changes <- ifelse(group,
    (mean(d$completed[group]) - d$completed) / (sum(group) - 1),
    (d$completed - mean(d$completed[!group])) / (sum(!group) - 1)
  )
  data.frame(
    survey = d$survey[1], estimate,
    minimum = min(estimate + changes), maximum = max(estimate + changes)
  )
}

completion_checks <- function(data) {
  d <- data[!is.na(data$old), ]
  fit <- glm(completed ~ old, data = d, family = binomial())
  if (!fit$converged) stop("Completion model failed to converge")
  log_odds <- unname(coef(fit)[2])
  se <- sqrt(vcov(fit)[2, 2])
  data.frame(
    survey = d$survey[1], odds_ratio = exp(log_odds),
    low = exp(log_odds - qnorm(.975) * se),
    high = exp(log_odds + qnorm(.975) * se),
    fisher_p = fisher.test(table(d$old, d$completed))$p.value
  )
}

unknown_browser_bounds <- function(data) {
  known_old <- data[which(data$old), ]
  known_other <- data[which(!data$old), ]
  unknown <- data[is.na(data$old), ]
  assignments <- expand.grid(
    completed_old = 0:sum(unknown$completed),
    dropout_old = 0:sum(unknown$completed == 0)
  )
  assigned_old <- assignments$completed_old + assignments$dropout_old
  old_rate <- (sum(known_old$completed) + assignments$completed_old) /
    (nrow(known_old) + assigned_old)
  other_rate <- (sum(known_other$completed) + sum(unknown$completed) - assignments$completed_old) /
    (nrow(known_other) + nrow(unknown) - assigned_old)
  data.frame(
    survey = data$survey[1], unknown = nrow(unknown),
    low = min(old_rate - other_rate), high = max(old_rate - other_rate)
  )
}
