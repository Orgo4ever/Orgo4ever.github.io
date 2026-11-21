# JobScout NL — Public Engineering Showcase

**Python · data ingestion · explainable screening · data quality · testing · operations automation**

[Portfolio case study](https://orgo4ever.github.io/jobscout-case-study.html) · [Portfolio homepage](https://orgo4ever.github.io/)

## The problem

Job boards contain misleading remote labels, hard language requirements, unsuitable seniority, and technical requirements that a keyword ranking alone can misinterpret. A useful analyst workflow needs to distinguish *professional fit* from *whether the vacancy is actually actionable*, and explain uncertain decisions rather than inventing confidence.

In my working, **private** JobScout NL project, I built a Python system around public ATS collection, eligibility-focused scoring, candidate evidence, historical tracking, manual feedback, automated checks, and controlled Google Sheets synchronization.

This repository folder is a **separate, deliberately small offline demonstration** of those engineering concepts. It is **not** a mirror of the full production code and contains no private candidate profile, job history, Google Sheet identifiers, API keys, or working credentials.

## Architecture

```text
Fictional Greenhouse-shaped jobs ──┐
                                  ├──► normalize to common job schema
Fictional Lever-shaped jobs ───────┘                 │
                                                    ▼
                                        screen location & Dutch
                                                    │
                                                    ▼
                                   professional-fit heuristic (separate)
                                                    │
                                                    ▼
                                     exact-vacancy feedback application
                                                    │
                                                    ▼
                                 ranked human-review queue with reasons
```

The source fixtures represent **fictional** employers and roles. The program makes **zero network calls**. URLs use reserved `example.org` domains, not real application links.

### Decisions modeled in the demo

| Component | What it demonstrates |
|---|---|
| Two ATS-shaped fixture normalizers | Different raw schemas mapped to a consistent record |
| Country/region screening | Netherlands-listed roles vs. foreign onsite and remote roles requiring verification |
| Mandatory Dutch detection | Explicit language blockers are kept separate from skill scores |
| Skill evidence | Matched and unverified technical skills, not imaginary candidate qualifications |
| Seniority caution | Senior positions require review; title alone does not imply an employer rejection |
| Persistent feedback concept | Exact job URL decisions, never company-wide rejection |
| Input validation | Duplicate decisions and non-HTTPS URLs fail closed |
| 16 deterministic tests | Offline regression checks, including blocker and override behavior |

## Run it yourself

**Requirements:** Python 3.11+; **no packages, accounts, environment variables or internet access required**.

From this folder:

```bash
python jobscout_demo.py
python jobscout_demo.py --json
python -m unittest discover -s tests -p 'test_*.py' -v
```

From the GitHub Pages repository root:

```bash
python projects/jobscout-nl/jobscout_demo.py
python -m unittest discover -s projects/jobscout-nl/tests -p 'test_*.py' -v
```

The first command prints a deterministic review queue with reasons. The rejected example vacancy is omitted, but a different vacancy from its fictional employer remains visible.

## Structure

```text
projects/jobscout-nl/
├── README.md
├── jobscout_demo.py
├── data/
│   ├── fictional_profile.json
│   ├── fictional_feedback.json
│   ├── greenhouse_fixture.json
│   └── lever_fixture.json
└── tests/
    └── test_demo.py
```

The repository also contains a GitHub Actions workflow to run these tests against this public demo. It is isolated from the daily private JobScout automation.

## Key design choices

**1. Professional fit is not a hiring probability.** The 0–100 value is an intentionally simple heuristic that counts skills visible in a posting and whether the title resembles the target role family. It is not calibrated to interviews, job performance or eligibility.

**2. A remote label is not permission to work from the Netherlands.** Remote Europe/EMEA/worldwide cases remain *Needs verification*, and explicit US-only listings are blocked.

**3. Mandatory vs. preferred language matters.** Dutch listed as preferred is not treated as a hard requirement. Common explicit mandatory Dutch phrases block the fictional beginner-Dutch profile. This is a finite rules demonstration, not comprehensive Dutch-language understanding.

**4. Human review remains authoritative but cannot erase explicit blockers.** A manual `Apply` flag does not turn a blocked vacancy into an actionable one. Rejections apply to an exact normalized URL, not all jobs at that company.

**5. Privacy is part of the architecture.** This showcase uses synthetic fixtures only. The actual candidate configuration, application decisions, connected spreadsheets and private job history remain in the separate private system.

## Scope, limitations, and authorship

This demo is **not a production recruiter system**, does not collect live vacancies, does not access Google Sheets, and does not submit applications. Tests validate the demonstration logic only; they do not certify the private scheduled pipeline.

Some rules are necessarily simplified: job descriptions may express geography, Dutch requirements, or skills in ways these patterns do not recognize. A *Review* queue label is a prompt for a human to inspect the official vacancy, not a recommendation to apply without checking.

The private system was built iteratively to address a real job-search operations problem. This public sample is an independent minimal implementation that exposes representative concepts and decision rules, without publishing the working system's private files.

**Author:** Kyle Haustein · Public showcase prepared November 2026.
