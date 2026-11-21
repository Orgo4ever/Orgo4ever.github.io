# Source, redistribution, and reproducibility policy

## Original study

The private historical project used a supplied 2024 extract described as UK Find a Tender / pharmaceutical procurement data. The extraction and CPV-selection steps are not completely documented in that project, so this public code showcase **does not claim full end-to-end reproduction** of the reported totals.

Data source: [UK Find a Tender Service](https://www.find-tender.service.gov.uk/)

UK public sector information may be reusable under the [Open Government Licence v3.0](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/), subject to source-specific rights, attribution and exclusions. **Personal data in published records is not automatically licensed by the OGL.**

## What has deliberately NOT been published here

- Original source extracts, including any personal contact names, email addresses, phone numbers, or addresses.
- Historical commits or file versions from the original private project.
- Tableau workbook files that may contain local Windows/OneDrive connection paths.
- Power BI workbook files whose cached data and metadata have not been comprehensively reviewed.
- Raw staging-table exports or other files not needed to inspect the analytical SQL.

The included `sql/00_demo_setup.sql` dataset is entirely fictional and small, intended only to demonstrate the MySQL query logic. Its counts must not be conflated with the historical analysis.

## Visual evidence

The project website already publishes report screenshots and a Tableau Public dashboard. These demonstrate analytical outputs but are not a replacement for access to the original full source data.

## Credit and accuracy

**Historical work:** SQL analysis and dashboards built as a portfolio project using a supplied schema. Original extract creation and schema authorship are not claimed. This is not an endorsement or official product of the UK government or any public procurement authority.

**Project-specific findings:** Counts, concentrations and quality flags are derived from the supplied extract, not validated facts about all UK pharmaceutical procurement or actual government spending.

**Demo:** New illustrative records; no people or organizations in it correspond to real entities.
