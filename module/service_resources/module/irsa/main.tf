locals {
  sa_name = "${var.service_name}-sa"
}

resource "kubernetes_namespace" "ns" {
  metadata {
    name = "${var.service_name}-ns"
  }
}

resource "kubernetes_service_account" "sa" {
  metadata {
    name      = local.sa_name
    namespace = kubernetes_namespace.ns.metadata.0.name
    annotations = {
      "eks.amazonaws.com/role-arn" = module.irsa.arn
    }
  }
}

module "irsa" {
  source  = "registry.terraform.io/Young-ook/eks/aws//modules/iam-role-for-serviceaccount"
  version = "1.7.11"

  name           = "${var.service_name}-irsa"
  tags           = var.tags
  namespace      = kubernetes_namespace.ns.metadata[0].name
  serviceaccount = local.sa_name
  oidc_url       = var.oidc_url
  oidc_arn       = var.oidc_arn
  policy_arns    = var.policy_arns
}
