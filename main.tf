provider "aws" {
  region = var.region
}

locals {
  cluster_name = "dev-cl"
}

module vpc {
  source       = "./module/vpc"
  cluster_name = local.cluster_name
  vpc_name     = "dev-vpc"
}

module eks {
  source            = "./module/eks"
  cluster_name      = local.cluster_name
  high_availability = false
  vpc               = {
    foo        = "123"
    id         = module.vpc.vpc_id
    subnet_ids = module.vpc.vpc_private_subnet_ids
  }
  tags = {
    env = "dev"
  }
}
