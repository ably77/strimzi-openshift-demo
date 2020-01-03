#!/bin/bash

NAMESPACE=myproject

oc apply -f iot-demo/stream-app/resources/ -n ${NAMESPACE}

oc apply -f iot-demo/consumer-app/resources/ -n ${NAMESPACE}

oc apply -f iot-demo/device-app/resources/ -n ${NAMESPACE}

open http://$(oc get routes -n ${NAMESPACE} | grep consumer-app | awk '{ print $2 }')
