resource "aws_kms_key" "eks_secrets_key" {
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  description              = "Key for EKS Cluster Secrets Encryption"
  enable_key_rotation      = true
}

module "eks" {
  source          = "registry.terraform.io/terraform-aws-modules/eks/aws"
  version         = "~> 18.0"
  cluster_name    = var.cluster_name
  cluster_version = "1.21"
  tags            = var.tags

  # networking
  vpc_id                          = var.vpc.id
  subnet_ids                      = var.vpc.subnet_ids
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
    "${var.cluster_name}-ng-workers" = {
      # networking
      subnet_ids = var.vpc.subnet_ids
      #      vpc_security_group_ids = [aws_security_group.node_group.id] // todo: remove

      # instance settings
      instance_types = var.high_availability == true ? ["m5.large"] : ["t3.small"]
      desired_size   = 1
      max_size       = var.high_availability == true ? 5 : 1
      min_size       = var.high_availability == true ? 3 : 1
      update_config  = { max_unavailable = 1 }
    }
  }
}


### ALB Controller
data "aws_eks_cluster" "cluster" { name = module.eks.cluster_id }
data "aws_eks_cluster_auth" "cluster" { name = module.eks.cluster_id }

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  }
}

module "lb-controller" {
  source       = "registry.terraform.io/Young-ook/eks/aws//modules/lb-controller"
  cluster_name = var.cluster_name
  oidc         = tomap({
    url = module.eks.oidc_provider
    arn = module.eks.oidc_provider_arn
  })
  tags = var.tags
}


### Default K8S Tools
terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
  }
}
provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}
data "kubectl_path_documents" "metrics-server-manifests" { pattern = "${path.module}/k8s/metrics-server.yaml" }
resource "kubectl_manifest" "metrics-server" {
  count     = length(data.kubectl_path_documents.metrics-server-manifests.documents)
  yaml_body = element(data.kubectl_path_documents.metrics-server-manifests.documents, count.index)
}

// todo: test dashboard access, then remove _delete_me folder
data "kubectl_path_documents" "dashboard-manifests" { pattern = "${path.module}/k8s/dashboard.yaml" }
resource "kubectl_manifest" "dashboard-admin-rbac" { yaml_body = file("${path.module}/k8s/dashboard-admin.rbac.yaml") }
resource "kubectl_manifest" "dashboard" {
  count     = length(data.kubectl_path_documents.dashboard-manifests.documents)
  yaml_body = element(data.kubectl_path_documents.dashboard-manifests.documents, count.index)
}

// todo: make optional via variable
data "kubectl_path_documents" "sample-app-manifests" { pattern = "${path.module}/k8s/sample-app.yaml" }
resource "kubectl_manifest" "sample-app" {
  count     = length(data.kubectl_path_documents.sample-app-manifests.documents)
  yaml_body = element(data.kubectl_path_documents.sample-app-manifests.documents, count.index)
}
