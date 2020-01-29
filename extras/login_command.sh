#!/bin/bash

TOKEN=$(oc get kubeconfig demouser -o json | jq .spec.users[0].user.token)
APISERVER=$(oc config view -o json | jq .clusters[0].cluster.server)

echo
echo once codeready workspace is up, login to demouser using command below:
echo
echo oc login --token=$TOKEN --server=${APISERVER}
echo
