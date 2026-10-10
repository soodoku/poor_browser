# External-data acquisition checks

Checked October 7, 2026 following authorization to obtain and analyze the data.
No new external respondent-level dataset was acquired. This record belongs in
the repository, not the public manuscript.

| Source | Attempt and result | Input needed to proceed |
|---|---|---|
| [CRONOS / ESS](https://ess.sikt.no/en/api) | Retrieved the official API specification. Download requires a `userId`; no relevant environment variable was configured. | The user's ESS ID, available after signing in on the API page. It is a usage-statistics identifier, not a password. |
| [LISS mobile crossover](https://www.dataarchive.lissdata.nl/study-units/view/422) | The official smartphone-wave-one Stata download returned an HTML login page, not data. Downloaded and read its English codebook. | An authorized LISS archive session or locally downloaded study files. |
| [Digitize! replication](https://doi.org/10.11587/LUSBOX) | HTTPS metadata and landing-page retrieval repeatedly timed out, including an explicit IPv4 retry. Earlier inspection identified a restricted microdata file; no new file was retrieved. | A reachable archive and authorized access to the scientific-use file. A timeout is not evidence that access was denied. |
| [GESIS Panel.pop](https://www.gesis.org/en/gesis-panel/data-access/data-access-gesis-panelpop) | Official access instructions require a signed data-use agreement and approval for the Standard Edition. No existing local files were found. | An existing approved download or a completed access application. The Campus File is described as for teaching only and is not a substitute for research access. |

No browser session was available to check existing logins. No accounts were
created, agreements signed, or messages sent. The user has been asked which
archive accounts are available. The absence of environment variables does not
prove the user lacks an account.

## Exact LISS files and measurement checks

The study comprises a baseline plus October and December 2013 PC/smartphone
surveys with device crossover. Collect all components rather than treating a
single smartphone file as the experiment:

- [Baseline](https://www.dataarchive.lissdata.nl/study-units/view/423).
- [PC wave 1](https://www.dataarchive.lissdata.nl/study-units/view/477): `jr13a_EN_1.0p.dta`.
- [PC wave 2](https://www.dataarchive.lissdata.nl/study-units/view/478): `jr13b_EN_1.0p.dta`.
- [Smartphone wave 1](https://www.dataarchive.lissdata.nl/study-units/view/497): `jq13a_EN_2.0p.dta`.
- Smartphone wave 2: follow the link from the study's component list; retrieval
  through the web reader failed during this check.

The [smartphone-wave-one codebook](https://www.dataarchive.lissdata.nl/hosted-files/download/2926)
was downloaded to `tmp/external-acquisition/liss-wave1-codebook.pdf`.
SHA-256: `33ea7ac898165539c588572a03ae68a61a0e9724a14fa4d5923733373d2b4faa`.
Its design description and `jq13a001` identify assignment groups; `nomem_encr`
is the respondent identifier. The smartphone file omits the PC groups. The
hobbies prompt (`jq13a032`) explicitly permits blanks for people without hobbies;
these cannot automatically be coded as poor-quality item nonresponse. Verify
text availability and field limits in the actual microdata before counting
characters. Retain all assignment groups and distinguish assignment from
self-reported device use. Participation analysis additionally needs the assigned
sample, including nonparticipants; respondent files alone may not provide it.

## ESS download interface

The [official specification](https://api.ess.sikt.no/docs) defines
`GET /v1/data/dataFile/{doiPrefix}/{doiSuffix}` with required `userId` and optional
`fileFormat` (`parquet`, `csv`, `sav`, `dta`). The DOI must identify the data file,
not just the study. Leave `recodeMissingValues` unset for initial inspection so
documented sentinel categories remain distinguishable. The locally retrieved
specification is `tmp/external-acquisition/ess-openapi.json`. An identifier was
not invented or borrowed to submit a download request.

The next analysis follows [analysis_plan.md](analysis_plan.md): verify source
versions, keys, assignment, missingness, and unfinished-case metadata before
estimating any contrast. Access logistics and unsuccessful requests do not count
as additional empirical evidence.
