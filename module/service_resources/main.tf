locals {
  tags = merge(var.tags, {
    service_name = var.service_name
  })
}

module "ecr" {
  count  = var.create_ecr_repo ? 1 : 0
  source = "./module/ecr"

  tags            = local.tags
  repository_name = "${var.service_name}-repo"
}

module "dynamodb" {
  count  = var.enable_dynamodb_access ? 1 : 0
  source = "./module/dynamodb"

  tags         = local.tags
  service_name = var.service_name
}

module "postgres" {
  source = "./module/rds_postgres"
  count  = length(var.postgres_databases)

  tags                      = local.tags
  cluster_security_group_id = var.db_security_group_id
  vpc_id                    = var.vpc_id
  db_subnet_group_name      = var.vpc_subnet_group_name

  service_name        = var.service_name
  instance_name       = var.postgres_databases[count.index].db_name
  instance_class      = var.postgres_databases[count.index].instance_class
  multi_az            = var.postgres_databases[count.index].multi_az
  deletion_protection = var.postgres_databases[count.index].deletion_protection
}

module "mysql" {
  source = "./module/rds_mysql"
  count  = length(var.mysql_databases)

  tags                      = local.tags
  cluster_security_group_id = var.db_security_group_id
  vpc_id                    = var.vpc_id
  db_subnet_group_name      = var.vpc_subnet_group_name

  service_name        = var.service_name
  instance_name       = var.mysql_databases[count.index].db_name
  instance_class      = var.mysql_databases[count.index].instance_class
  multi_az            = var.mysql_databases[count.index].multi_az
  deletion_protection = var.mysql_databases[count.index].deletion_protection
}

module "mariadb" {
  source = "./module/rds_mariadb"
  count  = length(var.mariadb_databases)

  tags                      = local.tags
  cluster_security_group_id = var.db_security_group_id
  vpc_id                    = var.vpc_id
  db_subnet_group_name      = var.vpc_subnet_group_name

  service_name        = var.service_name
  instance_name       = var.mariadb_databases[count.index].db_name
  instance_class      = var.mariadb_databases[count.index].instance_class
  multi_az            = var.mariadb_databases[count.index].multi_az
  deletion_protection = var.mariadb_databases[count.index].deletion_protection
}

module "eventbridge" {
  source = "./module/eventbridge"
  count  = var.eventbus ? 1 : 0

  aws_region     = var.aws_region
  tags           = local.tags
  event_bus_name = var.service_name

  firehose_s3_archive_stream_arn                        = var.firehose_s3_archive_stream_arn
  event_bridge_firehose_s3_catchall_invocation_role_arn = var.event_bridge_firehose_s3_invocation_role_arn
}

module "irsa" {
  source = "./module/irsa"

  tags         = local.tags
  service_name = var.service_name
  cluster_id   = var.cluster_id
  oidc_arn     = var.oidc_arn
  oidc_url     = var.oidc_url
  policy_arns  = concat(module.postgres[*].iam_policy_arn, module.dynamodb[*].policy_arn, module.mysql[*].iam_policy_arn, module.mariadb[*].iam_policy_arn)
}
