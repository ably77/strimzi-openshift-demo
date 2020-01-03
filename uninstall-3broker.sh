#!/bin/bash

NAMESPACE=myproject

# Removing the consumer
oc delete pod kafka-consumer1 -n ${NAMESPACE}
oc delete pod kafka-consumer2 -n ${NAMESPACE}

# Removing jobs and cronJobs
oc delete -f jobs/generated/

# Remove Kafka Topics
oc delete -f strimzi-operator/deploy/crs/topics/ -n ${NAMESPACE}

# Delete Kafka Cluster
oc delete -f strimzi-operator/deploy/crs/deployments/kafka-cluster-3broker.yaml -n ${NAMESPACE}

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
rm -rf jobs/generated
mkdir jobs/generated
