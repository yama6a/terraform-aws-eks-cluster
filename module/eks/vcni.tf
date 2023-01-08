# This entire file exists only to increase the number of pods per node (t3.micro nodes only support 11 pods per node).
# This has something to do with the number of IP addresses per network interface, and number of interfaces.
# We fix this by assigning a CIDR block instead of an IP address to each interface (Prefix Delegation).
# Ref: https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
#
# This solution probably has a slight race condition: If the node-group gets created before we replace the vcni addon,
# the node-group will not be able to use the ENABLE_PREFIX_DELEGATION env-var. It seems to work fine though, but if it
# stops working, this is probably the reason.
# This workaround was found here: https://github.com/aws/eks-charts/issues/57#issuecomment-588983667
#
# This works now, but is kinda ugly, since we have to remove the vcni plugin and replace it.
# There seems to be a better solution, which can modify the ENV of the existing pre-installed vcni addon, which should
# mitigate (but not solve!) the above-mentioned race-condition, if it ever becomes a problem, try this:
# https://github.com/aws/eks-charts/tree/master/stable/aws-vpc-cni#adopting-the-existing-aws-node-resources-in-an-eks-cluster
resource "null_resource" "remove_aws_vpc_cni_plugin" {
  provisioner "local-exec" {
    command = format("%s/remove-aws-vpc-cni-plugin.sh", path.module)

    environment = {
      CLUSTER_ENDPOINT = data.aws_eks_cluster.cluster.endpoint
      CLUSTER_CA       = data.aws_eks_cluster.cluster.certificate_authority.0.data
      CLUSTER_TOKEN    = data.aws_eks_cluster_auth.cluster.token
    }
  }
}

resource "helm_release" "vcni" {
  repository = "https://aws.github.io/eks-charts"
  depends_on = [
    null_resource.remove_aws_vpc_cni_plugin
  ]

  name      = "aws-vpc-cni"
  chart     = "aws-vpc-cni"
  namespace = "kube-system"

  set {
    name  = "env.ENABLE_PREFIX_DELEGATION"
    value = true
  }
}
