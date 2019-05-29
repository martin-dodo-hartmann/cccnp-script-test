#!/usr/bin/env bash

# RESTART script, requires instanceUUID and component (web/tomcat)

export KUBERNETES_PORT=tcp://172.20.0.1:443
export KUBERNETES_PORT_443_TCP_PORT=443
export KUBERNETES_SERVICE_PORT=443
export KUBERNETES_SERVICE_HOST=172.20.0.1
export KUBERNETES_PORT_443_TCP_PROTO=tcp
export KUBERNETES_SERVICE_PORT_HTTPS=443
export KUBERNETES_PORT_443_TCP_ADDR=172.20.0.1
export KUBERNETES_PORT_443_TCP=tcp://172.20.0.1:443

whoami
echo "EVN..."
env
echo "DONE!"

export ID=$1
export COMPONENT=$2

echo "Check for $COMPONENT pod with id '$ID'..."

pods=$(kubectl get pods -n default -l "id=$ID,component=$COMPONENT" -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')

while read -r line; do
    echo "Restarting pod $line ..."
    kubectl delete pod $line -n default
done <<< "$pods"
