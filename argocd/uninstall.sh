#!/bin/bash

# argo deployment varaiables
argo_namespace="argocd"
argo_version="1.4.2"

# delete argo apps
oc delete -f argocd/apps/2/
oc delete -f argocd/apps/1/
oc delete -f argocd/apps/testing/

# Wait for app deletion
./extras/wait-for-argo-app-deletion.sh

# delete argocd
oc delete -f https://raw.githubusercontent.com/argoproj/argo-cd/v${argo_version}/manifests/install.yaml -n ${argo_namespace}
#oc delete -f argocd/testing/cr.yaml
#oc delete -f argocd/testing/subscription.yaml
#oc delete -f argocd/testing/operator-group.yaml

# delete route
oc delete routes argocd-server -n ${argo_namespace}
