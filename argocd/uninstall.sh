#!/bin/bash

# argo deployment varaiables
argo_namespace="argocd"
argo_route="argocd-server"
argo_version="1.3.6"

app1_name="iot-demo"
app2_name="strimzi-loadtest"

# delete app1
argocd app delete ${app1_name} --cascade

# delete app2
argocd app delete ${app2_name} --cascade 

oc delete -f https://raw.githubusercontent.com/argoproj/argo-cd/v${argo_version}/manifests/install.yaml -n ${argo_namespace}

oc delete routes ${argo_route} -n ${argo_namespace}
