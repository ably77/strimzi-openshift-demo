#!/bin/bash

NAMESPACE="myproject"

#### Create Grafana CRDs
oc create -f grafana-operator/deploy/crds

### Deploy Strimzi CRDs
oc apply -f strimzi-operator/deploy/crds/strimzi-cluster-operator-0.15.0.yaml

### Create the project namespace
echo creating project: ${NAMESPACE}
oc new-project ${NAMESPACE}

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
