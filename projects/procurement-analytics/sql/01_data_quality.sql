-- Public portfolio copy of analytical SQL from the original 2024 extract study.
-- For safe reproducibility, schema target changed to synthetic fixture database.
-- The demo data is entirely fictional and does not reproduce historical results.
-- ============================================================
-- Pharmaceutical Procurement & Supplier Analytics
-- 03_data_quality.sql
-- ============================================================
--
-- Purpose:
-- Assess data quality issues that could affect procurement
-- reporting, supplier analysis, and financial interpretation.
--
-- Source: UK Find a Tender Service, 2024
-- Dataset: Pharmaceutical procurement (CPV 336)
--
-- ============================================================

USE procurement_portfolio_demo;

-- ============================================================
-- 1. CONTRACT VALUE COMPLETENESS
-- ============================================================

-- Business question:
-- How many contracts have missing or nominal monetary values?
--
-- Contract values are stored as TEXT in the staging table.
-- A value of 1 may represent a nominal framework value
-- rather than actual procurement expenditure.

SELECT
    COUNT(*) AS total_contracts,

    SUM(
        CASE
            WHEN value_amount IS NULL
              OR TRIM(value_amount) = ''
            THEN 1 ELSE 0
        END
    ) AS missing_values,

    SUM(
        CASE
            WHEN TRIM(value_amount) = '1'
            THEN 1 ELSE 0
        END
    ) AS nominal_one_values,

    SUM(
        CASE
            WHEN value_amount IS NOT NULL
             AND TRIM(value_amount) <> ''
             AND TRIM(value_amount) <> '1'
            THEN 1 ELSE 0
        END
    ) AS other_values

FROM stg_contracts;

-- ============================================================
-- 2. FRAMEWORK AGREEMENTS AND NOMINAL CONTRACT VALUES
-- ============================================================

-- Business question:
-- Are contracts associated with framework agreements
-- more likely to report a nominal value of 1?
--
-- Join contracts to procurement records using main_id.
-- Missing framework indicators are classified as
-- "Not specified", not as non-framework contracts.

SELECT
    CASE
        WHEN LOWER(TRIM(p.tender_techniques_hasFrameworkAgreement)) = 'true'
            THEN 'Framework'
        WHEN LOWER(TRIM(p.tender_techniques_hasFrameworkAgreement)) = 'false'
            THEN 'Non-framework'
        ELSE 'Not specified'
    END AS framework_status,

    COUNT(*) AS total_contracts,

    SUM(
        CASE
            WHEN TRIM(c.value_amount) = '1'
            THEN 1 ELSE 0
        END
    ) AS nominal_one_contracts,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN TRIM(c.value_amount) = '1'
                THEN 1 ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS nominal_one_percentage

FROM stg_contracts c

LEFT JOIN stg_procurement p
    ON c.main_id = p.id

GROUP BY framework_status

ORDER BY total_contracts DESC;