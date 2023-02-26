resource "aws_cloudwatch_event_connection" "event_subscriber_connection" {
  name               = "service-subscription-connection"
  description        = "A connection description"
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

resource "aws_secretsmanager_secret" "subscription_api_key_secret" {
  name = "global-eventbridge-subscription-api-key"
}

resource "aws_secretsmanager_secret_version" "subscription_api_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.subscription_api_key_secret.id
  secret_string = random_password.subscription_api_key_string.result
}
