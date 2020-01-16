#!/bin/bash

NAMESPACE="myproject"

# Modules
ARGOCD_ENABLED="true"

CODEREADY_DEVFILE_URL="https://raw.githubusercontent.com/ably77/strimzi-demo-codeready/master/dev-file/strimzi-demo-devfile.yaml"
CODEREADY_NAMESPACE="codeready"

### Create the project namespace
echo creating project: ${NAMESPACE}
oc new-project ${NAMESPACE}

#### Create Grafana CRDs
oc create -f grafana-operator/deploy/crds

#### Create CodeReady CRDs
oc apply -f codeready/deploy/crds/org_v1_che_crd.yaml

### Deploy Strimzi Operator
oc apply -f https://github.com/strimzi/strimzi-kafka-operator/releases/download/0.15.0/strimzi-cluster-operator-0.15.0.yaml -n ${NAMESPACE}


#### If ArgoCD Demo is Enabled ####

if [ "$ARGOCD_ENABLED" = "true" ]; then

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

### use project argocd
oc project argocd

### deploy ArgoCD
./argocd/runme.sh

### Open argocd route
argocd_route=$(oc -n argocd get route argocd-server -o jsonpath='{.spec.host}')
open http://${argocd_route}

echo sleeping 10 seconds before deploying argo apps
sleep 10

### deploy grafana in argocd
echo deploying grafana
oc create -f argocd/strimzi-demo-grafana.yaml

### deploy prometheus in argocd
echo deploying prometheus
oc create -f argocd/strimzi-demo-prometheus.yaml

### deploy codeready in argocd
oc create -f argocd/strimzi-demo-codeready.yaml

### deploy kafka in argocd
echo deploying prometheus
oc create -f argocd/strimzi-demo-kafka.yaml

### check kafka deployment status
echo waiting for kafka deployment to complete
./extras/wait-for-condition.sh my-cluster-kafka-2 ${NAMESPACE}

### check grafana deployment status
echo checking grafana deployment status before deploying applications
./extras/wait-for-condition.sh grafana-deployment ${NAMESPACE}

### deploy IoT demo application in argocd
echo creating iot-demo app in argocd
oc create -f argocd/iot-demo.yaml

### deploy strimzi loadtesting demo in argocd
echo creating strimzi-loadtest demo in argocd
oc create -f argocd/strimzi-loadtest.yaml

fi


#### If ArgoCD Demo is Disabled ####
if [ "$ARGOCD_ENABLED" = "false" ]; then

### deploy grafana operator
echo
echo now deploying grafana operator

### setup role permissions
oc create -f grafana-operator/deploy/roles -n ${NAMESPACE}

### deploy grafana operator
oc create -f grafana-operator/deploy/operator.yaml -n ${NAMESPACE}

### deploy grafana datasource
oc create -f grafana-operator/deploy/crs/datasources/Prometheus.yaml -n ${NAMESPACE}

### deploy grafana
oc create -f grafana-operator/deploy/crs/deployment/grafana-cr.yaml -n ${NAMESPACE}

### deploy dashboards
oc create -f grafana-operator/deploy/crs/dashboards/ -n ${NAMESPACE}

#### Deploy Kafka ####
echo deploying kafka

### Deploy Strimzi Operator
oc apply -f https://github.com/strimzi/strimzi-kafka-operator/releases/download/0.15.0/strimzi-cluster-operator-0.15.0.yaml -n ${NAMESPACE}

### Provision the Apache Kafka Cluster
oc create -f strimzi-operator/deploy/crs/deployments/kafka-cluster-3broker-pv.yaml -n ${NAMESPACE}

### Create Kafka Topics
oc create -f strimzi-operator/deploy/crs/topics/ -n ${NAMESPACE}

### check kafka deployment status
echo waiting for kafka deployment to complete
./extras/wait-for-condition.sh my-cluster-kafka-2 ${NAMESPACE}

oc create -f extras/manual_deploy/iot-demo/consumer-app/resources/consumer-app.yml -n ${NAMESPACE}
oc create -f extras/manual_deploy/iot-demo/device-app/resources/device-app.yml -n ${NAMESPACE}
oc create -f extras/manual_deploy/iot-demo/stream-app/resources/stream-app.yml -n ${NAMESPACE}
oc create -f extras/manual_deploy/iot-demo/stream-app/resources/topics.yml -n ${NAMESPACE}

### make jobs/generated if it doesnt exist
mkdir extras/manual_deploy/jobs/generated

### setup kafka jobs with correct NodeIP service addresses
./extras/manual_deploy/jobs/setup_cron.sh
./extras/manual_deploy/jobs/setup_jobs.sh

### deploy kafka jobs
oc create -f extras/manual_deploy/jobs/generated/ -n ${NAMESPACE}

fi


### open grafana route
echo opening grafana route
grafana_route=$(oc get routes -n ${NAMESPACE} | grep grafana-route | awk '{ print $2 }')
open https://${grafana_route}

### Wait for IoT Demo
./extras/wait-for-condition.sh consumer-app myproject

### open IoT demo app route
echo opening consumer-app route
iot_route=$(oc get routes -n ${NAMESPACE} | grep consumer-app | awk '{ print $2 }')
open http://${iot_route}

#fix this
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
