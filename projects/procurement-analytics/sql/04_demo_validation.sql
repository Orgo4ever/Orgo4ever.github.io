-- Synthetic demo validation: expected values are specific to the fictional fixture.
USE procurement_portfolio_demo;

SELECT
  (SELECT COUNT(*) FROM stg_procurement) AS procurement_processes,
  (SELECT COUNT(*) FROM stg_awards) AS awards,
  (SELECT COUNT(*) FROM stg_award_suppliers) AS supplier_award_associations,
  (SELECT COUNT(*) FROM stg_contracts) AS contracts;
-- Expected: 6 | 8 | 10 | 7

SELECT
  COUNT(*) AS contract_records,
  SUM(value_amount IS NULL OR TRIM(value_amount) = '') AS missing_values,
  SUM(TRIM(value_amount) = '1') AS nominal_one_values,
  SUM(value_amount IS NOT NULL
      AND TRIM(value_amount) <> ''
      AND TRIM(value_amount) <> '1') AS other_values
FROM stg_contracts;
-- Expected: 7 | 1 | 2 | 4

SELECT
  SUM(p.id IS NULL) AS orphan_awards,
  (SELECT COUNT(*) FROM stg_award_suppliers s
     LEFT JOIN stg_awards a ON a.id = s.awards_id
     WHERE a.id IS NULL) AS orphan_supplier_award_links,
  (SELECT COUNT(*) FROM stg_contracts c
     LEFT JOIN stg_procurement p2 ON p2.id = c.main_id
     WHERE p2.id IS NULL) AS orphan_contract_process_links
FROM stg_awards a
LEFT JOIN stg_procurement p ON p.id = a.main_id;
-- Expected: 0 | 0 | 0

-- Quality note: '1' is a reporting usability flag, not definitive proof of an error.
