"""
Lambda function: process_upload

Triggered by S3 ObjectCreated events. For each uploaded object:
1. Reads the object metadata (size, ETag, content type)
2. Computes the SHA-256 hash of the object content
3. Writes a record to DynamoDB with the metadata

Uses only boto3, no external dependencies.
"""

import hashlib
import json
import logging
import os
import urllib.parse
from datetime import datetime, timezone

import boto3
from botocore.exceptions import ClientError

LOG_LEVEL = os.environ.get("LOG_LEVEL", "INFO")
TABLE_NAME = os.environ["TABLE_NAME"]

logger = logging.getLogger()
logger.setLevel(LOG_LEVEL)

s3 = boto3.client("s3")
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)


def lambda_handler(event, context):
    """
    Entry point. Processes each S3 record in the event.
    """
    logger.info("Received event: %s", json.dumps(event))

    processed = 0
    failed = 0

    for record in event.get("Records", []):
        try:
            process_record(record)
            processed += 1
        except Exception as e:
            logger.exception("Failed to process record: %s", e)
            failed += 1

    logger.info("Processed %d, failed %d", processed, failed)

    return {
        "processed": processed,
        "failed": failed,
    }


def process_record(record):
    """
    Handles one S3 record: read object, compute hash, write to DynamoDB.
    """
    bucket = record["s3"]["bucket"]["name"]
    raw_key = record["s3"]["object"]["key"]
    key = urllib.parse.unquote_plus(raw_key)
    size = record["s3"]["object"].get("size", 0)
    event_time = record.get("eventTime", datetime.now(timezone.utc).isoformat())
    event_name = record.get("eventName", "unknown")

    logger.info("Processing bucket=%s key=%s size=%d", bucket, key, size)

    # Read object and compute SHA-256
    try:
        response = s3.get_object(Bucket=bucket, Key=key)
        body = response["Body"].read()
        sha256 = hashlib.sha256(body).hexdigest()
        content_type = response.get("ContentType", "unknown")
        etag = response.get("ETag", "").strip('"')
    except ClientError as e:
        logger.error("Failed to read object: %s", e)
        raise

    # Write metadata record
    item = {
        "object_key": key,
        "event_time": event_time,
        "bucket": bucket,
        "size_bytes": int(size),
        "sha256": sha256,
        "content_type": content_type,
        "etag": etag,
        "event_name": event_name,
        "processed_at": datetime.now(timezone.utc).isoformat(),
    }

    try:
        table.put_item(Item=item)
        logger.info("Wrote metadata for key=%s sha256=%s", key, sha256)
    except ClientError as e:
        logger.error("Failed to write DynamoDB item: %s", e)
        raise

    return item