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
  oidc         = tomap({
    url = module.eks.oidc_provider
    arn = module.eks.oidc_provider_arn
  })
  tags = var.tags
  helm = {
    vars =  {
      clusterName = module.eks.cluster_id
    }
  }
}
