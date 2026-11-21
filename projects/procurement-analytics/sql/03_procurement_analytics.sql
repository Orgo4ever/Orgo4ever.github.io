-- Public portfolio copy of analytical SQL from the original 2024 extract study.
-- For safe reproducibility, schema target changed to synthetic fixture database.
-- The demo data is entirely fictional and does not reproduce historical results.
-- ============================================================
-- Pharmaceutical Procurement & Supplier Analytics
-- 05_procurement_analytics.sql
-- ============================================================
--
-- Purpose:
-- Analyze buyer activity and procurement practices in
-- UK pharmaceutical public procurement during 2024.
--
-- Source: UK Find a Tender Service
-- Dataset: Pharmaceutical procurement (CPV 336)
--
-- ============================================================

USE procurement_portfolio_demo;

-- ============================================================
-- 1. TOP BUYERS BY PROCUREMENT ACTIVITY
-- ============================================================

-- Business question:
-- Which organizations conduct the most pharmaceutical
-- procurement processes?
--
-- Buyer names are recorded as provided in the source.
-- Naming inconsistencies may fragment buyer activity.
--
-- Procurement counts do not represent purchasing spend.

SELECT
    buyer_name,

    COUNT(DISTINCT id) AS procurement_processes,

    COUNT(DISTINCT ocid) AS unique_ocids

FROM stg_procurement

WHERE buyer_name IS NOT NULL
  AND TRIM(buyer_name) <> ''

GROUP BY buyer_name

ORDER BY
    procurement_processes DESC,
    buyer_name ASC

LIMIT 15;

-- ============================================================
-- 2. PROCUREMENT METHODS AND FRAMEWORK AGREEMENTS
-- ============================================================

-- Business question:
-- Which procurement methods are most commonly used,
-- and what proportion are identified as frameworks?
--
-- Missing framework indicators are not interpreted as false.
-- Framework percentages represent explicitly confirmed
-- framework agreements.

SELECT
    COALESCE(
        NULLIF(TRIM(tender_procurementMethod), ''),
        'Not specified'
    ) AS procurement_method,

    COUNT(*) AS procurement_processes,

    SUM(
        CASE
            WHEN LOWER(TRIM(tender_techniques_hasFrameworkAgreement)) = 'true'
            THEN 1 ELSE 0
        END
    ) AS framework_processes,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN LOWER(TRIM(tender_techniques_hasFrameworkAgreement)) = 'true'
                THEN 1 ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS framework_percentage

FROM stg_procurement

GROUP BY procurement_method

ORDER BY procurement_processes DESC;

-- ============================================================
-- 3. AWARDS PER PROCUREMENT PROCESS
-- ============================================================

-- Business question:
-- Which procurement processes generate the most awards?
--
-- Join procurement records to awards using the source
-- record identifier.
--
-- LEFT JOIN preserves procurement processes with no
-- matching award records.

SELECT
    p.id AS procurement_id,

    p.buyer_name,

    p.tender_title,

    COUNT(DISTINCT a.id) AS total_awards

FROM stg_procurement p

LEFT JOIN stg_awards a
    ON p.id = a.main_id

GROUP BY
    p.id,
    p.buyer_name,
    p.tender_title

ORDER BY
    total_awards DESC,
    procurement_id ASC

LIMIT 15;

-- ============================================================
-- 4. AWARD DISTRIBUTION BY PROCUREMENT PROCESS
-- ============================================================

-- Business question:
-- How are awards distributed across procurement processes?
--
-- Includes procurement processes with zero recorded awards.
-- Each procurement process is counted once.

WITH procurement_awards AS (
    SELECT
        p.id AS procurement_id,
        COUNT(DISTINCT a.id) AS award_count

    FROM stg_procurement p

    LEFT JOIN stg_awards a
        ON p.id = a.main_id

    GROUP BY p.id
)

SELECT
    CASE
        WHEN award_count = 0 THEN '0 awards'
        WHEN award_count = 1 THEN '1 award'
        WHEN award_count BETWEEN 2 AND 5 THEN '2-5 awards'
        WHEN award_count BETWEEN 6 AND 20 THEN '6-20 awards'
        ELSE '21+ awards'
    END AS award_category,

    COUNT(*) AS procurement_count,

    SUM(award_count) AS total_awards,

    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM procurement_awards),
        2
    ) AS percentage_of_procurements

FROM procurement_awards

GROUP BY award_category

ORDER BY
    CASE award_category
        WHEN '0 awards' THEN 1
        WHEN '1 award' THEN 2
        WHEN '2-5 awards' THEN 3
        WHEN '6-20 awards' THEN 4
        ELSE 5
    END;