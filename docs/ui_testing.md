# Testing whether the interface causes difficulty

Proposed October 7, 2026. No usability participants have been recruited and no
interface effect has been estimated. The descriptive browser and OS results
identify tasks to inspect; they do not establish a broken interface.

## What is feasible now

| Work | Feasible with current materials? | What is missing |
|---|---|---|
| Audit wording, question formats, routing documentation, and exported response codes | Yes; PDFs and the existing exports support this work | These materials do not reveal every deployed interaction |
| Diagnose the original live UI across browsers | No runnable original has been located | Original survey project or archived executable assets |
| Build a contemporary version of the relevant tasks and test saving, navigation, and rendering | Yes, as a new implementation | Choose the implementation and reference version; its results would not reproduce the historical UI |
| Observe human effort and difficulty | A protocol is ready; sessions have not been run | A working target, participants, and the actual test sessions |
| Estimate the benefit of a repair for completion or content | Not from existing observational comparisons | Randomized assignment to the reference and revised interfaces |

The immediate empirical work is the questionnaire/export audit and analysis of
observed responses. The next UI step is to select or recover a runnable target.
Building a new survey is technically feasible; diagnosing the historical
interface from PDFs alone is not.

## Recover the interface before testing it

The available instruments are the March and July 2017 questionnaire PDFs listed
with hashes in [exposure_sources.csv](exposure_sources.csv). The March instrument
contains the two common immigration and climate-change narrative prompts. July
contains a numeric rating format with a separate Not Applicable option.

A search of the sibling repositories found no `.qsf` export. PDFs preserve
wording and some display information, but not the deployed HTML, CSS, scripts,
responsive behavior, validation rules, or server handling. Obtain a working
survey project or archived implementation before calling a test a reproduction.
A reconstructed interface would test a new implementation. A current survey is
also a useful target, but cannot explain a historical browser association by itself.

## 1. Reproduce a specific failure

Test the same deployed questionnaire on actual desktop and mobile devices,
recording OS/browser versions, viewport, zoom, orientation, input method, and
network conditions. Keep a reproducible sequence of actions and the saved
response for each failure. A narrow desktop window does not reproduce a mobile
keyboard or touchscreen. Modern browser emulation does not reproduce IE8's
historical compatibility engine.

| Task | Evidence of a technical problem | Evidence to retain |
|---|---|---|
| Enter, edit, and submit a supplied short passage | Lost/truncated text, hidden input, blocked submit, incorrect saved text | Expected and saved text; screenshot; steps; console/network errors |
| Select a specified rating, then revise it | Intended option cannot be selected or saved | Requested, displayed, and saved values |
| Choose Not Applicable, then in a separate trial leave the field unanswered | Interface or export cannot distinguish the two states | Interaction trace and export coding; distinguish UI failure from an export limitation |
| Navigate back and forward, then submit | Previously entered answers disappear or change | Before/after saved state and navigation sequence |
| Correct an intentionally invalid answer | Error is undiscoverable or prevents recovery | Message, focus behavior, correction attempts, final state |

Check keyboard operation, visible focus, labels, zoom, and reflow as part of this
inspection. The [W3C preliminary accessibility checks](https://www.w3.org/WAI/test-evaluate/preliminary/)
provide an established starting point, not a complete accessibility audit.
Browser automation can verify deterministic saving and navigation behavior;
it cannot establish human difficulty or respondent dropout effects.

## 2. Observe task performance

Run a small moderated pilot with people spanning device familiarity and relevant
access needs. Use neutral task instructions and record assistance separately
from unaided success. The purpose is to discover and reproduce obstacles,
not estimate their population prevalence. [Moran's usability-testing guide](https://www.nngroup.com/articles/usability-testing-101/)
describes observing representative users performing realistic tasks.

Use both a fixed-text entry task and a separate substantive narrative prompt.
Fixed text holds the intended answer constant and tests input demands; it does
not reproduce knowledge retrieval or motivation. The narrative task preserves
those demands. Do not ask a participant to answer the identical substantive
prompt twice and interpret the difference as a pure interface effect.

Record task completion, assistance, mis-selections, correction attempts, lost
answers, active task time, and reported difficulty. Separate pauses and focus
loss from active work. Record think-aloud observations in the diagnostic pilot;
do not compare its timings with ordinary unmoderated survey duration.

Produce an issue log with the task, environment, observed behavior, saved-data
consequence, reproducibility, and a proposed repair. An awkward interaction
without a saving error may still impose burden. A shorter substantive answer
without observed difficulty is not itself a usability failure.

## 3. Randomize a concrete repair

Freeze the diagnosed change before the trial. Change one feature, or explicitly
define a bundle of changes. Hold wording, answer options, incentives, routing,
and character limits fixed. Randomize respondents before the affected page;
log assignment independently of the code being tested. Capture device metadata
at entry, retaining missing metadata as a category. Include every assigned
respondent in subsequent-completion comparisons. This is conditional on reaching
assignment, not a measure of invitation response.

Choose the primary outcome to match the diagnosed problem before inspecting
trial outcomes. For a submission failure, use successful task submission or
subsequent survey completion. For text-entry burden, use unaided task success
and active time on the standardized task; measure narrative content separately.
Size the trial for a practically meaningful improvement using pilot event rates,
with enough observations for any planned device-by-treatment interaction.

For narratives, report response provision and retained characters per assigned
respondent alongside length among answerers. Zero retained characters means no
recorded text, not no knowledge. Report verified page exposure separately. Code
relevant content and interpretability using a prespecified rubric, with coders
blind to interface assignment and a reliability check. Faster or longer answers
alone do not establish better measurement.

Estimate differences by assignment with uncertainty. Repeated task observations
require respondent-level dependence; within-person usability comparisons require
counterbalanced order and equivalent tasks. Pre-survey profiles support checks
of who benefits and who completes. Adopt a repair only if its gains on the
prespecified outcome are useful and it does not introduce material failures in
other tasks or groups. The conclusion concerns the tested interface change.

## Relationship to the manuscript and repository

The manuscript discusses the evidentiary role of these tests. This document
contains implementation and fieldwork planning. Once a runnable target exists,
keep its versioned assets and deterministic tests together; record human task
observations separately from synthetic browser checks. Add analysis modules and
generated exhibits only when actual observations are available. Do not manufacture
a demonstration failure and present it as evidence about the historical survey.
