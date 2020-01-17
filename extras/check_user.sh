#!/bin/bash

WHOAMI=$(oc whoami)
if [[ $WHOAMI != "kube:admin" ]]
then
        echo
        echo not logged in as kube:admin
        echo login using token from Openshift dashboard
        echo if you have another user with kube:admin rights, comment this part of script out
        echo "re-run the script after kube:admin user is logged in"
        echo
        exit 1
fi
