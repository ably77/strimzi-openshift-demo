You can just run the iot-demo app without ArgoCD
```
oc create -f extras/manual_deploy/iot-demo/consumer-app/resources/consumer-app.yml -n myproject
oc create -f extras/manual_deploy/iot-demo/device-app/resources/device-app.yml -n myproject
oc create -f extras/manual_deploy/iot-demo/stream-app/resources/stream-app.yml -n myproject
oc create -f extras/manual_deploy/iot-demo/stream-app/resources/topics.yml -n myproject
```
