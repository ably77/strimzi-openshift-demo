#!/bin/bash

NAMESPACE=myproject

### Create the project namespace
oc new-project ${NAMESPACE}

### Apply Strimzi Installation File
oc apply -f https://github.com/strimzi/strimzi-kafka-operator/releases/download/0.14.0/strimzi-cluster-operator-0.14.0.yaml -n ${NAMESPACE}

### Provision the Apache Kafka Cluster
oc create -f strimzi-operator/deploy/crs/kafka-cluster-3broker.yaml -n ${NAMESPACE}

### Create Kafka Topics
oc create -f strimzi-operator/deploy/crs/my-topic1.yaml
oc create -f strimzi-operator/deploy/crs/my-topic2.yaml
oc create -f strimzi-operator/deploy/crs/my-topic3.yaml

### Start up your Prometheus server
oc create -f prometheus/alerting-rules.yaml -n ${NAMESPACE}
oc create -f prometheus/prometheus.yaml -n ${NAMESPACE}

### deploy grafana operator
echo now deploying grafana operator

### deploy crds
oc create -f grafana-operator/deploy/crds -n ${NAMESPACE}

### setup role permissions
oc create -f grafana-operator/deploy/roles -n ${NAMESPACE}

### deploy grafana operator
oc create -f grafana-operator/deploy/operator.yaml -n ${NAMESPACE}

### deploy grafana datasource
oc create -f grafana-operator/deploy/examples/datasources/Prometheus.yaml -n ${NAMESPACE}

### deploy grafana
oc create -f grafana-operator/deploy/examples/GrafanaWithIngressHost.yaml -n ${NAMESPACE}

### deploy dashboard
### currently not working due to Issue #75 https://github.com/integr8ly/grafana-operator/issues/75 - must be done manually for now

#oc create -f deploy/examples/dashboards/kafka-dashboard.yaml -n ${NAMESPACE}

### sleep
#echo sleeping for 20 seconds before checking workload deployment status ...
#echo
#sleep 20

### check kafka deployment status
echo
echo waiting for kafka deployment to complete
./extras/wait-for-condition.sh my-cluster-kafka-2 myproject

### setup kafka jobs with correct NodeIP service addresses
./setup_cron.sh
./setup_jobs.sh

### deploy kafka jobs
oc create -f cron_job1.yaml
oc create -f cron_job2.yaml

### check grafana deployment status
echo
echo checking to see if the grafana deployment is Running before opening route
./extras/wait-for-condition.sh grafana-deployment myproject

### open grafana route
open https://$(oc get routes | grep grafana-route | awk '{ print $2 }')

###
echo
echo
echo login to Grafana with root/secret
echo to add Kafka dashboard use ID: 11271
echo to add Kafka Exporter dashboard use ID: 11285
