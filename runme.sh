#!/bin/bash

# Codeready Parameters
CODEREADY_DEVFILE_URL="https://raw.githubusercontent.com/ably77/strimzi-demo-codeready/master/dev-file/strimzi-demo-devfile.yaml"
CODEREADY_NAMESPACE="codeready"

# Don't change unless you change argocd/<app>.yaml namespace pointers
KAFKA_NAMESPACE="myproject"
GRAFANA_NAMESPACE="myproject"

#### Create Grafana CRDs
oc create -f grafana-operator/deploy/crds

#### Create CodeReady CRDs
oc apply -f codeready/deploy/crds/org_v1_che_crd.yaml

### Deploy Strimzi CRDs
oc apply -f strimzi-operator/deploy/crds/strimzi-cluster-operator-0.15.0.yaml

### Deploy Tekton CRDs
oc apply -f tekton/crd.yaml

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

echo sleeping 10 seconds before deploying argo apps
sleep 10

### create main argocd project
oc create -f argocd/main-project.yaml

### deploy apps in argocd
echo deploying prometheus, kafka, grafana, and codeready applications in argocd
oc create -f argocd/apps/1/

### check kafka deployment status
echo waiting for kafka deployment to complete
./extras/wait-for-condition.sh my-cluster-kafka-2 ${KAFKA_NAMESPACE}

### check grafana deployment status
echo checking grafana deployment status before deploying applications
./extras/wait-for-condition.sh grafana-deployment ${GRAFANA_NAMESPACE}

### deploy IoT demo and strimzi-loadtest application in argocd
echo creating iot-demo and strimzi-loadtest apps in argocd
oc create -f argocd/apps/2/

### open grafana route
echo opening grafana route
grafana_route=$(oc get routes -n ${GRAFANA_NAMESPACE} | grep grafana-route | awk '{ print $2 }')
open https://${grafana_route}

### Wait for IoT Demo
./extras/wait-for-condition.sh consumer-app myproject

### open IoT demo app route
echo opening consumer-app route
# fix this static address
iot_route=$(oc get routes -n ${KAFKA_NAMESPACE} | grep consumer-app-myproject.apps.ly-demo.openshiftaws.com | awk '{ print $2 }')
open http://${iot_route}

### switch to codeready namespace
oc project codeready

### wait for codeready workspace to deploy
./extras/wait-for-rollout.sh deployment codeready codeready

### create/open codeready workspace from custom URL dev-file.yaml
echo deploying codeready workspace
CHE_HOST=$(oc get routes -n ${CODEREADY_NAMESPACE} | grep codeready-codeready | awk '{ print $2 }')
open http://${CHE_HOST}/f?url=${CODEREADY_DEVFILE_URL}

### end
echo
echo installation complete
echo
echo
echo links to console routes:
echo
echo iot demo console:
echo http://${iot_route}
echo
echo grafana dashboards:
echo https://${grafana_route}
echo
echo argocd console:
echo argocd login: admin/secret
echo http://${argocd_route}
echo
echo codeready workspaces: create a new user to initiate workspace build
echo http://${CHE_HOST}/f?url=${CODEREADY_DEVFILE_URL}
echo
