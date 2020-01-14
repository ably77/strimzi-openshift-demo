#!/bin/bash

NAMESPACE=myproject

argocd_route=$(oc -n argocd get route argocd-server -o jsonpath='{.spec.host}')
open http://${argocd_route}

### open grafana route
echo opening grafana route
open https://$(oc get routes -n ${NAMESPACE} | grep grafana-route | awk '{ print $2 }')

### open IoT demo app route
echo opening consumer-app route
open http://$(oc get routes -n ${NAMESPACE} | grep consumer-app | awk '{ print $2 }')
