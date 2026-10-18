# -----------------------------------------------------------------------------
# 1. Athena Workgroup
# Why? Groups queries and enforces cost controls. If a query tries to scan
# too much data, the workgroup cancels it.
# -----------------------------------------------------------------------------
resource "aws_athena_workgroup" "main" {
  name          = "${var.project_name}-workgroup"
  force_destroy = true

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = false

    result_configuration {
      output_location = "s3://${var.cloudtrail_bucket_name}/athena-results/"
    }
  }
}

# -----------------------------------------------------------------------------
# 2. Glue Catalog Database
# Why? Athena uses the Glue Data Catalog to store table definitions.
# -----------------------------------------------------------------------------
resource "aws_glue_catalog_database" "cloudtrail_db" {
  name = "cloudtrail_db"
}

# -----------------------------------------------------------------------------
# 3. Glue Catalog Table (Schema for CloudTrail Logs)
# Why? Athena needs to know how to parse the JSON inside the .json.gz files.
# This defines the columns we can query (like eventName, sourceIPAddress, userIdentity).
# -----------------------------------------------------------------------------
resource "aws_glue_catalog_table" "cloudtrail_table" {
  name          = "cloudtrail_logs"
  database_name = aws_glue_catalog_database.cloudtrail_db.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "EXTERNAL"                     = "TRUE"
    "parquet.compression"          = "SNAPPY"
    "projection.enabled"           = "true"
    "projection.day.type"          = "date"
    "projection.day.range"         = "2024/01/01,NOW"
    "projection.day.format"        = "yyyy/MM/dd"
    "projection.day.interval"      = "1"
    "projection.day.interval.unit" = "DAYS"
    "storage.location.template"    = "s3://${var.cloudtrail_bucket_name}/AWSLogs/106573904834/CloudTrail/eu-north-1/$${day}"
  }

  storage_descriptor {
    location      = "s3://${var.cloudtrail_bucket_name}/AWSLogs/106573904834/CloudTrail/eu-north-1/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
      parameters = {
        "serialization.format"  = "1"
        "ignore.malformed.json" = "true"
      }
    }

    columns {
      name = "eventversion"
      type = "string"
    }
    columns {
      name = "useridentity"
      type = "struct<type:string,principalid:string,arn:string,accountid:string,invokedby:string,accesskeyid:string,username:string,sessioncontext:struct<attributes:struct<mfaauthenticated:string,creationdate:string>,sessionissuer:struct<type:string,principalid:string,arn:string,accountid:string,username:string>>>"
    }
    columns {
      name = "eventtime"
      type = "string"
    }
    columns {
      name = "eventsource"
      type = "string"
    }
    columns {
      name = "eventname"
      type = "string"
    }
    columns {
      name = "awsregion"
      type = "string"
    }
    columns {
      name = "sourceipaddress"
      type = "string"
    }
    columns {
      name = "useragent"
      type = "string"
    }
    columns {
      name = "errorcode"
      type = "string"
    }
    columns {
      name = "errormessage"
      type = "string"
    }
    columns {
      name = "requestid"
      type = "string"
    }
    columns {
      name = "eventid"
      type = "string"
    }
    columns {
      name = "readonly"
      type = "string"
    }
    columns {
      name = "resources"
      type = "array<struct<arn:string,accountid:string,type:string>>"
    }
  }

  partition_keys {
    name = "day"
    type = "string"
  }
}