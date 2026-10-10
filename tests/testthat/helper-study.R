root <- normalizePath(file.path("..", ".."))
for (file in c("browser", "sources", "analysis", "historical")) {
  source(file.path(root, "R", paste0(file, ".R")))
}
study <- read_study(file.path(root, "data/raw/luth2.rdata"))
items <- read.csv(file.path(root, "docs/items.csv"))
demographic <- component_data(study, "x", items$column[items$survey == "Demographic"])
political <- component_data(study, "y", items$column[items$survey == "Political"])
