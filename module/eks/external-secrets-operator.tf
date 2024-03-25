locals {
  values = {
    "replicaCount" : 2
    "leaderElect" : true
    "podLabels" : {
      "app" : "external-secrets"
    }
    "affinity" : {
      "podAntiAffinity" : {
        "requiredDuringSchedulingIgnoredDuringExecution" : [
          {
            "labelSelector" : {
              "matchExpressions" : [
                {
                  "key" : "app"
                  "operator" : "In"
                  "values" : [
                    "external-secrets"
                  ]
                }
              ]
            }
            "topologyKey" : "topology.kubernetes.io/zone"
          }
        ]
      }
    }
  }
}

module "external_secrets_helm" {
  source  = "registry.terraform.io/lablabs/eks-external-secrets/aws"
  version = "~> 1.0"
  depends_on = [time_sleep.wait_60_seconds_after_cluster_creation]

  enabled           = true
  argo_enabled      = false
  argo_helm_enabled = false

  // enables 2 pods on separate nodes for fault tolerance purposes.
  values = yamlencode(local.values)

  helm_timeout = 240
  helm_wait    = true
}
