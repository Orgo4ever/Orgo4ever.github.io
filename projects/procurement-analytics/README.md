# UK Pharmaceutical Procurement Analytics | Public SQL Showcase

Procurement managers need reliable evidence of award activity and supplier participation. Missing or nominal contract values can make spending comparisons misleading.

## Historical findings

| Metric | Result |
|---|---:|
| Procurement processes | 170 |
| Awards | 1,222 |
| Supplier-award associations | 1,533 |
| Unique recorded supplier names | 494 |
| Contract records | 1,216 |
| Missing or nominal £1 contract values | 791 (65.05%) |

Twelve procurement processes accounted for 69.56% of awards. This measures award counts, not spending.

**Recommendation:** Use activity and award distribution for reporting, and reconcile contract values before drawing expenditure conclusions.

## Explore the analysis

[Portfolio case study](https://orgo4ever.github.io/procurement-case-study.html) | [Interactive Tableau report](https://public.tableau.com/app/profile/kyle.haustein/viz/pharmaceutical_procurement_interactive/Dashboard1) | [Power BI screenshot](../../powerbi-dashboard.png)

I developed MySQL queries, prepared reporting tables in Power Query, built Power BI and Tableau reports and reconciled totals across SQL and Power BI.

The public SQL demonstration uses entirely fictional data. It includes [setup](sql/00_demo_setup.sql), [quality checks](sql/01_data_quality.sql), [supplier analysis](sql/02_supplier_analytics.sql), [procurement analysis](sql/03_procurement_analytics.sql) and [validation](sql/04_demo_validation.sql). Run the setup first in MySQL, then the analysis and validation scripts.

## Scope and attribution

The historical source was the UK Find a Tender Service. The original dataset and unreviewed Power BI workbook remain private. The demo does not reproduce historical results and includes no original source records.

See [data and reuse notes](DATA_AND_REUSE.md) and the [Open Government Licence v3.0](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/); personal data and third-party rights are not licensed by the OGL.
