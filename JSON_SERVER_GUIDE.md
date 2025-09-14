# JSON Server Setup and Testing Guide

## Overview
The JSON Server acts as a database service providing RESTful API endpoints for the Todo application. It runs on **port 3001** and serves data from consolidated JSON files.

## Prerequisites
- Node.js (16+ recommended)
- npm package manager
- Terminal access

## Directory Structure
```
Database/
├── package.json          # Dependencies and scripts
├── server.js             # Custom JSON Server with CORS
├── db.json               # Consolidated database file
├── routes.json           # Custom route mappings
├── users.json            # Legacy user data (backup)
├── todos.json            # Legacy todo data (backup)
└── user-todo-relations.json  # Legacy relations (backup)
```

## Setup Instructions

### 1. Install Dependencies
```bash
cd /workspaces/todo-reactjs-18/Database
npm install
```

### 2. Start JSON Server

#### Option A: Custom Server (Recommended)
```bash
npm start
```
This starts the custom server with enhanced CORS support for GitHub Codespaces.

#### Option B: Legacy JSON Server
```bash
npm run start:legacy
```
This uses the standard json-server package.

#### Option C: Development Mode (with delay)
```bash
npm run start:dev
```
This adds a 200ms delay to simulate network latency.

### 3. Verify Server is Running
The server should start on port 3001. You'll see output like:
```
🌐 JSON Server running on http://0.0.0.0:3001
📊 Resources available:
  /users
  /todos  
  /categories
  /user-todo-relations
🌍 External access: Available on GitHub Codespaces forwarded port
```

## Database Schema

### Users Resource (`/users`)
```json
{
  "id": 1,
  "username": "testuser",
  "email": "test@example.com",
  "password": "$2a$10$hashedpassword",
  "firstName": "John",
  "lastName": "Doe",
  "preferences": {
    "theme": "light",
    "language": "en",
    "notifications": true
  },
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

### Todos Resource (`/todos`)
```json
{
  "id": 1,
  "title": "Sample Todo",
  "description": "This is a sample todo item",
  "completed": false,
  "priority": "medium",
  "dueDate": "2024-12-31",
  "categoryId": 1,
  "userId": 1,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

### Categories Resource (`/categories`)
```json
{
  "id": 1,
  "name": "Work",
  "color": "#FF6B6B",
  "description": "Work related tasks",
  "userId": 1,
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

### User-Todo Relations (`/user-todo-relations`)
```json
{
  "id": 1,
  "userId": 1,
  "todoId": 1,
  "role": "owner",
  "permissions": ["read", "write", "delete"],
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

## Testing with CURL Scripts

### Basic Health Check
```bash
curl -X GET http://localhost:3001/users \
  -H "Content-Type: application/json"
```

### Create Test User
```bash
curl -X POST http://localhost:3001/users \
  -H "Content-Type: application/json" \
  -d '{
    "username": "jsonuser",
    "email": "jsonuser@example.com", 
    "password": "hashedpassword123",
    "firstName": "JSON",
    "lastName": "User",
    "preferences": {
      "theme": "dark",
      "language": "en",
      "notifications": true
    }
  }'
```

### Create Test Todo
```bash
curl -X POST http://localhost:3001/todos \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test JSON Server Todo",
    "description": "Testing direct JSON Server access",
    "completed": false,
    "priority": "high",
    "dueDate": "2024-12-31",
    "categoryId": 1,
    "userId": 1
  }'
```

### Create Test Category
```bash
curl -X POST http://localhost:3001/categories \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Testing",
    "color": "#4ECDC4", 
    "description": "Category for testing purposes",
    "userId": 1
  }'
```

### Query with Filters
```bash
# Get todos for specific user
curl "http://localhost:3001/todos?userId=1"

# Get completed todos
curl "http://localhost:3001/todos?completed=true"

# Get todos with pagination
curl "http://localhost:3001/todos?_page=1&_limit=10"

# Get todos sorted by creation date
curl "http://localhost:3001/todos?_sort=createdAt&_order=desc"

# Search todos by title
curl "http://localhost:3001/todos?title_like=Test"
```

### Update Operations
```bash
# Update todo (PUT - full replace)
curl -X PUT http://localhost:3001/todos/1 \
  -H "Content-Type: application/json" \
  -d '{
    "id": 1,
    "title": "Updated Todo Title",
    "description": "Updated description",
    "completed": true,
    "priority": "low",
    "dueDate": "2024-12-31",
    "categoryId": 1,
    "userId": 1,
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "'$(date -Iseconds)'"
  }'

# Update todo (PATCH - partial update)
curl -X PATCH http://localhost:3001/todos/1 \
  -H "Content-Type: application/json" \
  -d '{
    "completed": true,
    "updatedAt": "'$(date -Iseconds)'"
  }'
```

### Delete Operations
```bash
# Delete specific todo
curl -X DELETE http://localhost:3001/todos/1

# Delete specific user
curl -X DELETE http://localhost:3001/users/1
```

### Advanced Queries
```bash
# Get user with their todos (using _embed)
curl "http://localhost:3001/users/1?_embed=todos"

# Get todo with its category (using _expand)
curl "http://localhost:3001/todos/1?_expand=category"

# Full text search across multiple fields
curl "http://localhost:3001/todos?q=important"

# Multiple conditions
curl "http://localhost:3001/todos?userId=1&completed=false&priority=high"
```

## Automated Testing Script

Use the provided test script for comprehensive testing:

```bash
# Run JSON Server specific tests
cd /workspaces/todo-reactjs-18/curl-scripts
./test-json-server.sh
```

This script tests:
- ✅ Server connectivity
- ✅ CRUD operations on all resources
- ✅ Query parameters and filters
- ✅ Pagination and sorting
- ✅ Relationship queries
- ✅ Error handling
- ✅ Data validation

## Troubleshooting

### Common Issues

1. **Port Already in Use**
   ```bash
   # Kill existing process
   lsof -ti :3001 | xargs kill
   # Or use the cleanup script
   ./start-servers.sh
   ```

2. **CORS Issues**
   - The custom server handles CORS automatically
   - For external access, ensure GitHub Codespaces port forwarding is enabled

3. **Database Reset**
   ```bash
   npm run reset
   ```

4. **Backup Current Data**
   ```bash
   npm run backup
   ```

5. **Check Server Status**
   ```bash
   curl http://localhost:3001/
   ```

## Monitoring and Logs

The JSON Server provides detailed logging:
- Request/Response logging
- CORS origin detection
- Error messages with context
- Performance metrics

### Log Levels
- **INFO**: Server startup and configuration
- **DEBUG**: Request/response details
- **ERROR**: Error conditions and failures

## Development Notes

- The server automatically detects GitHub Codespaces environment
- CORS is dynamically configured for external access
- All resources support full CRUD operations
- Query parameters follow json-server conventions
- Relationships are handled through foreign keys

## Next Steps
After setting up JSON Server, proceed to:
1. [Express API Setup Guide](EXPRESS_API_GUIDE.md)
2. [Swagger UI Setup Guide](SWAGGER_UI_GUIDE.md)
3. [Master Startup Guide](STARTUP_GUIDE.md)