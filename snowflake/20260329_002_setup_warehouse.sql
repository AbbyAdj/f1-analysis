-- Use the role we created
USE ROLE f1_role;

-- Create compute warehouse with auto-suspend to control costs
CREATE WAREHOUSE IF NOT EXISTS f1_wh
  WAREHOUSE_SIZE = 'X-SMALL'
  AUTO_SUSPEND = 60           -- Suspend after 1 minute of inactivity
  AUTO_RESUME = TRUE          -- Auto-resume when queried
  INITIALLY_SUSPENDED = TRUE;

-- Grant usage to role
GRANT USAGE ON WAREHOUSE f1_wh TO ROLE f1_role;