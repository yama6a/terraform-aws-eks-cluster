data "aws_caller_identity" "current" {}

// ToDo: Move this to the service's terraform module because if one service returns 401 to eventbridge, it will stop all other services from receiving events.
resource "aws_cloudwatch_event_connection" "event_subscriber_connection" {
  name               = "service-subscription-connection"
  description        = "Connection Definition for EventBridge Service Subscriptions via Access Token"
  authorization_type = "API_KEY"

  auth_parameters {
    api_key {
      key   = "x-api-key"
      value = random_password.subscription_api_key_string.result
    }
  }
}

// random password of 32 alphanum characters
resource "random_password" "subscription_api_key_string" {
  length      = 32
  special     = false
  min_lower   = 3
  min_upper   = 3
  min_numeric = 3
}

resource "aws_iam_policy" "subscription_api_key_secret_policy" {
  name = "eventbridge-subscription-api-key-access-rds-policy"
  tags = var.tags

  policy = jsonencode({
    Version = "2012-10-17"
    Statement : [
      {
        // Allow an SA to retrieve the API ACCESS KEY from aws secrets manager.
        // This IAM role still needs to be pegged to every service's SA, so we need to export it.
        Resource = aws_cloudwatch_event_connection.event_subscriber_connection.secret_arn
        Effect   = "Allow"

        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ],
      },
    ]
  })
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
