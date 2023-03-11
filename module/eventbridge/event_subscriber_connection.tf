data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_event_connection" "event_subscriber_connection" {
  name               = "service-subscription-connection"
  description        = "Connection Definition for EventBridge Service Subscriptions via Access Token"
  authorization_type = "API_KEY"

  auth_parameters {
    api_key {
      key   = "x-api-key"
      value = aws_secretsmanager_secret_version.subscription_api_key_secret_version.secret_string
    }
  }
}

resource "aws_secretsmanager_secret" "subscription_api_key_secret" {
  name = "global-eventbridge-subscription-api-key_${random_string.suffix.result}"
}

resource "aws_secretsmanager_secret_version" "subscription_api_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.subscription_api_key_secret.id
  secret_string = random_password.subscription_api_key_string.result
}

// random password of 32 alphanum characters
resource "random_password" "subscription_api_key_string" {
  length      = 32
  special     = false
  min_lower   = 3
  min_upper   = 3
  min_numeric = 3
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
  lower   = true
  number  = true
}

// allow eventbridge to invoke the api destinations specified to subscribe to this event bus
resource "aws_iam_role" "event_subscriber_connection_role" {
  name = "service-subscription-connection-role"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "events.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "api_destination_stream_policy"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "events:InvokeApiDestination"
          ],
          "Resource" : "arn:aws:events:${var.aws_region}:${data.aws_caller_identity.current.account_id}:api-destination/*"
        }
      ]
    })
  }
}
