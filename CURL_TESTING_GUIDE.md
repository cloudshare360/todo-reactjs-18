# CURL Testing Guide - Complete API Verification

## Overview
This guide provides comprehensive instructions for using CURL scripts with mock data to verify all API endpoints in the Todo application. It includes step-by-step testing procedures, mock data examples, and endpoint verification strategies.

## Prerequisites

### System Requirements
- **CURL**: Command-line tool for HTTP requests
- **jq**: JSON processor for formatting responses (recommended)
- **All servers running**:
  - JSON Server (port 3001)
  - Express API (port 5000)
  - Swagger UI (port 8080)

### Installation Check
```bash
# Verify CURL is installed
curl --version

# Verify jq is installed (for JSON formatting)
jq --version

# If jq is not installed:
sudo apt-get update && sudo apt-get install jq
```

### Server Status Verification
```bash
# Check all servers are running
curl -s http://localhost:3001/users | head -1        # JSON Server
curl -s http://localhost:5000/api/health | jq '.'   # Express API
curl -s http://localhost:8080/proxy-health | jq '.' # Swagger UI
```

## Testing Workflow Overview

### Phase 1: Authentication Testing
1. User Registration
2. User Login  
3. Token Validation
4. Authentication Error Scenarios

### Phase 2: User Management Testing
1. Profile Retrieval
2. Profile Updates
3. Preferences Management
4. User Statistics

### Phase 3: Category Management Testing
1. Category Creation
2. Category Listing
3. Category Updates
4. Category Deletion

### Phase 4: Todo Management Testing
1. Todo Creation
2. Todo Retrieval with Filters
3. Todo Updates
4. Todo Status Changes
5. Bulk Operations
6. Advanced Search

### Phase 5: Database Layer Testing
1. Direct JSON Server Access
2. Relationship Queries
3. Pagination and Sorting
4. Data Validation

## Mock Data Preparation

### User Mock Data
```bash
# Generate unique usernames to avoid conflicts
TIMESTAMP=$(date +%s)
USERNAME="testuser_${TIMESTAMP}"
EMAIL="test_${TIMESTAMP}@example.com"

echo "Generated Test User:"
echo "Username: $USERNAME"
echo "Email: $EMAIL"
```

### Category Mock Data
```json
{
  "name": "Work Tasks",
  "color": "#FF6B6B",
  "description": "Professional work-related tasks"
}
```

### Todo Mock Data
```json
{
  "title": "Complete API Testing",
  "description": "Comprehensive testing of all API endpoints with CURL",
  "priority": "high",
  "dueDate": "2024-12-31",
  "categoryId": 1
}
```

## Phase 1: Authentication Testing

### Test 1.1: User Registration
```bash
# Generate unique user data
TIMESTAMP=$(date +%s)
USERNAME="testuser_${TIMESTAMP}"
EMAIL="test_${TIMESTAMP}@example.com"

echo "=== TEST 1.1: User Registration ==="
REGISTER_RESPONSE=$(curl -s -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d "{
    \"username\": \"${USERNAME}\",
    \"email\": \"${EMAIL}\",
    \"password\": \"SecurePass123!\",
    \"firstName\": \"Test\",
    \"lastName\": \"User\"
  }")

echo "Registration Response:"
echo $REGISTER_RESPONSE | jq '.'

# Extract and save token
TOKEN=$(echo $REGISTER_RESPONSE | jq -r '.data.token // empty')
USER_ID=$(echo $REGISTER_RESPONSE | jq -r '.data.user.id // empty')

if [ "$TOKEN" != "" ] && [ "$TOKEN" != "null" ]; then
    echo "✅ Registration successful - Token: ${TOKEN:0:20}..."
    echo "User ID: $USER_ID"
else
    echo "❌ Registration failed"
    echo $REGISTER_RESPONSE | jq '.error // .message'
fi
```

### Test 1.2: User Login
```bash
echo -e "\n=== TEST 1.2: User Login ==="
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{
    \"username\": \"${USERNAME}\",
    \"password\": \"SecurePass123!\"
  }")

echo "Login Response:"
echo $LOGIN_RESPONSE | jq '.'

# Update token from login
TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.data.token // empty')

if [ "$TOKEN" != "" ] && [ "$TOKEN" != "null" ]; then
    echo "✅ Login successful - Token updated"
else
    echo "❌ Login failed"
fi
```

### Test 1.3: Token Validation
```bash
echo -e "\n=== TEST 1.3: Token Validation ==="
AUTH_CHECK=$(curl -s -X GET http://localhost:5000/api/auth/me \
  -H "Authorization: Bearer $TOKEN")

echo "Token Validation Response:"
echo $AUTH_CHECK | jq '.'

if echo $AUTH_CHECK | jq -e '.success' > /dev/null; then
    echo "✅ Token validation successful"
else
    echo "❌ Token validation failed"
fi
```

### Test 1.4: Authentication Error Scenarios
```bash
echo -e "\n=== TEST 1.4: Authentication Error Scenarios ==="

# Test invalid credentials
echo "Testing invalid credentials:"
curl -s -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"nonexistent","password":"wrongpass"}' | jq '.'

# Test invalid token
echo -e "\nTesting invalid token:"
curl -s -X GET http://localhost:5000/api/auth/me \
  -H "Authorization: Bearer invalid_token" | jq '.'

# Test missing token
echo -e "\nTesting missing token:"
curl -s -X GET http://localhost:5000/api/auth/me | jq '.'
```

## Phase 2: User Management Testing

### Test 2.1: Get User Profile
```bash
echo -e "\n=== TEST 2.1: Get User Profile ==="
PROFILE_RESPONSE=$(curl -s -X GET http://localhost:5000/api/users/profile \
  -H "Authorization: Bearer $TOKEN")

echo "Profile Response:"
echo $PROFILE_RESPONSE | jq '.'

if echo $PROFILE_RESPONSE | jq -e '.success' > /dev/null; then
    echo "✅ Profile retrieval successful"
else
    echo "❌ Profile retrieval failed"
fi
```

### Test 2.2: Update User Profile
```bash
echo -e "\n=== TEST 2.2: Update User Profile ==="
UPDATE_PROFILE=$(curl -s -X PUT http://localhost:5000/api/users/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "firstName": "Updated",
    "lastName": "TestUser",
    "email": "'${EMAIL}'"
  }')

echo "Profile Update Response:"
echo $UPDATE_PROFILE | jq '.'

if echo $UPDATE_PROFILE | jq -e '.success' > /dev/null; then
    echo "✅ Profile update successful"
else
    echo "❌ Profile update failed"
fi
```

### Test 2.3: Update User Preferences
```bash
echo -e "\n=== TEST 2.3: Update User Preferences ==="
UPDATE_PREFS=$(curl -s -X PUT http://localhost:5000/api/users/preferences \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "theme": "dark",
    "language": "en",
    "notifications": true
  }')

echo "Preferences Update Response:"
echo $UPDATE_PREFS | jq '.'

if echo $UPDATE_PREFS | jq -e '.success' > /dev/null; then
    echo "✅ Preferences update successful"
else
    echo "❌ Preferences update failed"
fi
```

### Test 2.4: Get User Statistics
```bash
echo -e "\n=== TEST 2.4: Get User Statistics ==="
USER_STATS=$(curl -s -X GET http://localhost:5000/api/users/stats \
  -H "Authorization: Bearer $TOKEN")

echo "User Statistics Response:"
echo $USER_STATS | jq '.'

if echo $USER_STATS | jq -e '.success' > /dev/null; then
    echo "✅ User statistics retrieval successful"
else
    echo "❌ User statistics retrieval failed"
fi
```

## Phase 3: Category Management Testing

### Test 3.1: Create Category
```bash
echo -e "\n=== TEST 3.1: Create Category ==="
CREATE_CATEGORY=$(curl -s -X POST http://localhost:5000/api/categories \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Work Tasks",
    "color": "#FF6B6B", 
    "description": "Professional work-related tasks"
  }')

echo "Category Creation Response:"
echo $CREATE_CATEGORY | jq '.'

CATEGORY_ID=$(echo $CREATE_CATEGORY | jq -r '.data.id // empty')

if [ "$CATEGORY_ID" != "" ] && [ "$CATEGORY_ID" != "null" ]; then
    echo "✅ Category creation successful - ID: $CATEGORY_ID"
else
    echo "❌ Category creation failed"
fi
```

### Test 3.2: List Categories
```bash
echo -e "\n=== TEST 3.2: List Categories ==="
LIST_CATEGORIES=$(curl -s -X GET http://localhost:5000/api/categories \
  -H "Authorization: Bearer $TOKEN")

echo "Categories List Response:"
echo $LIST_CATEGORIES | jq '.'

if echo $LIST_CATEGORIES | jq -e '.success' > /dev/null; then
    echo "✅ Categories listing successful"
else
    echo "❌ Categories listing failed"
fi
```

### Test 3.3: Update Category
```bash
echo -e "\n=== TEST 3.3: Update Category ==="
if [ "$CATEGORY_ID" != "" ] && [ "$CATEGORY_ID" != "null" ]; then
    UPDATE_CATEGORY=$(curl -s -X PUT http://localhost:5000/api/categories/$CATEGORY_ID \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d '{
        "name": "Updated Work Tasks",
        "color": "#4ECDC4",
        "description": "Updated work-related tasks description"
      }')
    
    echo "Category Update Response:"
    echo $UPDATE_CATEGORY | jq '.'
    
    if echo $UPDATE_CATEGORY | jq -e '.success' > /dev/null; then
        echo "✅ Category update successful"
    else
        echo "❌ Category update failed"
    fi
else
    echo "⚠️  Skipping category update - no category ID available"
fi
```

### Test 3.4: Get Category Details
```bash
echo -e "\n=== TEST 3.4: Get Category Details ==="
if [ "$CATEGORY_ID" != "" ] && [ "$CATEGORY_ID" != "null" ]; then
    GET_CATEGORY=$(curl -s -X GET http://localhost:5000/api/categories/$CATEGORY_ID \
      -H "Authorization: Bearer $TOKEN")
    
    echo "Category Details Response:"
    echo $GET_CATEGORY | jq '.'
    
    if echo $GET_CATEGORY | jq -e '.success' > /dev/null; then
        echo "✅ Category retrieval successful"
    else
        echo "❌ Category retrieval failed"
    fi
else
    echo "⚠️  Skipping category retrieval - no category ID available"
fi
```

## Phase 4: Todo Management Testing

### Test 4.1: Create Todo
```bash
echo -e "\n=== TEST 4.1: Create Todo ==="
CREATE_TODO=$(curl -s -X POST http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"title\": \"Complete API Testing\",
    \"description\": \"Comprehensive testing of all API endpoints with CURL\",
    \"priority\": \"high\",
    \"dueDate\": \"2024-12-31\",
    \"categoryId\": ${CATEGORY_ID:-1}
  }")

echo "Todo Creation Response:"
echo $CREATE_TODO | jq '.'

TODO_ID=$(echo $CREATE_TODO | jq -r '.data.id // empty')

if [ "$TODO_ID" != "" ] && [ "$TODO_ID" != "null" ]; then
    echo "✅ Todo creation successful - ID: $TODO_ID"
else
    echo "❌ Todo creation failed"
fi
```

### Test 4.2: List Todos with Filters
```bash
echo -e "\n=== TEST 4.2: List Todos with Filters ==="

# Test basic listing
echo "Basic todo listing:"
curl -s -X GET "http://localhost:5000/api/todos" \
  -H "Authorization: Bearer $TOKEN" | jq '.'

# Test with priority filter
echo -e "\nTodos filtered by priority (high):"
curl -s -X GET "http://localhost:5000/api/todos?priority=high" \
  -H "Authorization: Bearer $TOKEN" | jq '.'

# Test with completion status filter
echo -e "\nTodos filtered by completion status (incomplete):"
curl -s -X GET "http://localhost:5000/api/todos?completed=false" \
  -H "Authorization: Bearer $TOKEN" | jq '.'

# Test with pagination
echo -e "\nTodos with pagination (page 1, limit 5):"
curl -s -X GET "http://localhost:5000/api/todos?page=1&limit=5" \
  -H "Authorization: Bearer $TOKEN" | jq '.'

# Test with sorting
echo -e "\nTodos sorted by creation date (descending):"
curl -s -X GET "http://localhost:5000/api/todos?sortBy=createdAt&sortOrder=desc" \
  -H "Authorization: Bearer $TOKEN" | jq '.'
```

### Test 4.3: Update Todo
```bash
echo -e "\n=== TEST 4.3: Update Todo ==="
if [ "$TODO_ID" != "" ] && [ "$TODO_ID" != "null" ]; then
    UPDATE_TODO=$(curl -s -X PUT http://localhost:5000/api/todos/$TODO_ID \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d '{
        "title": "Updated API Testing Task",
        "description": "Updated comprehensive testing of all API endpoints",
        "completed": false,
        "priority": "medium",
        "dueDate": "2024-12-25"
      }')
    
    echo "Todo Update Response:"
    echo $UPDATE_TODO | jq '.'
    
    if echo $UPDATE_TODO | jq -e '.success' > /dev/null; then
        echo "✅ Todo update successful"
    else
        echo "❌ Todo update failed"
    fi
else
    echo "⚠️  Skipping todo update - no todo ID available"
fi
```

### Test 4.4: Mark Todo Complete
```bash
echo -e "\n=== TEST 4.4: Mark Todo Complete ==="
if [ "$TODO_ID" != "" ] && [ "$TODO_ID" != "null" ]; then
    COMPLETE_TODO=$(curl -s -X PATCH http://localhost:5000/api/todos/$TODO_ID/complete \
      -H "Authorization: Bearer $TOKEN")
    
    echo "Todo Completion Response:"
    echo $COMPLETE_TODO | jq '.'
    
    if echo $COMPLETE_TODO | jq -e '.success' > /dev/null; then
        echo "✅ Todo completion successful"
    else
        echo "❌ Todo completion failed"
    fi
else
    echo "⚠️  Skipping todo completion - no todo ID available"
fi
```

### Test 4.5: Advanced Todo Search
```bash
echo -e "\n=== TEST 4.5: Advanced Todo Search ==="
SEARCH_TODOS=$(curl -s -X GET "http://localhost:5000/api/todos/search?q=testing&priority=high" \
  -H "Authorization: Bearer $TOKEN")

echo "Todo Search Response:"
echo $SEARCH_TODOS | jq '.'

if echo $SEARCH_TODOS | jq -e '.success' > /dev/null; then
    echo "✅ Todo search successful"
else
    echo "❌ Todo search failed"
fi
```

### Test 4.6: Bulk Todo Operations
```bash
echo -e "\n=== TEST 4.6: Bulk Todo Operations ==="
# Create additional todos for bulk testing
TODO_IDS=()

for i in {1..3}; do
    BULK_TODO=$(curl -s -X POST http://localhost:5000/api/todos \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d "{
        \"title\": \"Bulk Test Todo $i\",
        \"description\": \"Todo created for bulk operations testing\",
        \"priority\": \"low\",
        \"dueDate\": \"2024-12-20\"
      }")
    
    BULK_ID=$(echo $BULK_TODO | jq -r '.data.id // empty')
    if [ "$BULK_ID" != "" ] && [ "$BULK_ID" != "null" ]; then
        TODO_IDS+=($BULK_ID)
    fi
done

if [ ${#TODO_IDS[@]} -gt 0 ]; then
    # Convert array to JSON array format
    IDS_JSON=$(printf '%s\n' "${TODO_IDS[@]}" | jq -R . | jq -s .)
    
    BULK_OPERATION=$(curl -s -X POST http://localhost:5000/api/todos/bulk \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d "{
        \"operation\": \"complete\",
        \"todoIds\": $IDS_JSON
      }")
    
    echo "Bulk Operation Response:"
    echo $BULK_OPERATION | jq '.'
    
    if echo $BULK_OPERATION | jq -e '.success' > /dev/null; then
        echo "✅ Bulk operation successful"
    else
        echo "❌ Bulk operation failed"
    fi
else
    echo "⚠️  Skipping bulk operations - no todos created for testing"
fi
```

## Phase 5: Database Layer Testing

### Test 5.1: Direct JSON Server Access
```bash
echo -e "\n=== TEST 5.1: Direct JSON Server Access ==="

# Test user creation directly in JSON Server
echo "Creating user directly in JSON Server:"
DIRECT_USER=$(curl -s -X POST http://localhost:3001/users \
  -H "Content-Type: application/json" \
  -d '{
    "username": "directuser_'$(date +%s)'",
    "email": "direct'$(date +%s)'@example.com",
    "password": "hashedpassword123",
    "firstName": "Direct",
    "lastName": "User",
    "preferences": {
      "theme": "light",
      "language": "en",
      "notifications": true
    }
  }')

echo $DIRECT_USER | jq '.'

DIRECT_USER_ID=$(echo $DIRECT_USER | jq -r '.id // empty')
echo "Direct User ID: $DIRECT_USER_ID"

# Test todo creation directly in JSON Server
echo -e "\nCreating todo directly in JSON Server:"
curl -s -X POST http://localhost:3001/todos \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Direct JSON Server Todo\",
    \"description\": \"Todo created directly in JSON Server\",
    \"completed\": false,
    \"priority\": \"medium\",
    \"userId\": $DIRECT_USER_ID,
    \"dueDate\": \"2024-12-31\"
  }" | jq '.'
```

### Test 5.2: Relationship Queries
```bash
echo -e "\n=== TEST 5.2: Relationship Queries ==="

if [ "$DIRECT_USER_ID" != "" ] && [ "$DIRECT_USER_ID" != "null" ]; then
    # Get user with embedded todos
    echo "User with embedded todos:"
    curl -s "http://localhost:3001/users/$DIRECT_USER_ID?_embed=todos" | jq '.'
    
    # Get todos for specific user
    echo -e "\nTodos for specific user:"
    curl -s "http://localhost:3001/todos?userId=$DIRECT_USER_ID" | jq '.'
else
    echo "⚠️  Skipping relationship queries - no direct user ID available"
fi

# Test category expansion
echo -e "\nTodos with expanded category information:"
curl -s "http://localhost:3001/todos?_expand=category" | jq '.'
```

### Test 5.3: Advanced JSON Server Queries
```bash
echo -e "\n=== TEST 5.3: Advanced JSON Server Queries ==="

# Full text search
echo "Full text search for 'testing':"
curl -s "http://localhost:3001/todos?q=testing" | jq '.'

# Multiple conditions
echo -e "\nMultiple conditions (completed=false AND priority=high):"
curl -s "http://localhost:3001/todos?completed=false&priority=high" | jq '.'

# Pagination with JSON Server
echo -e "\nPagination (page 1, limit 3):"
curl -s "http://localhost:3001/todos?_page=1&_limit=3" | jq '.'

# Sorting
echo -e "\nSorted by creation date (newest first):"
curl -s "http://localhost:3001/todos?_sort=createdAt&_order=desc" | jq '.'

# Field selection
echo -e "\nTodos with only title and completed fields:"
curl -s "http://localhost:3001/todos?_select=title,completed" | jq '.'
```

## Complete Testing Script

### Automated Full Test Suite
```bash
echo -e "\n=== AUTOMATED FULL TEST SUITE ==="
echo "Running all tests in sequence..."

# Save this script as run-comprehensive-test.sh
cat > run-comprehensive-test.sh << 'EOF'
#!/bin/bash

echo "🚀 Starting Comprehensive CURL API Testing"
echo "==========================================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run test and check result
run_test() {
    local test_name="$1"
    local test_command="$2"
    local success_check="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "${BLUE}Running Test: $test_name${NC}"
    
    result=$(eval "$test_command")
    
    if eval "$success_check"; then
        echo -e "${GREEN}✅ PASSED: $test_name${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}❌ FAILED: $test_name${NC}"
        echo "Response: $result"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    echo ""
}

# Generate unique user data
TIMESTAMP=$(date +%s)
USERNAME="testuser_${TIMESTAMP}"
EMAIL="test_${TIMESTAMP}@example.com"

echo "Generated Test Data:"
echo "Username: $USERNAME"
echo "Email: $EMAIL"
echo ""

# Test 1: User Registration
run_test "User Registration" \
    "curl -s -X POST http://localhost:5000/api/auth/register -H 'Content-Type: application/json' -d '{\"username\":\"$USERNAME\",\"email\":\"$EMAIL\",\"password\":\"SecurePass123!\",\"firstName\":\"Test\",\"lastName\":\"User\"}'" \
    'echo "$result" | jq -e ".success" > /dev/null'

# Extract token
TOKEN=$(echo "$result" | jq -r '.data.token // empty')

# Test 2: User Login
run_test "User Login" \
    "curl -s -X POST http://localhost:5000/api/auth/login -H 'Content-Type: application/json' -d '{\"username\":\"$USERNAME\",\"password\":\"SecurePass123!\"}'" \
    'echo "$result" | jq -e ".success" > /dev/null'

# Update token from login
TOKEN=$(echo "$result" | jq -r '.data.token // empty')

# Test 3: Token Validation
run_test "Token Validation" \
    "curl -s -X GET http://localhost:5000/api/auth/me -H 'Authorization: Bearer $TOKEN'" \
    'echo "$result" | jq -e ".success" > /dev/null'

# Test 4: Create Category
run_test "Create Category" \
    "curl -s -X POST http://localhost:5000/api/categories -H 'Content-Type: application/json' -H 'Authorization: Bearer $TOKEN' -d '{\"name\":\"Test Category\",\"color\":\"#FF6B6B\",\"description\":\"Test category for API testing\"}'" \
    'echo "$result" | jq -e ".success" > /dev/null'

CATEGORY_ID=$(echo "$result" | jq -r '.data.id // empty')

# Test 5: List Categories
run_test "List Categories" \
    "curl -s -X GET http://localhost:5000/api/categories -H 'Authorization: Bearer $TOKEN'" \
    'echo "$result" | jq -e ".success" > /dev/null'

# Test 6: Create Todo
run_test "Create Todo" \
    "curl -s -X POST http://localhost:5000/api/todos -H 'Content-Type: application/json' -H 'Authorization: Bearer $TOKEN' -d '{\"title\":\"Test Todo\",\"description\":\"Test todo for API testing\",\"priority\":\"high\",\"dueDate\":\"2024-12-31\"}'" \
    'echo "$result" | jq -e ".success" > /dev/null'

TODO_ID=$(echo "$result" | jq -r '.data.id // empty')

# Test 7: List Todos
run_test "List Todos" \
    "curl -s -X GET http://localhost:5000/api/todos -H 'Authorization: Bearer $TOKEN'" \
    'echo "$result" | jq -e ".success" > /dev/null'

# Test 8: Update Todo
if [ "$TODO_ID" != "" ] && [ "$TODO_ID" != "null" ]; then
    run_test "Update Todo" \
        "curl -s -X PUT http://localhost:5000/api/todos/$TODO_ID -H 'Content-Type: application/json' -H 'Authorization: Bearer $TOKEN' -d '{\"title\":\"Updated Test Todo\",\"description\":\"Updated description\",\"priority\":\"medium\"}'" \
        'echo "$result" | jq -e ".success" > /dev/null'
fi

# Test 9: Todo Search
run_test "Todo Search" \
    "curl -s -X GET 'http://localhost:5000/api/todos/search?q=test' -H 'Authorization: Bearer $TOKEN'" \
    'echo "$result" | jq -e ".success" > /dev/null'

# Test 10: User Profile
run_test "Get User Profile" \
    "curl -s -X GET http://localhost:5000/api/users/profile -H 'Authorization: Bearer $TOKEN'" \
    'echo "$result" | jq -e ".success" > /dev/null'

# Test 11: Update User Profile
run_test "Update User Profile" \
    "curl -s -X PUT http://localhost:5000/api/users/profile -H 'Content-Type: application/json' -H 'Authorization: Bearer $TOKEN' -d '{\"firstName\":\"Updated\",\"lastName\":\"TestUser\"}'" \
    'echo "$result" | jq -e ".success" > /dev/null'

# Test 12: JSON Server Direct Access
run_test "JSON Server Direct Access" \
    "curl -s http://localhost:3001/users" \
    'echo "$result" | jq -e ". | length >= 0" > /dev/null'

# Final Results
echo "========================================="
echo -e "${BLUE}TEST RESULTS SUMMARY${NC}"
echo "========================================="
echo -e "Total Tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL TESTS PASSED!${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Some tests failed. Check the output above.${NC}"
    exit 1
fi
EOF

chmod +x run-comprehensive-test.sh
echo "✅ Comprehensive test script created: run-comprehensive-test.sh"
echo "Execute with: ./run-comprehensive-test.sh"
```

## Error Scenarios and Validation

### Common Error Tests
```bash
echo -e "\n=== ERROR SCENARIO TESTING ==="

# Test validation errors
echo "Testing validation errors:"
curl -s -X POST http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{}' | jq '.'

# Test rate limiting (if enabled)
echo -e "\nTesting rate limiting (rapid requests):"
for i in {1..5}; do
    curl -s http://localhost:5000/api/health -w "%{http_code} " -o /dev/null
done
echo ""

# Test CORS
echo -e "\nTesting CORS headers:"
curl -I -H "Origin: http://localhost:3000" http://localhost:5000/api/health

# Test database connectivity
echo -e "\nTesting database connectivity:"
curl -s http://localhost:5000/api/health | jq '.database // "No database status"'
```

## Performance Testing

### Response Time Testing
```bash
echo -e "\n=== PERFORMANCE TESTING ==="

# Test response times
echo "Testing API response times:"
time curl -s http://localhost:5000/api/health > /dev/null
time curl -s -H "Authorization: Bearer $TOKEN" http://localhost:5000/api/todos > /dev/null

# Test concurrent requests
echo -e "\nTesting concurrent requests:"
for i in {1..5}; do
    curl -s http://localhost:5000/api/health &
done
wait
echo "Concurrent requests completed"
```

## Cleanup and Best Practices

### Cleanup Test Data
```bash
echo -e "\n=== CLEANUP TEST DATA ==="

# Note: In a production environment, you might want to clean up test data
# For this test environment, we'll leave the data for inspection

echo "Test data created during this session:"
echo "Username: $USERNAME"
echo "Email: $EMAIL"
echo "User ID: $USER_ID"
echo "Category ID: $CATEGORY_ID" 
echo "Todo ID: $TODO_ID"

echo -e "\nTo clean up test data manually:"
echo "1. Delete user from JSON Server: curl -X DELETE http://localhost:3001/users/$USER_ID"
echo "2. Delete associated todos and categories"
echo "3. Or restart JSON Server to reset to initial state"
```

### Testing Best Practices
```bash
echo -e "\n=== TESTING BEST PRACTICES ==="
cat << 'EOF'
1. Always verify server status before testing
2. Use unique identifiers to avoid conflicts
3. Test both success and error scenarios
4. Validate response structure and data types
5. Test authentication and authorization
6. Verify CORS headers for cross-origin requests
7. Test rate limiting and performance
8. Clean up test data when appropriate
9. Use jq for JSON processing and validation
10. Save tokens and IDs for subsequent requests

Common CURL flags:
-s : Silent mode (no progress meter)
-X : Specify HTTP method
-H : Add headers
-d : Add request data
-i : Include response headers
-w : Format output (for status codes, timing)
-o : Output to file
EOF
```

## Troubleshooting Common Issues

### Connection Issues
```bash
echo -e "\n=== TROUBLESHOOTING GUIDE ==="

# Check server connectivity
echo "Checking server connectivity:"
nc -z localhost 3001 && echo "✅ JSON Server (3001) is reachable" || echo "❌ JSON Server (3001) is not reachable"
nc -z localhost 5000 && echo "✅ Express API (5000) is reachable" || echo "❌ Express API (5000) is not reachable"
nc -z localhost 8080 && echo "✅ Swagger UI (8080) is reachable" || echo "❌ Swagger UI (8080) is not reachable"

# Check process status
echo -e "\nChecking process status:"
ps aux | grep -E "(json-server|node.*server)" | grep -v grep
```

### Debug Mode
```bash
# Enable verbose CURL output for debugging
echo -e "\n=== DEBUG MODE EXAMPLE ==="
echo "Use -v flag for verbose output:"
echo "curl -v -X GET http://localhost:5000/api/health"
echo ""
echo "Use -i flag to include response headers:"
echo "curl -i -X GET http://localhost:5000/api/health"
```

## Summary

This guide provides comprehensive CURL testing procedures for:

✅ **Authentication System**
- User registration and login
- Token validation and management
- Error scenario testing

✅ **User Management**
- Profile operations
- Preferences management
- Statistics retrieval

✅ **Category Management** 
- CRUD operations
- Listing and filtering

✅ **Todo Management**
- Complete CRUD operations
- Advanced search and filtering
- Bulk operations
- Status management

✅ **Database Layer**
- Direct JSON Server access
- Relationship queries
- Advanced querying

✅ **System Validation**
- Health checks
- Performance testing
- Error handling
- CORS validation

✅ **Automation**
- Complete test scripts
- Error scenario testing
- Cleanup procedures
- Best practices

Use this guide to systematically verify all API endpoints and ensure the complete Todo application is functioning correctly with proper data validation, authentication, and error handling.