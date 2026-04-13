-- Staging: cleaned race results table. One row per driver per race.
-- Rename columns to snake_case, cast types as needed.
-- Look at your raw data first: SELECT * FROM F1_DB.RAW.race_results LIMIT 5

-- ADDRESS FORIEGN KEY ISSUE LATER
{{ config(
    sql_header="ALTER SESSION SET TIME_OUTPUT_FORMAT = 'HH24:MI:SS.FF3';"
) }}

WITH race_results_raw AS (
  SELECT 
    SEASON,
    ROUND,
    DRIVER_ID,
    CONSTRUCTOR_ID,
    DRIVER_CODE,
    POSITION_TEXT,
    RACE_STATUS,
    FINISHING_POSITION,
    STARTING_POSITION,
    RACE_POINTS,
    LAPS_COMPLETED,
    FASTEST_LAP,
    CASE 
      WHEN FASTEST_LAP_TIME IS NULL THEN NULL
      WHEN LENGTH(SPLIT_PART(FASTEST_LAP_TIME, ':', 1)) = 1 
        THEN '00:0' || FASTEST_LAP_TIME
      ELSE '00:' || FASTEST_LAP_TIME
    END AS FASTEST_LAP_TIME,
    FASTEST_LAP_RANK
  FROM {{ source('f1_raw', 'race_results') }}
)

SELECT 
    SEASON,
    ROUND AS SEASON_ROUND,
    DRIVER_ID,
    CONSTRUCTOR_ID,
    DRIVER_CODE,
    POSITION_TEXT,
    RACE_STATUS,
    FINISHING_POSITION,
    STARTING_POSITION,
    RACE_POINTS,
    LAPS_COMPLETED,
    FASTEST_LAP_TIME,
    FASTEST_LAP,

    FASTEST_LAP_RANK
FROM race_results_raw
