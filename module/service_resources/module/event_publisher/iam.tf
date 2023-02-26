// allow eventbridge to invoke the api destinations specified to subscribe to this event bus
resource "aws_iam_role" "event_subscriber_connection_role" {
  name               = "service-subscription-connection-role"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "events.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name   = "firehose_s3_stream_policy"
    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "events:InvokeApiDestination"
          ],
          "Resource": flatten(values(var.event_subscribers))
        }
      ]
    })
  }
}

// allows a SA to send events to the event bus
resource "aws_iam_policy" "eventbridge_policy" {
  name = "${var.event_bus_name}-eventbus-policy"
  tags = var.tags

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "events:DescribeEventBus",
          "events:PutEvents",
          "events:DescribeEndpoint"
        ],
        "Resource" : [
          "arn:aws:events:eu-west-1:902409284726:event-bus/${var.event_bus_name}",
          "arn:aws:events:*:902409284726:endpoint/*"
        ]
      },
      {
        "Sid" : "VisualEditor1",
        "Effect" : "Allow",
        "Action" : [
          "events:ListEndpoints",
          "events:ListEventBuses"
        ],
        "Resource" : "*"
      }
    ]
  })
}
