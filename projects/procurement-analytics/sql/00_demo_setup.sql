-- Pharmaceutical Procurement Analytics | SYNTHETIC DEMO
-- All records and organization names in this file are fictional.
-- This database does not reproduce the source extract or historical metrics.
-- Requires MySQL 8.0+. Running it resets ONLY the named demo tables.
CREATE DATABASE IF NOT EXISTS procurement_portfolio_demo;
USE procurement_portfolio_demo;

DROP TABLE IF EXISTS stg_contracts;
DROP TABLE IF EXISTS stg_award_suppliers;
DROP TABLE IF EXISTS stg_awards;
DROP TABLE IF EXISTS stg_procurement;

CREATE TABLE stg_procurement (
  id VARCHAR(20) PRIMARY KEY,
  ocid VARCHAR(50) NOT NULL,
  buyer_name VARCHAR(150),
  tender_title VARCHAR(200),
  tender_procurementMethod VARCHAR(40),
  tender_techniques_hasFrameworkAgreement VARCHAR(12)
);

CREATE TABLE stg_awards (
  id VARCHAR(20) PRIMARY KEY,
  main_id VARCHAR(20) NOT NULL
);

CREATE TABLE stg_award_suppliers (
  main_id VARCHAR(20) NOT NULL,
  awards_id VARCHAR(20) NOT NULL,
  id VARCHAR(20),
  name VARCHAR(150)
);

CREATE TABLE stg_contracts (
  id VARCHAR(20) PRIMARY KEY,
  main_id VARCHAR(20) NOT NULL,
  awardID VARCHAR(20),
  status VARCHAR(40),
  value_currency VARCHAR(3),
  value_amount VARCHAR(30)
);

INSERT INTO stg_procurement
(id,ocid,buyer_name,tender_title,tender_procurementMethod,tender_techniques_hasFrameworkAgreement)
VALUES
('p001','demo-ocid-001','Demo Buyer A','Pharmaceutical supply - A','open','true'),
('p002','demo-ocid-002','Demo Buyer B','Pharmaceutical supply - B','limited','false'),
('p003','demo-ocid-003','Demo Buyer A','Pharmaceutical supply - C','open','true'),
('p004','demo-ocid-004','Demo Buyer C','Pharmaceutical supply - D','selective','false'),
('p005','demo-ocid-005','Demo Buyer D','Pharmaceutical supply - E',NULL,NULL),
('p006','demo-ocid-006','Demo Buyer E','Pharmaceutical supply - F','open','true');

INSERT INTO stg_awards (id,main_id) VALUES
('a001','p001'),('a002','p001'),('a003','p002'),('a004','p003'),
('a005','p003'),('a006','p004'),('a007','p005'),('a008','p006');

INSERT INTO stg_award_suppliers (main_id,awards_id,id,name) VALUES
('p001','a001','s01','Supplier Alpha'),
('p001','a001','s02','Supplier Beta'),
('p001','a002','s01','SUPPLIER ALPHA'),
('p002','a003','s03','Supplier Gamma'),
('p003','a004','s02','Supplier Beta'),
('p003','a004','s04','Supplier Delta'),
('p003','a005','s04','Supplier Delta'),
('p004','a006','s05','Supplier Epsilon'),
('p005','a007','s03','Supplier Gamma'),
('p006','a008','s06','Supplier Zeta');

INSERT INTO stg_contracts (id,main_id,awardID,status,value_currency,value_amount) VALUES
('c001','p001','a001','active','GBP','1'),
('c002','p001','a002','active','GBP','1'),
('c003','p002','a003','active','GBP',NULL),
('c004','p003','a004','active','GBP','25000'),
('c005','p003','a005','active','GBP','48000'),
('c006','p004','a006','active','GBP','12000'),
('c007','p006','a008','active','GBP','8300');
