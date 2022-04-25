# TF EKS Module Docs: https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
#                And: https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/node_groups.tf
# EKS Worker Nodes vs. Control Plane: https://blog.gruntwork.io/comprehensive-guide-to-eks-worker-nodes-94e241092cbe
locals {
  cluster_name = "${local.project_name}-cluster"
}

module "eks" {
  source          = "registry.terraform.io/terraform-aws-modules/eks/aws"
  version         = "~> 18.0"
  cluster_name    = local.cluster_name
  cluster_version = "1.21"
  tags            = { env = "dev" }

  # networking
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = concat(module.vpc.private_subnets, module.vpc.public_subnets)
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


  # Options: https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/submodules/eks-managed-node-group
  #     And: https://eksctl.io/usage/eks-managed-nodes/
  eks_managed_node_group_defaults = {
    ami_type             = "AL2_x86_64"
    force_update_version = true
    labels               = { role = "worker" }
    invalid_stuff        = "foo"

    # disk size workaround: https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1739
    # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
    # so we need to disable it to use the default template provided by the AWS EKS managed node group service
    create_launch_template = false
    launch_template_name   = ""
    disk_size              = 10 # in GB
    root_volume_type       = "gp2"

    # ToDo: EBS encryption doesn't work, even when using this example: https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/eks_managed_node_group/main.tf#L233-L347
    # disk_encrypted  = true
    # disk_kms_key_id = aws_kms_key.ebs_storage_key.arn
  }

  eks_managed_node_groups = {
    "${local.project_name}-nodegroup-pri1" = {
      # networking
      subnet_ids             = module.vpc.private_subnets
      vpc_security_group_ids = [aws_security_group.node_group.id]

      # instance settings
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      # capacity config
      desired_size  = 3
      max_size      = 5
      min_size      = 3
      update_config = { max_unavailable = 1 }
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
