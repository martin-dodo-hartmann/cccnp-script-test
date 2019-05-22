#!/usr/bin/env bash

# This entrypoint is always called, when a command get's executed for a node.
# This will delegate the command further...
# TODO implement

echo node-type: "$1"
echo node-realm: "$2"
echo node-instance: "$3"
echo command: "$4"

exit 0
