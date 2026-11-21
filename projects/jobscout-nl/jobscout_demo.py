"""Standalone, offline demonstration of JobScout NL screening concepts.

No personal candidate data, credentials, live API calls, or application records.
Run: python projects/jobscout-nl/jobscout_demo.py
"""
from __future__ import annotations

import argparse
import html
import json
import re
from pathlib import Path
from urllib.parse import parse_qsl, urlencode, urlsplit, urlunsplit

HERE = Path(__file__).resolve().parent

SKILL_PATTERNS = {
    "SQL": r"\bsql\b",
    "Python": r"\bpython\b",
    "Power BI": r"\bpower[\s-]*bi\b",
    "Tableau": r"\btableau\b",
    "Excel": r"\bexcel\b",
    "dbt": r"\bdbt\b",
    "data quality": r"\bdata quality\b",
}
DUTCH_REQUIRED = [
    r"\bdutch\s+(?:language\s+)?(?:is\s+)?(?:required|mandatory|essential)\b",
    r"\b(?:fluent|native|excellent|c1|c2)\s+(?:level\s+)?dutch\b",
    r"\bdutch\s+(?:at\s+)?(?:c1|c2)\b",
]
US_ONLY = r"\b(?:us|u\.?s\.?a?\.?|united states)\s*[- ]?only\b|\bonly\s+(?:in\s+)?(?:the\s+)?(?:us|usa|united states)\b"
NL_LOCATIONS = ("netherlands", "nederland", "utrecht", "amsterdam", "rotterdam", "eindhoven", "arnhem", "wageningen")
REGION_REMOTE = ("europe", "emea", "worldwide", "global", "anywhere")
TARGET_FAMILIES = ("analyst", "data quality", "data steward", "reporting", "business intelligence", "operations")


def clean_text(value: object) -> str:
    raw = "" if value is None else str(value)
    return " ".join(html.unescape(re.sub(r"<[^>]*>", " ", raw)).split())


def canonical_url(value: str) -> str:
    """Remove only tracking parameters; retain job identity and nontracking query."""
    u = urlsplit(value.strip())
    if u.scheme.lower() != "https" or not u.netloc:
        raise ValueError("Job URLs must be absolute HTTPS URLs")
    query = [(k, v) for k, v in parse_qsl(u.query, keep_blank_values=True)
             if not k.lower().startswith("utm_") and k.lower() not in {"ref", "fbclid", "gclid"}]
    path = u.path.rstrip("/") or "/"
    return urlunsplit(("https", u.netloc.lower(), path, urlencode(query), ""))


def normalize_greenhouse(payload: dict, company: str) -> list[dict]:
    """Map a Greenhouse-shaped local fixture to the common vacancy schema."""
    jobs = []
    for item in payload.get("jobs", []):
        jobs.append({
            "company": company,
            "id": str(item["id"]),
            "title": clean_text(item.get("title")),
            "location": clean_text((item.get("location") or {}).get("name")),
            "description": clean_text(item.get("content")),
            "workplace_type": clean_text(item.get("workplace_type")),
            "url": canonical_url(item["absolute_url"]),
            "source": "greenhouse-fixture",
        })
    return jobs


def normalize_lever(payload: list[dict], company: str) -> list[dict]:
    """Map a Lever-shaped local fixture to the same vacancy schema."""
    jobs = []
    for item in payload:
        categories = item.get("categories") or {}
        jobs.append({
            "company": company,
            "id": str(item["id"]),
            "title": clean_text(item.get("text")),
            "location": clean_text(categories.get("location")),
            "description": clean_text(item.get("descriptionPlain", "")),
            "workplace_type": clean_text(item.get("workplaceType")),
            "url": canonical_url(item["hostedUrl"]),
            "source": "lever-fixture",
        })
    return jobs


def location_review(job: dict) -> tuple[str, str]:
    """Listed NL is location-eligible for review, never verified legal eligibility."""
    loc = job["location"].lower()
    desc = job["description"].lower()
    workplace = job["workplace_type"].lower()
    full = f"{loc} {desc}"
    if re.search(US_ONLY, full):
        return "blocked", "Advertised geography explicitly limits applicants to the US"
    if any(p in loc for p in NL_LOCATIONS):
        return "nl_listed", "Position lists a Netherlands location; confirm all conditions"
    if any(p in loc for p in REGION_REMOTE) and ("remote" in loc or "remote" in workplace):
        return "verify", "Remote regional eligibility requires employer confirmation"
    if "remote" in workplace or "remote" in loc:
        return "verify", "Remote does not establish Netherlands hiring eligibility"
    return "blocked", "No supported Netherlands hiring location"


def language_review(job: dict, dutch_level: str) -> tuple[bool, str]:
    text = job["description"].lower()
    required = any(re.search(pattern, text, flags=re.I) for pattern in DUTCH_REQUIRED)
    if required and dutch_level.lower() not in {"fluent", "c1", "c2", "native"}:
        return True, "Explicit mandatory Dutch requirement is not met"
    return False, "No unsupported assumption about Dutch fluency"


def evaluate(job: dict, profile: dict) -> dict:
    """Heuristic professional fit, separate from eligibility and qualification cautions."""
    text = f"{job['title']} {job['description']}"
    mentioned = [name for name, pattern in SKILL_PATTERNS.items() if re.search(pattern, text, re.I)]
    owned = {s.casefold() for s in profile["skills"]}
    matched = [s for s in mentioned if s.casefold() in owned]
    unverified = [s for s in mentioned if s.casefold() not in owned]
    # This deliberately assigns neutral evidence (not zero) if no known skill is mentioned.
    skill_points = round(70 * len(matched) / len(mentioned)) if mentioned else 35
    family_points = 30 if any(term in job["title"].lower() for term in TARGET_FAMILIES) else 0
    score = min(100, skill_points + family_points)
    geography, geo_reason = location_review(job)
    language_block, language_reason = language_review(job, profile["dutch_level"])
    seniority_caution = bool(re.search(r"\b(?:senior|lead|principal|director|head of)\b", job["title"], re.I))
    if geography == "blocked" or language_block:
        queue = "Blocked"
    elif geography == "verify" or seniority_caution or unverified:
        queue = "Needs verification"
    else:
        queue = "Review"
    return {
        **job,
        "professional_fit_score": score,
        "location_state": geography,
        "language_block": language_block,
        "queue": queue,
        "matched_skills": matched,
        "unverified_skills": unverified,
        "seniority_caution": seniority_caution,
        "reasons": [geo_reason] + ([language_reason] if language_block else [])
                    + (["Seniority needs manual review"] if seniority_caution else [])
                    + (["Skills not evidenced: " + ", ".join(unverified)] if unverified else []),
    }


def apply_feedback(rows: list[dict], feedback: list[dict]) -> list[dict]:
    """Apply reviews by *exact canonical job URL*, never by employer."""
    mapping = {}
    for item in feedback:
        url = canonical_url(item["url"])
        if url in mapping:
            raise ValueError("Duplicate feedback URL")
        if item["decision"] not in {"Reject", "Apply", "Needs verification", "Realistic stretch"}:
            raise ValueError("Unrecognized feedback decision")
        mapping[url] = item["decision"]
    output = []
    for job in rows:
        review = mapping.get(canonical_url(job["url"]))
        if review == "Reject":
            continue
        # A human 'Apply' label cannot override explicit geography/language blockers.
        current = {**job, "human_feedback": review}
        if review == "Apply" and current["queue"] != "Blocked":
            current["queue"] = "Review" if current["location_state"] == "nl_listed" else "Needs verification"
        output.append(current)
    return output


def run_demo(directory: Path = HERE) -> list[dict]:
    profile = json.loads((directory / "data" / "fictional_profile.json").read_text(encoding="utf-8"))
    gh = json.loads((directory / "data" / "greenhouse_fixture.json").read_text(encoding="utf-8"))
    lever = json.loads((directory / "data" / "lever_fixture.json").read_text(encoding="utf-8"))
    feedback = json.loads((directory / "data" / "fictional_feedback.json").read_text(encoding="utf-8"))
    jobs = normalize_greenhouse(gh, "Fictional Employer A") + normalize_lever(lever, "Fictional Employer B")
    evaluated = [evaluate(job, profile) for job in jobs]
    reviewed = apply_feedback(evaluated, feedback)
    priority = {"Review": 0, "Needs verification": 1, "Blocked": 2}
    return sorted(reviewed, key=lambda x: (priority[x["queue"]], -x["professional_fit_score"], x["title"]))


def main() -> None:
    parser = argparse.ArgumentParser(description="Offline JobScout NL demonstration")
    parser.add_argument("--json", action="store_true", help="Print structured JSON output")
    args = parser.parse_args()
    rows = run_demo()
    if args.json:
        print(json.dumps(rows, indent=2, ensure_ascii=False))
    else:
        print("JobScout NL | FICTIONAL OFFLINE DEMO | scores are not hiring probabilities")
        for j in rows:
            print(f"{j['queue']:<20} {j['professional_fit_score']:>3}/100  {j['title']}")
            print(f"  {j['location']} | {j['company']} | {j['url']}")
            for reason in j["reasons"]:
                print(f"  - {reason}")


if __name__ == "__main__":
    main()
