
#!/bin/bash

maxnodestotal=15
cores_min=6
cores_max=30
mem_min=24
mem_max=120
scaledown_enabled=false

sed -e "s/<MAXNODESTOTAL>/${maxnodestotal}/g" -e "s/<CORES_MIN>/${cores_min}/g" -e "s/<CORES_MAX>/${cores_max}/g" -e "s/<MEM_MIN>/${mem_min}/g" -e "s/<MEM_MAX>/${mem_max}/g" -e "s/<SCALEDOWN_ENABLED>/${scaledown_enabled}/g" clusterautoscaler.template.yaml > generated/clusterautoscaler.yaml
