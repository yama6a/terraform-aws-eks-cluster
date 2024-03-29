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

module "eventbridge" {
  source = "./module/eventbridge"

  tags         = local.tags
  project_name = var.project_name
  aws_region   = var.aws_region
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
