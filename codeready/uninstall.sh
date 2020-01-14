#!/bin/bash

NAMESPACE=che-operator

oc delete -f deploy/crds/org_v1_che_cr.yaml -n ${NAMESPACE}

oc delete -f deploy/operator.yaml -n ${NAMESPACE}

oc delete -f deploy/service_account.yaml -n ${NAMESPACE}
oc delete -f deploy/role.yaml -n ${NAMESPACE}
oc delete -f deploy/role_binding.yaml -n ${NAMESPACE}
oc delete -f deploy/crds/org_v1_che_crd.yaml

# uncomment if you need Login with OpenShift
oc delete -f deploy/cluster_role_binding.yaml
oc delete -f deploy/cluster_role.yaml -n=${NAMESPACE}

# delete pvc
#oc delete pvc --all -n myproject
