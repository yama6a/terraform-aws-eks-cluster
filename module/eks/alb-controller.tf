module "lb-controller" {
  source  = "registry.terraform.io/Young-ook/eks/aws//modules/lb-controller"
  version = "1.7.11"

  tags = var.tags

  oidc = tomap({
    url = module.eks.oidc_provider
    arn = module.eks.oidc_provider_arn
  })

  helm = {
    vars = {
      clusterName = module.eks.cluster_name
    }
  }
}
