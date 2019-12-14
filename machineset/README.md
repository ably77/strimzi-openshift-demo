# Generate kafka labeled machineset
Use this script in order to generate a specific machineset with the following parameters and then create the machineset.
```
role=kafka
second_role=stateful
instancetype=r5.xlarge
region=us-east-1
zone=c
desired_replicas=3
```

Run this script
```
./runme.sh
```
