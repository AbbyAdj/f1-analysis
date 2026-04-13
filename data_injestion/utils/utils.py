from pathlib import Path
import json
import os

CACHE_DIR = Path(__file__).parent.parent / "cache"

if not CACHE_DIR.exists():
    os.mkdir(CACHE_DIR)

def create_json_cache(data: dict | list, file_name:str):
    file_path = Path(CACHE_DIR) / f"{file_name}.json"

    with open(file_path, "w") as f:
        f.write(json.dumps(data, indent=4))

