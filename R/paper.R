read_result <- function(name) read.csv(file.path("tabs", paste0(name, ".csv")))

write_table <- function(header, rows, align, path) {
  body <- apply(rows, 1L, function(row) paste(paste(row, collapse = " & "), "\\\\"))
  writeLines(c(
    paste0("\\begin{tabular}{", align, "}"), "\\toprule",
    paste(paste(header, collapse = " & "), "\\\\"), "\\midrule",
    body, "\\bottomrule", "\\end{tabular}"
  ), path)
}

interval_text <- function(estimate, low, high, scale = 1, digits = 2) {
  sprintf(
    paste0("%.", digits, "f [%.", digits, "f, %.", digits, "f]"),
    scale * estimate, scale * low, scale * high
  )
}
