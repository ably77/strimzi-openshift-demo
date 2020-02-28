#!/bin/bash

# argo deployment varaiables
argo_namespace="argocd"
new_password="secret"
argo_version="1.4.2"
repo1_url="https://github.com/ably77/iot-argocd"
repo2_url="https://github.com/ably77/strimzi-loadtest"
repo3_url="https://github.com/ably77/strimzi-demo-prometheus"
repo4_url="https://github.com/ably77/strimzi-demo-grafana"
repo5_url="https://github.com/ably77/strimzi-demo-kafka"
repo6_url="https://github.com/ably77/strimzi-demo-codeready"
repo7_url="https://github.com/ably77/strimzi-demo-shared"
repo8_url="https://github.com/ably77/strimzi-demo-tekton"
repo9_url="https://github.com/ably77/strimzi-demo-voteapp-pipeline"
repo10_url="https://github.com/ably77/strimzi-demo-voteapp"

# Create a new namespace for ArgoCD components
oc new-project ${argo_namespace}

# Apply the ArgoCD Install Manifest
oc apply -f https://raw.githubusercontent.com/argoproj/argo-cd/v${argo_version}/manifests/install.yaml -n ${argo_namespace}
#oc create -f argocd/testing/operator-group.yaml
#oc create -f argocd/testing/subscription.yaml

# Create the argocd cluster
#oc create -f argocd/testing/cr.yaml

./extras/wait-for-condition.sh argocd-server ${argo_namespace}

# Get the ArgoCD Server password
argocd_server_password=$(oc -n ${argo_namespace} get pod -l "app.kubernetes.io/name=argocd-server" -o jsonpath='{.items[*].metadata.name}')

# patch ArgoCD Server so no TLS is configured on the server (--insecure)
patch='{"spec":{"template":{"spec":{"$setElementOrder/containers":[{"name":"argocd-server"}],"containers":[{"command":["argocd-server","--insecure","--staticassets","/shared/app"],"name":"argocd-server"}]}}}}'

oc -n ${argo_namespace} patch deployment argocd-server -p $patch

# Expose the ArgoCD Server using an Edge OpenShift Route so TLS is used for incoming connections
oc -n ${argo_namespace} create route edge argocd-server --service=argocd-server --port=http --insecure-policy=Redirect

# Get ArgoCD Server Route Hostname
argocd_route=$(oc -n ${argo_namespace} get route argocd-server -o jsonpath='{.spec.host}')

# wait for patch re-deployment
./extras/wait-for-condition.sh argocd-server ${argo_namespace}

# sleep for route creation
#echo sleeping for 30 seconds for route creation
sleep 30

# Login with the current admin password
argocd --insecure --grpc-web login ${argocd_route}:443 --username admin --password ${argocd_server_password}

# Update admin's password
argocd --insecure --grpc-web --server ${argocd_route}:443 account update-password --current-password ${argocd_server_password} --new-password ${new_password}

# Open route
#open http://${argocd_route}

# Add repo to be managed to argo repositories
argocd repo add ${repo1_url}
argocd repo add ${repo2_url}
argocd repo add ${repo3_url}
argocd repo add ${repo4_url}
argocd repo add ${repo5_url}
argocd repo add ${repo6_url}
argocd repo add ${repo7_url}
argocd repo add ${repo8_url}
argocd repo add ${repo9_url}
argocd repo add ${repo10_url}
