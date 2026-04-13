-- Staging: cleaned constructors table. One row per team.
-- Rename columns to snake_case, cast types as needed.
-- Look at your raw data first: SELECT * FROM F1_DB.RAW.constructors LIMIT 5

WITH constructors_raw AS (
  SELECT 
    CONSTRUCTOR_ID,
    CONSTRUCTOR_NAME,
    NATIONALITY
  FROM {{ source('f1_raw', 'constructors') }}
)

SELECT
  CONSTRUCTOR_ID,
  CONSTRUCTOR_NAME,
  NATIONALITY
FROM constructors_raw
