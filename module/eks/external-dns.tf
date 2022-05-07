module "external_dns" {
  count  = var.custom_domain != "" ? 1 : 0
  source = "registry.terraform.io/DNXLabs/eks-external-dns/aws"

  enabled = true

  cluster_name                     = data.aws_eks_cluster.cluster.id
  cluster_identity_oidc_issuer     = module.eks.oidc_provider
  cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn
  policy_allowed_zone_ids          = [data.aws_route53_zone.cloud_hosted_zone.zone_id]

  settings = {
    "policy"        = "sync" # Modify how DNS records are synchronized between sources and providers.
    "zoneIdFilters" = [data.aws_route53_zone.cloud_hosted_zone.zone_id]
  }
}

data "aws_route53_zone" "cloud_hosted_zone" {
  name = var.custom_domain
}

# Ref: External DNS https://kubernetes-sigs.github.io/aws-load-balancer-controller/v1.1/guide/external-dns/setup/
# Ref: with ALB ingress controller: https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/main/docs/examples/external-dns.yaml
# Ref: convert K8S to TF (download release, homebrew version is broken): https://github.com/sl1pm4t/k2tf
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

resource "kubernetes_service_account" "external_dns" {
  count = var.custom_domain != "" ? 1 : 0
  metadata {
    name = "external-dns"
  }
}

resource "kubernetes_cluster_role" "external_dns" {
  count = var.custom_domain != "" ? 1 : 0
  metadata {
    name = "external-dns"
  }

  rule {
    verbs      = ["get", "watch", "list"]
    api_groups = [""]
    resources  = ["services"]
  }

  rule {
    verbs      = ["get", "watch", "list"]
    api_groups = [""]
    resources  = ["pods"]
  }

  rule {
    verbs      = ["get", "watch", "list"]
    api_groups = ["extensions"]
    resources  = ["ingresses"]
  }

  rule {
    verbs      = ["list"]
    api_groups = [""]
    resources  = ["nodes"]
  }
}

resource "kubernetes_cluster_role_binding" "external_dns_viewer" {
  count = var.custom_domain != "" ? 1 : 0
  metadata {
    name = "external-dns-viewer"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "external-dns"
    namespace = "default"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "external-dns"
  }
}

resource "kubernetes_deployment" "external_dns" {
  count = var.custom_domain != "" ? 1 : 0
  metadata {
    name = "external-dns"
  }

  spec {
    selector {
      match_labels = {
        app = "external-dns"
      }
    }

    template {
      metadata {
        labels = {
          app = "external-dns"
        }
      }

      spec {
        container {
          name  = "external-dns"
          image = "bitnami/external-dns:0.7.4"
          args  = [
            #- --policy=upsert-only # would prevent ExternalDNS from deleting any records, omit to enable full synchronization
            "--source=service",
            "--source=ingress",
            "--provider=aws",
            "--aws-zone-type=public",
            "--registry=txt",
            "--txt-owner-id=my-identifier",
            "--domain-filter=${var.custom_domain}",
          ]
        }

        service_account_name = "external-dns"
      }
    }

    strategy {
      type = "Recreate"
    }
  }
}
