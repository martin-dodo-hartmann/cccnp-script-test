#!/usr/bin/env bash

# RESTART script, requires instanceUUID and component (web/tomcat)

export ID=$1
export COMPONENT=$2

echo "Check for $COMPONENT pod with id '$ID'..."

pods=$(kubectl get pods -n default -l "id=$ID,component=$COMPONENT" -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')

while read -r line; do
    echo "Restarting pod $line ..."
    kubectl delete pod $line -n default
done <<< "$pods"
