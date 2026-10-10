# Technical paradata and survey performance

## Questions, fixed before the new summaries

The manuscript and analysis answer the same questions: why examine metadata;
what it measures; where it identifies poorer performance; whether it adds useful
information; and what a survey organization could do with the signal.

This is a retrospective descriptive analysis. The 2009 results and July 2017
browser-by-completion counts were already inspected. Source profiling also
revealed metadata missingness, timing fields, and repeated item records. This is
not a blinded preregistration. New contrasts are selected for interpretability,
not statistical significance.

## Measures and comparisons

- Retain the 2009 advertised-version and installed-version comparisons. Keep
  historical regex results and additional definitions in the appendix.
- For July 2017, analyze consented US-coded records, keeping unfinished cases.
  Compare earlier versus current desktop Chrome major versions using the
  field-period stable release (59). Exclude higher major versions and missing
  versions from this contrast, and report their counts. Restrict this comparison
  to Windows/Mac/Linux metadata; do not extend a desktop release calendar to iOS
  or ChromeOS. Firefox 52 can represent an ESR channel, so a low major number is
  not automatically unsupported software.
- Compare recorded resolutions with a shorter side below 600 pixels versus at
  least 600 pixels. This is a fixed descriptive split, not a validated breakpoint
  for rendering, a measure of physical size, or an optimized threshold. Show
  continuous resolution counts as supplementary metadata.
- Completion differences use Newcombe differences of Wilson intervals in the
  sparse July sample; retain HC2 for the established historical contrasts.
  Confidence intervals describe respondent-level sampling uncertainty under
  independence within each survey, not probability-sample uncertainty.
- Summarize positive elapsed seconds with medians and quartiles, without deleting
  long durations. Analyze finished 2017/2024 records and separately label the
  retained Stanford records with no recorded screenout. Show mobile-OS versus
  desktop-OS summaries, retaining unresolved OS as unknown. These are recorded
  software environments, not verified hardware types.
- Item analysis uses explicit item/timer mappings in `docs/exposure_items.csv`.
  The source instruments and hashes are in `docs/exposure_sources.csv`.
  A positive page-submit timer supplies evidence of a submitted page. Zero or
  absent timers are unknown exposure, not a missing answer. Count blanks and
  explicit don't-knows separately. The July 24K slider offers Not Applicable;
  Qualtrics exports that selection as a blank. Its blanks therefore measure
  unrecorded numeric ratings, not identified item nonresponse. Summarize by survey, question format,
  and resolution; include unfinished respondents with submitted pages. The outcome
  is blank answers on logged submitted pages, not nonresponse on all displayed
  pages. A timer cannot reveal an unsubmitted final page or rendering failure.
- Lucid and Stanford data lack a verified item/exposure map for these purposes:
  contribute metadata and duration summaries, not invented nonresponse rates.
- Do not pool separate studies. Do not count long-format item rows as independent
  respondents. Check exact file copies, repeated response IDs, and panel-ID overlap
  where available. No export of respondent IDs or raw user agents is required.

## Incremental information and practical use

Adjusted completion requires covariates measured before dropout, observed for
both outcome groups. None of the local samples currently satisfies the complete
baseline-plus-history design. Do not manufacture an adjusted or predictive
result. Record the failed eligibility condition explicitly.

For a future accessible panel: train on earlier waves and evaluate on later
waves, excluding future information; compare profiles, profiles plus prior
participation, and that baseline plus technical paradata. Report calibration,
Brier score and log loss on identical held-out records. For new-respondent
generalization, also hold out people. This is distinct from forecasting later
participation by known panelists. Preserve survey weights where the target
requires them and use respondent-level dependence for repeated observations.

Composition analysis requires pre-survey profiles for starters and completers.
Population bias additionally needs a defensible population benchmark. Effects
of a remedy require randomized assignment and outcomes for every assigned
starter. Observational gaps are not estimates of recoverable completions.

## Staged external analyses

The [acquisition record](external_access.md) documents actual download attempts
and unresolved access requirements. The [UI testing protocol](ui_testing.md)
specifies a complementary design: reproduce technical failures, observe task
performance, then randomize a diagnosed repair. These are prospective studies,
not additional results in the manuscript.

CRONOS: obtain the authorized archive, verify entry metadata for unfinished
sessions, link country/respondent/wave/session, then analyze participation and
progression and evaluate later-wave predictions. Digitize!: reproduce documented
resolution/QR-entry and breakoff contrasts, including the source's eligibility
and missingness rules. GESIS: recover layout assignment and completion for every
randomized online case; estimate the intention-to-treat completion difference.
Do not stratify its dropout effect by a device variable collected only at completion.

Until microdata access is available these are specified extensions, not computed
results. No fees, account creation, external messages, or new fieldwork are
assumed. Every external source has an explicit status in `docs/access.csv`.


## Open-ended response length extension

Added after inspecting question wording and the existing descriptive results,
before estimating the new browser/length contrasts. The primary local comparison
uses March 2017's two common narrative questions, immigration and climate change.
They ask respondents to list what they know. Conditional explanation probes and
short name/office recall fields are distinct tasks and are not pooled with these
narratives. The old March format label Open denotes multiple choice followed by
open probes; it is corrected to Choice + open probe.

Retain the existing consented US-coded population. Require a positive matching
page-submit timer to count a submitted opportunity, and show blank answers
separately. Count Unicode characters after trimming boundary whitespace, including
internal spaces and punctuation, and whitespace-delimited tokens as a secondary
length measure. Do not infer content quality or count literal missing-value
markers as text. Use the same two questions for every respondent in the primary
comparison: average their two lengths at person level, with blanks zero only for
verified submitted pages. Show item-specific summaries and the number excluded
because a page submission is unverified. Keep nonblank-only lengths separately.

Report browser-family distributions and mobile-OS versus desktop-OS distributions,
including sample sizes and unknown metadata. Use a Welch interval for the mean
mobile-minus-desktop difference in person-level average characters. Repeat in
log(1 + characters) units for tail sensitivity; browser-family summaries within
desktop OS assess device composition without calling this an isolated browser
effect. These are exploratory selected-completer associations, not a causal effect
of keyboards, browser software, or respondent ability. Equal question weights
avoid changing prompt composition across groups. No significance-based threshold
or browser selection, and no automated semantic-quality rating.

Browser-family contrasts against Chrome (all OS and desktop-only) are secondary,
exploratory additions made after viewing group summaries. All observed families
are reported; Welch intervals require at least two records in each group. These
intervals are unadjusted for multiple comparisons and are not confirmatory tests.
The planned log sensitivity is log(1 + each person's mean characters), not a
percentage effect on raw character counts. Single-record deletion bounds are a
separate influence diagnostic; no records are dropped from the reported means.

The literature review adds a prospective measurement question, not a new claim
from these data: does answer length indicate comparable engagement across
technical environments? Wasow (2026) and Cavaillé et al. (2025) motivate checking
length against independent measures of interest or relevant behavior. In a
future interface experiment, hold prompts, incentives, and character limits
fixed, record device information at entry, and measure interest before assignment.
Compare completion, answer provision, length, and independently coded relevant
content by assigned interface. Examine whether the length–interest relationship
changes with assignment; device-stratified comparisons require entry metadata
and adequate sample sizes. This can test the consequences of an interface
change without interpreting naturally selected browser groups as treatments.
