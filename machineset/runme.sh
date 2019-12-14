#!/bin/bash

# create a directory for the generated templates
mkdir generated

# generate the templates
./setup_machineset.sh

# test the generated manifests
echo
echo testing the generated manifests using --dry-run
echo
oc create -f generated/ --dry-run
echo

# run the generated manifests
read -p "Select 'y' to deploy the machineset:" -n1 -s c
if [ "$c" = "y" ]; then
        echo yes
oc create -f generated/

echo

else
        echo no
fi
