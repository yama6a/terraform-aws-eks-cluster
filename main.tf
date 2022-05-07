provider "aws" {
  region = var.aws_region
}

locals {
  name_prefix  = "${var.project_name}-${var.env}"
  cluster_name = "${local.name_prefix}-cl"
  tags         = merge(var.tags, {
    env       = var.env
    project   = var.project_name
    managedBy = "terraform"
  })
}

module vpc {
  source       = "./module/vpc"
  cluster_name = local.cluster_name
  vpc_name     = "${local.name_prefix}-vpc"
  tags         = local.tags
}

module eks {
  source            = "./module/eks"
  cluster_name      = local.cluster_name
  high_availability = var.high_availability
  vpc_id            = module.vpc.vpc_id
  vpc_subnet_ids    = module.vpc.vpc_private_subnet_ids
  tags              = local.tags
  custom_domain     = var.custom_domain
}
