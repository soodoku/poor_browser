library(ggplot2)
source("R/paper.R")
source("R/style.R")
data <- read_result("completion")
labels <- c(
  historical = "Historical regex", token = "Advertised version", installed = "Installed-version proxy",
  ie_firefox = "IE / Firefox only", no_compatibility = "Exclude compatibility"
)
data$coding <- factor(data$specification, levels = rev(names(labels)), labels = rev(labels))
data$study_label <- paste(data$survey, data$year)
plot <- ggplot(data, aes(x = 100 * estimate, y = coding)) +
  geom_vline(xintercept = 0, color = "#777777", linetype = "dashed", linewidth = .4) +
  geom_segment(aes(x = 100 * low, xend = 100 * high, yend = coding), linewidth = .55) +
  geom_point(size = 2, color = "#215968") +
  facet_wrap(~study_label, nrow = 1) +
  labs(x = "Completion difference: legacy minus other (percentage points)", y = NULL) +
  paper_theme()
dir.create("figs", showWarnings = FALSE)
ggsave("figs/completion.pdf", plot, width = 7.4, height = 3.2, device = cairo_pdf)
ggsave("figs/completion.png", plot, width = 7.4, height = 3.2, dpi = 240)
