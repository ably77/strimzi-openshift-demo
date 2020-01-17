#!/bin/bash

seconds=0
OUTPUT=0
# example rollout would be deployments/<deployment_name>
rollout_type=$1
rollout_name=$2
namespace=$3

while [ "$OUTPUT" -ne 1 ]; do
  OUTPUT=`oc get ${rollout_type}/${rollout_name} -n ${namespace} 2>/dev/null | grep -c ${rollout_name}`;
  seconds=$((seconds+20))
  printf "Waiting %s seconds for ${rollout_type} ${rollout_name} to come up.\n" "${seconds}"
  sleep 20
  oc rollout status ${rollout_type}/${rollout_name} -n ${namespace}
done
