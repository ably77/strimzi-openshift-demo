#!/bin/bash

NAMESPACE=myproject

### Create the project namespace
oc new-project ${NAMESPACE}

### Apply Strimzi Installation File
oc apply -f https://github.com/strimzi/strimzi-kafka-operator/releases/download/0.15.0/strimzi-cluster-operator-0.15.0.yaml -n ${NAMESPACE}

### Provision the Apache Kafka Cluster
oc create -f strimzi-operator/deploy/crs/deployments/kafka-cluster-3broker-pv.yaml -n ${NAMESPACE}

### Create Kafka Topics
oc create -f strimzi-operator/deploy/crs/topics/ -n ${NAMESPACE}

### Start up your Prometheus server
oc create -f prometheus/alerting-rules.yaml -n ${NAMESPACE}
oc create -f prometheus/prometheus.yaml -n ${NAMESPACE}

### deploy grafana operator
echo
echo now deploying grafana operator

### deploy crds
oc create -f grafana-operator/deploy/crds -n ${NAMESPACE}

### setup role permissions
oc create -f grafana-operator/deploy/roles -n ${NAMESPACE}

### deploy grafana operator
oc create -f grafana-operator/deploy/operator.yaml -n ${NAMESPACE}

### deploy grafana datasource
oc create -f grafana-operator/deploy/crs/datasources/Prometheus.yaml -n ${NAMESPACE}

### deploy grafana
oc create -f grafana-operator/deploy/crs/deployment/grafana.yaml -n ${NAMESPACE}

### deploy dashboards
oc create -f grafana-operator/deploy/crs/dashboards/ -n ${NAMESPACE}

### check kafka deployment status
echo
echo waiting for kafka deployment to complete
./extras/wait-for-condition.sh my-cluster-kafka-2 myproject

### make directory
mkdir jobs/generated

### setup kafka jobs with correct NodeIP service addresses
./jobs/setup_cron.sh
./jobs/setup_jobs.sh

### deploy kafka jobs
oc create -f jobs/generated/cron_job1.yaml
oc create -f jobs/generated/cron_job2.yaml

### check grafana deployment status
echo
echo checking to see if the grafana deployment is Running before opening route
./extras/wait-for-condition.sh grafana-deployment ${NAMESPACE}

### open grafana route
echo
echo opening grafana route
open https://$(oc get routes -n ${NAMESPACE} | grep grafana-route | awk '{ print $2 }')

### end
echo
echo installation complete
