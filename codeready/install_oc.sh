#!/bin/bash

mkdir clients

wget -O /projects/clients/ https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux-4.2.13.tar.gz

tar -xvf /projects/clients/openshift-client-linux-4.2.13.tar.gz

mv /projects/clients/oc /go/bin/

curl -sSL -o /go/bin/ https://github.com/argoproj/argo-cd/releases/download/v1.3.6/argocd-linux-amd64

wget -O /go/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v1.3.6/argocd-linux-amd64

chmod +x /go/bin/argocd
