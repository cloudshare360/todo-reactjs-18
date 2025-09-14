#!/bin/bash

echo "🚀 Starting Todo App Servers"

# Function to check if port is in use
check_port() {
    lsof -i :$1 > /dev/null 2>&1
}

# Function to kill process on port
kill_port() {
    local port=$1
    local pid=$(lsof -t -i :$port)
    if [ ! -z "$pid" ]; then
        echo "🔪 Killing process on port $port (PID: $pid)"
        kill $pid
        sleep 1
    fi
}

# Clean up ports
kill_port 3001
kill_port 5000

echo "📊 Starting JSON Server (Database) on port 3001..."
cd /workspaces/todo-reactjs-18/Database
npx json-server --watch users.json todos.json user-todo-relations.json --port 3001 &
JSON_SERVER_PID=$!

echo "⏳ Waiting for JSON Server to start..."
sleep 3

echo "🖥️ Starting Express Server (API) on port 5000..."
cd /workspaces/todo-reactjs-18/Back-End
npm start &
EXPRESS_SERVER_PID=$!

echo "⏳ Waiting for Express Server to start..."
sleep 3

echo "✅ Servers started!"
echo "📊 JSON Server: http://localhost:3001"
echo "🖥️ Express API: http://localhost:5000"
echo ""
echo "Process IDs:"
echo "JSON Server PID: $JSON_SERVER_PID"
echo "Express Server PID: $EXPRESS_SERVER_PID"
echo ""
echo "To stop servers:"
echo "kill $JSON_SERVER_PID $EXPRESS_SERVER_PID"