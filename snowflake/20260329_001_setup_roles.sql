USE ROLE USERADMIN;

-- Create role for dbt transformations
CREATE ROLE IF NOT EXISTS f1_role COMMENT = 'Role to handle all f1 data lifecycle';

USE ROLE SECURITYADMIN;

-- Grant role to your user (replace with your Snowflake username)
GRANT ROLE f1_role TO USER abbyadjei;
GRANT ROLE f1_role TO ROLE SYSADMIN;

-- Switch to ACCOUNTADMIN for account-level privileges
USE ROLE ACCOUNTADMIN;

-- Grant necessary privileges (requires ACCOUNTADMIN)
GRANT CREATE DATABASE ON ACCOUNT TO ROLE f1_role;
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE f1_role;