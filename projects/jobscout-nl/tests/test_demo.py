"""Offline regression tests for the fictional JobScout public showcase."""
from __future__ import annotations

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from jobscout_demo import (
    apply_feedback,
    canonical_url,
    evaluate,
    normalize_greenhouse,
    normalize_lever,
    run_demo,
)

PROFILE = {"dutch_level": "beginner", "skills": ["SQL", "Python", "Power BI", "Excel", "data quality"]}


def sample_job(title="Junior Data Analyst", location="Utrecht, Netherlands",
               description="SQL and Python", workplace="hybrid", url="https://jobs.example.org/demo/1"):
    return {"company": "Fictional Employer", "id": "1", "title": title,
            "location": location, "description": description,
            "workplace_type": workplace, "url": url, "source": "test"}


class JobScoutDemoTests(unittest.TestCase):

    def test_offline_fixtures_and_exact_feedback(self):
        rows = run_demo()
        self.assertEqual(len(rows), 5)
        self.assertNotIn("https://jobs.example.org/gh/1003", [r["url"] for r in rows])
        self.assertIn("https://jobs.example.org/gh/1001", [r["url"] for r in rows])
        self.assertEqual(rows[0]["queue"], "Review")

    def test_normalize_greenhouse_html(self):
        payload = {"jobs": [{"id": 1, "title": "QA Analyst",
                             "location": {"name": "Utrecht, Netherlands"},
                             "content": "<p>SQL &amp; Python</p>",
                             "absolute_url": "https://jobs.example.org/gh/1?utm_source=portal"}]}
        result = normalize_greenhouse(payload, "Fictional Company")[0]
        self.assertEqual(result["description"], "SQL & Python")
        self.assertEqual(result["url"], "https://jobs.example.org/gh/1")

    def test_normalize_lever(self):
        payload = [{"id": "123", "text": "BI Analyst", "categories": {"location": "Europe"},
                    "workplaceType": "remote", "descriptionPlain": "Power BI",
                    "hostedUrl": "https://jobs.example.org/lever/123"}]
        result = normalize_lever(payload, "Demo")[0]
        self.assertEqual(result["title"], "BI Analyst")
        self.assertEqual(result["location"], "Europe")

    def test_dutch_preferred_does_not_block(self):
        result = evaluate(sample_job(description="SQL. Dutch preferred."), PROFILE)
        self.assertFalse(result["language_block"])
        self.assertEqual(result["queue"], "Review")

    def test_mandatory_dutch_blocks(self):
        result = evaluate(sample_job(description="SQL. Fluent Dutch required."), PROFILE)
        self.assertTrue(result["language_block"])
        self.assertEqual(result["queue"], "Blocked")

    def test_remote_europe_requires_manual_verification(self):
        result = evaluate(sample_job(location="Europe — Remote", workplace="remote"), PROFILE)
        self.assertEqual(result["location_state"], "verify")
        self.assertEqual(result["queue"], "Needs verification")

    def test_unverified_remote_unscoped(self):
        result = evaluate(sample_job(location="Remote", workplace="remote"), PROFILE)
        self.assertEqual(result["location_state"], "verify")

    def test_us_only_blocks_despite_skill_fit(self):
        result = evaluate(sample_job(location="United States only — Remote", workplace="remote"), PROFILE)
        self.assertEqual(result["location_state"], "blocked")
        self.assertEqual(result["queue"], "Blocked")
        self.assertGreater(result["professional_fit_score"], 0)

    def test_foreign_onsite_blocks(self):
        result = evaluate(sample_job(location="New York, USA", workplace="onsite"), PROFILE)
        self.assertEqual(result["queue"], "Blocked")

    def test_missing_skills_are_unverified_not_assumed_disqualifying(self):
        result = evaluate(sample_job(description="SQL and dbt required"), PROFILE)
        self.assertIn("dbt", result["unverified_skills"])
        self.assertEqual(result["queue"], "Needs verification")

    def test_seniority_is_caution_not_fabricated_rejection(self):
        result = evaluate(sample_job(title="Senior Data Analyst"), PROFILE)
        self.assertTrue(result["seniority_caution"])
        self.assertEqual(result["queue"], "Needs verification")

    def test_manual_feedback_cannot_override_blockers(self):
        blocked = evaluate(sample_job(description="SQL. Fluent Dutch required."), PROFILE)
        result = apply_feedback([blocked], [{"url": blocked["url"], "decision": "Apply"}])
        self.assertEqual(result[0]["queue"], "Blocked")

    def test_feedback_rejects_only_exact_vacancy(self):
        one = evaluate(sample_job(url="https://jobs.example.org/jobs/1"), PROFILE)
        two = evaluate(sample_job(url="https://jobs.example.org/jobs/2"), PROFILE)
        result = apply_feedback([one, two], [{"url": "https://jobs.example.org/jobs/1?utm_source=test",
                                              "decision": "Reject"}])
        self.assertEqual([r["url"] for r in result], ["https://jobs.example.org/jobs/2"])

    def test_canonical_url_keeps_job_identity(self):
        url = canonical_url("https://JOBS.example.org/jobs/?id=42&utm_source=mail&ref=weekly")
        self.assertEqual(url, "https://jobs.example.org/jobs?id=42")

    def test_duplicate_feedback_fails_closed(self):
        data = [{"url": "https://jobs.example.org/1", "decision": "Reject"},
                {"url": "https://jobs.example.org/1?utm_medium=email", "decision": "Apply"}]
        with self.assertRaises(ValueError):
            apply_feedback([], data)

    def test_reject_non_https_job_url(self):
        with self.assertRaises(ValueError):
            canonical_url("http://jobs.example.org/1")


if __name__ == "__main__":
    unittest.main()
