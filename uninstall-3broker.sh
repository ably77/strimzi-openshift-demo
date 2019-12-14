#!/bin/bash

NAMESPACE=myproject

# Removing the consumer
oc delete pod kafka-consumer1 -n ${NAMESPACE}
oc delete pod kafka-consumer2 -n ${NAMESPACE}

# Removing Jobs
oc delete -f job1.yaml -n ${NAMESPACE}
oc delete -f job2.yaml -n ${NAMESPACE}
oc delete -f job3.yaml -n ${NAMESPACE}

# Removing Cron jobs
oc delete -f cron_job1.yaml -n ${NAMESPACE}
oc delete -f cron_job2.yaml -n ${NAMESPACE}
oc delete -f cron_job3.yaml -n ${NAMESPACE}

# Remove Kafka Topics
oc delete -f strimzi-operator/deploy/crs/my-topic1.yaml -n ${NAMESPACE}
oc delete -f strimzi-operator/deploy/crs/my-topic2.yaml -n ${NAMESPACE}
oc delete -f strimzi-operator/deploy/crs/my-topic3.yaml -n ${NAMESPACE}

# Delete Kafka Cluster
oc delete -f strimzi-operator/deploy/crs/kafka-cluster-3broker.yaml -n ${NAMESPACE}

# Delete Prometheus:
oc delete -f prometheus/alerting-rules.yaml -n ${NAMESPACE}
oc delete -f prometheus/prometheus.yaml -n ${NAMESPACE}

# Delete Grafana:
oc delete -f grafana-operator/deploy/examples/datasources/Prometheus.yaml -n ${NAMESPACE}
oc delete -f grafana-operator/deploy/examples/GrafanaWithIngressHost.yaml -n ${NAMESPACE}
oc delete -f grafana-operator/deploy/operator.yaml -n ${NAMESPACE}
oc delete -f grafana-operator/deploy/roles -n ${NAMESPACE}
oc delete -f grafana-operator/deploy/crds -n ${NAMESPACE}

# Remove Strimzi Operator
oc delete -f https://github.com/strimzi/strimzi-kafka-operator/releases/download/0.14.0/strimzi-cluster-operator-0.14.0.yaml -n ${NAMESPACE}

# Delete all PVCs
oc delete pvc --all -n myproject
