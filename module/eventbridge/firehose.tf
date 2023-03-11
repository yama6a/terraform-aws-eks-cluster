// This file creates a Kinesis Firehose stream that archives events from an Eventbridge stream to an S3 bucket.
resource "aws_kinesis_firehose_delivery_stream" "firehose_s3_event_archive" {
  tags        = var.tags
  name        = "${var.project_name}_firehose_s3_event_archive"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_to_s3_iam_role.arn
    bucket_arn = aws_s3_bucket.event_archive.arn

    buffer_size         = 64
    buffer_interval     = 60
    prefix              = "events/detail_type=!{partitionKeyFromQuery:detail_type}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
    error_output_prefix = "errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/!{firehose:error-output-type}/"

    dynamic_partitioning_configuration {
      enabled = true
    }

    # Multi-record deaggregation processor
    processing_configuration {
      enabled = "true"

      processors {
        type = "RecordDeAggregation"
        parameters {
          parameter_name  = "SubRecordType"
          parameter_value = "JSON"
        }
      }

      # Adds a new line after each record (with Firehose there will always be multiple events per file)
      processors {
        type = "AppendDelimiterToRecord"
      }

      # JQ processor to extract the detail-type (= event name) from the event's metadata
      processors {
        type = "MetadataExtraction"
        parameters {
          // the parameters need to be in this order, or terraform will keep trying to swap them.
          parameter_name  = "MetadataExtractionQuery"
          parameter_value = "{detail_type:.\"detail-type\"}"
        }
        parameters {
          parameter_name  = "JsonParsingEngine"
          parameter_value = "JQ-1.6"
        }
      }
    }
  }
}
