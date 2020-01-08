# Openshift Strimzi Kafka Operator Demo - Multi-node Deployment (AWS)
- Real-time Streaming IoT Application with Console
- ArgoCD driven Continuous Delivery for all components (Kafka, Grafana, Prometheus, load-testing demo, iot-demo app)
- Prometheus metrics
- Grafana Dashboards

Optional:
- Autoscaling
- Infrastructure pinning
- Run all components without ArgoCD

## Youtube Video Demonstration
[![Youtube Video Demonstration](https://github.com/ably77/strimzi-openshift-demo/blob/master/resources/youtube1.png)](https://www.youtube.com/watch?v=ufa2rkSlHec)

## Overview
Apache Kafka is a highly scalable and performant distributed event streaming platform great for storing, reading, and analyzing streaming data. Originally created at LinkedIn, the project was open sourced to the Apache Foundation in 2011. Kafka enables companies looking to move from traditional batch processes over to more real-time streaming use cases.

![](https://github.com/ably77/strimzi-openshift-demo/blob/master/resources/architecture1.jpg)

The diagram above is a common example of many fast-data (streaming) solutions today. With kafka as a core component of your architecture, multiple raw data sources can pipe data to Kafka, be analyzed in real-time by tools such as Apache Spark, and persisted or consumed by other microservices

### Kubernetes Operators
An Operator is a method of packaging, deploying and managing a Kubernetes application. A Kubernetes application is an application that is both deployed on Kubernetes and managed using the Kubernetes APIs and kubectl tooling. With Operators, the kubernetes community gains a standardized way to build, deploy, operate, upgrade, and troubleshoot Kubernetes applications.

The full list of Operators can be found on [operatorhub.io](https://operatorhub.io/), the home for the Kubernetes community to share Operators.

#### Strimzi Kafka Operator
Today we will be using the [strimzi.io](https://operatorhub.io/operator/strimzi-kafka-operator) Kafka Operator. Strimzi makes it easy to run Apache Kafka on OpenShift or Kubernetes.

Strimzi provides three operators:

Cluster Operator
Responsible for deploying and managing Apache Kafka clusters within an OpenShift or Kubernetes cluster.

Topic Operator
Responsible for managing Kafka topics within a Kafka cluster running within an OpenShift or Kubernetes cluster.

User Operator
Responsible for managing Kafka users within a Kafka cluster running within an OpenShift or Kubernetes cluster.

#### Integr8ly Grafana Operator
A Kubernetes Operator based on the Operator SDK for creating and managing Grafana instances.

The Operator is available on [Operator Hub](https://operatorhub.io/operator/grafana-operator).

It can deploy and manage a Grafana instance on Kubernetes and OpenShift. The following features are supported:

* Install Grafana to a namespace
* Import Grafana dashboards from the same or other namespaces
* Import Grafana datasources from the same namespace
* Install Plugins (panels) defined as dependencies of dashboards

#### ArgoCD Operator
Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes.

Why Argo CD?
- Application definitions, configurations, and environments should be declarative and version controlled.
- Application deployment and lifecycle management should be automated, auditable, and easy to understand.

## Prerequisites for Lab:
- Multi Node Openshift/Kubernetes Cluster - (This guide is tested on 2x r5.xlarge workers)
- Admin Privileges (i.e. cluster-admin RBAC privileges or logged in as system:admin user)
- ArgoCLI Installed (see https://github.com/argoproj/argo-cd/blob/master/docs/cli_installation.md)
- oc client installed (see https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/)

## Running this Demo
If you have an Openshift cluster up, `argocd` CLI installed, and are authenticated to the `oc` CLI just run the installation script below. The script itself has more commented information on the steps and commands if you prefer to run through this demo manually.
```
./runme.sh
```

This quick script will:
- Deploy the Strimzi Kafka Operator
- Deploy an persistent EBS-backed kafka cluster with 3 broker nodes and 3 zookeeper nodes
- Setup the kafka brokers connectivity using nodePort services
- Create three Kafka topics (my-topic1, my-topic2, my-topic3)
- Deploy Prometheus
- Deploy the Integr8ly Grafana Operator
- Add the Prometheus Datasource to Grafana
- Add Strimzi Kafka, Kafka Exporter, and Zookeeper Dashboards
- Deploy and configure ArgoCD
- Connect ArgoCD to IoT Github Repo (customizable)
- Deploy the IoT Temperature Sensors Demo using ArgoCD
- Open ArgoCD Route
- Open Grafana Route
- Open IoT Sensors Demo App Route
- Generate sample Kafka Producer jobs and cronJobs with correct network routing (/jobs/generated/)
- Deploy sample cronJob1 and cronJob2


### Demonstrating the IoT Demo
By default, the demo will deploy an example IoT Temperature Sensors Demo using ArgoCD based on ![this repo](https://github.com/ably77/iot-argocd). This demo will deploy a consumer facing portal that collects temperature data from simulated IoT devices and processes them.

![](https://github.com/ably77/strimzi-openshift-demo/blob/master/resources/iot1.png)

This demo creates a couple of topics. The first one named `iot-temperature` is used by the device simulator for sending temperature values and by the stream application for getting such values and processing them. The second one is the `iot-temperature-max` topic where the stream application puts the max temperature value processed in the specified time window that is then displayed in real-time on the consumer facing dashboard in the gauges charts as well as the log of incoming messages.

![](https://github.com/ably77/strimzi-openshift-demo/blob/master/resources/iot2.png)

Check out the ![Official Github](https://github.com/strimzi/strimzi-lab/tree/master/iot-demo) for this IoT demo for further detail

#### Demonstrating IoT Demo in Grafana
As part of the provided Grafana dashboards, you can also view more kafka-specific metrics for the IoT demo by filtering by the `iot-temperature` or `iot-temperature-max` topics

Here you can see metrics such as:
- Kafka broker CPU/MEM usage
- JVM statistics
- Incoming/Outgoing byte and message rates
- Log Size

![](https://github.com/ably77/strimzi-openshift-demo/blob/master/resources/grafana1.png)


### Demonstrating the strimzi-loadtest Demo

By default, the demo will deploy an example Strimzi loadtesting demo using ArgoCD based on ![this repo](https://github.com/ably77/strimzi-loadtest). This demo will create several topics `my-topic1` and `my-topic2` and deploy cronJobs and Jobs to these topics. You can leverage Github and argoCD in order to increase producer load, as well as watch logs of messages from the consumers.

By default the cronJobs will have the following characteristics:
- Parallelism: 1
- Completions: 4
- Schedule: every 2 minutes

By default the Jobs will have the following characteristics:
- Parallelism: 1
- Completions: 50

You can visualize the dynamic job creation through the Pods/Jobs tab in the Openshift Console as well as through the Grafana Dashboards provided.

![](https://github.com/ably77/strimzi-openshift-demo/blob/master/resources/cron1.png)

![](https://github.com/ably77/strimzi-openshift-demo/blob/master/resources/cron2.png)


Navigate to the logs of a consumer to view incoming messages
```
oc logs -n myproject kafka-consumer1
oc logs -n myproject kafka-consumer2
```

A single kafka topic can also handle many Producers sending many different messages to it, to demonstrate this you can look at `job1.yaml` and `job2.yaml`
```
$ cat job1.yaml
<...>
kafka-producer-perf-test --topic my-topic1 --num-records 2500000 --record-size 5

$ cat job2.yaml
<...>
kafka-producer-perf-test --topic my-topic1 --num-records 2500000 --record-size 10
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

Navigate to the Openshift UI and demo through all of the orchestration of pods, jobs, monitoring, resource consumption, etc.
![](https://github.com/ably77/strimzi-openshift-demo/blob/master/resources/openshift1.png)

If you are using Openshift 4 you can also see additional cluster level metrics for pods, for example our kafka broker `kafka-cluster-0`
![](https://github.com/ably77/strimzi-openshift-demo/blob/master/resources/openshift2.png)

#### Demonstrating strimzi-loadtest demo in Grafana
As part of the provided Grafana dashboards, you can also view more kafka-specific metrics for the strimzi-loadtest demo by filtering by the `my-topic1` or `my-topic2` topics

Navigate back to the Grafana UI to see Kafka/Zookeeper specific metrics collected by Prometheus and how the Jobs that we deployed in our demo can be visualized in real-time. Select and filter the topic to  in order to see specific metrics for the strimzi-loadtest demo

Here you can see metrics such as:
- Kafka broker CPU/MEM usage
- JVM statistics
- Incoming/Outgoing byte and message rates
- Log Size

![](https://github.com/ably77/strimzi-openshift-demo/blob/master/resources/grafana2.png)


### Demonstrating Continuous Delivery with ArgoCD


To login to the ArgoCD console and navigate to the iot-demo application
```
username: admin
password: secret
```

Here you should see the existing argocd applications: the IoT demo application as well as the strimzi-loadtest applications
![](https://github.com/ably77/strimzi-openshift-demo/blob/master/resources/argo1.png)

If you click select the application you should see the topology of the application and more details
![](https://github.com/ably77/strimzi-openshift-demo/blob/master/resources/argo1.png)

By default, the repo is set up to deploy the demo app based off of these repos below
- https://github.com/ably77/iot-argocd
- https://github.com/ably77/strimzi-loadtest
- https://github.com/ably77/strimzi-demo-prometheus
- https://github.com/ably77/strimzi-demo-grafana
- https://github.com/ably77/strimzi-demo-kafka

If you want to demonstrate and control git push to drive continuous delivery, fork this repository and re-direct to your own personal github. An example of doing so with the iot-demo app is below, but you can fork any of the repositories above if you want to demonstrate CD with that component. Only one fork is needed to effectively show Continuous Delivery in action.

First uninstall the existing iot-demo app deployment:
```
oc delete -f argocd/iot-demo.yaml -n myproject
```

Next, add your repo using the argoCD CLI
```
argocd repo add <GITHUB_REPO_URL_HERE>
```

Then set the `repoURL` variable in the `argocd/iot-demo.yaml` manifest to point at your own github URL before re-deploying the demo application
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: iot-demo
  namespace: argocd
spec:
  project: default
  source:
    repoURL: <YOUR_GITHUB_REPO_URL_HERE>
```

Redeploy the application you've modified to argoCD
```
oc create -f argocd/iot-demo.yaml -n myproject
```

Now you can make corresponding changes to the IoT github repo, such as increasing replicas of the `device-app.yml` from 30 to 50
```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: device-app
  labels:
    app: iot-demo
spec:
  replicas: 30
<...>
```

Push your changes to Github and within minutes you should automatically see the desired changes reflected in your deployments
```
$ oc get deployments
NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
device-app                   50/50   50           50          12m
```

You will also see the number of devices reflected in the IoT consumer app dashboard
![](https://github.com/ably77/strimzi-openshift-demo/blob/master/resources/iot3.png)

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

## Troubleshooting

#### Running without ArgoCD
If you would like to run the entire demo without any ArgoCD components, just simply switch the variable in the `runme.sh` script:
```
ARGOCD_ENABLED="false"
```

This will run the script off of the static files in the directories instead of deploying applications from ArgoCD

## Uninstall
```
./uninstall.sh
```

Note: If the uninstall hangs, just re-run the script
