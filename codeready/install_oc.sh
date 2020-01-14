#!/bin/bash

mkdir clients

wget -O /projects/strimzi-openshift-demo/codeready/clients/openshift-client-linux-4.2.13.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux-4.2.13.tar.gz

tar -xvf /projects/strimzi-openshift-demo/codeready/clients/openshift-client-linux-4.2.13.tar.gz -C /projects/strimzi-openshift-demo/codeready/clients/

mv /projects/strimzi-openshift-demo/codeready/clients/oc /go/bin/

curl -sSL -o /go/bin/ https://github.com/argoproj/argo-cd/releases/download/v1.3.6/argocd-linux-amd64

wget -O /go/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v1.3.6/argocd-linux-amd64

chmod +x /go/bin/argocd
