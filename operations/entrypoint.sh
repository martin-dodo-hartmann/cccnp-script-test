#!/usr/bin/env bash

# This entrypoint is always called, when a command get's executed for a node.
# This will delegate the command further...
# TODO implement

export node_type="$1"
export node_realm="$2"
export node_instance="$3"
export node_id="$4"
export command="$5"

echo node-type: "$node_type"
echo node-realm: "$node_realm"
echo node-instance: "$node_instance"
echo node-id: "$node_id"
echo command: "$command"

cd $(dirname $0)

# Set required environment variables
additionalEnvVars=$(cat /home/rundeck/server/data/env.properties)
while read line; do
    export $line
done <<< "$additionalEnvVars"

# Check RESTART
if [[ -z "${command##*restart*}" ]]; then
  if [[ -z "${command##*tomcat*}" ]]; then
    echo "Restarting tomcat pods..."
    /bin/bash restart.sh "$node_id" "tomcat"
  elif [[ -z "${command##*web*}" ]]; then
    echo "Restarting web pods..."
    /bin/bash restart.sh "$node_id" "web"
  else
    echo "No suitable pod type!"
  fi
fi

exit 0
