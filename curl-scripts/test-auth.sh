#!/bin/bash

# =============================================================================
# Todo App API Testing - Authentication Endpoints
# =============================================================================

# Configuration
API_BASE="http://localhost:5000/api"
JSON_SERVER="http://localhost:3001"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test variables
TEST_USER_USERNAME="testuser123"
TEST_USER_EMAIL="test@example.com"
TEST_USER_PASSWORD="TestPassword123!"
TOKEN=""

echo -e "${BLUE}=== Todo App API - Authentication Tests ===${NC}\n"

# Function to print test headers
print_test() {
    echo -e "${YELLOW}📋 $1${NC}"
    echo "-------------------------------------------"
}

# Function to extract token from response
extract_token() {
    echo "$1" | jq -r '.data.token // empty' 2>/dev/null || echo "$1" | grep -o '"token":"[^"]*' | cut -d'"' -f4
}

# 1. Health Check
print_test "Health Check"
curl -X GET "http://localhost:5000/health" \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 2. Register User
print_test "Register New User"
REGISTER_RESPONSE=$(curl -X POST "${API_BASE}/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "'"${TEST_USER_USERNAME}"'",
    "email": "'"${TEST_USER_EMAIL}"'",
    "password": "'"${TEST_USER_PASSWORD}"'",
    "firstName": "Test",
    "lastName": "User"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s)

echo "$REGISTER_RESPONSE"
TOKEN=$(extract_token "$REGISTER_RESPONSE")
echo -e "\n"

# 3. Login User
print_test "Login User"
LOGIN_RESPONSE=$(curl -X POST "${API_BASE}/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "'"${TEST_USER_USERNAME}"'",
    "password": "'"${TEST_USER_PASSWORD}"'"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s)

echo "$LOGIN_RESPONSE"
# Update token with login token (more recent)
TOKEN=$(extract_token "$LOGIN_RESPONSE")
echo -e "Extracted Token: ${TOKEN:0:20}...\n"

# 4. Get Current User Profile (Protected)
print_test "Get Current User Profile"
curl -X GET "${API_BASE}/auth/me" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 5. Change Password
print_test "Change Password"
NEW_PASSWORD="NewTestPassword123!"
curl -X PUT "${API_BASE}/auth/change-password" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "currentPassword": "'"${TEST_USER_PASSWORD}"'",
    "newPassword": "'"${NEW_PASSWORD}"'"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 6. Login with New Password
print_test "Login with New Password"
LOGIN_NEW_RESPONSE=$(curl -X POST "${API_BASE}/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "'"${TEST_USER_USERNAME}"'",
    "password": "'"${NEW_PASSWORD}"'"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s)

echo "$LOGIN_NEW_RESPONSE"
TOKEN=$(extract_token "$LOGIN_NEW_RESPONSE")
echo -e "\n"

# 7. Logout
print_test "Logout User"
curl -X POST "${API_BASE}/auth/logout" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 8. Test Invalid Login
print_test "Test Invalid Login"
curl -X POST "${API_BASE}/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "invaliduser",
    "password": "wrongpassword"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 9. Test Protected Route Without Token
print_test "Test Protected Route Without Token"
curl -X GET "${API_BASE}/auth/me" \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

echo -e "${GREEN}✅ Authentication tests completed!${NC}"
echo -e "${BLUE}📝 Token for further testing: ${TOKEN:0:30}...${NC}"

# Save token to file for use in other scripts
echo "$TOKEN" > /tmp/todo_app_token.txt
echo -e "${YELLOW}💾 Token saved to /tmp/todo_app_token.txt${NC}\n"