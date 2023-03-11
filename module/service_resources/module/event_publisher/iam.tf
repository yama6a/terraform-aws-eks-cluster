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
          "arn:aws:events:${var.aws_region}:${data.aws_caller_identity.current.account_id}:event-bus/${var.event_bus_name}",
          "arn:aws:events:*:${data.aws_caller_identity.current.account_id}:endpoint/*"
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
