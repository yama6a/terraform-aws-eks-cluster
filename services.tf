// Full example of a service that publishes and subscribes to (its own) events and uses all databases.
module "my-awesome-service" {
  source       = "./my-awesome-service"
  service_name = "my-awesome-service"

  tags                  = local.tags
  vpc_id                = module.vpc.vpc_id
  vpc_subnet_group_name = module.vpc.db_subnet_group_name
  db_security_group_id  = module.eks.cluster_security_group_id
  oidc_url              = module.eks.oidc_url
  oidc_arn              = module.eks.oidc_arn
  cluster_id            = module.eks.cluster_id
  aws_region            = var.aws_region

  firehose_s3_event_archive_stream_arn         = module.eventbridge.s3_firehose_stream_arn
  event_bridge_firehose_s3_invocation_role_arn = module.eventbridge.eventbridge_to_firehose_iam_role_arn
}


// Full example of a second service that publishes and subscribes to (its own) events and uses all databases.
module "my-awesome-service2" {
  source       = "./my-awesome-service2"
  service_name = "my-awesome-service2"

  tags                  = local.tags
  vpc_id                = module.vpc.vpc_id
  vpc_subnet_group_name = module.vpc.db_subnet_group_name
  db_security_group_id  = module.eks.cluster_security_group_id
  oidc_url              = module.eks.oidc_url
  oidc_arn              = module.eks.oidc_arn
  cluster_id            = module.eks.cluster_id
  aws_region            = var.aws_region

  firehose_s3_event_archive_stream_arn         = module.eventbridge.s3_firehose_stream_arn
  event_bridge_firehose_s3_invocation_role_arn = module.eventbridge.eventbridge_to_firehose_iam_role_arn
}
