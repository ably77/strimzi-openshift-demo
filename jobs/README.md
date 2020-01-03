By default, this demo will generate a few Jobs and CronJobs in the `jobs/generated` directory and will deploy `cron_job1.yaml`. These jobs leverage the client tools built into kafka itself in order to demonstrate producing test messages as well as consuming them.

By default the cronJobs will have the following characteristics:
- Parallelism: 1
- Completions: 4
- Schedule: every 2 minutes

You can visualize the dynamic job creation through the Pods/Jobs tab in the Openshift Console as well as through the Grafana Dashboards provided.

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
oc create -n myproject -f jobs/generated/job3.yaml
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

Navigate to the Openshift UI and demo through all of the orchestration of pods, jobs, monitoring, resource consumption, etc.
![](https://github.com/ably77/strimzi-openshift-demo/blob/master/resources/openshift1.png)

If you are using Openshift 4 you can also see additional cluster level metrics for pods, for example our kafka broker `kafka-cluster-0`
![](https://github.com/ably77/strimzi-openshift-demo/blob/master/resources/openshift2.png)

Navigate back to the Grafana UI to see Kafka/Zookeeper specific metrics collected by Prometheus and how the Jobs that we deployed in our demo can be visualized in real-time
![](https://github.com/ably77/strimzi-openshift-demo/blob/master/resources/openshift3.png)
