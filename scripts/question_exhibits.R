source("R/paper.R")
source("R/style.R")
library(ggplot2)
read_signal <- function(name) read.csv(file.path("data/validation", paste0("signal_", name, ".csv")))
qmacro <- new.env(parent = emptyenv())
add <- function(name, value) assign(name, sprintf("\\newcommand{\\%s}{%s}", name, value), qmacro)
num <- function(x) format(x, big.mark = ",", trim = TRUE, scientific = FALSE)
sources <- read_result("q1_study_coverage")
for (i in seq_len(nrow(sources))) {
  prefix <- c("March", "July", "Lucid", "StanfordA", "StanfordB")[i]
  add(paste0(prefix, "AnalysisN"), num(sources$analysis_records[i]))
}
completion <- read_result("q3_completion")
for (i in seq_len(nrow(completion))) {
  prefix <- c("Chrome", "Resolution")[i]
  r <- completion[i, ]
  add(paste0(prefix, "Gap"), sprintf("%.2f", 100 * r$estimate))
  add(paste0(prefix, "Interval"), sprintf("[%.2f, %.2f]", 100 * r$low, 100 * r$high))
  add(paste0(prefix, "N"), num(r$n))
  add(paste0(prefix, "ReferenceN"), num(r$reference_n))
  add(paste0(prefix, "Rate"), sprintf("%.2f", 100 * r$rate))
  add(paste0(prefix, "ReferenceRate"), sprintf("%.2f", 100 * r$reference_rate))
}
cells <- read_signal("completion_cells")
outside <- cells$study == "July 2017" & cells$dimension == "chrome_recency" &
  cells$group %in% c("Outside comparison", "Above stable major")
add("ChromeOutsideN", sum(cells$n[outside]))
cover <- read_signal("coverage")
lucid <- cover[cover$study == "Lucid 2024" & cover$status == "Finished", ]
add("LucidMetadataMissing", lucid$n - lucid$browser_observed)
corpus <- read_signal("parser_coverage")
add("CorpusUnknown", corpus$Freq[corpus$family == "Unknown"])
agreement <- read_signal("parser_agreement")
for (i in seq_len(nrow(agreement))) {
  name <- c(
    "Agreement" = "ParserAgreement", "Different family labels" = "ParserDifferent",
    "Raw string unresolved" = "ParserUnresolved", "Reported metadata missing" = "ParserMissing"
  )[[agreement$comparison[i]]]
  add(name, agreement$Freq[i])
}
overlap <- read_signal("overlap")
add("LongRows", num(overlap$n[1]))
add("LongRespondents", num(overlap$n[2]))
add("StanfordRepeated", overlap$n[4])
answers <- read_result("q3_answer_formats")
slider <- answers[answers$study == "July 2017" & answers$format == "24K", ]
add("SliderBlanks", num(slider$blanks))
add("SliderItems", num(slider$submitted_item_records))
add("SliderRate", sprintf("%.1f", 100 * slider$blank_item_rate))
add("SliderRespondents", slider$respondents)
strata <- read_result("q3_answer_provision")
for (g in c("Below 600", "600 or more")) {
  r <- strata[strata$study == "July 2017" & strata$format == "24K" & strata$resolution == g, ]
  prefix <- if (g == "Below 600") "SliderNarrow" else "SliderWide"
  add(paste0(prefix, "N"), r$respondents)
  add(paste0(prefix, "Rate"), sprintf("%.1f", 100 * r$blank_item_rate))
}
burden <- read_result("q3_duration")
for (study in unique(burden$study)) {
  prefix <- c(
    "March 2017" = "March", "July 2017" = "July", "Lucid 2024" = "Lucid",
    "Stanford A" = "StanfordA", "Stanford B" = "StanfordB"
  )[[study]]
  for (g in c("Mobile OS", "Desktop OS", "Unknown")) {
    r <- burden[burden$study == study & burden$dimension == "os" & burden$group == g, ]
    if (nrow(r)) add(paste0(prefix, sub(" OS", "", g), "Minutes"), sprintf("%.1f", r$median))
  }
}
text_groups <- read_result("q3_text_length")
text_comparisons <- read_result("q3_text_comparisons")
for (g in c("Mobile OS", "Desktop OS")) {
  use <- text_groups$dimension == "os" & text_groups$outcome == "characters" & text_groups$group == g
  r <- text_groups[use, ]
  prefix <- if (g == "Mobile OS") "TextMobile" else "TextDesktop"
  add(paste0(prefix, "N"), num(r$n))
  add(paste0(prefix, "Mean"), sprintf("%.1f", r$mean))
}
r <- text_comparisons[text_comparisons$dimension == "os" & text_comparisons$outcome == "characters", ]
add("TextGap", sprintf("%.1f", r$estimate))
add("TextInterval", sprintf("[%.1f, %.1f]", r$low, r$high))
for (dimension in c("browser", "desktop_browser")) {
  use <- text_groups$dimension == dimension & text_groups$outcome == "characters" &
    text_groups$group == "Safari"
  r <- text_groups[use, ]
  add(if (dimension == "browser") "SafariTextMean" else "SafariDesktopTextMean", sprintf("%.1f", r$mean))
}
writeLines(unlist(mget(sort(ls(qmacro)), qmacro)), "tabs/question_macros.tex")
text_rows <- text_groups[text_groups$outcome == "characters" & text_groups$dimension != "desktop_browser", ]
write_table(c("Recorded group", "People", "Mean characters", "Median [Q1, Q3]"), data.frame(
  Group = paste(ifelse(text_rows$dimension == "browser", "Browser:", "OS:"), text_rows$group),
  N = text_rows$n, Mean = sprintf("%.1f", text_rows$mean),
  Median = sprintf("%.1f [%.1f, %.1f]", text_rows$median, text_rows$q25, text_rows$q75)
), "lrrr", "tabs/question_text.tex")

historical <- read_result("samples")
historical <- historical[match(c("Political", "Demographic"), historical$survey), ]
rows <- data.frame(
  Study = c("Political", "Demographic", sub(" [0-9]{4}$", "", sources$study)),
  Year = c(historical$year, sources$year),
  N = num(c(historical$n, sources$analysis_records)),
  Unfinished = c(historical$dropout, ifelse(is.na(sources$unfinished), "--", sources$unfinished)),
  Role = c(
    "Completion; fixed fields", "Completion; fixed fields", "Fields; duration",
    "Completion; fields; duration", "Metadata; duration", "Metadata; duration", "Metadata; duration"
  )
)
write_table(
  c("Study", "Year", "Records", "Unfinished", "Analytical contribution"), rows,
  "lrrrl", "tabs/question_coverage.tex"
)
write_table(c("Comparison", "$N_1$", "$N_0$", "Gap [95\\% CI], points"), data.frame(
  Contrast = c("Earlier / current Chrome", "Screen narrow side: <600 / 600+ px"),
  N1 = completion$n, N0 = completion$reference_n,
  Gap = interval_text(completion$estimate, completion$low, completion$high, scale = 100)
), "lrrr", "tabs/question_completion.tex")
format_labels <- c(
  "14K" = "Choice + DK (14K)", "24K" = "Numeric slider (24K)",
  "FSR" = "Choice + DK (FSR)", "IPS" = "Choice (IPS)", "RW" = "Media wording (RW)"
)
answer_labels <- answers$format
july <- answers$study == "July 2017"
answer_labels[july] <- format_labels[answer_labels[july]]
write_table(c("Study / format", "People", "Item records", "Blank (\\%)", "DK (\\%)"), data.frame(
  Format = paste(answers$study, answer_labels, sep = ": "), N = answers$respondents,
  Items = num(answers$submitted_item_records), Blank = sprintf("%.1f", 100 * answers$blank_item_rate),
  DK = sprintf("%.1f", 100 * answers$dk_item_rate)
), "lrrrr", "tabs/question_answers.tex")
main_burden <- burden[burden$dimension == "os", ]
write_table(c("Study", "Year", "OS group", "$N$", "Minutes: median [Q1, Q3]"), data.frame(
  Study = sub(" [0-9]{4}$", "", main_burden$study), Year = main_burden$year,
  Group = main_burden$group, N = main_burden$observed,
  Minutes = sprintf("%.1f [%.1f, %.1f]", main_burden$median, main_burden$q25, main_burden$q75)
), "lrlrr", "tabs/question_duration.tex")

h <- read_result("completion")
h <- h[h$specification %in% c("token", "installed"), ]
h$label <- paste(
  h$survey, paste0(h$year, ":"),
  ifelse(h$specification == "token", "advertised", "installed proxy")
)
r <- data.frame(
  label = c(h$label, "July 2017: Chrome below 59 vs 59", "July 2017: screen narrow side <600 vs 600+ px"),
  estimate = c(h$estimate, completion$estimate), low = c(h$low, completion$low),
  high = c(h$high, completion$high)
)
r$label <- factor(r$label, levels = rev(r$label))
p <- ggplot(r, aes(x = 100 * estimate, y = label)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "#777777", linewidth = .4) +
  geom_segment(aes(x = 100 * low, xend = 100 * high, yend = label), linewidth = .55) +
  geom_point(size = 2, color = "#215968") +
  labs(x = "Completion difference (percentage points)", y = NULL) +
  paper_theme()
ggsave("figs/question_completion.pdf", p, width = 7.4, height = 3.4, device = cairo_pdf)
ggsave("figs/question_completion.png", p, width = 7.4, height = 3.4, dpi = 240)
