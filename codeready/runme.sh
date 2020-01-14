#!/bin/bash

NAMESPACE=che-operator

oc new-project ${NAMESPACE}

oc apply -f deploy/service_account.yaml -n ${NAMESPACE}
oc apply -f deploy/role.yaml -n ${NAMESPACE}
oc apply -f deploy/role_binding.yaml -n ${NAMESPACE}
#oc apply -f deploy/cluster_role.yaml -n ${NAMESPACE}
#oc apply -f deploy/cluster_role_binding.yaml -n ${NAMESPACE}
oc apply -f deploy/crds/org_v1_che_crd.yaml
# sometimes the operator cannot get CRD right away
sleep 2

# uncomment if you need Login with OpenShift
#oc new-app -f deploy/role_binding_oauth.yaml -p NAMESPACE=${NAMESPACE} -n=${NAMESPACE}
#oc apply -f deploy/cluster_role.yaml -n=${NAMESPACE}

oc apply -f deploy/operator.yaml -n ${NAMESPACE}
oc apply -f deploy/crds/org_v1_che_cr.yaml -n ${NAMESPACE}

# add cluster-admin privileges (not sure if working)
#oc adm policy add-cluster-role-to-user self-provisioner system:serviceaccount:${NAMESPACE}:che-workspace

# wait for deployment
#./wait-for-condition.sh che ${NAMESPACE}

### open codeready workspaces route
#echo opening codeready workspaces route
#open http://$(oc get routes -n ${NAMESPACE} | grep che-host | awk '{ print $2 }')
