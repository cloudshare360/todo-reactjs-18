# Master Startup and Testing Guide

## Overview
This guide provides comprehensive instructions for starting all servers in the Todo application ecosystem and running complete end-to-end testing with mock data for every operation.

## System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Swagger UI    │    │   Express API   │    │   JSON Server   │
│   Port: 8080    │◄──►│   Port: 5000    │◄──►│   Port: 3001    │
│   (Proxy+Docs)  │    │ (Business Logic)│    │   (Database)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │  CURL Scripts   │
                    │   (Testing)     │
                    └─────────────────┘
```

## Prerequisites

### System Requirements
- **Node.js**: Version 16.0.0 or higher
- **npm**: Version 8.0.0 or higher
- **Operating System**: Linux (Ubuntu 24.04.2 LTS)
- **Terminal**: Bash shell access
- **Memory**: Minimum 2GB available RAM
- **Network**: Ports 3001, 5000, 8080 available

### Environment Setup
```bash
# Verify Node.js version
node --version  # Should be >= 16.0.0

# Verify npm version
npm --version   # Should be >= 8.0.0

# Check available ports
lsof -i :3001 :5000 :8080
```

## Quick Start (Automated)

### Option 1: Use Automated Startup Script
```bash
cd /workspaces/todo-reactjs-18
./start-servers.sh
```

This script automatically:
- ✅ Kills existing processes on required ports
- ✅ Starts JSON Server (port 3001)
- ✅ Starts Express API (port 5000)
- ✅ Provides process IDs for management

### Option 2: Start Individual Servers (Manual)

If you prefer manual control or need to troubleshoot:

#### Step 1: Start JSON Server (Database Layer)
```bash
# Terminal 1
cd /workspaces/todo-reactjs-18/Database
npm install
npm start
```

**Wait for:** `🌐 JSON Server running on http://0.0.0.0:3001`

#### Step 2: Start Express API (Business Logic Layer)
```bash
# Terminal 2
cd /workspaces/todo-reactjs-18/Back-End
npm install
npm start
```

**Wait for:** `✅ Server ready for requests!`

#### Step 3: Start Swagger UI (Documentation & Testing Layer)
```bash
# Terminal 3
cd /workspaces/todo-reactjs-18/swagger-ui
npm install
npm start
```

**Wait for:** `🌐 Swagger UI Proxy Server running on http://0.0.0.0:8080`

## Verification Checklist

After starting all servers, verify each component:

### 1. JSON Server Health Check
```bash
curl -s http://localhost:3001/users | jq '.' || echo "JSON Server not responding"
```

**Expected:** Array of users or empty array `[]`

### 2. Express API Health Check
```bash
curl -s http://localhost:5000/api/health | jq '.' || echo "Express API not responding"
```

**Expected:** 
```json
{
  "status": "OK",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "uptime": "30s",
  "version": "1.0.0",
  "database": "Connected"
}
```

### 3. Swagger UI Health Check
```bash
curl -s http://localhost:8080/proxy-health | jq '.' || echo "Swagger UI not responding"
```

**Expected:**
```json
{
  "status": "OK",
  "message": "Swagger UI Proxy Server",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "apiTarget": "http://localhost:5000"
}
```

### 4. End-to-End Connectivity Test
```bash
curl -s http://localhost:8080/api-proxy/api/health | jq '.' || echo "End-to-end connection failed"
```

**Expected:** Same as Express API health check response

## Comprehensive Testing Workflow

### Phase 1: Authentication Testing

#### Test 1: User Registration
```bash
cd /workspaces/todo-reactjs-18/curl-scripts
./test-auth.sh
```

**Manual Registration Test:**
```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser_'$(date +%s)'",
    "email": "test'$(date +%s)'@example.com",
    "password": "SecurePass123!",
    "firstName": "Test",
    "lastName": "User"
  }' | jq '.'
```

#### Test 2: User Login & Token Management
```bash
# Login and save token
RESPONSE=$(curl -s -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "SecurePass123!"
  }')

TOKEN=$(echo $RESPONSE | jq -r '.data.token')
echo "Token: $TOKEN"

# Test authenticated endpoint
curl -X GET http://localhost:5000/api/auth/me \
  -H "Authorization: Bearer $TOKEN" | jq '.'
```

### Phase 2: Category Management Testing

#### Test 3: Category CRUD Operations
```bash
./test-categories.sh
```

**Manual Category Testing:**
```bash
# Create category
CATEGORY_RESPONSE=$(curl -s -X POST http://localhost:5000/api/categories \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Work Tasks",
    "color": "#FF6B6B",
    "description": "Work-related todo items"
  }')

CATEGORY_ID=$(echo $CATEGORY_RESPONSE | jq -r '.data.id')
echo "Category ID: $CATEGORY_ID"

# List categories
curl -X GET http://localhost:5000/api/categories \
  -H "Authorization: Bearer $TOKEN" | jq '.'

# Update category
curl -X PUT http://localhost:5000/api/categories/$CATEGORY_ID \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Updated Work Tasks",
    "color": "#4ECDC4",
    "description": "Updated work-related todo items"
  }' | jq '.'
```

### Phase 3: Todo Management Testing

#### Test 4: Todo CRUD Operations
```bash
./test-todos.sh
```

**Manual Todo Testing:**
```bash
# Create todo
TODO_RESPONSE=$(curl -s -X POST http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "Complete API Testing",
    "description": "Test all API endpoints thoroughly",
    "priority": "high",
    "dueDate": "2024-12-31",
    "categoryId": '$CATEGORY_ID'
  }')

TODO_ID=$(echo $TODO_RESPONSE | jq -r '.data.id')
echo "Todo ID: $TODO_ID"

# List todos with filters
curl -X GET "http://localhost:5000/api/todos?priority=high&completed=false" \
  -H "Authorization: Bearer $TOKEN" | jq '.'

# Update todo
curl -X PUT http://localhost:5000/api/todos/$TODO_ID \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "Updated API Testing Task",
    "description": "Updated description for API testing",
    "completed": false,
    "priority": "medium",
    "dueDate": "2024-12-25"
  }' | jq '.'

# Mark todo complete
curl -X PATCH http://localhost:5000/api/todos/$TODO_ID/complete \
  -H "Authorization: Bearer $TOKEN" | jq '.'
```

#### Test 5: Advanced Todo Operations
```bash
# Todo search
curl -X GET "http://localhost:5000/api/todos/search?q=testing&priority=high" \
  -H "Authorization: Bearer $TOKEN" | jq '.'

# Bulk operations
curl -X POST http://localhost:5000/api/todos/bulk \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "operation": "complete",
    "todoIds": [1, 2, 3]
  }' | jq '.'

# Pagination test
curl -X GET "http://localhost:5000/api/todos?page=1&limit=5&sortBy=createdAt&sortOrder=desc" \
  -H "Authorization: Bearer $TOKEN" | jq '.'
```

### Phase 4: User Profile Testing

#### Test 6: Profile Management
```bash
./test-users.sh
```

**Manual Profile Testing:**
```bash
# Get current profile
curl -X GET http://localhost:5000/api/users/profile \
  -H "Authorization: Bearer $TOKEN" | jq '.'

# Update profile
curl -X PUT http://localhost:5000/api/users/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "firstName": "Updated",
    "lastName": "TestUser",
    "email": "updated.testuser@example.com"
  }' | jq '.'

# Update preferences
curl -X PUT http://localhost:5000/api/users/preferences \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "theme": "dark",
    "language": "es",
    "notifications": false
  }' | jq '.'

# Get user statistics
curl -X GET http://localhost:5000/api/users/stats \
  -H "Authorization: Bearer $TOKEN" | jq '.'
```

### Phase 5: Database Layer Testing

#### Test 7: Direct JSON Server Access
```bash
./test-json-server.sh
```

**Manual JSON Server Testing:**
```bash
# Direct database operations
curl -X POST http://localhost:3001/users \
  -H "Content-Type: application/json" \
  -d '{
    "username": "directuser",
    "email": "direct@example.com",
    "password": "hashedpassword",
    "firstName": "Direct",
    "lastName": "User",
    "preferences": {
      "theme": "light",
      "language": "en",
      "notifications": true
    }
  }' | jq '.'

# Query with filters
curl "http://localhost:3001/todos?userId=1&completed=false" | jq '.'

# Relationship queries
curl "http://localhost:3001/users/1?_embed=todos" | jq '.'
curl "http://localhost:3001/todos/1?_expand=category" | jq '.'
```

### Phase 6: Swagger UI Interactive Testing

#### Test 8: Swagger UI Interface
1. **Open Swagger UI:** Navigate to `http://localhost:8080`
2. **Authenticate:**
   - Click "Authorize" button
   - Enter: `Bearer YOUR_TOKEN_HERE`
   - Click "Authorize"

3. **Test Authentication Endpoints:**
   - Try `POST /api/auth/register`
   - Try `POST /api/auth/login`
   - Try `GET /api/auth/me`

4. **Test CRUD Operations:**
   - Create categories via `POST /api/categories`
   - Create todos via `POST /api/todos`
   - Test filters with `GET /api/todos`
   - Update items with `PUT` operations

5. **Generate CURL Commands:**
   - Execute any request
   - Copy from "Curl" tab in response
   - Use generated commands in terminal

### Phase 7: Comprehensive Test Suite

#### Test 9: Run All Automated Tests
```bash
cd /workspaces/todo-reactjs-18/curl-scripts
./run-all-tests.sh
```

This executes:
- ✅ Authentication flow tests
- ✅ User management tests  
- ✅ Todo CRUD operations
- ✅ Category management tests
- ✅ JSON Server direct access
- ✅ Error handling validation
- ✅ Performance benchmarking

## Mock Data Examples

### Sample User Data
```json
{
  "username": "mockuser1",
  "email": "mockuser1@example.com",
  "password": "MockPass123!",
  "firstName": "Mock",
  "lastName": "User One",
  "preferences": {
    "theme": "dark",
    "language": "en",
    "notifications": true
  }
}
```

### Sample Category Data
```json
[
  {
    "name": "Personal",
    "color": "#FF6B6B",
    "description": "Personal tasks and reminders"
  },
  {
    "name": "Work", 
    "color": "#4ECDC4",
    "description": "Professional work items"
  },
  {
    "name": "Shopping",
    "color": "#45B7D1", 
    "description": "Shopping lists and purchases"
  }
]
```

### Sample Todo Data
```json
[
  {
    "title": "Complete API Documentation",
    "description": "Finish writing comprehensive API documentation",
    "priority": "high",
    "dueDate": "2024-12-31",
    "categoryId": 2,
    "completed": false
  },
  {
    "title": "Buy Groceries",
    "description": "Milk, bread, eggs, vegetables",
    "priority": "medium", 
    "dueDate": "2024-12-15",
    "categoryId": 3,
    "completed": false
  },
  {
    "title": "Schedule Doctor Appointment",
    "description": "Annual health checkup",
    "priority": "low",
    "dueDate": "2024-12-20",
    "categoryId": 1,
    "completed": true
  }
]
```

## Performance Testing

### Load Testing
```bash
# Test API under load (requires apache2-utils)
ab -n 100 -c 10 -H "Authorization: Bearer $TOKEN" \
  http://localhost:5000/api/todos

# Memory usage monitoring
while true; do
  ps aux | grep -E "(node|json-server)" | grep -v grep
  sleep 5
done
```

### Response Time Testing
```bash
# Measure API response times
time curl -s http://localhost:5000/api/health > /dev/null
time curl -s -H "Authorization: Bearer $TOKEN" \
  http://localhost:5000/api/todos > /dev/null
```

## Error Scenario Testing

### Test Authentication Failures
```bash
# Invalid credentials
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "nonexistent",
    "password": "wrongpassword"
  }' | jq '.'

# Expired/invalid token
curl -X GET http://localhost:5000/api/todos \
  -H "Authorization: Bearer invalid_token" | jq '.'
```

### Test Validation Errors
```bash
# Missing required fields
curl -X POST http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{}' | jq '.'

# Invalid email format
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "invalid-email",
    "password": "password"
  }' | jq '.'
```

### Test Rate Limiting
```bash
# Rapid requests to trigger rate limiting
for i in {1..10}; do
  curl -s http://localhost:5000/api/health -w "%{http_code}\n" -o /dev/null
done
```

## Monitoring and Logging

### Real-time Monitoring
```bash
# Monitor all server logs in real-time
tail -f /dev/null \
  <(cd /workspaces/todo-reactjs-18/Database && npm start 2>&1 | sed 's/^/[JSON-SERVER] /') \
  <(cd /workspaces/todo-reactjs-18/Back-End && npm start 2>&1 | sed 's/^/[EXPRESS-API] /') \
  <(cd /workspaces/todo-reactjs-18/swagger-ui && npm start 2>&1 | sed 's/^/[SWAGGER-UI] /')
```

### System Resource Monitoring
```bash
# Monitor system resources
watch -n 2 'echo "=== Process Status ===" && \
ps aux | grep -E "(node|json-server)" | grep -v grep && \
echo "=== Port Usage ===" && \
lsof -i :3001 :5000 :8080 && \
echo "=== Memory Usage ===" && \
free -h'
```

## Troubleshooting Guide

### Common Issues and Solutions

#### 1. Port Conflicts
```bash
# Identify processes using required ports
lsof -i :3001 :5000 :8080

# Kill specific processes
kill $(lsof -t -i :3001)
kill $(lsof -t -i :5000) 
kill $(lsof -t -i :8080)

# Or use the automated cleanup
./start-servers.sh
```

#### 2. Database Connection Issues
```bash
# Test JSON Server connectivity
curl http://localhost:3001/users

# Check JSON Server process
ps aux | grep json-server

# Restart JSON Server
cd /workspaces/todo-reactjs-18/Database
npm start
```

#### 3. Authentication Problems
```bash
# Verify JWT secret configuration
grep JWT_SECRET /workspaces/todo-reactjs-18/Back-End/.env

# Test authentication flow
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"password"}'
```

#### 4. CORS Issues
```bash
# Check CORS headers
curl -I -H "Origin: http://localhost:3000" \
  http://localhost:5000/api/health

# Verify Codespace environment
echo "CODESPACE_NAME: $CODESPACE_NAME"
echo "GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN: $GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN"
```

### Debug Mode Activation
```bash
# Enable debug logging for Express API
DEBUG=express:* cd /workspaces/todo-reactjs-18/Back-End && npm start

# Enable verbose JSON Server logging
cd /workspaces/todo-reactjs-18/Database && npm run start:dev
```

## Cleanup and Shutdown

### Graceful Shutdown
```bash
# If using automated script, use provided PIDs
kill $JSON_SERVER_PID $EXPRESS_SERVER_PID

# Or find and kill all processes
pkill -f "json-server"
pkill -f "node.*server.js"
pkill -f "proxy-server"
```

### Complete Cleanup
```bash
# Kill all node processes (careful!)
pkill -f node

# Verify ports are free
lsof -i :3001 :5000 :8080
```

### Data Reset
```bash
# Reset database to original state
cd /workspaces/todo-reactjs-18/Database
npm run reset

# Clear application logs
rm -f *.log
```

## Conclusion

This comprehensive guide provides everything needed to:
- ✅ Set up the complete Todo application environment
- ✅ Test all API endpoints with mock data
- ✅ Validate authentication and security features
- ✅ Perform end-to-end testing workflows
- ✅ Monitor system performance and health
- ✅ Troubleshoot common issues
- ✅ Generate automated test reports

The system is now ready for development, testing, and production deployment with full confidence in all operations and error handling scenarios.

## Additional Resources

- [JSON Server Guide](JSON_SERVER_GUIDE.md) - Detailed database layer documentation
- [Express API Guide](EXPRESS_API_GUIDE.md) - Comprehensive API documentation  
- [Swagger UI Guide](SWAGGER_UI_GUIDE.md) - Interactive testing documentation
- [CURL Scripts README](curl-scripts/README.md) - Automated testing documentation