apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: "${app_name}"
  namespace: argocd
spec:
  project: default
  source:
    repoURL: "${repo_url}"
    targetRevision: "${target_revision}"
    path: "${helm_chart_path}"
  destination:
    server: "https://kubernetes.default.svc"
    namespace: "${namespace}"
  syncPolicy:
    automated:
      prune: true
      selfHeal: true