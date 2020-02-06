#!/bin/bash

# Codeready Parameters
CODEREADY_DEVFILE_URL="https://raw.githubusercontent.com/ably77/strimzi-demo-codeready/master/dev-file/strimzi-demo-devfile.yaml"
CODEREADY_NAMESPACE="codeready"

# Don't change unless you change argocd/<app>.yaml namespace pointers
KAFKA_NAMESPACE="myproject"
GRAFANA_NAMESPACE="myproject"

# Add argocd cli path
echo adding path to argocd cli to your ~/.bash_profile
echo
echo export PATH=/home/jboss/.local/bin:/home/jboss/bin:/usr/share/Modules/bin:/usr/bin:/usr/bin:/home/jboss/go/bin:/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/projects/strimzi-openshift-demo/argocd/ >> ~/.bash_profile
source ~/.bash_profile

### Check if user has cluster-admin privileges
CANI=$(oc auth can-i get namespaces)
if [[ $CANI != "yes" ]]
then
        echo
        echo "not logged in as a user with cluster-admin access"
        echo "re-run the script after a user with cluster-admin rights such as kubeadmin is logged in"
        echo
        exit 1
fi

### deploy kafka in argocd
echo deploying kafka
oc create -f argocd/apps/1/strimzi-demo-kafka.yaml

### deploy grafana in argocd
echo deploying grafana
oc create -f argocd/apps/1/strimzi-demo-grafana.yaml

### deploy prometheus in argocd
echo deploying prometheus
oc create -f argocd/apps/1/strimzi-demo-prometheus.yaml

### check kafka deployment status
echo waiting for kafka deployment to complete
./extras/wait-for-condition.sh my-cluster-kafka-2 ${KAFKA_NAMESPACE}

### check grafana deployment status
echo checking grafana deployment status before deploying applications
./extras/wait-for-condition.sh grafana-deployment ${GRAFANA_NAMESPACE}

### deploy IoT demo and strimzi-loadtest application in argocd
echo creating iot-demo and strimzi-loadtest apps in argocd
oc create -f argocd/apps/2/

### open grafana route
echo opening grafana route
grafana_route=$(oc get routes -n ${GRAFANA_NAMESPACE} | grep grafana-route | awk '{ print $2 }')
open https://${grafana_route}

### Wait for IoT Demo
./extras/wait-for-condition.sh consumer-app myproject

### open IoT demo app route
echo opening consumer-app route
iot_route=$(oc get routes -n ${KAFKA_NAMESPACE} | grep consumer-app | awk '{ print $2 }')
open http://${iot_route}

### end
echo
echo installation complete
echo
echo
echo links to console routes:
echo
echo iot demo console:
echo http://${iot_route}
echo
echo grafana dashboards:
echo https://${grafana_route}
echo
