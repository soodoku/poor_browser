# Correctness and interpretation audit

The political-survey completion difference is sensitive to how IE8 compatibility
mode is classified. The demographic difference is smaller and imprecise. The
historical missing-cell outcome does not measure unanswered eligible questions.
The [note](../ms/main.pdf) reports the magnitudes and intervals, generated from
the analysis. This record explains what was checked and what the evidence permits.

## Claims and quantities

| Claim | Computed quantity and universe | What the design supports |
|---|---|---|
| Older browsers predict abandonment | Legacy-minus-other completion difference among observed component starters who are in the completed framing-experiment file | Conditional descriptive association; not a population response rate or causal upgrade effect |
| Browser age is a proxy for skill or bandwidth | No direct skill or bandwidth measure is present | Hypothesis only; browser and engine tokens do not validate the proxy |
| Older browsers cause more missing answers | Historical total `NA` count across the merged file | Not identified as item nonresponse; routing and measurement domains are mixed |
| Fixed-item blank differences | Mean blanks in an explicit field set among component completers with classified browsers | A different, limited descriptive outcome; eligibility and all-question nonresponse remain unverified |
| Two datasets corroborate the result | Linked components with overlapping respondents and identical browser strings where both are observed | Dependent comparisons; no pooled independent-sample significance claim |
| Fixing technical barriers reduces demographic bias | Neither intervention assignment nor pre-survey profiles for all dropouts are available | Requires a new design and a measured composition outcome |

## Findings and implemented changes

1. **Browser measurement.** The original regex scans punctuation-stripped strings
   for broad substrings, including an unanchored `98`. Tests demonstrate false
   matches from unrelated digits, a second MSIE token, and mobile-device labels;
   older Firefox versions can be missed. The revised parser reads explicit
   version tokens and preserves unknown values. [Reclassification counts](../tabs/reclassification.csv)
   show changes on the observed data. [Completion sensitivities](../tabs/completion.csv)
   distinguish advertised version, installed-version proxy, within-family
   comparisons, and exclusion of IE8 compatibility records. These are different
   measurements, not a declaration that compatibility mode is always the wrong
   category. Microsoft documents the engine marker in the citation ledger.

2. **Missing-cell outcome.** `rowSums(is.na(luth2))` is exactly reproducible from
   the supplied file, but it changes when an unrelated missing column is added
   and ignores empty strings. The fixed-field implementation has invariance
   tests and an explicit [item manifest](items.csv). The original and revised
   outcomes are not interchangeable estimates of one quantity. The manuscript
   consequently withdraws the broad missing-answer interpretation rather than
   presenting the narrow check as a full correction of it.

3. **Selection and dependence.** `uniq` is unique, while the `pcid` fields are
   constant survey markers. Missing component records remain unobserved, rather
   than failures. All demographic starters are political completers. Both
   historical adjusted missing-cell regressions select exactly the same rows
   and produce the same coefficient. All political dropouts disappear in a
   complete-case covariate analysis. [Selection counts](../tabs/selection.csv)
   and [sample counts](../tabs/samples.csv) make this explicit. Adjustment cannot
   recover the missing pre-survey profiles.

4. **Provenance and coding.** Source exports establish that `.x` is demographic
   and `.y` political, opposite to the old note's table labels. Start dates are
   in October 2009, inconsistent with the old README's December–January account.
   Age copies a birth-year category code; education is a categorical degree
   measure. A constant shift of age in an intercept model does not itself change
   the browser coefficient, so the age label error is not presented as the
   explanation of the completion association. Unsupported invitation and
   representativeness statements are removed from the current note.

5. **Specification drift.** The 2011 note uses logistic completion models and
   duration-restricted completed cases for missingness; the 2023 script uses
   linear completion models and a different adjustment set. Both are
   reproduced separately in [historical results](../tabs/historical.csv).
   The earlier note's completion significance claims reproduce under its own
   specifications. They cannot be transferred to the later script without
   checking its changed sample and estimator.

6. **Inference and influence.** Binary-outcome comparisons use HC2 standard
   errors, checked against independent group-variance arithmetic. Logistic odds
   ratios and Fisher tests are in [completion checks](../tabs/completion_checks.csv).
   [Leave-one-out bounds](../tabs/influence.csv) show that no single respondent
   changes the sign of the advertised-version gap. The confidence intervals
   assume independent respondents within a component. Recruitment-network
   dependence cannot be assessed from the supplied metadata; no probability
   sampling or population-weight claim is made.

## Validation coverage

| Check | Evidence or limit |
|---|---|
| Denominators and units | Counts reconstruct completion shares; means and gaps use people within the same component and classification |
| Missing coded as zero | Unknown browsers and absent components remain missing; blank text is treated explicitly |
| Silent row loss and joins | Unique respondent key; status/participation agreement; source joins checked for uniqueness, row conservation, and matching fields |
| Prose provenance | Note estimates and sample sizes use generated macros and table fragments; historical models remain separately labeled |
| Internal consistency | CSVs feed both the figure and manuscript; both classifications and overlapping samples are disclosed |
| EDA | Completion, dropout, unknown-browser, compatibility, field-date, and covariate-availability summaries are saved |
| Construct validity | Total merged missingness is separated from fixed-field blanks; skill, bandwidth, rendering, and question exposure remain unmeasured |
| Estimand and identification | Conditional observational comparisons; no causal identification from controls, model fit, or p-values |
| Statistical inference | HC2 identity; logistic model convergence; Fisher cross-check; no independence assumption between the two components |
| Skew and extreme values | Duration is not used in revised inclusion rules; historical duration cutoffs remain only in historical reproduction |
| Influence | Analytical deletion bounds checked against explicit refits |
| Unknown browsers | Every allocation of unclassified completers and dropouts to the two browser groups is enumerated in `tabs/unknown_browser_bounds.csv`; these are classification bounds on the observed gap, not confidence intervals |
| Simulation | Seeded null, political-rate, and near-ceiling Bernoulli scenarios; bias, empirical SD, reported SE, coverage, and Monte Carlo error saved in `tabs/simulation.csv` |
| Multiplicity and design flexibility | Five browser definitions shown together; exploratory sensitivities, not five independent confirmations |
| Power and sign/magnitude error | No externally specified target effect or prospective power claim; uncertainty is reported in outcome units rather than using the selected estimate to claim adequate power |
| Experiment-specific checks | Browser assignment is observational; randomization checks of browser treatment are inapplicable |
| IV, matching, DiD, RD, welfare | Not used; no such identification or welfare claims |
| External validity | Broader search found July 2017 data with 11 unfinished responses; other inspected exports lack completion variation or an explicit status field; CRONOS microdata remain unanalyzed |
| Independent data access | Original SPSS and MTurk files checked locally; normal build does not depend on sibling directories |
| Software regression | Parser fixtures, malformed inputs, stable blank-count definitions, known source counts, historical coefficients, and independent uncertainty arithmetic |

Simulation checks describe behavior under a stipulated data-generating process.
They cannot validate the untestable independence assumption or resolve selection.
The narrow regression tests were also run with the production fixes temporarily
reversed; the browser-token and blank-string regressions fail without their
respective fixes and pass after restoration. The full test harness, lint, and
manuscript build are the final local verification targets.

The final local `make check` passes with no lint findings, test failures,
warnings, or skips. The dependency lockfile restores successfully. The note
compiles without unresolved references or overflow warnings, and every page was
rendered for visual review. In the restricted execution environment, renv's
optional filesystem sandbox was disabled while the project package library
remained active; CRAN metadata access was allowed for dependency validation.
Docker verification was unavailable because the installed daemon was stopped.

## Additional data and alternative design

The [additional-data review](additional_data.md) records the broader October 7
search, including a July 2017 export with browser metadata for all 11 unfinished
responses. Four identical copies are counted as one dataset. It also records
the downloaded JSS user-agent supplement, the Austrian breakoff deposit, and a
randomized GESIS layout experiment, distinguishing inspected files from
documentation-only candidates. This extends the initial search described below.

The [data inventory](data_inventory.csv) distinguishes checked local files,
documented public candidates, and access requirements. The SPSS exports confirm
provenance but do not increase the sample. The March MTurk export cannot
identify breakoff because it includes only completers. Alumni and staff exports
in `../hidden` have status fields but no browser or user-agent field in their
headers, so they do not directly test the browser hypothesis.

CRONOS is the most concrete extension identified: basic participation data,
session-level detailed paradata, and respondent profiles can be linked by
country and respondent ID, with wave and session retained. Obtain the archive
and codebook, then audit browser coverage among dropouts before any model. Use
browser age relative to field date and distinguish initial browser from browsers
observed only after a successful session. A repeated-person design needs
respondent-clustered inference and cannot assume upgrades are random. GESIS
Panel documentation offers another candidate; exact version variables and
edition-specific access need verification before it can be called a replication.

The note proposes random assignment of a lightweight versus standard survey
interface at the first server request, before scripts that might fail. Keep
content and incentives fixed, retain every assigned starter, log server and
client failures separately, and predefine completion and eligible-item outcomes.
Browser-stratified treatment effects test whether an interface remedy helps
legacy configurations. They do not identify the effect of a browser upgrade.
Pre-survey profiles are needed to test the further claim about demographic bias.


## Expanded descriptive analysis (October 7, 2026)

The manuscript now starts with the survey problem and uses the same five
questions as the analysis plan and generated output files. Historical correction
and specification details are in the appendix. The original motivation is
retained, while unsupported claims about technical mechanisms and demographic
bias are separated from the quantities the data measure.

The new source checks establish the following:

- July 2017 has 1,264 consented US-coded records, including all 11 unfinished
  records with observed technical metadata. Sparse completion differences use
  Newcombe intervals from Wilson limits. The desktop Chrome comparison uses the
  release calendar during fieldwork; the resolution split was not optimized.
- The 5,652-row related export contains nine item rows for each of 628 people
  already in July. It contributes no independent completion observations.
- The explicit item/timer map retains submitted blocks from unfinished records.
  Every mapped nonblank field has a positive corresponding timer in the source
  exports. This check supports the mapping but cannot establish exposure to all
  displayed questions or recover an unsubmitted final page.
- July's 24K slider exports Not Applicable selections as blank. Its 448 blanks
  among 2,407 timer-linked item records are unrecorded numeric ratings, not
  identified item nonresponse. Other formats' explicit don't-knows are counted
  separately. Item rows are not treated as independent people for uncertainty.
- The Lucid file was fielded in January 2024 despite its 2023 filename. Duration
  summaries retain unknown OS as a group; reported labels and raw user-agent
  tokens are compared without treating either as installation ground truth.
- Stanford durations use 1,460 and 1,304 records with no screenout flag. Stored
  minute and second fields agree. Repeated panel IDs are documented; completion
  status is not inferred. All-record duration summaries are also saved.
- The public user-agent corpus supplies token-coverage checks only. It has no
  completion outcome or independently verified browser labels.

An independent review recomputed the July interval arithmetic, checked source
counts and timer mappings, and compared manuscript claims with generated
outputs. It caught a raw-versus-retained denominator mismatch in Stanford
metadata coverage and interleaved study rows in the answer-format table; both
were corrected before delivery.

Local validation passes: lint has no findings; the test suite has 89 passing
assertions with no failures, warnings, or skips; the seeded 1,500-replication
simulation completes. The revised source import also completes against the
local exports and downloaded JSS supplement. A table-integrity audit finds
unique study/format/resolution keys and no missing summary fields. The prose
provenance checker flags only the fixed 1.12 line-spacing setting as a possible
number mismatch; this is a formatting constant, not an estimate. PDF compilation
and rendered-page review accompany the final manuscript check. Restricted
external microdata remain pending as recorded in `access.csv`.


## Narrative response length and literature extension

The user proposed character counts in open-ended answers. Instrument review
found two common March narrative questions with genuine free text and distinct
positive submission timers. All 1,060 retained records supplied nonblank answers
to both; literal `na` and `n/a` remain text. An earlier table label Open was
incorrect: its fields are multiple choice followed by open probes. It is now
Choice + open probe; the corresponding closed-probe arm is labeled explicitly.
This changes the interpretation/label, not the historical choice-field counts.

The extension uses one two-question mean per person, not two independent
observations. All browser families are shown alongside OS groups; desktop-only
browser summaries expose device composition. Welch intervals use unequal group
variances and Satterthwaite degrees of freedom; tests compare the aggregate
calculation with R's individual-data `t.test`. An independent reviewer reproduced
character, word, and log contrasts, standard errors, and degrees of freedom from
the raw CSV in Python. The reviewer also caught inconsistent MSIE/IE labels in
question-specific output; these are now normalized consistently. The primary
mobile-minus-desktop character gap is descriptive of finished records and does
not measure semantic quality, keyboard causality, or population bias.

The literature review verifies publisher records and distinguishes abstracts from
full-text evidence. The 2011 note's displayed date and PDF metadata agree; the
2013 Callegaro chapter independently cites it. That supports recognition of an
early browser-age application, without claiming priority over paradata generally.
The manuscript uses paradata terminology, removes the self-referential origin
sentence, and places a specialized appendix after the references. The screen
comparison now states the 600-pixel threshold and comparator explicitly.


Final local verification for this extension: 103 passing assertions, no test
warnings or skips, clean lint, successful regeneration from the original sources,
and PDF compilation without unresolved references or overflow. The prose audit's
remaining literals are the 1.12 line-spacing setting and day 31 in the verified
July 31, 2011 provenance footnote; neither is a hand-entered analytical estimate.
All pages were rendered for review, including the appendix after the references.
