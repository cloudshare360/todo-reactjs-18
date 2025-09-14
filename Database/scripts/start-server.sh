#!/bin/bash

# Start JSON Server
echo "Starting JSON Server..."

# Check if json-server is installed globally
if ! command -v json-server &> /dev/null
then
    echo "json-server is not installed globally. Installing..."
    npm install -g json-server
fi

# Start the JSON Server with multiple files
echo "Starting JSON Server on port 3001..."
json-server --watch users.json todos.json user-todo-relations.json --port 3001 --host 0.0.0.0 --routes routes.json

echo "JSON Server started successfully!"
echo "API Base URL: http://localhost:3001"
echo "Users API: http://localhost:3001/users"
echo "Todos API: http://localhost:3001/todos" 
echo "Relations API: http://localhost:3001/userTodoRelations"
echo "Categories API: http://localhost:3001/categories"