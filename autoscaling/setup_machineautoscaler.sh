
#!/bin/bash

machinesetid_1=$(oc get machinesets -n openshift-machine-api | awk 'NR==2{ print $1 }')
machinesetid_2=$(oc get machinesets -n openshift-machine-api | awk 'NR==3{ print $1 }')
machinesetid_3=$(oc get machinesets -n openshift-machine-api | awk 'NR==4{ print $1 }')
machinesetid_4=$(oc get machinesets -n openshift-machine-api | awk 'NR==5{ print $1 }')
minreplicas=1
maxreplicas=6

sed -e "s/<MACHINESETID>/${machinesetid_1}/g" -e "s/<MINREPLICAS>/${minreplicas}/g" -e "s/<MAXREPLICAS>/${maxreplicas}/g" machineautoscaler.template.yaml > generated/${machinesetid_1}.yaml

sed -e "s/<MACHINESETID>/${machinesetid_2}/g" -e "s/<MINREPLICAS>/${minreplicas}/g" -e "s/<MAXREPLICAS>/${maxreplicas}/g" machineautoscaler.template.yaml > generated/${machinesetid_2}.yaml

sed -e "s/<MACHINESETID>/${machinesetid_3}/g" -e "s/<MINREPLICAS>/${minreplicas}/g" -e "s/<MAXREPLICAS>/${maxreplicas}/g" machineautoscaler.template.yaml > generated/${machinesetid_3}.yaml

sed -e "s/<MACHINESETID>/${machinesetid_4}/g" -e "s/<MINREPLICAS>/${minreplicas}/g" -e "s/<MAXREPLICAS>/${maxreplicas}/g" machineautoscaler.template.yaml > generated/${machinesetid_4}.yaml
