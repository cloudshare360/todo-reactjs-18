# 📝 Todo App API Testing Scripts

This directory contains comprehensive CURL testing scripts for the Todo App REST API. These scripts provide systematic testing of all API endpoints including authentication, user management, todo operations, categories, and JSON Server functionality.

## 📋 Overview

The testing suite consists of modular scripts that test different aspects of the API:

- **Authentication & Security** - User registration, login, logout, password changes
- **User Management** - Profile updates, preferences, statistics, account operations
- **Todo Operations** - CRUD operations, bulk operations, status management, search
- **Category Management** - Category creation, todo relationships, statistics
- **JSON Server Testing** - Direct database access, relations, data integrity

## 🚀 Quick Start

### Prerequisites

Before running the tests, ensure both servers are running:

1. **Express API Server** (Port 5000):
   ```bash
   cd ../Back-End
   npm start
   ```

2. **JSON Server** (Port 3001):
   ```bash
   cd ../Database  
   npm start
   ```

### Run All Tests

```bash
# Make scripts executable
chmod +x *.sh

# Run complete test suite
./run-all-tests.sh

# Run specific test categories
./run-all-tests.sh --auth          # Authentication only
./run-all-tests.sh --users         # User management only
./run-all-tests.sh --todos         # Todo operations only
./run-all-tests.sh --categories    # Category management only
./run-all-tests.sh --json-server   # JSON Server tests only

# Run quick health check
./run-all-tests.sh --quick
```

## 📁 Script Files

### Core Testing Scripts

| Script | Purpose | Dependencies |
|--------|---------|--------------|
| `test-auth.sh` | Authentication endpoints testing | None (creates test user) |
| `test-users.sh` | User management operations | Requires valid token from auth |
| `test-todos.sh` | Todo CRUD and advanced operations | Requires valid token |
| `test-categories.sh` | Category management and relations | Requires valid token |
| `test-json-server.sh` | Direct JSON Server testing | JSON Server running |

### Utility Scripts

| Script | Purpose | Description |
|--------|---------|-------------|
| `run-all-tests.sh` | Master test runner | Orchestrates all test execution |

## 🔧 Individual Script Usage

### Authentication Tests (`test-auth.sh`)

Tests user authentication flows:

```bash
./test-auth.sh
```

**What it tests:**
- User registration with validation
- User login with credentials
- Profile access with JWT token
- Password change functionality  
- User logout
- Invalid login attempts
- Protected route access control

**Output:** Creates `/tmp/todo_app_token.txt` with authentication token for other tests.

### User Management Tests (`test-users.sh`)

Tests user profile and preference management:

```bash
# Requires authentication token from test-auth.sh
./test-users.sh
```

**What it tests:**
- Profile retrieval and updates
- User preferences management
- User statistics and activity
- Profile avatar upload (mock)
- Data export functionality
- Account deactivation
- Input validation

### Todo Management Tests (`test-todos.sh`)

Comprehensive todo operations testing:

```bash
./test-todos.sh
```

**What it tests:**
- Todo creation with categories
- Individual and bulk todo operations
- Status and progress updates
- Filtering and search functionality
- Priority and due date management
- Tag management
- File attachment handling (mock)
- Todo deletion and cleanup

### Category Management Tests (`test-categories.sh`)

Tests category system and todo relationships:

```bash
./test-categories.sh
```

**What it tests:**
- Category CRUD operations
- Category-todo relationships
- Category statistics and counts
- Todo movement between categories
- Category deletion with data integrity
- Search and filtering

### JSON Server Tests (`test-json-server.sh`)

Direct database layer testing:

```bash
./test-json-server.sh
```

**What it tests:**
- Direct JSON Server API access
- User-todo relationship management
- Data integrity and foreign keys
- Complex queries and filters
- Bulk operations
- Data cleanup and maintenance

## 🔍 Test Output and Results

### Success Indicators

- ✅ **Status 200/201**: Successful operations
- ✅ **Proper JSON responses**: Correctly formatted data
- ✅ **Token generation**: Authentication working
- ✅ **Data relationships**: Foreign keys maintained

### Error Handling

- ❌ **Status 400**: Validation errors (expected for invalid input tests)
- ❌ **Status 401**: Authentication failures (expected for protected routes)
- ❌ **Status 404**: Resource not found (expected for deleted items)
- ❌ **Status 500**: Server errors (investigate if unexpected)

### Token Management

The authentication script creates a temporary token file:
- **Location**: `/tmp/todo_app_token.txt`
- **Usage**: Automatically loaded by dependent scripts
- **Cleanup**: Removed after test completion

## 🛠️ Configuration

### Server URLs

Default configuration (modify in scripts if needed):

```bash
API_BASE="http://localhost:5000/api"
JSON_SERVER="http://localhost:3001"
```

### Test Data

Scripts create and cleanup their own test data:

- **Test User**: `test@example.com` / `TestPassword123!`
- **Categories**: Work, Personal, Shopping
- **Todos**: Various priorities and statuses
- **Relations**: User-todo associations

## 📊 Understanding Test Results

### Master Test Runner Output

The `run-all-tests.sh` script provides comprehensive reporting:

```
📊 Test Statistics:
   Total Tests: 5
   Passed: 5
   Failed: 0
   Success Rate: 100%

📋 Detailed Results:
   ✅ PASSED: Authentication Tests
   ✅ PASSED: User Management Tests
   ✅ PASSED: Todo Management Tests
   ✅ PASSED: Category Management Tests
   ✅ PASSED: JSON Server & Relations Tests
```

### Individual Script Results

Each script shows:
- **Colored output** for easy scanning
- **HTTP status codes** for each request
- **JSON responses** with actual data
- **Extracted IDs** for relationship testing
- **Progress indicators** throughout execution

## 🔧 Troubleshooting

### Common Issues

1. **Server Not Running**
   ```
   ❌ Express API Server is not running
   ```
   **Solution**: Start the backend server (`cd ../Back-End && npm start`)

2. **Authentication Token Issues**
   ```
   ❌ No token found. Please run test-auth.sh first
   ```
   **Solution**: Run authentication tests first or check token file

3. **Port Conflicts**
   ```
   curl: (7) Failed to connect to localhost port 5000
   ```
   **Solution**: Verify servers are running on correct ports

4. **Permission Errors**
   ```
   Permission denied: ./test-auth.sh
   ```
   **Solution**: Make scripts executable (`chmod +x *.sh`)

### Debug Mode

Add debug output to any script:

```bash
# Add at beginning of script
set -x  # Enable debug mode
```

### Manual Testing

Test individual endpoints manually:

```bash
# Health check
curl -X GET http://localhost:5000/api/health

# JSON Server status
curl -X GET http://localhost:3001/db
```

## 🚀 Advanced Usage

### Custom Test Scenarios

Create custom test scripts by copying and modifying existing ones:

```bash
cp test-auth.sh custom-test.sh
# Edit custom-test.sh for specific scenarios
```

### Integration with CI/CD

The master test runner returns appropriate exit codes:

```bash
# In CI pipeline
./run-all-tests.sh --quick
if [ $? -ne 0 ]; then
    echo "Tests failed!"
    exit 1
fi
```

### Performance Testing

Add timing to test scripts:

```bash
start_time=$(date +%s)
# ... run tests ...
end_time=$(date +%s)
echo "Test completed in $((end_time - start_time)) seconds"
```

## 📚 API Documentation

For detailed API specifications, see:
- **Swagger UI**: Open `../swagger-ui/index.html` in browser
- **API Spec**: `../swagger-ui/api-docs.yaml`
- **Backend Routes**: `../Back-End/routes/`

## 🤝 Contributing

When adding new test scripts:

1. Follow the naming convention: `test-[feature].sh`
2. Include comprehensive error handling
3. Add cleanup procedures
4. Update the master test runner
5. Document new tests in this README

---

**📧 Need Help?** Check the main project README or API documentation for additional details.