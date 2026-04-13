-- Use the role we created
USE ROLE f1_role;

-- Create the database
CREATE DATABASE IF NOT EXISTS f1_db;

-- Create schemas: one for raw data from S3, one for dbt output
CREATE SCHEMA IF NOT EXISTS f1_db.raw;
CREATE SCHEMA IF NOT EXISTS f1_db.f1_schema;

-- Grant all privileges on the database to the role
GRANT ALL ON DATABASE f1_db TO ROLE f1_role;

-- Grant all privileges on schemas to the role
GRANT ALL ON SCHEMA f1_db.raw TO ROLE f1_role;
GRANT ALL ON SCHEMA f1_db.f1_schema TO ROLE f1_role;

-- Grant privileges on future tables (so dbt-created tables are automatically accessible)
GRANT ALL ON FUTURE TABLES IN SCHEMA f1_db.raw TO ROLE f1_role;
GRANT ALL ON FUTURE TABLES IN SCHEMA f1_db.f1_schema TO ROLE f1_role;