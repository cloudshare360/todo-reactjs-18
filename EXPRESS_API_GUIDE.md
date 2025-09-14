# Express REST API Setup and Testing Guide

## Overview
The Express REST API serves as the main business logic layer for the Todo application. It runs on **port 5000** and provides authenticated endpoints with JWT tokens, rate limiting, and comprehensive CRUD operations.

## Prerequisites
- Node.js (16+ recommended)
- npm package manager
- JSON Server running on port 3001
- Terminal access

## Directory Structure
```
Back-End/
├── src/
│   ├── server.js              # Main server file
│   ├── routes/
│   │   ├── auth.js            # Authentication routes
│   │   ├── users.js           # User management routes
│   │   ├── todos.js           # Todo CRUD routes
│   │   └── categories.js      # Category management routes
│   ├── middleware/
│   │   ├── auth.js            # JWT authentication middleware
│   │   ├── validation.js      # Request validation
│   │   └── rateLimiting.js    # Rate limiting configuration
│   ├── services/
│   │   └── database.js        # Database abstraction layer
│   └── utils/
│       └── helpers.js         # Utility functions
├── package.json               # Dependencies and scripts
└── .env                       # Environment configuration
```

## Setup Instructions

### 1. Install Dependencies
```bash
cd /workspaces/todo-reactjs-18/Back-End
npm install
```

### 2. Environment Configuration
Create or verify `.env` file:
```bash
# Server Configuration
PORT=5000
NODE_ENV=development

# Database Configuration  
DATABASE_URL=http://localhost:3001

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRES_IN=7d

# Rate Limiting
RATE_LIMIT_WINDOW=15
RATE_LIMIT_MAX_REQUESTS=100

# CORS Configuration (auto-detected for Codespaces)
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

### 3. Start Express Server

#### Option A: Production Mode
```bash
npm start
```

#### Option B: Development Mode (with nodemon)
```bash
npm run dev
```

### 4. Verify Server is Running
The server should start on port 5000. You'll see output like:
```
🚀 Express API Server starting...
🔗 Express API: Detected GitHub Codespace environment
🌐 Server running on http://0.0.0.0:5000
📊 Database: Connected to JSON Server at http://localhost:3001
🔒 JWT Authentication: Enabled
⚡ Rate Limiting: 100 requests per 15 minutes
🌍 CORS: Configured for external access
✅ Server ready for requests!
```

## API Endpoints Overview

### Authentication Endpoints (`/api/auth`)
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/refresh` - Refresh JWT token
- `POST /api/auth/logout` - User logout
- `GET /api/auth/me` - Get current user info

### User Management (`/api/users`)
- `GET /api/users/profile` - Get user profile
- `PUT /api/users/profile` - Update user profile
- `PUT /api/users/preferences` - Update user preferences
- `DELETE /api/users/account` - Delete user account
- `GET /api/users/stats` - Get user statistics

### Todo Management (`/api/todos`)
- `GET /api/todos` - Get user's todos (with filters)
- `POST /api/todos` - Create new todo
- `GET /api/todos/:id` - Get specific todo
- `PUT /api/todos/:id` - Update todo
- `DELETE /api/todos/:id` - Delete todo
- `PATCH /api/todos/:id/complete` - Mark todo as complete
- `POST /api/todos/bulk` - Bulk operations
- `GET /api/todos/search` - Advanced search

### Category Management (`/api/categories`)
- `GET /api/categories` - Get user's categories
- `POST /api/categories` - Create new category
- `GET /api/categories/:id` - Get specific category
- `PUT /api/categories/:id` - Update category
- `DELETE /api/categories/:id` - Delete category
- `GET /api/categories/:id/todos` - Get todos in category

## Testing with CURL Scripts

### 1. User Registration
```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testapi",
    "email": "testapi@example.com",
    "password": "SecurePass123!",
    "firstName": "Test",
    "lastName": "API"
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": 1,
      "username": "testapi",
      "email": "testapi@example.com",
      "firstName": "Test",
      "lastName": "API"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### 2. User Login
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testapi",
    "password": "SecurePass123!"
  }'
```

**Save the token for subsequent requests:**
```bash
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### 3. Create Category (Authenticated)
```bash
curl -X POST http://localhost:5000/api/categories \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "API Testing",
    "color": "#FF6B6B",
    "description": "Category for API testing"
  }'
```

### 4. Create Todo (Authenticated)
```bash
curl -X POST http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "Test Express API Todo",
    "description": "Testing the Express API endpoints",
    "priority": "high",
    "dueDate": "2024-12-31",
    "categoryId": 1
  }'
```

### 5. Get User's Todos with Filters
```bash
# Get all todos
curl -X GET "http://localhost:5000/api/todos" \
  -H "Authorization: Bearer $TOKEN"

# Get completed todos
curl -X GET "http://localhost:5000/api/todos?completed=true" \
  -H "Authorization: Bearer $TOKEN"

# Get todos by priority
curl -X GET "http://localhost:5000/api/todos?priority=high" \
  -H "Authorization: Bearer $TOKEN"

# Get todos with pagination
curl -X GET "http://localhost:5000/api/todos?page=1&limit=5" \
  -H "Authorization: Bearer $TOKEN"

# Get todos sorted by due date
curl -X GET "http://localhost:5000/api/todos?sortBy=dueDate&sortOrder=asc" \
  -H "Authorization: Bearer $TOKEN"
```

### 6. Update Todo
```bash
curl -X PUT http://localhost:5000/api/todos/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "Updated API Todo",
    "description": "Updated through Express API",
    "completed": false,
    "priority": "medium",
    "dueDate": "2024-12-25"
  }'
```

### 7. Mark Todo Complete
```bash
curl -X PATCH http://localhost:5000/api/todos/1/complete \
  -H "Authorization: Bearer $TOKEN"
```

### 8. Advanced Todo Search
```bash
curl -X GET "http://localhost:5000/api/todos/search?q=testing&category=1&priority=high" \
  -H "Authorization: Bearer $TOKEN"
```

### 9. Bulk Todo Operations
```bash
curl -X POST http://localhost:5000/api/todos/bulk \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "operation": "complete",
    "todoIds": [1, 2, 3]
  }'
```

### 10. Update User Profile
```bash
curl -X PUT http://localhost:5000/api/users/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "firstName": "Updated",
    "lastName": "Name",
    "email": "updated@example.com"
  }'
```

### 11. Update User Preferences
```bash
curl -X PUT http://localhost:5000/api/users/preferences \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "theme": "dark",
    "language": "es",
    "notifications": false
  }'
```

### 12. Get User Statistics
```bash
curl -X GET http://localhost:5000/api/users/stats \
  -H "Authorization: Bearer $TOKEN"
```

## Automated Testing Scripts

### Run Authentication Tests
```bash
cd /workspaces/todo-reactjs-18/curl-scripts
./test-auth.sh
```

### Run User Management Tests
```bash
./test-users.sh
```

### Run Todo Management Tests
```bash
./test-todos.sh
```

### Run Category Tests
```bash
./test-categories.sh
```

### Run All API Tests
```bash
./run-all-tests.sh
```

## Authentication & Security Features

### JWT Authentication
- Secure token-based authentication
- 7-day token expiration (configurable)
- Automatic token refresh capability
- Password hashing with bcrypt

### Rate Limiting
- 100 requests per 15-minute window per IP
- Configurable limits in environment variables
- Graceful error responses when limit exceeded

### Request Validation
- Input sanitization and validation
- Email format validation
- Password strength requirements
- Required field validation

### CORS Configuration
- Dynamic origin detection for GitHub Codespaces
- Configurable allowed origins
- Credentials support for authenticated requests

## Error Handling

The API provides structured error responses:

```json
{
  "success": false,
  "error": "Validation Error",
  "message": "Username is required",
  "details": {
    "field": "username",
    "code": "REQUIRED_FIELD"
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### Common Error Codes
- `400` - Bad Request (validation errors)
- `401` - Unauthorized (authentication required)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found (resource doesn't exist)
- `429` - Too Many Requests (rate limit exceeded)
- `500` - Internal Server Error

## Monitoring and Health Checks

### Health Check Endpoint
```bash
curl http://localhost:5000/api/health
```

**Response:**
```json
{
  "status": "OK",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "uptime": "2h 15m 30s",
  "version": "1.0.0",
  "database": "Connected",
  "memory": {
    "used": "45.2 MB",
    "free": "1.2 GB"
  }
}
```

### API Status Endpoint
```bash
curl http://localhost:5000/api/status
```

## Performance Optimization

### Database Connection Pooling
- Efficient connection reuse to JSON Server
- Automatic retry on connection failures
- Connection timeout handling

### Request Optimization
- Efficient query processing
- Optimized database queries
- Response caching where appropriate

### Memory Management
- Proper resource cleanup
- Memory leak prevention
- Garbage collection optimization

## Troubleshooting

### Common Issues

1. **Server Won't Start**
   ```bash
   # Check if port is in use
   lsof -i :5000
   # Kill existing process
   lsof -ti :5000 | xargs kill
   ```

2. **Database Connection Failed**
   ```bash
   # Verify JSON Server is running
   curl http://localhost:3001/users
   # Check database service status
   curl http://localhost:5000/api/health
   ```

3. **Authentication Issues**
   ```bash
   # Check JWT token validity
   curl http://localhost:5000/api/auth/me \
     -H "Authorization: Bearer $TOKEN"
   ```

4. **CORS Issues**
   - Check that client origin is in allowed list
   - Verify CODESPACE environment variables are set
   - Check browser console for CORS errors

5. **Rate Limiting**
   ```bash
   # Check current rate limit status
   curl -I http://localhost:5000/api/todos \
     -H "Authorization: Bearer $TOKEN"
   # Look for X-RateLimit-* headers
   ```

### Debug Mode
Enable debug logging by setting:
```bash
DEBUG=express:* npm start
```

## Development Notes

- The API automatically detects and configures for GitHub Codespaces
- All endpoints require JWT authentication except health checks
- Database operations are atomic and include error recovery
- Request validation prevents malformed data from reaching the database
- Rate limiting helps prevent abuse and ensures fair resource usage

## Next Steps
After setting up the Express API, proceed to:
1. [Swagger UI Setup Guide](SWAGGER_UI_GUIDE.md)
2. [Master Startup Guide](STARTUP_GUIDE.md)
3. [JSON Server Guide](JSON_SERVER_GUIDE.md) (if not already completed)