data "aws_caller_identity" "current" {}

locals {
  // only instances >= medium (medium, large, 2xlarge ...) support performance insights for MySQL
  enable_performance_insights = length(regexall(".*(medium|large)$", terraform.workspace)) > 0
}

module "rds_mysql" {
  source = "registry.terraform.io/terraform-aws-modules/rds/aws"

  identifier = "${var.service_name}-${var.instance_name}"
  db_name    = replace(var.instance_name, "-", "_")
  tags       = var.tags

  engine                              = "mysql"
  engine_version                      = "8.0"
  family                              = "mysql8.0"
  major_engine_version                = "8.0"
  port                                = 3306
  iam_database_authentication_enabled = true


  instance_class = var.instance_class
  multi_az       = var.multi_az

  allocated_storage     = 20
  max_allocated_storage = 100

  username               = "dbuser"
  create_random_password = true

  db_subnet_group_name = var.db_subnet_group_name

  vpc_security_group_ids = [
    module.security_group.security_group_id
  ]

  maintenance_window          = "Mon:00:00-Mon:01:00"
  create_cloudwatch_log_group = true

  enabled_cloudwatch_logs_exports = [
    "general",
    "slowquery"
  ]


  // if we don't skip the final snapshot, terraform will fail to destroy the option group until we manually delete the final snapshot
  skip_final_snapshot     = true
  backup_window           = "01:00-02:00"
  backup_retention_period = 30
  deletion_protection     = var.deletion_protection

  performance_insights_enabled          = local.enable_performance_insights
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name                  = "rds-monitoring-role-${var.instance_name}"
  monitoring_role_use_name_prefix       = false
  monitoring_role_description           = "Monitoring role for RDS instance ${var.instance_name}"

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  db_instance_tags = {
    "Sensitive" = "high"
  }

  db_option_group_tags = {
    "Sensitive" = "low"
  }

  db_parameter_group_tags = {
    "Sensitive" = "low"
  }

  db_subnet_group_tags = {
    "Sensitive" = "high"
  }
}


module "security_group" {
  source  = "registry.terraform.io/terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "rds-${var.instance_name}"
  tags        = var.tags
  description = "MySQL DB security group"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = var.cluster_security_group_id
      description              = "Allow MySQL TCP Traffic via Ingress Rule from EKS Cluster Nodes"
    },
  ]
}


// used for IAM auth, doesn't properly work at the moment, so we're using user/pw auth via secret manager below
resource "aws_iam_policy" "rds_iam_policy" {
  name = "${var.service_name}-${var.instance_name}-rds-policy"
  tags = var.tags

  policy = jsonencode({
    Version = "2012-10-17"
    Statement : [
      {
        // allow SA connect to DBs via IAM authentication
        // (doesn't quite work yet. With root credentials it works, with SA credentials generated token is not valid...)
        Resource = "${module.rds_mysql.db_instance_arn}/${module.rds_mysql.db_instance_username}"
        Effect   = "Allow"

        Action = [
          "rds-db:connect",
        ],
      },
      {
        // allow SA to retrieve the db password from aws secrets manager
        Resource = aws_secretsmanager_secret.password.arn
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

// When destroying TF resources, secrets still hang around in AWS while they are scheduled for deletion.
// So, we add a random suffix to the secret name to ensure that the secret can be created again with the "same" name.
resource "random_string" "random" {
  length  = 8
  numeric = true
  lower   = true
  special = false
  upper   = false
}

resource "aws_secretsmanager_secret" "password" {
  name = "${var.service_name}-${var.instance_name}-rds-password-${random_string.random.result}"
}

resource "aws_secretsmanager_secret_version" "password" {
  secret_id     = aws_secretsmanager_secret.password.id
  secret_string = module.rds_mysql.db_instance_password
}
