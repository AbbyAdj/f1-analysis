-- ============================================================================
-- STEP 2: Create Stage
-- ============================================================================
-- Run this ONLY AFTER completing Terraform apply in Step 2

USE ROLE ACCOUNTADMIN;
USE DATABASE f1_db;
USE SCHEMA raw;

-- Grant permissions
GRANT CREATE STAGE ON SCHEMA raw TO ROLE f1_role;
GRANT USAGE ON INTEGRATION f1_s3_integration TO ROLE f1_role;

USE ROLE F1_ROLE;

-- Create stage
CREATE OR REPLACE STAGE f1_s3_stage
  STORAGE_INTEGRATION = f1_s3_integration
  URL = 's3://abby-snowflake-raw/raw/f1/'
  FILE_FORMAT = (TYPE = CSV);

-- Verify stage was created
SHOW STAGES IN SCHEMA raw;
