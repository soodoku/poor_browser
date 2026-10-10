# Additional data: inspected files and public candidates

The implemented question-organized analysis is described in [analysis_plan.md](analysis_plan.md).
Aggregate results now cover completion, timer-linked exported blanks, duration,
and metadata agreement; [access.csv](access.csv) distinguishes pending sources.
The [acquisition record](external_access.md) documents the subsequent download
attempts, verified access requirements, and LISS codebook inspection.

The strongest immediately available extension is the **July 2017 MTurk raw
export** in `../waters-of-casablanca`. It retains unfinished records and their
browser metadata. **CRONOS-1** remains the best documented candidate for a larger
browser-and-completion study. A **GESIS randomized layout experiment** addresses
the effect of a practical interface change more directly.

## Local files actually inspected

The October 7, 2026 search inspected the first two lines of 6,406 CSV files under
the sibling-repository directory, looking for browser, user-agent, resolution,
metadata, and breakoff column names. It also attempted to inspect names and
labels in 770 SPSS/Stata files; 709 could be read. The 61 failures were in
`dyad`, `dp-data`, and `pareto_partisan`. Some legacy dictionaries produced import
warnings. This was a candidate search, not a data-integrity audit of those files.
RData objects, compressed archives, and Parquet schemas were not exhaustively
searched. Absence from this list is not proof that a repository lacks usable data.

| Source | Verified contents | Use and limit |
|---|---|---|
| `waters-of-casablanca/data/raw/mturk_july_2017.csv` | 1,296 records; 11 unfinished; browser, version, OS, resolution, and block timers | A small external completion check; only 11 events |
| Same July export in `partisan-gaps` and `misinformation` | Four paths have the same SHA-256 | One dataset, not four replications |
| March 2017 exports in `hidden`, `waters-of-casablanca`, and `partisan-gaps` | Full export: 1,133 finished records (1,060 consented and US-coded); earlier export: 1,090, also all finished | Browser/version coverage and selected-completer outcomes; no completion contrast |
| `partisan-gaps/data/mturk1.csv` | 5,652 item rows for 628 respondents, all present in July | No additional respondents; a derived long-format July file |
| `extreme_recall_2023/data/lucid/er2_lucid_jan2023.csv` | 904 records, all finished; January 2024 timestamps despite the filename; parsed browser fields and raw user agent | Metadata agreement and elapsed-time summaries; no dropout contrast |
| Two Stanford prospect-theory files in `prospect_theory/data/protzko/source/` | 1,647 and 1,442 records; every row has a user agent; no explicit completion-status field | Duration summaries for 1,460 and 1,304 retained records without a screenout flag; no inferred abandonment |

[Local candidate summaries](../data/validation/local_candidates.csv) retain paths,
hashes, counts, and metadata coverage. The raw respondent files remain in their
source repositories. Derived and overlapping exports must not be pooled as
independent surveys; hashes identify exact copies but do not establish respondent
independence between different files.

### July 2017 feasibility check

After excluding two Qualtrics metadata rows, all 1,296 records have distinct
response IDs. All consented. Of these, 1,264 have `ccode == "US"`: 1,253 marked
finished and 11 unfinished. The 32 other records are marked finished but have no
question-format assignment, so survey termination and substantive completion
cannot be equated across the unrestricted export. Country coding is not a
verified citizenship or eligibility measure. No US-coded records carry the
export's `Spam` flag.

All 11 unfinished records contain browser/version metadata: eight Chrome, two
Firefox, and one Safari iPhone. All also contain OS and screen resolution.
[Browser-by-completion counts](../data/validation/july_browser_completion.csv)
and [selection checks](../data/validation/july_support.csv) are saved separately.
The instrument at `../partisan-gaps/data/turk/2017_07_misinfo_survey.pdf` places
browser metadata directly after consent. It does not establish that the export
retains everyone who reached the initial survey URL.

Nine of the 11 unfinished records lack age; all 11 lack party identification.
Do not use a complete-case demographic adjustment. The implemented comparison uses the desktop Chrome release calendar for
July 9, 2017 rather than the 2009 legacy cutoff. The retrospective plan discloses
that browser-by-completion counts had already been inspected. Two narrow
contrasts retain their group counts and uncertainty. With only 11 events, a
large adjusted model or a search across thresholds would give misleading
precision. Timer-linked answer summaries are now implemented; they distinguish
blank slider exports from explicit textual don't-knows and do not claim
randomized format effects.

## Public sources

| Priority | Source | What is verified | Access and next check |
|---|---|---|---|
| 1: browser/completion | [CRONOS-1 raw paradata](https://ess.sikt.no/en/datafile/db8c442b-6b17-4996-ace6-a6cc7099dc93) | Official guide describes linked participation, software/device, timing, sessions, and repeated waves | ESS API download requires ESS user ID. Microdata not downloaded; verify browser coverage among early dropouts before modeling. |
| 2: technical friction | [Digitize! breakoff replication, AUSSDA](https://doi.org/10.11587/LUSBOX) | Archive reports 1,228 observations, 19 variables, Stata replication code; associated study analyzes screen resolution, QR entry, digital-use measures, and breakoff | Data file is restricted; logged-in access required. Documentation/code are public. Browser-version fields have not been verified. |
| 3: interface remedy | [GESIS Panel.pop layout experiment](https://journals.sagepub.com/doi/10.1177/14707853261483760) | Wave hd, August 2020, randomized mobile-first versus desktop-first layout; article says data are archived at GESIS | Inspect assignment and completion for all randomized online cases. Article footnote 3 says device is only available for completed web surveys: it cannot stratify dropout effects by device. |
| Measurement only | [JSS parseuas supplement](https://www.jstatsoft.org/article/view/v092c01) | Downloaded and inspected: 36,575 rows, 29 surveys, exactly `wave` and `useragent` | Public direct download. Useful parser corpus; no completion, demographics, or independently validated browser labels. |

The [CRONOS guide](https://openaccess.city.ac.uk/id/eprint/30024/1/CRONOS_user_guide_e01_1.pdf)
supports a concrete linkage plan: country and respondent ID, retaining wave and
session. Use browser metadata from entry, not a later successful session. Cluster
repeated-wave inference by respondent. Within-person comparisons still face
selected upgrades and device switches.

The GESIS experiment is an alternative strategy, not evidence that browser
upgrades have a causal effect. Its randomized treatment changes layout. A
replication could estimate its overall online completion effect without requiring
post-completion device reports. Recovering valid browser-specific effects would
require metadata measured for unfinished cases as well.

Also screened: the [PsychArchives breakoff deposit](https://doi.org/10.23668/psycharchives.2660)
is described as survey breakoff rates and questionnaire-element counts. That
description supports questionnaire-burden research, but does not establish
respondent-level browser data; it is not ranked as a browser replication source.

## Repeating the file checks

Run from this repository with the sibling repositories present:

```sh
make validate-extensions
```

The optional public-file check is:

```sh
mkdir -p tmp
curl -L --fail 'https://www.jstatsoft.org/article/download/v092c01/3903' -o tmp/parseuas.dta
JSS_UA_SOURCE=tmp/parseuas.dta make validate-extensions
```

The script verifies completion coding, removes the Qualtrics metadata rows,
checks the July response key, computes coverage and duplicate-file hashes, and
exports aggregate summaries. The JSS check asserts the actual two-column schema
and saves a hash. It does not run an external completion replication. The normal
note build consumes these saved aggregates and requires neither sibling files
nor live downloads.
