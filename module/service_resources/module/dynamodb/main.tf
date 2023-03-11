data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "dynamodb_policy" {
  name = "${var.service_name}-dynamodb-policy"
  tags = var.tags

  policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Effect : "Allow"
        Action : [
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:UntagResource",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem",
          "dynamodb:UpdateContinuousBackups",
          "dynamodb:CreateTable",
          "dynamodb:TagResource",
          "dynamodb:GetItem",
          "dynamodb:UpdateTable",
          "dynamodb:DescribeTable",
        ],
        Resource : "arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/${var.service_name}.*"
      },
      {
        "Effect" : "Allow",
        "Action" : "dynamodb:ListTables",
        "Resource" : "*"
      },
      {
        Effect : "Allow"
        Action : [
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:GetRecords"
        ],
        Resource : [
          "arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/${var.service_name}.*/index/*",
          "arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/${var.service_name}.*/stream/*"
        ]
      }
    ]
  })
}
