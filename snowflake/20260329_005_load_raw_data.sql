-- ============================================================================
-- Load Raw F1 Data with Explicit Schema Control
-- ============================================================================

-- SEPARATE INTO DIFFERENT FILES LATER


USE ROLE f1_role;
USE DATABASE f1_db;
USE SCHEMA raw;
USE WAREHOUSE f1_wh;

-- ============================================================================
-- TABLE 1: Drivers
-- ============================================================================

CREATE OR REPLACE TABLE drivers (
  driver_id VARCHAR(50) PRIMARY KEY COMMENT  '',
  driver_number INT,   
  driver_code VARCHAR(3),
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  date_of_birth DATE,        
  nationality VARCHAR(100)
)
COMMENT=''
;

COPY INTO drivers
FROM @f1_s3_stage/drivers.csv
FILE_FORMAT = (
  TYPE = CSV
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER = 1
  TRIM_SPACE = TRUE
  EMPTY_FIELD_AS_NULL = True
)
ON_ERROR = 'CONTINUE';


-- ============================================================================
-- TABLE 2: Constructors
-- ============================================================================

CREATE OR REPLACE TABLE constructors (
  constructor_id VARCHAR(50) PRIMARY KEY ,
  constructor_name VARCHAR(200) NOT NULL,
  nationality VARCHAR(100)
);

COPY INTO constructors
FROM @f1_s3_stage/constructors.csv
FILE_FORMAT = (
  TYPE = CSV
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER = 1
  TRIM_SPACE = TRUE
  EMPTY_FIELD_AS_NULL = True
)
ON_ERROR = 'CONTINUE';


-- ============================================================================
-- TABLE 3: Races
-- ============================================================================

CREATE OR REPLACE TABLE races (
  season INT NOT NULL,
  round INT NOT NULL,
  race_name VARCHAR(200) NOT NULL,
  race_date DATE NOT NULL,
  race_time VARCHAR(20) NOT NULL,                 -- Format: "04:00:00Z"
  circuit_id VARCHAR(50) NOT NULL,
  circuit_name VARCHAR(200) NOT NULL,
  circuit_locality VARCHAR(100),
  circuit_country VARCHAR(100),
  PRIMARY KEY (season, round)
);

COPY INTO races
FROM @f1_s3_stage/races.csv
FILE_FORMAT = (
  TYPE = CSV
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER = 1
  TRIM_SPACE = TRUE
  EMPTY_FIELD_AS_NULL = True
)
ON_ERROR = 'CONTINUE';


-- ============================================================================
-- TABLE 4: Race Results
-- ============================================================================

CREATE OR REPLACE TABLE race_results (
  season INT NOT NULL,
  round INT NOT NULL,
  driver_id VARCHAR(50) NOT NULL,
  constructor_id VARCHAR(50) NOT NULL,
  driver_code VARCHAR(3) NOT NULL,
  position_text VARCHAR(10) NOT NULL,             -- Can be "1" or "R", "D", "W"
  race_status VARCHAR(100) NOT NULL,
  finishing_position INT NOT NULL,
  starting_position INT NOT NULL,
  race_points INT NOT NULL,              
  laps_completed INT NOT NULL,
  fastest_lap INT,          
  fastest_lap_time VARCHAR,      
  fastest_lap_rank INT,
  PRIMARY KEY (season, round, driver_id),
  FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
  FOREIGN KEY (constructor_id) REFERENCES constructors(constructor_id),
  FOREIGN KEY (season, round) REFERENCES races(season, round)
);

COPY INTO race_results
FROM @f1_s3_stage/race_results.csv
FILE_FORMAT = (
  TYPE = CSV
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER = 1
  TRIM_SPACE = TRUE
--   TIME_FORMAT = 'ME:SS.FF3'
  EMPTY_FIELD_AS_NULL = True
)
ON_ERROR = 'CONTINUE';


-- ============================================================================
-- Validation Queries
-- ============================================================================

-- Check for any load errors
-- Check all tables
SELECT TABLE_NAME, FILE_NAME, ROW_COUNT, ROW_PARSED, ERROR_COUNT, STATUS
FROM INFORMATION_SCHEMA.LOAD_HISTORY
WHERE TABLE_NAME IN ('DRIVERS', 'CONSTRUCTORS', 'RACES', 'RACE_RESULTS') 
ORDER BY LAST_LOAD_TIME DESC;

-- -- Sample data verification
SELECT * FROM drivers LIMIT 5;
SELECT * FROM constructors LIMIT 5;
SELECT * FROM races LIMIT 5;
SELECT * FROM race_results LIMIT 5;