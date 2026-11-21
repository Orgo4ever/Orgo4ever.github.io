-- Public portfolio copy of analytical SQL from the original 2024 extract study.
-- For safe reproducibility, schema target changed to synthetic fixture database.
-- The demo data is entirely fictional and does not reproduce historical results.
-- ============================================================
-- Pharmaceutical Procurement & Supplier Analytics
-- 04_supplier_analytics.sql
-- ============================================================
--
-- Purpose:
-- Analyze supplier participation in UK pharmaceutical
-- procurement awards during 2024.
--
-- Source: UK Find a Tender Service
-- Dataset: Pharmaceutical procurement (CPV 336)
--
-- ============================================================

USE procurement_portfolio_demo;

-- ============================================================
-- 1. TOP SUPPLIERS BY AWARD ACTIVITY
-- ============================================================

-- Business question:
-- Which suppliers are associated with the most awards?
--
-- Supplier names are normalized to reduce inconsistencies
-- caused by capitalization and surrounding whitespace.
--
-- Award counts represent recorded supplier participation,
-- not actual procurement spending.

SELECT
    LOWER(TRIM(name)) AS supplier_name,

    COUNT(DISTINCT awards_id) AS total_awards,

    COUNT(DISTINCT main_id) AS procurement_processes,

    COUNT(*) AS supplier_relationships

FROM stg_award_suppliers

WHERE name IS NOT NULL
  AND TRIM(name) <> ''

GROUP BY LOWER(TRIM(name))

ORDER BY
    total_awards DESC,
    supplier_name ASC

LIMIT 15;

-- ============================================================
-- 2. SUPPLIER CONCENTRATION ANALYSIS
-- ============================================================

-- Business question:
-- What percentage of recorded supplier relationships
-- is associated with the 10 most active suppliers?
--
-- Supplier names are normalized using LOWER() and TRIM().
-- This measures supplier participation concentration,
-- NOT procurement spending or market share.

WITH supplier_activity AS (
    SELECT
        LOWER(TRIM(name)) AS supplier_name,
        COUNT(*) AS relationship_count
    FROM stg_award_suppliers
    WHERE name IS NOT NULL
      AND TRIM(name) <> ''
    GROUP BY LOWER(TRIM(name))
),

ranked_suppliers AS (
    SELECT
        supplier_name,
        relationship_count,
        ROW_NUMBER() OVER (
            ORDER BY relationship_count DESC, supplier_name
        ) AS supplier_rank
    FROM supplier_activity
)

SELECT
    SUM(
        CASE
            WHEN supplier_rank <= 10
            THEN relationship_count
            ELSE 0
        END
    ) AS top_10_relationships,

    SUM(relationship_count) AS total_relationships,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN supplier_rank <= 10
                THEN relationship_count
                ELSE 0
            END
        ) / SUM(relationship_count),
        2
    ) AS top_10_concentration_pct

FROM ranked_suppliers;

-- ============================================================
-- 3. SUPPLIER PARTICIPATION DISTRIBUTION
-- ============================================================

-- Business question:
-- How frequently do suppliers participate in procurement awards?
--
-- Supplier names are normalized using LOWER() and TRIM().
-- Each supplier is counted once in its participation category.

WITH supplier_activity AS (
    SELECT
        LOWER(TRIM(name)) AS supplier_name,
        COUNT(DISTINCT awards_id) AS award_count
    FROM stg_award_suppliers
    WHERE name IS NOT NULL
      AND TRIM(name) <> ''
    GROUP BY LOWER(TRIM(name))
)

SELECT
    CASE
        WHEN award_count = 1 THEN '1 award'
        WHEN award_count BETWEEN 2 AND 5 THEN '2-5 awards'
        WHEN award_count BETWEEN 6 AND 10 THEN '6-10 awards'
        ELSE '11+ awards'
    END AS participation_category,

    COUNT(*) AS supplier_count,

    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM supplier_activity),
        2
    ) AS percentage_of_suppliers

FROM supplier_activity

GROUP BY participation_category

ORDER BY
    CASE participation_category
        WHEN '1 award' THEN 1
        WHEN '2-5 awards' THEN 2
        WHEN '6-10 awards' THEN 3
        ELSE 4
    END;
    
    -- ============================================================
-- 4. AWARDS PER PROCUREMENT PROCESS BY SUPPLIER
-- ============================================================

-- Business question:
-- Which suppliers have multiple awards concentrated
-- within a relatively small number of procurement processes?
--
-- This measures recorded award activity, not spending.

SELECT
    LOWER(TRIM(name)) AS supplier_name,

    COUNT(DISTINCT awards_id) AS total_awards,

    COUNT(DISTINCT main_id) AS procurement_processes,

    ROUND(
        COUNT(DISTINCT awards_id) * 1.0 /
        NULLIF(COUNT(DISTINCT main_id), 0),
        2
    ) AS awards_per_process

FROM stg_award_suppliers

WHERE name IS NOT NULL
  AND TRIM(name) <> ''

GROUP BY LOWER(TRIM(name))

HAVING COUNT(DISTINCT awards_id) >= 5

ORDER BY
    awards_per_process DESC,
    total_awards DESC

LIMIT 15;