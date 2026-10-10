historical_results <- function(data) {
  result <- list()
  data$old_x <- historical_browser(data$cleanagx)
  data$old_y <- historical_browser(data$cleanagy)
  data$missing_cells <- rowSums(is.na(data))
  for (s in c("x", "y")) {
    selected <- data[!is.na(data[[paste0("pcid.", s)]]), ]
    selected$old <- selected[[paste0("old_", s)]]
    selected$completed <- trimws(as.character(selected[[paste0("status.", s)]])) == "COMPLETED"
    fits <- list(
      completion_2023 = lm(completed ~ old, data = selected),
      missing_2023 = lm(missing_cells ~ old + ppage + factor(ppeduc) + factor(race2) + ppgender,
        data = selected
      )
    )
    # The 2011 note uses the stored browser classifications and missing count.
    selected$old <- selected[[paste0("brow", s)]] == "old"
    fits$completion_2011 <- if (s == "x") {
      glm(completed ~ old + ppage + ppeduc + factor(race2), data = selected, family = binomial())
    } else {
      glm(completed ~ old, data = selected, family = binomial())
    }
    duration <- as.numeric(selected[[paste0("dur", s)]])
    eligible <- selected$completed & !is.na(duration) & duration < if (s == "x") 300 else 1000
    fits$missing_2011 <- if (s == "x") {
      glm(na ~ old + ppage + ppeduc + factor(race2), data = selected[eligible, ])
    } else {
      glm(na ~ old, data = selected[eligible, ])
    }
    for (name in names(fits)) {
      fit <- fits[[name]]
      coefficients <- coef(summary(fit))["oldTRUE", ]
      result[[paste(s, name)]] <- data.frame(
        survey = if (s == "x") "Demographic" else "Political",
        model = name, n = nobs(fit), estimate = coefficients[1],
        se = coefficients[2], p_value = coefficients[4]
      )
    }
  }
  do.call(rbind, result)
}
