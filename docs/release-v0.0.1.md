# Release candidate 0.0.1

This research release assembles the revised “Poor” Browsers and Internet Surveys
note and its reproducible R analysis. Version 0.0.1 follows `DESCRIPTION`; this
repository is a research project, not an installable R package.

## Changes since the 2023 repository

- Preserve the original script, README, and 2011 note in `archive/`, and move the
  historical data file to `data/raw/` without changing its contents.
- Replace the single historical script with shared imports, browser measures,
  descriptive estimates, figures, tables, and manuscript generation.
- Document source identities, fieldwork dates, outcome denominators, browser
  compatibility settings, respondent overlap, and the limits of each comparison.
- Add aggregate snapshots from additional surveys, including completion,
  recorded answers, narrative response length, and elapsed time.
- Add pinned R dependencies, regression tests, lint, seeded simulations, and
  local and GitHub Actions builds.

## Reproduction

Run `make restore` followed by `make check`, or run `make ci-docker` with Docker
available. The ordinary build uses the bundled historical file and aggregate
snapshots. It does not require sibling repositories or restricted downloads.
The compiled note is `ms/main.pdf`.

## Scope

The results describe the available survey records. They do not identify causal
browser effects or establish gains from forecasting, interface interventions,
or sample-composition adjustments. External-data extensions remain pending as
documented in `docs/access.csv` and `docs/external_access.md`.

Source-import and validation commands require the original authorized exports;
these are separate from the self-contained release build. The existing data's
provenance and redistribution limits are documented in `data/README.md`.
