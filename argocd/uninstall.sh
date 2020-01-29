#!/bin/bash

# argo deployment varaiables
argo_namespace="argocd"
argo_route="argocd-server"
argo_version="1.3.6"

app1_name="iot-demo"
app2_name="strimzi-loadtest"
app3_name="strimzi-demo-prometheus"
app4_name="strimzi-demo-grafana"
app5_name="strimzi-demo-kafka"
app6_name="strimzi-demo-codeready"
app7_name="strimzi-demo-shared"
app8_name="strimzi-demo-klum"

# delete app1
argocd app delete ${app1_name} --cascade

# delete app2
argocd app delete ${app2_name} --cascade

# delete app3
argocd app delete ${app3_name} --cascade

# delete app4
argocd app delete ${app4_name} --cascade

# delete app5
argocd app delete ${app5_name} --cascade

# delete app6
argocd app delete ${app6_name} --cascade

# delete app7
argocd app delete ${app7_name} --cascade

# delete app8
argocd app delete ${app8_name} --cascade

# Wait for app deletion
./extras/wait-for-argo-app-deletion.sh

# delete argocd
oc delete -f https://raw.githubusercontent.com/argoproj/argo-cd/v${argo_version}/manifests/install.yaml -n ${argo_namespace}

# delete route
oc delete routes ${argo_route} -n ${argo_namespace}
