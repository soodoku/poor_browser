.PHONY: restore analysis questions import-signals figures tables manuscript paper format lint test simulate validate-sources validate-extensions check ci-docker clean

restore:
	Rscript -e 'renv::restore(prompt = FALSE)'

analysis:
	Rscript scripts/run_all.R

questions: analysis
	Rscript scripts/questions.R

import-signals:
	Rscript scripts/import_signals.R

figures: questions
	Rscript scripts/figures.R

tables: questions
	Rscript scripts/tables.R
	Rscript scripts/question_exhibits.R

manuscript: figures tables
	cd ms && latexmk -xelatex -interaction=nonstopmode -halt-on-error main.tex

paper: manuscript

format:
	Rscript -e 'styler::cache_deactivate(); styler::style_dir("R"); styler::style_dir("scripts"); styler::style_dir("tests")'

lint:
	Rscript -e 'l <- unlist(lapply(c("R", "scripts", "tests"), lintr::lint_dir), recursive = FALSE); print(l); quit(status = as.integer(length(l) > 0))'

test:
	Rscript -e 'testthat::test_dir("tests/testthat", stop_on_failure = TRUE)'

simulate: analysis
	Rscript scripts/simulate.R

validate-sources:
	Rscript scripts/validate_sources.R

validate-extensions:
	Rscript scripts/validate_extensions.R

check: paper lint test simulate

ci-docker:
	docker run --rm -v "$(PWD):/project" -w /project rocker/verse:4.6.0 \
		bash -lc 'make restore check'

clean:
	cd ms && latexmk -c main.tex
