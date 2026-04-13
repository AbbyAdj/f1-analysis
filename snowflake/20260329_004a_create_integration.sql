-- ============================================================================
-- STEP 1: Create Storage Integration and Get AWS Values
-- ============================================================================
-- Run this file first, then copy the DESC output for Terraform

USE ROLE ACCOUNTADMIN;
USE DATABASE f1_db;  
USE SCHEMA raw;

-- Create storage integration with the IAM role ARN from Terraform
CREATE STORAGE INTEGRATION IF NOT EXISTS f1_s3_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::359994327007:role/snowflake_s3_access_role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://abby-snowflake-raw/raw/f1/');

-- Get the AWS IAM principal info
DESC STORAGE INTEGRATION f1_s3_integration;

-- IMPORTANT: From the DESC output above, copy these two values:
--   STORAGE_AWS_IAM_USER_ARN
--   STORAGE_AWS_EXTERNAL_ID
-- 
-- Next step: Update terraform/terraform.tfvars with those values
-- Then run: terraform apply
-- Then run: 20260329_004B_create_stage.sql
