#### strimzi-loadtest demo troubleshooting
If you are having issues with argocd and would like to manually deploy the strimzi-loadtesting demo follow the instructions below

Make extras/manual_deploy/jobs/generated directory if it doesnt exist
```
mkdir extras/manual_deploy/jobs/generated
```

Setup kafka jobs with correct NodeIP service addresses
```
./extras/manual_deploy/jobs/setup_cron.sh
./extras/manual_deploy/jobs/setup_jobs.sh
```

Deploy kafka jobs
```
oc create -f extras/manual_deploy/jobs/generated/cron_job1.yaml -n ${NAMESPACE}
oc create -f extras/manual_deploy/jobs/generated/cron_job2.yaml -n ${NAMESPACE}
```
