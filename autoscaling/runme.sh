#!/bin/bash

# create a directory for the generated templates
mkdir generated

# generate the templates
./setup_clusterautoscaler.sh
./setup_machineautoscaler.sh

# create the generated manifests
oc create -f generated/
