#!/bin/bash

# DR Cluster Parameters
CONTEXT_NAME="dr"

# argo deployment varaiables
argo_namespace="argocd"
argo_route="argocd-server"
argo_version="1.4.2"

app1_name="iot-demo-dr"
app2_name="strimzi-loadtest-dr"
app3_name="strimzi-demo-prometheus-dr"
app4_name="strimzi-demo-grafana-dr"
app5_name="strimzi-demo-kafka-dr"
#app6_name="strimzi-demo-codeready-dr"
app7_name="strimzi-demo-shared-dr"

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
#argocd app delete ${app6_name} --cascade

# delete app7
argocd app delete ${app7_name} --cascade
