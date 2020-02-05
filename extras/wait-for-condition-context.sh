#!/bin/bash

seconds=0
OUTPUT=0
pod_name=$1
namespace=$2
context=$3

while [ "$OUTPUT" -ne 1 ]; do
  hashed_name=$(oc get pods -n ${namespace} --context ${context} | grep ${pod_name}  | awk 'NR==1{ print $1 }')
  OUTPUT=`oc wait --for=condition=Ready pod/${hashed_name} -n ${namespace} --context ${context} --timeout=300s 2>/dev/null | grep -c "condition met"`;
  seconds=$((seconds+5))
  printf "Waiting %s seconds for ${pod_name} to come up.\n" "${seconds}"
  sleep 5
done

echo $hashed_name is up and Running!
echo
