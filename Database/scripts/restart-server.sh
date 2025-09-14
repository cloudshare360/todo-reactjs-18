#!/bin/bash

# Restart JSON Server
echo "Restarting JSON Server..."

# Stop the server first
./stop-server.sh

# Wait a moment
sleep 2

# Start the server
./start-server.sh