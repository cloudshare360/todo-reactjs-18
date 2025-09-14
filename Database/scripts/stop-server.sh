#!/bin/bash

# Stop JSON Server
echo "Stopping JSON Server..."

# Find and kill the json-server process
PID=$(ps aux | grep json-server | grep -v grep | awk '{print $2}')

if [ -z "$PID" ]
then
    echo "JSON Server is not running."
else
    kill $PID
    echo "JSON Server (PID: $PID) stopped successfully!"
fi