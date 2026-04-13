from pathlib import Path
import pandas as pd
import json
import os

CACHE_DIR = Path(__file__).parent / "cache"
CLEANED_CSV_DIR = Path(__file__).parent / "cleaned_csv"

if not CLEANED_CSV_DIR.exists():
    os.mkdir(CLEANED_CSV_DIR)

def create_drivers_data():
    drivers_json = Path(CACHE_DIR) / "drivers.json"

    with open(drivers_json) as f:
        drivers = json.load(f)

    df = pd.json_normalize(drivers)

    df = df.loc[:, [
        "driverId", 
        "permanentNumber", 
        "code", 
        "givenName", 
        "familyName", 
        "dateOfBirth", 
        "nationality"
        ]]
    
    df.rename(columns={
        "permanentNumber": "driver_number",
        "code": "driver_code",
        "givenName": "first_name",
        "familyName": "last_name",
        "dateOfBirth": "date_of_birth"
    },
    inplace=True)

    drivers_csv = Path(CLEANED_CSV_DIR) / "drivers.csv"

    df.to_csv(drivers_csv, index=False)

def create_constructors_data():
    constructors_json = Path(CACHE_DIR) / "constructors.json"

    with open(constructors_json) as f:
        constructors = json.load(f)
    df = pd.json_normalize(constructors)

    df = df.loc[:, ["constructorId", "name", "nationality"]]

    df.rename(columns={
        "constructorId": "constructor_id",
        "name": "constructor_name"
    },
    inplace=True)

    constructors_csv = Path(CLEANED_CSV_DIR) / "constructors.csv"

    df.to_csv(constructors_csv, index=False)

def create_races():
    races_json = Path(CACHE_DIR) / "races.json"

    with open(races_json) as f:
        races = json.load(f)

    df = pd.json_normalize(races)

    df = df.loc[:, ["season", "round", "raceName", "date", "time", "Circuit.circuitId", "Circuit.circuitName", "Circuit.Location.locality", "Circuit.Location.country"]]

    df.rename(columns={
        "raceName": "race_name",
        "date": "race_date",
        "time": "race_time",
        "Circuit.circuitId": "circuit_id",
        "Circuit.circuitName": "circuit_name",
        "Circuit.Location.locality": "circuit_locality",
        "Circuit.Location.country": "circuit_country"
    },
    inplace=True)

    races_csv = Path(CLEANED_CSV_DIR) / "races.csv"

    df.to_csv(races_csv, index=False)   

def create_race_results():
    race_results_json = Path(CACHE_DIR) / "race_results.json"

    with open(race_results_json) as f:
        race_results = json.load(f)
    
    df = pd.json_normalize(
        race_results, 
        record_prefix="Results.",
        record_path=["Results"],
        meta=["season", "round", "raceName", ["Circuit", "circuitId"], ["Circuit", "circuitName"]],
    )

    df = df.loc[
            :, 
            [
                "season", 
                "round", 
                "Results.Driver.driverId", 
                "Results.Constructor.constructorId",
                "Results.Driver.code", 
                "Results.positionText", 
                "Results.status", 
                "Results.position", 
                "Results.grid", 
                "Results.points", 
                "Results.laps", 
                "Results.FastestLap.lap", 
                "Results.FastestLap.Time.time", 
                "Results.FastestLap.rank"
            ]
        ]

    df.rename(columns={
        "Results.Driver.driverId": "driver_id",
        "Results.Constructor.constructorId": "constructor_id",
        "Results.Driver.code": "driver_code",
        "Results.status": "status",
        "Results.positionText": "position_text",
        "Results.position": "finishing_position",
        "Results.grid": "starting_position",
        "Results.points": "race_points",
        "Results.laps": "laps_completed",
        "Results.FastestLap.lap": "fastest_lap",
        "Results.FastestLap.Time.time": "fastest_lap_time",
        "Results.FastestLap.rank": "fastest_lap_rank",
    },
    inplace=True)

    race_results_csv = Path(CLEANED_CSV_DIR) / "race_results.csv"

    df.to_csv(race_results_csv, index=False)

def create_csv_files():
    create_drivers_data()
    create_constructors_data()
    create_races()
    create_race_results()

if __name__ == "__main__":
    create_csv_files()
