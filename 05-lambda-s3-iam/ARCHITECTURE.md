              [You upload a file]
                       |
                       | PUT object
                       v
              [S3 bucket: uploads]
                       |
                       | s3:ObjectCreated:* event
                       v
              [Lambda function: process_upload]
                       |
        +--------------+--------------+
        |                             |
        v                             v
[DynamoDB: file_metadata]    [CloudWatch Logs]
  stores: key, size, hash,       stores: execution
  timestamp, event_type          traces, print output