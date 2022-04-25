- change tf/globals.tf to your preferred settings
- Configure
  kubectl `aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)`
- (optional) rename
  context: `kubectl config rename-context $(terraform output -raw cluster_arn) $(terraform output -raw project_name)-dev`
    - replace the last argument with your preferred context name
- Install metrics server: `kubectl apply -f metrics-server-0.3.6/deploy-1.8+`
- Install K8S Dashboard: `kubectl apply -f k8s/k8s-dashboard/`
    - generate auth token for
      dashboard: `kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user-token | awk '{print $1}')`
    - proxy to dashboard: `kubectl proxy`
    - Login to
      Dashboard: http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
        - and paste auth-token from above.

# LB Controller

1. create IAM
   policy: `aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json`
2. attach role and policy to service account
   ```
   eksctl create iamserviceaccount \
   --cluster=my-cluster \
   --namespace=kube-system \
   --name=aws-load-balancer-controller \
   --role-name "AmazonEKSLoadBalancerControllerRole" \
   --attach-policy-arn=arn:aws:iam::111122223333:policy/AWSLoadBalancerControllerIAMPolicy \
   --approve
   --override-existing-serviceaccounts
   ```
3. annotate service acount
   `kubectl annotate serviceaccount -n kube-system aws-load-balancer-controller eks.amazonaws.com/sts-regional-endpoints=true`
4. Install cert-manager to inject certificate configuration into the
   webhooks. `kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.yaml`
5. (Fix for broken AWS
   guide): `kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"`
6. replacements:
    1. `sed -i.bak -e "s|my-cluster-name|$(terraform output -raw cluster_name)|" ./alb-controller-v2.4.1-full.yaml`
    2. `sed -i.bak -e "s|my-vpc-id|$(terraform output -raw vpc_id)|" ./alb-controller-v2.4.1-full.yaml`
    2. `sed -i.bak -e "s|my-region|$(terraform output -raw region)|" ./alb-controller-v2.4.1-full.yaml`
7. Run `kubectl apply -f alb-controller-v2.4.1-full.yaml`
