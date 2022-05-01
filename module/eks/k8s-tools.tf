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

# metrics server
data "kubectl_path_documents" "metrics-server-manifests" { pattern = "${path.module}/k8s/metrics-server.yaml" }
resource "kubectl_manifest" "metrics-server" {
  count     = length(data.kubectl_path_documents.metrics-server-manifests.documents)
  yaml_body = element(data.kubectl_path_documents.metrics-server-manifests.documents, count.index)
}

# k8s dashboard admin access (probably insecure? TODO: validate that this is safe!)
data "kubectl_path_documents" "dashboard-rbac-manifests" { pattern = "${path.module}/k8s/dashboard-rbac.yaml" }
resource "kubectl_manifest" "dashboard-admin-rbac" {
  count     = length(data.kubectl_path_documents.dashboard-rbac-manifests.documents)
  yaml_body = element(data.kubectl_path_documents.dashboard-rbac-manifests.documents, count.index)
}

data "kubectl_path_documents" "dashboard-manifests" { pattern = "${path.module}/k8s/dashboard.yaml" }
resource "kubectl_manifest" "dashboard" {
  # todo: Ensure namespace exists before running this,
  #       becuase this manifest runs all parts in parallel and the namespace might not exist yet when needed.
  #       Current workaround: re-run `tf apply`
  count     = length(data.kubectl_path_documents.dashboard-manifests.documents)
  yaml_body = element(data.kubectl_path_documents.dashboard-manifests.documents, count.index)
}
