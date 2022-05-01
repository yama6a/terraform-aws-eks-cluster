resource "aws_kms_key" "eks_secrets_key" {
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  description              = "Key for EKS Cluster Secrets Encryption"
  enable_key_rotation      = true
}

module "eks" {
  source          = "registry.terraform.io/terraform-aws-modules/eks/aws"
  version         = "~> 18.0"
  cluster_version = "1.21"
  cluster_name    = var.cluster_name
  tags            = var.tags

  # networking
  vpc_id                          = var.vpc_id
  subnet_ids                      = var.vpc_subnet_ids
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  # eks cluster settings
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cluster_addons            = {
    coredns    = { resolve_conflicts = "OVERWRITE" }
    kube-proxy = {}
    vpc-cni    = { resolve_conflicts = "OVERWRITE" }
  }
  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.eks_secrets_key.arn
      resources        = ["secrets"]
    }
  ]


  eks_managed_node_group_defaults = {
    ami_type             = "AL2_x86_64"
    force_update_version = true
    labels               = { role = "worker" }

    # disk size workaround: https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1739
    create_launch_template = false
    launch_template_name   = ""
    disk_size              = var.high_availability == true ? 20 : 10 # in GB
  }

  eks_managed_node_groups = {
    "${var.cluster_name}-ng1" = {
      subnet_ids = var.vpc_subnet_ids

      # instance settings
      # Keep number of network interfaces in mind! EC2 instances have a limit depending on instance-type.
      # Our cluster consumes 8 pods by default (per node?).
      # Number of pods per instance-type: https://github.com/awslabs/amazon-eks-ami/blob/master/files/eni-max-pods.txt
      instance_types = var.high_availability == true ? ["m5.large"] : ["t3.medium"]
      desired_size   = var.high_availability == true ? 3 : 1
      min_size       = var.high_availability == true ? 3 : 1
      max_size       = var.high_availability == true ? 5 : 1
      update_config  = { max_unavailable = 1 }
    }
  }
}
