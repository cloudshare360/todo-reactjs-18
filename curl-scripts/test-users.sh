#!/bin/bash

# =============================================================================
# Todo App API Testing - User Management Endpoints
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

# Load token from auth test or use provided token
if [ -f "/tmp/todo_app_token.txt" ]; then
    TOKEN=$(cat /tmp/todo_app_token.txt)
else
    echo -e "${RED}❌ No token found. Please run test-auth.sh first or provide TOKEN environment variable${NC}"
    exit 1
fi

echo -e "${BLUE}=== Todo App API - User Management Tests ===${NC}\n"
echo -e "${YELLOW}🔑 Using Token: ${TOKEN:0:20}...${NC}\n"

# Function to print test headers
print_test() {
    echo -e "${YELLOW}👤 $1${NC}"
    echo "-------------------------------------------"
}

# 1. Get Current User Profile
print_test "Get Current User Profile"
USER_RESPONSE=$(curl -X GET "${API_BASE}/users/profile" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -w "\nStatus: %{http_code}\n" \
  -s)

echo "$USER_RESPONSE"
USER_ID=$(echo "$USER_RESPONSE" | grep -o '"id":"[^"]*' | cut -d'"' -f4)
echo -e "User ID: $USER_ID\n"

# 2. Update User Profile
print_test "Update User Profile"
curl -X PUT "${API_BASE}/users/profile" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "name": "Updated Test User",
    "email": "updated.test@example.com",
    "bio": "This is my updated bio",
    "location": "New York, USA"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 3. Get Updated Profile
print_test "Get Updated Profile"
curl -X GET "${API_BASE}/users/profile" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 4. Update User Preferences
print_test "Update User Preferences"
curl -X PUT "${API_BASE}/users/preferences" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "theme": "light",
    "notifications": false,
    "language": "en",
    "timezone": "America/New_York",
    "dateFormat": "MM/DD/YYYY"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 5. Get User Preferences
print_test "Get User Preferences"
curl -X GET "${API_BASE}/users/preferences" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 6. Get User Statistics
print_test "Get User Statistics"
curl -X GET "${API_BASE}/users/stats" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 7. Upload Profile Avatar (Mock multipart data)
print_test "Upload Profile Avatar (Mock)"
# Create a temporary test file
echo "This is a mock avatar file" > /tmp/avatar.txt
curl -X POST "${API_BASE}/users/avatar" \
  -H "Authorization: Bearer ${TOKEN}" \
  -F "avatar=@/tmp/avatar.txt" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 8. Get User Activity Log
print_test "Get User Activity Log"
curl -X GET "${API_BASE}/users/activity?limit=10&page=1" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 9. Export User Data
print_test "Export User Data"
curl -X GET "${API_BASE}/users/export" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 10. Test Invalid Profile Update (Missing fields)
print_test "Test Invalid Profile Update"
curl -X PUT "${API_BASE}/users/profile" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "email": "invalid-email"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 11. Deactivate Account (Soft Delete)
print_test "Deactivate User Account"
curl -X DELETE "${API_BASE}/users/deactivate" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "reason": "Testing account deactivation",
    "password": "NewTestPassword123!"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 12. Try to Access Profile After Deactivation
print_test "Try Access After Deactivation"
curl -X GET "${API_BASE}/users/profile" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# Cleanup
rm -f /tmp/avatar.txt

echo -e "${GREEN}✅ User management tests completed!${NC}\n"