resource "aws_iam_policy" "dynamodb_policy" {
  name = "${var.service_name}-dynamodb-policy"
  # merge tags
  tags = merge(var.tags, {
    service = var.service_name
  })

  policy = jsonencode({
    Version = "2012-10-17"
    Statement: [
      {
        Sid      = "VisualEditor0"
        Effect   = "Allow"
        Action   = [
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
        Resource = "arn:aws:dynamodb:*:902409284726:table/${var.service_name}.*"
      },
      {
        "Sid": "VisualEditor1",
        "Effect": "Allow",
        "Action": "dynamodb:ListTables",
        "Resource": "*"
      },
      {
        Sid      = "VisualEditor2"
        Effect   = "Allow"
        Action   = [
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:GetRecords"
        ],
        Resource = [
          "arn:aws:dynamodb:*:902409284726:table/${var.service_name}.*/index/*",
          "arn:aws:dynamodb:*:902409284726:table/${var.service_name}.*/stream/*"
        ]
      }
    ]
  })
}

resource "kubernetes_namespace" "ns" {
  metadata {
    name = "${var.service_name}-ns"
  }
}

module "irsa" {
  source = "registry.terraform.io/Young-ook/eks/aws//modules/iam-role-for-serviceaccount"

  name           = "${var.service_name}-irsa"
  namespace      = kubernetes_namespace.ns.metadata[0].name
  serviceaccount = "${var.service_name}-sa"
  oidc_url       = var.oidc_url
  oidc_arn       = var.oidc_arn

  tags           = merge(var.tags, {
    service = var.service_name
  })

  policy_arns = [
    aws_iam_policy.dynamodb_policy.arn
  ]
}
