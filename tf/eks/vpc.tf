data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "registry.terraform.io/terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name                 = "${local.project_name}-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
  public_subnets       = ["10.0.48.0/20", "10.0.64.0/20", "10.0.80.0/20"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "owned" // only one cluster can use this vpc
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "owned" // only one cluster can use this subnet
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "owned" // only one cluster can use this subnet
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
