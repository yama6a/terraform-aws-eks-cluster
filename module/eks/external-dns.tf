# If you want to configure it yourself (instead of using the module below), look at the following resources.
# CAUTION: This assumes that you have another way to set up IAM policies and such.
# Ref: External DNS https://kubernetes-sigs.github.io/aws-load-balancer-controller/v1.1/guide/external-dns/setup/
# Ref: with ALB ingress controller: https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/main/docs/examples/external-dns.yaml
# Ref: convert K8S to TF (download release, homebrew version is broken): https://github.com/sl1pm4t/k2tf

module "external_dns" {
  count   = (length(var.domains) > 0) ? 1 : 0
  depends_on = [time_sleep.wait_60_seconds_after_cluster_creation]
  source  = "registry.terraform.io/lablabs/eks-external-dns/aws"
  version = "~> 1.0"

  enabled = true

  cluster_identity_oidc_issuer     = module.eks.oidc_provider
  cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn
  policy_allowed_zone_ids          = [for s in data.aws_route53_zone.cloud_hosted_zone : s.zone_id]

  settings = {
    "policy" = "sync" # Modify how DNS records are synchronized between sources and providers.
  }
}

data "aws_route53_zone" "cloud_hosted_zone" {
  for_each = var.domains

  name = each.key
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = module.eks.cluster_certificate_authority_data
}

resource time_sleep "wait_60_seconds_after_cluster_creation" {
  depends_on = [module.eks]

  create_duration = "60s"
}