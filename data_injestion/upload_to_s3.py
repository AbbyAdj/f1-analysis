import boto3
from botocore.exceptions import ClientError
from dotenv import load_dotenv
import os
from pathlib import Path

load_dotenv(override=True)

RAW_BUCKET = os.getenv("RAW_S3_BUCKET")
CLEANED_CSV_DIR = Path(__file__).parent / "cleaned_csv"

s3_client = boto3.client("s3", region=os.getenv("AWS_REGION", "eu-west-2"))

if not CLEANED_CSV_DIR.exists():
    raise Exception("Please ensure that there are files to upload and their directory exists")

if not RAW_BUCKET:
    raise Exception("Please add a 'RAW_S3_BUCKET' environment variable")

def upload_to_s3(s3_client):
    """
    Upload CSV files from the cleaned_csv directory to AWS S3.
    
    Args:
        s3_client: Boto3 S3 client instance for uploading files.
    
    Raises:
        ClientError: If AWS S3 operation fails (e.g., bucket doesn't exist).
        Exception: For any unexpected errors during upload.
    """
    file_list = list(CLEANED_CSV_DIR.glob("*.csv"))
    for file in file_list:
        print(f"Uploading {file.name}......")
        try:
            s3_client.upload_file(
                Filename = str(file),
                Bucket = RAW_BUCKET,
                Key = f"raw/f1/{file.name}"
            )
            print(f"{file.name} upload successful!")
        except ClientError as e:
            if e.response['Error']['Code'] == 'NoSuchBucket':
                print("Please ensure the bucket exists and try again")
                break
            else:
                print(f"AWS Error: {e.response['Error']['Message']}")
        except Exception as e:
            print(f"An unknown exception occurred. Please check details below: \n\n {e}")

if __name__ == "__main__":
    upload_to_s3(s3_client)