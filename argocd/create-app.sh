#!/bin/bash

argo_project="$1"
app_name="$2"
repo_url="$3"
namespace="$4"
sync_policy="$5"

argocd app create --project ${argo_project} \
--name ${app_name} --repo ${repo_url} \
--path . --dest-server https://kubernetes.default.svc \
--dest-namespace ${namespace} --revision master --sync-policy ${sync_policy}
