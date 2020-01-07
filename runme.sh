#!/bin/bash

NAMESPACE="myproject"

# Modules
ARGOCD_ENABLED="true"

### Create the project namespace
oc new-project ${NAMESPACE}

### Deploy Strimzi Operator
oc apply -f https://github.com/strimzi/strimzi-kafka-operator/releases/download/0.15.0/strimzi-cluster-operator-0.15.0.yaml -n ${NAMESPACE}

### Provision the Apache Kafka Cluster
oc create -f strimzi-operator/deploy/crs/deployments/kafka-cluster-3broker-ephemeral.yaml -n ${NAMESPACE}

### Create Kafka Topics
oc create -f strimzi-operator/deploy/crs/topics/ -n ${NAMESPACE}

#### Create Grafana CRDs
oc create -f grafana-operator/deploy/crds -n ${NAMESPACE}


#### If ArgoCD Demo is Enabled ####
if [ "$ARGOCD_ENABLED" = "true" ]; then

### deploy ArgoCD
./argocd/runme.sh

### SUPER HACKY BUG FIX (BUT WORKS) - uninstall and reinstall
./argocd/uninstall.sh
./argocd/runme.sh

### deploy prometheus in argocd
oc create -f argocd/strimzi-demo-prometheus.yaml

### deploy grafana in argocd
oc create -f argocd/strimzi-demo-grafana.yaml

### check kafka deployment status
echo
echo waiting for kafka deployment to complete
./extras/wait-for-condition.sh my-cluster-kafka-2 ${NAMESPACE}

### deploy IoT demo application in argocd
oc create -f argocd/iot-demo.yaml

### deploy strimzi loadtesting demo in argocd
oc create -f argocd/strimzi-loadtest.yaml

### Open argocd route
argocd_route=$(oc -n argocd get route argocd-server -o jsonpath='{.spec.host}')
open http://${argocd_route}

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

### check kafka deployment status
echo
echo waiting for kafka deployment to complete
./extras/wait-for-condition.sh my-cluster-kafka-2 myproject

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


### Wait for IoT Demo
./extras/wait-for-condition.sh consumer-app myproject

### open IoT demo app route
echo
echo opening consumer-app route
open http://$(oc get routes -n ${NAMESPACE} | grep consumer-app | awk '{ print $2 }')

### check grafana deployment status
./extras/wait-for-condition.sh grafana-deployment ${NAMESPACE}

### open grafana route
echo
echo opening grafana route
open https://$(oc get routes -n ${NAMESPACE} | grep grafana-route | awk '{ print $2 }')

### end
echo
echo installation complete
