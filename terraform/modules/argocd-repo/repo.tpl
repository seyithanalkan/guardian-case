apiVersion: v1
kind: Secret
metadata:
  name: "${repo_name}"
  namespace: "argocd"
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  url: "${repo_url}"
  insecure: "true"  # veya false