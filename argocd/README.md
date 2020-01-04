# ArgoCD Demo

### Prerequisites
- Openshift Cluster
- User with cluster-admin privileges

### Adding a new project to ArgoCD
Add github repo
```
argocd repo add ${repo_url}
```

Create project in ArgoCD
```
./extras/create-app.sh ${argo_project} ${app_name} ${repo_url} ${app_namespace} ${sync_policy}
```

Dry run
```
argocd app sync ${app_name} --dry-run
```

Deploy
```
argocd app sync ${app_name}
```

### Extras
Setup sync policy and prune
```
argocd app set ${app_name} --sync-policy automated --auto-prune
```

### Uninstall
To uninstall this demo
```
./uninstall.sh
```
