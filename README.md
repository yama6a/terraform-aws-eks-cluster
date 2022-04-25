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
