provider "aws" {
  region = var.aws_region
}

locals {
  name_prefix  = "${var.project_name}-${var.env}"
  cluster_name = "${local.name_prefix}-cl"

  tags = merge(var.tags, {
    env       = var.env
    project   = var.project_name
    managedBy = "terraform"
  })
}

module "vpc" {
  source       = "./module/vpc"
  cluster_name = local.cluster_name
  vpc_name     = "${local.name_prefix}-vpc"
  tags         = local.tags
}

module "eks" {
  source            = "./module/eks"
  cluster_name      = local.cluster_name
  high_availability = var.high_availability
  vpc_id            = module.vpc.vpc_id
  vpc_subnet_ids    = module.vpc.vpc_private_subnet_ids
  tags              = local.tags
  domains           = keys(var.domains)
}

module "acm" {
  source   = "./module/acm"
  for_each = var.domains

  tags                      = local.tags
  domain                    = each.key
  subject_alternative_names = each.value
}

module "service_resources" {
  source   = "./module/service_resources"
  for_each = var.services

  // globals
  tags                  = local.tags
  vpc_id                = module.vpc.vpc_id
  vpc_subnet_group_name = module.vpc.db_subnet_group_name
  db_security_group_id  = module.eks.cluster_security_group_id
  oidc_url              = module.eks.oidc_url
  oidc_arn              = module.eks.oidc_arn
  cluster_id            = module.eks.cluster_id

  // service specific
  service_name           = each.key
  enable_dynamodb_access = each.value.enable_dynamodb_access
  create_ecr_repo        = each.value.create_ecr_repo
  postgres_databases     = each.value.postgres_dbs
  mysql_databases        = each.value.mysql_dbs
  mariadb_databases      = each.value.mariadb_dbs
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}
