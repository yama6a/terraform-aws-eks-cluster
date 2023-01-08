## Setup

1. run `terraform apply`
2. Configure k8s context:
    - `aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)`
3. (optional) Install Metrics server (required for CPU/Mem based HPAs):
    - `kubectl apply -f k8s/metrics-server.yaml`

### K8S Dashboard (optional)

- install dashboard `kubectl apply -f k8s/dashboard`
- generate auth token for
  dashboard: `kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user-token | awk '{print $1}') | grep token: | sed 's/token:.* ey/ey/'`
- proxy to dashboard: `kubectl proxy`
- Login to
  Dashboard: http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
- and paste auth-token from above.

### Example App with ALB-Ingress

1. Run `kubectl apply -f k8s/sample-app.yaml` to deploy the app
2. Run `kubectl get ingress/ingress-2048 -n game-2048` to ensure the ALB got created and the ingress has an **ADDRESS**
3. Wait about a minute or two for the Load-Balancer to fire up.
4. Copy/paste the **ADDRESS** from the output into your browser (http, not https) - and done.

## Wiping The Cluster

### Delete ALB resources

Delete all ingresses that use the ALB controller

- `kubectl delete ingress --all -n <namespace>`
- or delete them by referencing your manitests: `kubectl delete -f ./path/to/manifests`
- and then WAIT about 2 minutes for the ALB to delete all attached resources, such as security groups, listeners, etc

If you don't do this (including waiting), the remainders that were created by the ALB-controller
(`./module/eks/alb-controller.tf`) will prevent the VPC and service-namespaces from being destroyed. If you messed it
up, you have to manually delete the following resources (check region) and re-run `terraform destroy`:

- EC2 Target
  Groups: [https://console.aws.amazon.com/ec2/v2/home?#TargetGroups:tag:elbv2.k8s.aws/cluster=*](https://console.aws.amazon.com/ec2/v2/home?#TargetGroups:tag:elbv2.k8s.aws/cluster=*)
- EC2 Load
  Balancers: [https://console.aws.amazon.com/ec2/v2/home?#LoadBalancers:tag:elbv2.k8s.aws/cluster=*](https://console.aws.amazon.com/ec2/v2/home?#LoadBalancers:tag:elbv2.k8s.aws/cluster=*)
- VPC Security
  Groups: [https://console.aws.amazon.com/vpc/home?#securityGroups:tag:ingress.k8s.aws/resource=ManagedLBSecurityGroup](https://console.aws.amazon.com/vpc/home?#securityGroups:tag:ingress.k8s.aws/resource=ManagedLBSecurityGroup)

If the terraform-destroy action gets stuck upon deleting a k8s namespace, wipe them by hand by doing the following:

```sh
(
NAMESPACE=my-awesome-service-ns
kubectl proxy &
kubectl get namespace $NAMESPACE -o json |jq '.spec = {"finalizers":[]}' >temp.json
curl -k -H "Content-Type: application/json" -X PUT --data-binary @temp.json 127.0.0.1:8001/api/v1/namespaces/$NAMESPACE/finalize
rm temp.json
)
```

### Delete ECR references

Terraform will attempt and fail to delete the ECR repos that are referenced by active k8s manifests (deployments, pods).
To make sure it doesn't get stuck deleting anything, make sure to first delete all deployments and pods that reference
the ECR repos.

- `kubectl delete deployment --all -n <namespace>`
- `kubectl delete pod --all -n <namespace>`
- or delete them by referencing your manitests: `kubectl delete -f ./path/to/manifests`
- and then WAIT ~1 minute for the control plane to wipe all pods and deployments that reference images in the ECR repos.

If it still fails destroying the ECR repo, you might have to manually delete all images in the ECR repo first. This
shouldn't be an issue, because we set the repo ro force_delete, but it has happened in the past, so be warned.

### NOW Delete all AWS resources

- `terraform destroy [-var-file=my_env.tfvars]`
- confirm the prompt with "yes"

## Replacing SSL Certificates

When you add or remove subject-alternative-names to/from your SSL certificate, you need to replace the existing
certificate with a new one. The new one gets automatically created, but terraform will get stuck after the creation,
while trying to delete the old one. This is, because the old one is still pegged to the ALB, which needs to be replaced
by hand!

- go to the EC2 Load Balancer page
- if the certificate that is to be deleted is the default one, swap it for the new one
- if the certificate that is to be deleted is in the SNI list, add the new one to the list, then delete the old one.

You should fix the ALB config WHILE terraform is trying to delete the old certificate. If you do so, terraform fixes the
rest for you. If you don't manage to do so in time, you can just re-run `terraform apply` after you removed the old
certificate from the ALB.

If you want to save yourself the trouble, just use wildcard names in your subject-alternative-name field
(see example in variables.tf).

Adding new domains (rather than adding aubject-alt-names to existing ones) doesn't result in this problem, because each
domain receives its own certificate from ACM.
