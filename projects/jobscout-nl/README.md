# JobScout NL | Public Engineering Showcase

High-volume screening can waste time when irrelevant records rank highly or mandatory requirements are missed. I built a personal job-search workflow that separates professional fit from eligibility, preserves supporting evidence and keeps application decisions under human control.

This public offline example uses fictional vacancies and candidate information to demonstrate the screening logic.

## What it demonstrates

The Python pipeline normalizes vacancy records, checks mandatory requirements and geography, records reasons for screening decisions, and respects exact-vacancy feedback. Sixteen deterministic regression tests cover the demonstration, including blocker and override behavior.

The full private workflow uses scheduled collection and Google Sheets synchronization. This example does not access live vacancies, private spreadsheets or account credentials and does not submit applications. No improvement in hiring outcomes is claimed.

## Explore

[Portfolio case study](https://orgo4ever.github.io/jobscout-case-study.html)

From this directory, run `python jobscout_demo.py` or inspect the JSON output with `python jobscout_demo.py --json`. Tests: `python -m unittest discover -s tests -p 'test_*.py' -v`.
