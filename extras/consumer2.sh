#!/bin/bash

nodeip=$(oc get nodes | grep worker | awk 'NR==1{ print $1 }')
nodeportbs=$(oc get service my-cluster-kafka-external-bootstrap -n myproject -o=jsonpath='{.spec.ports[0].nodePort}{"\n"}')
topicname=my-topic2
namespace=myproject

oc run kafka-consumer2 -ti -n ${namespace} --image=strimzi/kafka:0.12.1-kafka-2.2.1 --rm=false --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server ${nodeip}:${nodeportbs} --topic $topicname --from-beginning
