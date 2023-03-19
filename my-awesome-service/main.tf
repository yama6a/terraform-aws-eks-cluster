locals {
  tags = merge(var.tags, {
    service_name = var.service_name
  })
}

module "ecr" {
  source = "../module/service_resources/module/ecr"

  tags            = local.tags
  repository_name = "${var.service_name}-repo"
}

module "activate_dynamodb" {
  source = "../module/service_resources/module/dynamodb"

  tags         = local.tags
  service_name = var.service_name
}

module "main_postgres" {
  source = "../module/service_resources/module/rds_postgres"

  tags                      = local.tags
  cluster_security_group_id = var.db_security_group_id
  vpc_id                    = var.vpc_id
  db_subnet_group_name      = var.vpc_subnet_group_name

  service_name        = var.service_name
  instance_name       = "pg-db-name-1"
  instance_class      = "db.t4g.micro"
  multi_az            = false
  deletion_protection = false
}

module "main_mysql" {
  source = "../module/service_resources/module/rds_mysql"

  tags                      = local.tags
  cluster_security_group_id = var.db_security_group_id
  vpc_id                    = var.vpc_id
  db_subnet_group_name      = var.vpc_subnet_group_name

  service_name        = var.service_name
  instance_name       = "mysql-db-name-1"
  instance_class      = "db.t4g.micro"
  multi_az            = false
  deletion_protection = false
}

module "main_mariadb" {
  source = "../module/service_resources/module/rds_mariadb"

  tags                      = local.tags
  cluster_security_group_id = var.db_security_group_id
  vpc_id                    = var.vpc_id
  db_subnet_group_name      = var.vpc_subnet_group_name

  service_name        = var.service_name
  instance_name       = "mariadb-db-name-1"
  instance_class      = "db.t4g.micro"
  multi_az            = false
  deletion_protection = false
}

module "event_publisher" {
  source = "../module/service_resources/module/event_publisher"

  aws_region     = var.aws_region
  tags           = local.tags
  event_bus_name = var.service_name

  firehose_s3_event_archive_stream_arn                  = var.firehose_s3_event_archive_stream_arn
  event_bridge_firehose_s3_catchall_invocation_role_arn = var.event_bridge_firehose_s3_invocation_role_arn
}

module "event_subscriber" {
  source = "../module/service_resources/module/event_subscriber"

  tags                    = local.tags
  subscriber_service_name = var.service_name
  subscriptions           = [
    {
      event_bus_name = "my-awesome-service2"
      event_name     = "Service2Event"
      messageGroupId = "default"
    },
    {
      event_bus_name = "my-awesome-service"
      event_name     = "AnimalCreatedEvent"
      messageGroupId = "default"
    },
    {
      event_bus_name = "my-awesome-service"
      event_name     = "AnimalCreatedEvent"
      messageGroupId = "metrics-counter"
    },
  ]
}

module "irsa" {
  source = "../module/service_resources/module/irsa"

  tags         = local.tags
  service_name = var.service_name
  cluster_id   = var.cluster_id
  oidc_arn     = var.oidc_arn
  oidc_url     = var.oidc_url

  policy_arns = tolist([
    // db permissions
    module.main_postgres.iam_policy_arn,
    module.main_mysql.iam_policy_arn,
    module.main_mariadb.iam_policy_arn,
    module.activate_dynamodb.iam_policy_arn,

    // pub/sub permissions
    module.event_publisher.iam_eventbridge_publishing_policy_arn,
    module.event_subscriber.iam_sqs_consumer_policy_arn
  ])
}
