#!/bin/bash

wget -O /projects/strimzi-openshift-demo/codeready/argocd https://github.com/argoproj/argo-cd/releases/download/v1.3.6/argocd-linux-amd64

chmod +x /projects/strimzi-openshift-demo/codeready/argocd

export PATH=/home/jboss/.local/bin:/home/jboss/bin:/usr/share/Modules/bin:/usr/bin:/usr/bin:/home/jboss/go/bin:/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/projects/strimzi-openshift-demo/codeready/
