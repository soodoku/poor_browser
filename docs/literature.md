# Paradata, browser characteristics, and survey performance

This focused review was assembled on October 7, 2026 to guide the descriptive
analysis and its next tests. It is not a systematic review or proof of priority.
Searches covered browser/version and breakoff, mobile versus PC response quality,
open-ended character counts, response timing, and early uses of web paradata.
Publisher records, author-hosted papers, and official archives were checked;
access limited to an abstract is stated below. References are organized around
the manuscript's questions rather than publication order.

## What the signal measures

Browser, operating-system, and screen records are device-type **paradata**;
page timings describe navigation and the response process. Answer text is survey
data, and its length is a derived outcome. This distinction prevents calling
every computed indicator paradata or treating a browser label as verified hardware.
[Callegaro (2013)](https://doi.org/10.1002/9781118596869.ch11) develops the device/navigation
distinction. [Vehovar and Čehovin (2026)](https://doi.org/10.1093/jssam/smag003)
review empirical paradata research and distinguish studies of response quality,
respondent characteristics, and substantive estimates. Those are separate uses
in this project too; predicting a length measure does not establish population bias.

## Participation, answer production, and burden

| Study and evidence checked | Design and finding relevant here | Consequence for this analysis |
|---|---|---|
| [Callegaro (2010)](https://www.surveypractice.org/article/2988-do-you-know-which-device-your-respondent-has-used-to-take-your-online-survey), article | User-agent collection and observational mobile/desktop completion patterns | Technical categories need a documented detector; device selection remains a rival explanation. |
| [Peytchev and Hill (2008 proceedings; 2010 journal article)](https://www.asasrms.org/Proceedings/y2008/Files/peytchev.pdf), proceedings | Experiments with mobile questionnaire display and input | Screen and input constraints were studied before this project's 2011 draft; layout experiments address remedies. |
| [Revilla and Ochoa (2016)](https://doi.org/10.1007/s11135-015-0273-2), publisher abstract | Random assignment to PC and smartphone versions over two waves; differences in character counts and time per character, without corresponding differences in nonanswer or nonsubstantive responses | Character counts are a relevant outcome distinct from answering at all. Do not infer semantic quality from length. |
| [Antoun, Couper, and Conrad (2017)](https://doi.org/10.1093/poq/nfw088), publisher abstract and indexed article sections | Randomized smartphone/PC crossover in LISS; no general deterioration in thoughtful responding, but some small touchscreen controls caused difficulty | Device effects depend on tasks and interfaces; no universal mobile-quality ranking. |
| [Antoun and Cernat (2020)](https://doi.org/10.1177/0894439318823703), publisher abstract and data statement | Timing analysis of the LISS crossover; smartphone completion took longer, especially on pages requiring text entry or multiple questions | Compare common prompts and page tasks; elapsed time is not typing speed. This reuses the crossover study, not an independent replication. |
| [Schmidt, Gummer, and Roßmann (2020)](https://doi.org/10.12758/mda.2019.05), publisher abstract | Multilevel observational analysis of open-ended answers across surveys; education and motivation associated with length and interpretability | Length and interpretability must be separated; respondent composition can explain technical-group differences. |
| [Schwerdtfeger, Weiß, and Struminskaya (2026)](https://doi.org/10.1177/14707853261483760), article | Randomized mobile-first/desktop-first layout experiment; includes open-answer length among outcomes | Test the effect of a deliverable interface change. Device information observed only among completers cannot identify device-stratified dropout effects. |

The literature supports the user's character-count hypothesis as worth testing;
it does not make a shorter response a quality failure or establish that browser
software causes it. Browser family bundles operating system, device, upgrade
policy, and respondent attributes. Knowledge and interest also influence how
much someone writes about immigration or climate change. A comparison holding
those two prompts fixed removes question mix, not those remaining differences.

## What the present data can add

### Response length as behavior: following Wasow's references

[Wasow (2026), *Text as Behavior*](https://doi.org/10.1017/pan.2026.10041),
published online May 6, uses character counts and nonresponse as signals of
preferences and engagement. The published article and its references were read.
It already addresses mode-specific response ceilings by transforming counts and
normalizing within mode; it should not be described as ignoring survey mode.

The following references were traced from that article to their original sources:

| Reference and evidence checked | What it contributes | Implication here |
|---|---|---|
| [Denscombe (2008)](https://doi.org/10.1177/0894439307309671), publisher abstract | Matched groups of adolescents answered online or on paper; length differences were not statistically significant, while gender and educational aspirations were more strongly associated with length | A mode difference is an empirical question, not an assumed universal penalty. |
| [Cavaillé, Chen, and Van der Straeten (2025)](https://doi.org/10.1017/psrm.2024.27), published article, especially Sections 2–3 | Randomized survey instruments were evaluated against behavioral tasks, including character counts in letters about abortion and minimum-wage bills | Length is a behavioral validation criterion here, not an independent measure of semantic quality. Assignment concerns the opinion instrument, not the typing device. |
| [Yimeng Li, *Incentivizing Open-Ended Survey Responses*](https://yimeng-li.com/all_research/), author's current abstract | Reports three experiments in which incentives increased response time, length, vocabulary richness, and topic-model performance | Incentives are a possible intervention and must be held fixed in an interface comparison. Wasow cites a 2023 conference presentation; the author lists a working paper presented in 2025. The linked PDF could not be retrieved, so details and publication status beyond that listing remain unverified. |

Our inference from these studies is that a behavioral interpretation of length
requires attention to response-production costs. That motivates validation
across technical environments; it is not evidence that the observed OS gap is
caused by typing costs or that Wasow's substantive results fail. A ceiling
adjustment alone does not test that mechanism. Keep observed lengths for the
descriptive question rather than normalizing away the group contrast we seek
to describe.

### Contribution and next test

The historical data address advertised browser age and compatibility settings,
which differ from a smartphone-versus-PC comparison. The March 2017 narratives
allow a second outcome: characters and words provided on common submitted
questions, with browser-family and OS summaries and a desktop-only browser
sensitivity. The contribution is measurement-aware description across tasks,
not discovery that devices matter or a new causal estimate of browser upgrades.

To go further, compare the same question in a randomized device or interface
experiment, code relevant and interpretable content independently of device,
and keep response provision, length, and coding reliability distinct. Panel
profiles/history support a separate question about incremental forecast value.
For deployment, the target is improvement from an actionable interface, with
completion and composition also measured.

## Early contribution and chronology

The archived [original note](../archive/browser-2011.pdf) displays July 31, 2011;
its PDF creation metadata agree. Git history starts in September 2023 and is not
evidence of a 2011 public repository. More substantially, Callegaro's 2013
chapter explicitly discusses Sood (2011)'s browser-age, breakoff, and missing-answer
analysis and lists the paper in its bibliography. See printed page 271 and the
bibliography in the [author-hosted chapter](https://callegaroresearch.com/wp-content/uploads/2025/07/callegaroparadatawebsurveys2013.pdf).
This documents recognition of an early browser-age contribution. It does not
establish that this was the first paradata study or first device/breakoff study.
The chapter repeats the earlier note's field-date account and interpretation;
the present source audit supersedes those empirical claims rather than using
an external citation as their validation.

## Additional data lead from the review

The official [LISS smartphone wave 1 archive](https://www.dataarchive.lissdata.nl/study-units/view/497)
identifies Antoun's *Nonresponse and Measurement Error in Mobile Web Surveys*
study, October 2013 fieldwork, English codebooks, and SPSS/Stata files. The timing
article also points to this archive. This is a strong candidate for the device
and open-response extension, but the present project has not downloaded or
linked the complete crossover waves. Verify assignment, order, completion, raw
text availability, and access terms before estimating anything. The two papers
using it must not be counted as two independent datasets.
