#!/bin/bash

NAMESPACE=myproject

# Removing Argo/IoT demo
./argocd/uninstall.sh

# Removing the consumers if manually deployed
oc delete deployment kafka-consumer1 -n ${NAMESPACE}
oc delete deployment kafka-consumer2 -n ${NAMESPACE}

# Removing the cronjobs if manually deployed
oc delete cronjob cron-producer1 -n ${NAMESPACE}
oc delete cronjob cron-producer2 -n ${NAMESPACE}

# Removing the jobs if manually deployed
oc delete job kafka-producer1 -n ${NAMESPACE}
oc delete job kafka-producer2 -n ${NAMESPACE}
oc delete job kafka-producer3 -n ${NAMESPACE}

# Removing jobs and cronJobs if manually deployed
oc delete -f extras/manual_deploy/jobs/generated/ -n ${NAMESPACE}

# Removing iot-demo if manually deployed
oc delete -f extras/manual_deploy/iot-demo/consumer-app/resources/ -n ${NAMESPACE}
oc delete -f extras/manual_deploy/iot-demo/device-app/resources/ -n ${NAMESPACE}
oc delete -f extras/manual_deploy/iot-demo/stream-app/resources/ -n ${NAMESPACE}

# Remove Kafka Topics
oc delete kafkatopics --all

# Delete Kafka Cluster
oc delete -f strimzi-operator/deploy/crs/deployments/kafka-cluster-3broker-pv.yaml -n ${NAMESPACE}

# Delete Prometheus:
oc delete -f prometheus/alerting-rules.yaml -n ${NAMESPACE}
oc delete -f prometheus/prometheus.yaml -n ${NAMESPACE}

# Delete Grafana:
oc delete -f grafana-operator/deploy/crs/datasources/ -n ${NAMESPACE}
oc delete -f grafana-operator/deploy/crs/dashboards/ -n ${NAMESPACE}
oc delete -f grafana-operator/deploy/crs/deployment/grafana.yaml -n ${NAMESPACE}
oc delete -f grafana-operator/deploy/operator.yaml -n ${NAMESPACE}
oc delete -f grafana-operator/deploy/roles -n ${NAMESPACE}
oc delete -f grafana-operator/deploy/crds -n ${NAMESPACE}

# Remove Strimzi Operator
oc delete -f https://github.com/strimzi/strimzi-kafka-operator/releases/download/0.14.0/strimzi-cluster-operator-0.14.0.yaml -n ${NAMESPACE}

# Delete all PVCs
oc delete pvc --all -n myproject

# Remove jobs and cronJobs from directory
rm -rf extras/manual_deploy/jobs/generated
mkdir extras/manual_deploy/jobs/generated
