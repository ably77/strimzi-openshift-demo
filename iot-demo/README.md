### Demonstrating the IoT Demo
By default, the demo will deploy an example IoT Temperature Sensors Demo. This demo will deploy a consumer facing portal that collects temperature data from simulated IoT devices and processes them.

This demo creates a couple of topics. The first one named `iot-temperature` is used by the device simulator for sending temperature values and by the stream application for getting such values and processing them. The second one is the `iot-temperature-max` topic where the stream application puts the max temperature value processed in the specified time window that is then displayed in real-time on the consumer facing dashboard in the gauges charts as well as the log of incoming messages.

![](https://github.com/ably77/strimzi-openshift-demo/blob/master/resources/iot1.png)

As a part of this demo, it is possible to scale up the number of pods in the deployment in order to simulate more devices sending temperature values, each one with a different and randomly generated id. By default this is set at 15 devices.
```
oc scale deployment device-app --replicas=20
```

Check out the ![Official Github](https://github.com/strimzi/strimzi-lab/tree/master/iot-demo) for this IoT demo for further detail

#### Demonstrating IoT Demo in Grafana
As part of the provided Grafana dashboards, you can also view more kafka-specific metrics for the IoT demo by filtering by the `iot-temperature` or `iot-temperature-max` topics

Here you can see metrics such as:
- Kafka broker CPU/MEM usage
- JVM statistics
- Incoming/Outgoing byte and message rates
- Log Size

![](https://github.com/ably77/strimzi-openshift-demo/blob/master/resources/iot2.png)
