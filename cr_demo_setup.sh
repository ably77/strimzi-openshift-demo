#!/bin/bash

# Codeready Parameters
CODEREADY_DEVFILE_URL="https://raw.githubusercontent.com/ably77/strimzi-demo-codeready/master/dev-file/strimzi-demo-devfile.yaml"
CODEREADY_NAMESPACE="codeready"

#### Create Grafana CRDs
oc create -f grafana-operator/deploy/crds/

#### Create CodeReady CRDs
oc apply -f codeready/deploy/crds/org_v1_che_crd.yaml

### Deploy Strimzi CRDs
oc apply -f strimzi-operator/deploy/crds/strimzi-cluster-operator-0.15.0.yaml

### Check if argocd CLI is installed
ARGOCLI=$(which argocd)
echo checking if argocd CLI is installed
if [[ $ARGOCLI == "" ]]
then
        echo
        echo "argocd CLI not installed"
        echo "see https://github.com/argoproj/argo-cd/blob/master/docs/cli_installation.md for installation instructions"
        echo "re-run the script after argocd CLI is installed"
        echo
        exit 1
fi

echo now deploying argoCD

### deploy ArgoCD
./argocd/runme.sh

### Open argocd route
argocd_route=$(oc -n argocd get route argocd-server -o jsonpath='{.spec.host}')
open http://${argocd_route}

### create codeready namespace
oc new-project codeready

### deploy codeready in argocd
oc create -f argocd/apps/1/strimzi-demo-codeready.yaml

### deploy shared components in argocd
oc create -f argocd/apps/1/strimzi-demo-shared.yaml

### wait for codeready workspace to deploy
./extras/wait-for-rollout.sh deployment codeready ${CODEREADY_NAMESPACE}

### create/open codeready workspace from custom URL dev-file.yaml
echo deploying codeready workspace
CHE_HOST=$(oc get routes -n ${CODEREADY_NAMESPACE} | grep codeready-codeready | awk '{ print $2 }')
open http://${CHE_HOST}/f?url=${CODEREADY_DEVFILE_URL}

### codeready workspaces url
echo
echo setup complete
echo
echo codeready workspaces: create a new user to initiate workspace build
echo
echo if on linux, the open the link below in your browser to initiate workspace build
echo http://${CHE_HOST}/f?url=${CODEREADY_DEVFILE_URL}
echo
