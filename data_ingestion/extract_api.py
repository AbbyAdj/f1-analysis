import requests
from pprint import pprint
from time import sleep
from utils.utils import create_json_cache
import os
from datetime import datetime

BASE_API = "https://api.jolpi.ca/ergast/f1"
CURRENT_YEAR = datetime.now().year
year = int(os.getenv("YEAR", 2025))
# RACES, DRIVERS, CONSTRUCTORS, RESULTS FOR 2025

def get_races(year: int):

    url = f"{BASE_API}/{year}/races"

    if year < 1950 or year > CURRENT_YEAR:
        raise Exception("You need to specify a year between 1950 and the current year")
    
    result = []

    try:   
        params = {"limit": 100, "offset": 0} 
        while True:
            r = requests.get(url, timeout=30, params=params)
            r.raise_for_status()
            data = r.json()["MRData"]
            result.extend(data["RaceTable"]["Races"])
            if params["limit"] + params["offset"] >= int(data["total"]):
                break
            params["offset"] += params["limit"]
            sleep(1)
        return(result)
    except requests.exceptions.RequestException as e:
        print(e.response)
    except Exception as e:
        print(e)

def get_drivers(year:int):
    url = f"{BASE_API}/{year}/drivers"


    if year < 1950 or year > CURRENT_YEAR:
        raise Exception("You need to specify a year between 1950 and the current year")
    
    result = []

    try:   
        params = {"limit": 100, "offset": 0} 
        while True:
            r = requests.get(url, timeout=30, params=params)
            r.raise_for_status()
            data = r.json()["MRData"]
            result.extend(data["DriverTable"]["Drivers"])
            if params["limit"] + params["offset"] >= int(data["total"]):
                break
            params["offset"] += params["limit"]
            sleep(1)
        return(result)
    except requests.exceptions.RequestException as e:
        print(e.response)
    except Exception as e:
        print(e)

def get_constructors(year:int):
    url = f"{BASE_API}/{year}/constructors"

    if year < 1950 or year > CURRENT_YEAR:
        raise Exception("You need to specify a year between 1950 and the current year")
    
    result = []

    try:   
        params = {"limit": 100, "offset": 0} 
        while True:
            r = requests.get(url, timeout=30, params=params)
            r.raise_for_status()
            data = r.json()["MRData"]
            result.extend(data["ConstructorTable"]["Constructors"])
            if params["limit"] + params["offset"] >= int(data["total"]):
                break
            params["offset"] += params["limit"]
            sleep(1)
        return(result)
    except requests.exceptions.RequestException as e:
        print(e.response)
    except Exception as e:
        print(e)

def get_race_results(year: int):
    url = f"{BASE_API}/{year}/results"

    if year < 1950 or year > CURRENT_YEAR:
        raise Exception("You need to specify a year between 1950 and the current year")
    
    result = []

    try:   
        params = {"limit": 100, "offset": 0} 
        while True:
            r = requests.get(url, timeout=30, params=params)
            r.raise_for_status()
            data = r.json()["MRData"]
            result.extend(data["RaceTable"]["Races"])
            if params["limit"] + params["offset"] >= int(data["total"]):
                break
            params["offset"] += params["limit"]
            sleep(1)
        return(result)
    except requests.exceptions.RequestException as e:
        print(e.response)
    except Exception as e:
        print(e)


def create_cache(year:int):
    races = get_races(year)
    drivers = get_drivers(year)
    constructors = get_constructors(year)
    race_results = get_race_results(year)

    if races:
        create_json_cache(races, "races")

    if drivers:
        create_json_cache(drivers, "drivers")

    if constructors:
        create_json_cache(constructors, "constructors")

    if race_results:
        create_json_cache(race_results, "race_results")


if __name__ == "__main__":
    create_cache(year)
