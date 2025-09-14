# Swagger UI Setup and Testing Guide

## Overview
The Swagger UI provides interactive API documentation and testing interface for the Todo application REST API. It runs on **port 8080** and acts as a proxy to the Express API server running on port 5000.

## Prerequisites
- Node.js (16+ recommended)
- npm package manager
- Express API server running on port 5000
- JSON Server running on port 3001
- Terminal access

## Directory Structure
```
swagger-ui/
├── index.html              # Main Swagger UI page
├── swagger.yaml            # API documentation specification
├── proxy-server.js         # Proxy server with CORS support
├── package.json            # Dependencies and scripts
├── dist/                   # Swagger UI static assets
│   ├── swagger-ui-bundle.js
│   ├── swagger-ui-standalone-preset.js
│   └── swagger-ui.css
└── config/
    └── swagger-config.js   # Swagger configuration
```

## Setup Instructions

### 1. Install Dependencies
```bash
cd /workspaces/todo-reactjs-18/swagger-ui
npm install
```

### 2. Verify API Specification
Check that `swagger.yaml` contains the complete API documentation:
- Authentication endpoints
- User management endpoints  
- Todo CRUD operations
- Category management
- Error response schemas

### 3. Start Swagger UI Server
```bash
npm start
```

**Alternative start methods:**
```bash
# Development mode with auto-reload
npm run dev

# Direct node execution
node proxy-server.js
```

### 4. Verify Server is Running
The server should start on port 8080. You'll see output like:
```
🌐 Swagger UI Proxy Server running on http://0.0.0.0:8080
📖 Swagger UI: http://localhost:8080
🔗 API Proxy: http://localhost:8080/api-proxy
❤️ Health Check: http://localhost:8080/proxy-health
🌍 External access: Available on GitHub Codespaces forwarded port
```

### 5. Access Swagger UI
Open your browser and navigate to:
- **Local Development:** `http://localhost:8080`
- **GitHub Codespaces:** Use the forwarded port URL (auto-detected)

## Features

### Interactive API Documentation
- Complete endpoint documentation with examples
- Request/response schemas with data types
- Authentication flow documentation
- Error code explanations
- Parameter validation rules

### Built-in API Testing
- **Try It Out** functionality for all endpoints
- Authentication token management
- Request customization and testing
- Response validation and formatting
- CURL command generation

### Dynamic CORS Support
- Automatic GitHub Codespaces detection
- Dynamic origin resolution
- Cross-origin request handling
- External client support

## Testing Workflow

### 1. Authentication Setup

#### Register New User
1. Navigate to **Authentication** section
2. Click on `POST /api/auth/register`
3. Click **"Try it out"**
4. Fill in the request body:
   ```json
   {
     "username": "swaggeruser",
     "email": "swagger@example.com",
     "password": "SecurePass123!",
     "firstName": "Swagger",
     "lastName": "User"
   }
   ```
5. Click **"Execute"**
6. **Copy the JWT token** from the response

#### Login Existing User  
1. Navigate to `POST /api/auth/login`
2. Click **"Try it out"**
3. Fill in credentials:
   ```json
   {
     "username": "swaggeruser",
     "password": "SecurePass123!"
   }
   ```
4. Click **"Execute"**
5. **Copy the JWT token** from the response

#### Authorize Swagger UI
1. Click the **"Authorize"** button at the top of the page
2. Enter the JWT token in the format: `Bearer YOUR_TOKEN_HERE`
3. Click **"Authorize"**
4. All subsequent requests will include authentication

### 2. Category Management Testing

#### Create Category
1. Navigate to `POST /api/categories`
2. Click **"Try it out"**
3. Fill in category data:
   ```json
   {
     "name": "Swagger Testing",
     "color": "#4ECDC4",
     "description": "Category created via Swagger UI"
   }
   ```
4. Click **"Execute"**
5. Note the category ID from the response

#### List Categories
1. Navigate to `GET /api/categories`
2. Click **"Try it out"**
3. Click **"Execute"**
4. Verify your category appears in the list

### 3. Todo Management Testing

#### Create Todo
1. Navigate to `POST /api/todos`
2. Click **"Try it out"**
3. Fill in todo data:
   ```json
   {
     "title": "Swagger UI Test Todo",
     "description": "Testing todo creation via Swagger UI",
     "priority": "high",
     "dueDate": "2024-12-31",
     "categoryId": 1
   }
   ```
4. Click **"Execute"**
5. Note the todo ID from the response

#### List Todos with Filters
1. Navigate to `GET /api/todos`
2. Click **"Try it out"**
3. Experiment with query parameters:
   - `completed`: `false`
   - `priority`: `high`
   - `page`: `1`
   - `limit`: `10`
4. Click **"Execute"**

#### Update Todo
1. Navigate to `PUT /api/todos/{id}`
2. Click **"Try it out"**
3. Enter the todo ID in the path parameter
4. Update the todo data:
   ```json
   {
     "title": "Updated Swagger Todo",
     "description": "Updated via Swagger UI",
     "completed": false,
     "priority": "medium",
     "dueDate": "2024-12-25"
   }
   ```
5. Click **"Execute"**

#### Mark Todo Complete
1. Navigate to `PATCH /api/todos/{id}/complete`
2. Click **"Try it out"**
3. Enter the todo ID
4. Click **"Execute"**

### 4. User Profile Testing

#### Get Profile
1. Navigate to `GET /api/users/profile`
2. Click **"Try it out"**
3. Click **"Execute"**

#### Update Profile
1. Navigate to `PUT /api/users/profile`
2. Click **"Try it out"**
3. Update profile data:
   ```json
   {
     "firstName": "Updated",
     "lastName": "SwaggerUser",
     "email": "updated-swagger@example.com"
   }
   ```
4. Click **"Execute"**

#### Update Preferences
1. Navigate to `PUT /api/users/preferences`
2. Click **"Try it out"**
3. Update preferences:
   ```json
   {
     "theme": "dark",
     "language": "en",
     "notifications": true
   }
   ```
4. Click **"Execute"**

### 5. Advanced Features Testing

#### Todo Search
1. Navigate to `GET /api/todos/search`
2. Click **"Try it out"**
3. Add search parameters:
   - `q`: `swagger`
   - `category`: `1`
   - `priority`: `high`
4. Click **"Execute"**

#### Bulk Operations
1. Navigate to `POST /api/todos/bulk`
2. Click **"Try it out"**
3. Perform bulk completion:
   ```json
   {
     "operation": "complete",
     "todoIds": [1, 2, 3]
   }
   ```
4. Click **"Execute"**

#### User Statistics
1. Navigate to `GET /api/users/stats`
2. Click **"Try it out"**
3. Click **"Execute"**

## CURL Command Generation

Swagger UI automatically generates CURL commands for each request:

1. Execute any API request in Swagger UI
2. Look for the **"Curl"** tab in the response section
3. Copy the generated CURL command
4. Use it in terminal or scripts

**Example generated CURL:**
```bash
curl -X 'POST' \
  'http://localhost:8080/api-proxy/api/todos' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' \
  -H 'Content-Type: application/json' \
  -d '{
  "title": "Swagger UI Test Todo",
  "description": "Testing todo creation via Swagger UI",
  "priority": "high",
  "dueDate": "2024-12-31",
  "categoryId": 1
}'
```

## Health Checks and Diagnostics

### Proxy Health Check
```bash
curl http://localhost:8080/proxy-health
```

**Expected Response:**
```json
{
  "status": "OK",
  "message": "Swagger UI Proxy Server",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "apiTarget": "http://localhost:5000"
}
```

### API Connection Test
```bash
curl http://localhost:8080/api-proxy/api/health
```

This tests the proxy connection to the Express API server.

## Advanced Configuration

### Custom API Base URL
Modify `swagger.yaml` to change the API server:
```yaml
servers:
  - url: http://localhost:8080/api-proxy
    description: Local development server via proxy
  - url: https://your-codespace-5000.app.github.dev
    description: Direct GitHub Codespaces API access
```

### Swagger UI Customization
Edit `index.html` to customize:
- Theme and styling
- Plugin configuration
- Default authorization
- Request interceptors

### Proxy Configuration
Modify `proxy-server.js` for:
- Different API target URLs
- Custom headers
- Request/response transformation
- Additional middleware

## Security Features

### CORS Protection
- Automatic origin detection
- GitHub Codespaces support
- Configurable allowed origins
- Credential handling

### JWT Token Management
- Secure token storage in UI
- Automatic header inclusion
- Token expiration handling
- Refresh token support

### Request Validation
- Schema validation before sending
- Parameter type checking
- Required field validation
- Format validation

## Troubleshooting

### Common Issues

1. **Swagger UI Won't Load**
   ```bash
   # Check server status
   curl http://localhost:8080/proxy-health
   
   # Verify static files
   ls -la /workspaces/todo-reactjs-18/swagger-ui/dist/
   ```

2. **API Requests Failing**
   ```bash
   # Test direct API connection
   curl http://localhost:5000/api/health
   
   # Test proxy connection
   curl http://localhost:8080/api-proxy/api/health
   ```

3. **Authentication Issues**
   - Verify JWT token format (should start with `Bearer `)
   - Check token expiration
   - Ensure Express API server is running
   - Test authentication directly:
     ```bash
     curl -X POST http://localhost:5000/api/auth/login \
       -H "Content-Type: application/json" \
       -d '{"username":"test","password":"password"}'
     ```

4. **CORS Errors**
   - Check browser console for CORS messages
   - Verify Codespace environment variables
   - Test with different origins

5. **Slow Response Times**
   - Check Express API server performance
   - Monitor JSON Server status
   - Verify network connectivity

### Debug Mode
Enable detailed logging by modifying `proxy-server.js`:
```javascript
logLevel: 'debug'  // Change from 'info' to 'debug'
```

### Browser Developer Tools
Use browser DevTools to:
- Monitor network requests
- Check console for errors  
- Inspect request/response headers
- Verify CORS policy compliance

## Performance Optimization

### Caching
- Static asset caching
- API response caching (where appropriate)
- Browser cache optimization

### Connection Management
- Keep-alive connections
- Connection pooling
- Timeout configuration

### Resource Optimization
- Minified static assets
- Gzip compression
- Efficient proxy routing

## Integration with Development Workflow

### Automated Testing
Use Swagger UI for:
- Manual API testing during development
- Generating test cases from examples
- Validating API responses
- Creating integration test scenarios

### Documentation Maintenance
- Keep `swagger.yaml` updated with API changes
- Add examples for all endpoints
- Document error scenarios
- Include authentication requirements

### Team Collaboration
- Share API documentation via Swagger UI
- Collaborative testing sessions
- API contract validation
- Client SDK generation

## Next Steps
After setting up Swagger UI, proceed to:
1. [Master Startup Guide](STARTUP_GUIDE.md) - Complete system startup
2. [Express API Guide](EXPRESS_API_GUIDE.md) - Detailed API documentation
3. [JSON Server Guide](JSON_SERVER_GUIDE.md) - Database layer details

## Additional Resources
- [Swagger UI Documentation](https://swagger.io/tools/swagger-ui/)
- [OpenAPI 3.0 Specification](https://spec.openapis.org/oas/v3.0.3)
- [JWT Authentication Best Practices](https://auth0.com/blog/a-look-at-the-latest-draft-for-jwt-bcp/)
- [Express.js CORS Configuration](https://expressjs.com/en/resources/middleware/cors.html)