# UK Pharmaceutical Procurement Analytics — Public Code Showcase

**SQL · Data Quality · Supplier Analysis · Power BI · Tableau**

**[Portfolio case study](https://orgo4ever.github.io/procurement-case-study.html)** · **[Interactive Tableau dashboard](https://public.tableau.com/app/profile/kyle.haustein/viz/pharmaceutical_procurement_interactive/Dashboard1)**

## Business question

How can we report meaningful UK pharmaceutical procurement activity when contract-value reporting is often nominal or missing?

In the original analysis of a **2024 UK Find a Tender extract**, I developed MySQL queries and interactive Power BI and Tableau reports covering procurement methods, supplier–award associations, buyer participation, award concentration, and reliability of reported contract values.

### Findings from the historical analysis — NOT from the demo data

| Measure | Original analysis |
|---|---:|
| Procurement processes | 170 |
| Recorded awards | 1,222 |
| Supplier–award associations | 1,533 |
| Unique recorded supplier names | 494 |
| Contract records | 1,216 |
| Contracts with missing or nominal £1 reported values | 791 (65.05%) |
| Award concentration | 12 processes accounted for 69.56% of awards |

These findings describe a supplied extract, **not an official census of the UK market**. The 65.05% figure is a warning against treating recorded contract values as actual expenditure. A nominal £1 entry is not necessarily a data-entry error. Association counts do not establish spending, supply performance, or market share.

## What I built

- Exploratory and analytical **MySQL** queries using joins, aggregation, CTEs, window functions, and normalized supplier names.
- Quality checks for missing/nominal contract values and their relationship to framework indicators.
- Distinct-grain Power BI reporting across procurement, award, supplier-association, and contract tables, with DAX measures.
- Tableau views and business-facing interpretation, reconciled against SQL outputs.

The **public folder contains a safe selection of the actual analytical SQL**, modified only to point at an isolated demonstration database. The raw procurement extracts and the original private Git history are **not** part of this showcase.

## Explore the code

| File | Purpose |
|---|---|
| [sql/00_demo_setup.sql](sql/00_demo_setup.sql) | Creates a separate demo database with **entirely fictional** records |
| [sql/01_data_quality.sql](sql/01_data_quality.sql) | Historical SQL patterns for contract-value data-quality checks |
| [sql/02_supplier_analytics.sql](sql/02_supplier_analytics.sql) | Supplier activity, concentration, and distribution |
| [sql/03_procurement_analytics.sql](sql/03_procurement_analytics.sql) | Buyer rankings, procurement methods, award distribution |
| [sql/04_demo_validation.sql](sql/04_demo_validation.sql) | Demo-table integrity and expected-result checks |
| [DATA_AND_REUSE.md](DATA_AND_REUSE.md) | Source attribution, synthetic-data policy, reproducibility limits |

### Run the public demo locally

Requirements: MySQL 8.0 or newer, using MySQL Workbench or a MySQL command-line client.

Run the following scripts **in order** against your own local database:

1. `sql/00_demo_setup.sql` (creates and resets *only* the `procurement_portfolio_demo` database tables).
2. `sql/04_demo_validation.sql` (check that the fixture contains 6 processes, 8 awards, 10 supplier associations, and 7 contracts).
3. `sql/01_data_quality.sql`
4. `sql/02_supplier_analytics.sql`
5. `sql/03_procurement_analytics.sql`

You can open each file directly in MySQL Workbench, or use MySQL's `SOURCE` command:

```sql
SOURCE sql/00_demo_setup.sql;
SOURCE sql/04_demo_validation.sql;
SOURCE sql/01_data_quality.sql;
SOURCE sql/02_supplier_analytics.sql;
SOURCE sql/03_procurement_analytics.sql;
```

**Demo expected quality counts:** 7 contracts, of which 2 report nominal 1 values, 1 is missing a value, and 4 have other reported values. These are **fictional numbers, not the real study results**.

> The demo setup uses `DROP TABLE IF EXISTS` **within its separate demo database** to reset the synthetic fixture. Do not point the demonstration scripts at a working production database.

## Dashboard previews

- [Power BI screenshot](../../powerbi-dashboard.png)
- [Tableau screenshot](../../procurement-dashboard.png)
- [Interactive Tableau report](https://public.tableau.com/app/profile/kyle.haustein/viz/pharmaceutical_procurement_interactive/Dashboard1)

The Power BI Desktop (.pbix) and Tableau workbook source files are **not included** in this public repository. Their cached data, connection metadata, and local file paths have not been completely cleared or reviewed for redistribution. The screenshots and previously published Tableau dashboard demonstrate the original reporting design.

## Scope and limitations

- The analytical SQL was originally written against staging tables created from a supplied extract. This public demo provides a minimal synthetic staging schema; it does **not** reconstruct the complete extraction/cleaning pipeline behind the historical 2024 findings.
- The original database schema and source extracts were supplied. I developed the analytical SQL, reporting, model measures and documented validation; I do not claim to have designed the original source schema.
- Supplier counts are based on recorded names, not verified unique legal entities.
- This project includes manual reconciliation and report checks, not a production test suite or proven deployed data-governance process.
- **No actual procurement rows or personal contact details are included in the synthetic demo.**

For methodology and decision-oriented interpretation, see the [portfolio case study](https://orgo4ever.github.io/procurement-case-study.html).

## Attribution

The original public-sector material was sourced from the **UK Find a Tender Service**. For portions of source information that are licensed for reuse, see the [Open Government Licence v3.0](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/). Personal data and third-party rights are not licensed by the OGL. This public showcase intentionally contains **no original dataset extracts**. The fictional demo fixture was authored solely to exercise the SQL patterns.

**Author:** Kyle Haustein · Portfolio demonstration · November 2026
