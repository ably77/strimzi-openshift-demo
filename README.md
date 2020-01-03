# Openshift Strimzi Kafka Operator Demo - Multi-node Deployment (AWS)

## Overview
Apache Kafka is a highly scalable and performant distributed event streaming platform great for storing, reading, and analyzing streaming data. Originally created at LinkedIn, the project was open sourced to the Apache Foundation in 2011. Kafka enables companies looking to move from traditional batch processes over to more real-time streaming use cases.


![](https://github.com/ably77/strimzi-openshift-demo/blob/master/resources/architecture1.jpg)

The diagram above is a common example of many fast-data (streaming) solutions today. With kafka as a core component of your architecture, multiple raw data sources can pipe data to Kafka, be analyzed in real-time by tools such as Apache Spark, and persisted or consumed by other microservices

### Kubernetes Operators
An Operator is a method of packaging, deploying and managing a Kubernetes application. A Kubernetes application is an application that is both deployed on Kubernetes and managed using the Kubernetes APIs and kubectl tooling. With Operators, the kubernetes community gains a standardized way to build, deploy, operate, upgrade, and troubleshoot Kubernetes applications.

The full list of Operators can be found on [operatorhub.io](https://operatorhub.io/), the home for the Kubernetes community to share Operators.

### Strimzi Kafka Operator
Today we will be using the [strimzi.io](https://operatorhub.io/operator/strimzi-kafka-operator) Kafka Operator. Strimzi makes it easy to run Apache Kafka on OpenShift or Kubernetes.

Strimzi provides three operators:

Cluster Operator
Responsible for deploying and managing Apache Kafka clusters within an OpenShift or Kubernetes cluster.

Topic Operator
Responsible for managing Kafka topics within a Kafka cluster running within an OpenShift or Kubernetes cluster.

User Operator
Responsible for managing Kafka users within a Kafka cluster running within an OpenShift or Kubernetes cluster.

### Integreatly Grafana Operator

A Kubernetes Operator based on the Operator SDK for creating and managing Grafana instances.

The Operator is available on [Operator Hub](https://operatorhub.io/operator/grafana-operator).

It can deploy and manage a Grafana instance on Kubernetes and OpenShift. The following features are supported:

* Install Grafana to a namespace
* Import Grafana dashboards from the same or other namespaces
* Import Grafana datasources from the same namespace
* Install Plugins (panels) defined as dependencies of dashboards

## Prerequisites:
- Multi Node Openshift/Kubernetes Cluster - (This guide is tested on 4x r5.large workers)
- Admin Privileges (i.e. cluster-admin RBAC privileges or logged in as system:admin user)

## Running this Demo
If you have an Openshift cluster up and are authenticated to the CLI, just run the command below. If you prefer to run through the commands manually, the instructions are in the section below.
```
./runme.sh
```

This quick script will:
- Login to Openshift as an admin
- Deploy the Strimzi Kafka Operator
- Deploy an persistent EBS-backed kafka cluster with 3 broker nodes and 3 zookeeper nodes
- Setup the kafka brokers connectivity using nodePort services
- Create three Kafka topics (my-topic1, my-topic2, my-topic3)
- Deploy Prometheus
- Deploy the Integr8ly Grafana Operator
- Add the Prometheus Datasource to Grafana
- Add Strimzi Kafka, Kafka Exporter, and Zookeeper Dashboards
- Open the Grafana Route
- Deploy the IoT Temperature Sensors Demo
- Open route to IoT Sensors Demo App
- Generate sample Kafka Producer jobs and cronJobs with correct network routing (/jobs/generated/)
- Deploy sample cronJob1


### Showing the Demo
By default, this demo will set up up a CronJob which will deploy a job every 2 minutes with a parallelism of 2 and completions of 4. You can visualize the dynamic job creation through the Jobs tab in the Openshift Console as well as through the Strimzi Dashboard we built earlier

![](https://github.com/ably77/strimzi-openshift-demo/blob/master/resources/cron1.png)

![](https://github.com/ably77/strimzi-openshift-demo/blob/master/resources/cron2.png)

To start a consumer to view incoming `my-topic1` messages
```
./extras/consumer1.sh
```

To start a consumer to view incoming `my-topic2` messages
```
./extras/consumer2.sh
```

Navigate to the logs of a consumer to view incoming messages
```
oc logs -n myproject kafka-consumer1
oc logs -n myproject kafka-consumer2
```

A single kafka topic can also handle many Producers sending many different messages to it, to demonstrate this you can run `job3.yaml`
```
oc create -n myproject -f job3.yaml
```

Taking a look at the `job3.yaml` compared to `job1.yaml` you can see that the only difference is in record-size
```
--record-size 10
```

Navigate back to the logs of `kafka-consumer1` and you should see two streams of different record sizes being consumed on `my-topic1`. An example output is below
```
$ oc logs kafka-consumer1 -n myproject
SSXVN
SSXVN
SSXVN
SSXVN
SSXVN
SSXVNJHPDQ
SSXVNJHPDQ
SSXVNJHPDQ
SSXVNJHPDQ
```

## Bonus:
Navigate to the Openshift UI and demo through all of the orchestration of pods, jobs, monitoring, resource consumption, etc.
![](https://github.com/ably77/strimzi-openshift-demo/blob/master/resources/openshift1.png)

If you are using Openshift 4 you can also see additional cluster level metrics for pods, for example our kafka broker `kafka-cluster-0`
![](https://github.com/ably77/strimzi-openshift-demo/blob/master/resources/openshift2.png)

Navigate back to the Grafana UI to see Kafka/Zookeeper specific metrics collected by Prometheus and how the Jobs that we deployed in our demo can be visualized in real-time
![](https://github.com/ably77/strimzi-openshift-demo/blob/master/resources/openshift3.png)


### Additional Useful Commands:

#### Strimzi

List all kafka topics
```
oc get kafkatopic
```

To scale your Kafka cluster up, add a broker using the commmand below and modify the `replicas:3 --> 4` for kafka brokers
```
oc edit -f strimzi-operator/deploy/crs/kafka-cluster-3broker.yaml -n myproject
```

To edit your topic (i.e. adding topic parameters or scaling up partitions)
```
oc edit -f strimzi-operator/deploy/crs/my-topic1.yaml
```

Check out the ![Official Documentation](https://strimzi.io/documentation/) for strimzi for additional documentation

#### Grafana

Should you need to login to Grafana, use the credentials `root/secret`

List Grafana dashboards
```
oc get grafanadashboards
```

List Grafana datasources
```
oc get grafanadatasources
```

Check out the ![Official Github](https://github.com/integr8ly/grafana-operator/tree/master/documentation) for integr8ly for additional documentation

## Uninstall

Run
```
./uninstall.sh
```
