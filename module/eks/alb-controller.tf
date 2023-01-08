module "lb-controller" {
  source = "registry.terraform.io/Young-ook/eks/aws//modules/lb-controller"
  tags   = var.tags

  oidc = tomap({
    url = module.eks.oidc_provider
    arn = module.eks.oidc_provider_arn
  })

  helm = {
    vars = {
      clusterName = module.eks.cluster_id
    }
  }
}
