#!/bin/bash

nodeip=$(oc get nodes | grep worker | awk 'NR==1{ print $1 }')
nodeportbs=$(oc get service my-cluster-kafka-external-bootstrap -n myproject -o=jsonpath='{.spec.ports[0].nodePort}{"\n"}')
nodeport0=$(oc get service my-cluster-kafka-0 -n myproject -o=jsonpath='{.spec.ports[0].nodePort}{"\n"}')
nodeport1=$(oc get service my-cluster-kafka-1 -n myproject -o=jsonpath='{.spec.ports[0].nodePort}{"\n"}')
nodeport2=$(oc get service my-cluster-kafka-2 -n myproject -o=jsonpath='{.spec.ports[0].nodePort}{"\n"}')

namespace=myproject
topic=my-topic1

oc run kafka-producer1 -n ${namespace} -ti --image=strimzi/kafka:0.12.1-kafka-2.2.1 --rm=true --restart=Never -- bin/kafka-console-producer.sh --broker-list ${nodeip}:${nodeportbs},${nodeip}:${nodeport0},${nodeip}:${nodeport1},${nodeip}:${nodeport2} --topic ${topic}
