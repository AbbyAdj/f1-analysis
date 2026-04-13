{{ config(
    materialized = "view"
) }}

WITH 
int_race_results AS (
    SELECT 
        SEASON,
        SEASON_ROUND,
        DRIVER_ID,
        DRIVER_FULL_NAME,
        CONSTRUCTOR_ID,
        CIRCUIT_ID,
        CIRCUIT_NAME,
        RACE_NAME,
        RACE_POINTS,
        SUM(RACE_POINTS) OVER (PARTITION BY DRIVER_ID ORDER BY SEASON_ROUND, RACE_DATE) AS CUM_RACE_POINTS,
        RACE_DATE
    FROM {{ ref('int_race_results_enriched') }}
),
int_race_results_processed AS (
    SELECT
        SEASON,
        SEASON_ROUND,
        DRIVER_ID,
        DRIVER_FULL_NAME,
        CONSTRUCTOR_ID,
        CIRCUIT_ID,
        CIRCUIT_NAME,
        RACE_NAME,
        RACE_POINTS,
        CUM_RACE_POINTS,
        RANK() OVER (PARTITION BY SEASON, SEASON_ROUND ORDER BY CUM_RACE_POINTS DESC) AS POINTS_RANKING,
        RACE_DATE
from int_race_results
)

SELECT 
    SEASON,
    SEASON_ROUND,
    DRIVER_ID,
    DRIVER_FULL_NAME,
    CONSTRUCTOR_ID,
    CIRCUIT_ID,
    CIRCUIT_NAME,
    RACE_NAME,
    RACE_POINTS,
    CUM_RACE_POINTS,
    POINTS_RANKING,
    RACE_DATE
FROM int_race_results_processed
ORDER BY SEASON_ROUND ASC, POINTS_RANKING ASC