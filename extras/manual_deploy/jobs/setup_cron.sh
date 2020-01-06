
#!/bin/bash

nodeip=$(oc get nodes | grep worker | awk 'NR==1{ print $1 }')
nodeportbs=$(oc get service my-cluster-kafka-external-bootstrap -n myproject -o=jsonpath='{.spec.ports[0].nodePort}{"\n"}')
nodeport0=$(oc get service my-cluster-kafka-0 -n myproject -o=jsonpath='{.spec.ports[0].nodePort}{"\n"}')
nodeport1=$(oc get service my-cluster-kafka-1 -n myproject -o=jsonpath='{.spec.ports[0].nodePort}{"\n"}')
nodeport2=$(oc get service my-cluster-kafka-2 -n myproject -o=jsonpath='{.spec.ports[0].nodePort}{"\n"}')
namespace=myproject
## job1 Variables (Optional)
job1_parallelism=1
job1_completions=4
job1_topic=my-topic1

## job2 Variables (Optional)
job2_parallelism=1
job2_completions=4
job2_topic=my-topic2

## job3 Variables (Optional)
job3_parallelism=1
job3_completions=4
job3_topic=my-topic1


sed -e "s/<PRODUCERNAME>/cron-producer1/g" -e "s/<NAMESPACE>/$namespace/g" -e "s/<PARALLELISM>/${job1_parallelism}/g" -e "s/<COMPLETIONS>/${job1_completions}/g" -e "s/<KAFKATOPIC>/my-topic1/g" -e "s/<RECORDSIZE>/5/g" -e "s/<NODEIP>/${nodeip}/g" -e "s/<NODEPORTBS>/${nodeportbs}/g" -e "s/<NODEPORT0>/${nodeport0}/g" -e "s/<NODEPORT1>/${nodeport1}/g" -e "s/<NODEPORT2>/${nodeport2}/g" extras/manual_deploy/jobs/templates/cronjob.template.yaml > extras/manual_deploy/jobs/generated/cron_job1.yaml
sed -e "s/<PRODUCERNAME>/cron-producer2/g" -e "s/<NAMESPACE>/$namespace/g" -e "s/<PARALLELISM>/${job1_parallelism}/g" -e "s/<COMPLETIONS>/${job1_completions}/g" -e "s/<KAFKATOPIC>/my-topic2/g" -e "s/<RECORDSIZE>/5/g" -e "s/<NODEIP>/${nodeip}/g" -e "s/<NODEPORTBS>/${nodeportbs}/g" -e "s/<NODEPORT0>/${nodeport0}/g" -e "s/<NODEPORT1>/${nodeport1}/g" -e "s/<NODEPORT2>/${nodeport2}/g" extras/manual_deploy/jobs/templates/cronjob.template.yaml > extras/manual_deploy/jobs/generated/cron_job2.yaml
sed -e "s/<PRODUCERNAME>/cron-producer3/g" -e "s/<NAMESPACE>/$namespace/g" -e "s/<PARALLELISM>/${job1_parallelism}/g" -e "s/<COMPLETIONS>/${job1_completions}/g" -e "s/<KAFKATOPIC>/my-topic1/g" -e "s/<RECORDSIZE>/10/g" -e "s/<NODEIP>/${nodeip}/g" -e "s/<NODEPORTBS>/${nodeportbs}/g" -e "s/<NODEPORT0>/${nodeport0}/g" -e "s/<NODEPORT1>/${nodeport1}/g" -e "s/<NODEPORT2>/${nodeport2}/g" extras/manual_deploy/jobs/templates/cronjob.template.yaml > extras/manual_deploy/jobs/generated/cron_job3.yaml
