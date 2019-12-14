## Applying Autoscaling
REF: https://docs.openshift.com/container-platform/4.1/machine_management/applying-autoscaling.html

Once your MachineSets have been created it is possible to set up Cluster AutoScaling using the Cluster Autoscaler Operator. Since the Cluster AutoScaler operates cluster-wide, it defines a global setting for the min/max cores, memory, and nodes for the entire cluster.

### Configure the ClusterAutoscaler Parameters
Edit the parameters in the script `setup_clusterautoscaler.sh` in order to generate a new cluster autoscaler based off of the `clusterautoscaler.template.yaml`. The default values are set for this demo to the parameters below, but you can change any values as you see fit.
```
maxnodestotal=15
cores_min=6
cores_max=30
mem_min=24
mem_max=120
scaledown_enabled=true
```

### Configure MachineAutoscaler Parameters
The MachineAutoscaler resource additionally allows more granular control of how kubernetes autoscales specific MachineSets. This allows us to set more specific min/max replicas for specific MachineSet groups. For example, I want resources to scale more in zone A because my limit of EC2 instances in zone A is 20, whereas in Zone B it is only 10. A MachineAutoscaler resource needs to be created for each MachineSet in your cluster that you want to autoscale

Edit the parameters in the script `setup_machineautoscaler.sh` in order to generate machine autoscalers based off of the `machineautoscaler.template.yaml`. The default values are set for this demo to the parameters below, but you can change any values as you see fit.
```
minreplicas=1
maxreplicas=6
```

## Run Script
Once you have completed adjusting the parameters as necessary, run the script below to create and deploy your ClusterAutoscaler and MachineAutoscalers
```
./runme.sh
```

To view existing MachineAutoscalers
```
oc get machineautoscalers -n openshift-machine-api
```

Example output below:
```
$ oc get machineautoscalers -n openshift-machine-api
NAME                                      REF KIND     REF NAME                                  MIN       MAX       AGE
testing-cluster-5zdxx-worker-us-west-2a   MachineSet   testing-cluster-5zdxx-worker-us-west-2a   2         6         18s
testing-cluster-5zdxx-worker-us-west-2b   MachineSet   testing-cluster-5zdxx-worker-us-west-2b   1         4         45s
testing-cluster-5zdxx-worker-us-west-2c   MachineSet   testing-cluster-5zdxx-worker-us-west-2c   1         2         60s
```
