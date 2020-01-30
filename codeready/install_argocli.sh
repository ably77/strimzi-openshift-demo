#!/bin/bash

echo adding path to argocd cli to your ~/.bash_profile
echo
echo export PATH=/home/jboss/.local/bin:/home/jboss/bin:/usr/share/Modules/bin:/usr/bin:/usr/bin:/home/jboss/go/bin:/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/projects/strimzi-openshift-demo/codeready/ >> ~/.bash_profile

source ~/.bash_profile