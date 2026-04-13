-- Staging: cleaned drivers table. One row per driver.
-- Rename columns to snake_case, cast types as needed.
-- Look at your raw data first: SELECT * FROM F1_DB.RAW.drivers LIMIT 5

WITH drivers_raw AS (
  SELECT 
    DRIVER_ID,
    DRIVER_NUMBER,
    DRIVER_CODE,
    FIRST_NAME,
    LAST_NAME,
    DATE_OF_BIRTH,
    NATIONALITY
  FROM {{ source('f1_raw', 'drivers') }}
)

SELECT 
  DRIVER_ID,
  DRIVER_NUMBER,
  DRIVER_CODE,
  FIRST_NAME,
  LAST_NAME,
  DATE_OF_BIRTH,
  NATIONALITY
FROM drivers_raw


