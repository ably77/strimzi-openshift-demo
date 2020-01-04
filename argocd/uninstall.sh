#!/bin/bash

# argo deployment varaiables
argo_namespace="argocd"
argo_route="argocd-server"
app_name="iot-demo"
argo_version="1.3.6"

# delete app
argocd app delete ${app_name}

oc delete -f https://raw.githubusercontent.com/argoproj/argo-cd/v${argo_version}/manifests/install.yaml -n ${argo_namespace}

oc delete routes ${argo_route} -n ${argo_namespace}
