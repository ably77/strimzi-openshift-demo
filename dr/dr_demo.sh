#!/bin/bash

# DR Cluster Parameters
CONTEXT_NAME="dr"

# Don't change unless you change argocd/<app>.yaml namespace pointers
KAFKA_NAMESPACE="myproject"
GRAFANA_NAMESPACE="myproject"

#### Create Grafana CRDs
oc create -f grafana-operator/deploy/crds --context=${CONTEXT_NAME}

#### Create CodeReady CRDs
#oc apply -f codeready/deploy/crds/org_v1_che_crd.yaml

### Deploy Strimzi CRDs
oc apply -f strimzi-operator/deploy/crds/strimzi-cluster-operator-0.15.0.yaml --context=${CONTEXT_NAME}

### Add dr context to argocd
argocd cluster add ${CONTEXT_NAME}

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

### deploy kafka in argocd
echo deploying prometheus
oc create -f dr/strimzi-demo-kafka-dr.yaml

### deploy grafana in argocd
echo deploying grafana
oc create -f dr/strimzi-demo-grafana-dr.yaml

### deploy prometheus in argocd
echo deploying prometheus
oc create -f dr/strimzi-demo-prometheus-dr.yaml

### deploy codeready in argocd
#oc create -f dr/strimzi-demo-codeready-dr.yaml

### deploy shared components in argocd
oc create -f dr/strimzi-demo-shared-dr.yaml

### check kafka deployment status
echo waiting for kafka deployment to complete
./extras/wait-for-condition-context.sh my-cluster-kafka-2 ${KAFKA_NAMESPACE} ${CONTEXT_NAME}

### check grafana deployment status
echo checking grafana deployment status before deploying applications
./extras/wait-for-condition-context.sh grafana-deployment ${GRAFANA_NAMESPACE} ${CONTEXT_NAME}

### deploy IoT demo application in argocd
echo creating iot-demo app in argocd
oc create -f dr/iot-demo-dr.yaml

### deploy strimzi loadtesting demo in argocd
echo creating strimzi-loadtest demo in argocd
oc create -f dr/strimzi-loadtest-dr.yaml

### open grafana route
echo opening grafana route
grafana_route=$(oc get routes -n ${GRAFANA_NAMESPACE} --context ${CONTEXT_NAME} | grep grafana-route | awk '{ print $2 }')
open https://${grafana_route}

### Wait for IoT Demo
./extras/wait-for-condition-context.sh consumer-app myproject ${CONTEXT_NAME}

### open IoT demo app route
echo opening consumer-app route
iot_route=$(oc get routes -n ${KAFKA_NAMESPACE} --context ${CONTEXT_NAME} | grep consumer-app-myproject.apps.ly-demo-dr | awk '{ print $2 }')
open http://${iot_route}

### end
echo
echo installation complete
echo
echo
echo links to console routes:
echo
echo iot demo-dr console:
echo http://${iot_route}
echo
echo grafana-dr dashboards:
echo https://${grafana_route}
echo
