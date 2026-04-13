-- Staging: cleaned races table. One row per race.
-- Rename columns to snake_case, cast types as needed.
-- Look at your raw data first: SELECT * FROM F1_DB.RAW.races LIMIT 5

-- ADDRESS FORIEGN KEY ISSUE LATER

WITH races_raw AS (
  SELECT 
    SEASON,
    ROUND,
    RACE_NAME,
    RACE_DATE,
    RACE_TIME,
    CIRCUIT_ID,
    CIRCUIT_NAME,
    CIRCUIT_LOCALITY,
    CIRCUIT_COUNTRY
  FROM {{ source('f1_raw', 'races') }}
)

SELECT
  SEASON,
  ROUND AS SEASON_ROUND,
  RACE_NAME,
  RACE_DATE,
  TO_TIMESTAMP_TZ(RACE_DATE || ' ' || REPLACE(RACE_TIME, 'Z', ' +0000'), 'YYYY-MM-DD HH24:MI:SS TZHTZM') AS RACE_TIMESTAMP,
  CIRCUIT_ID,
  CIRCUIT_NAME,
  CIRCUIT_LOCALITY,
  CIRCUIT_COUNTRY
FROM races_raw