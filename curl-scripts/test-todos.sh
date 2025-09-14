#!/bin/bash

# =============================================================================
# Todo App API Testing - Todo Management Endpoints
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
    echo -e "${RED}❌ No token found. Please run test-auth.sh first${NC}"
    exit 1
fi

echo -e "${BLUE}=== Todo App API - Todo Management Tests ===${NC}\n"
echo -e "${YELLOW}🔑 Using Token: ${TOKEN:0:20}...${NC}\n"

# Function to print test headers
print_test() {
    echo -e "${YELLOW}📝 $1${NC}"
    echo "-------------------------------------------"
}

# Variables for created todos
TODO_ID=""
CATEGORY_ID=""

# 1. Create a Category First
print_test "Create Category"
CATEGORY_RESPONSE=$(curl -X POST "${API_BASE}/categories" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "name": "Work",
    "color": "#FF5733",
    "description": "Work-related tasks"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s)

echo "$CATEGORY_RESPONSE"
CATEGORY_ID=$(echo "$CATEGORY_RESPONSE" | grep -o '"id":"[^"]*' | cut -d'"' -f4)
echo -e "Category ID: $CATEGORY_ID\n"

# 2. Create a Todo
print_test "Create Todo"
TODO_RESPONSE=$(curl -X POST "${API_BASE}/todos" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "title": "Complete API Documentation",
    "description": "Write comprehensive API documentation for the todo app",
    "priority": "high",
    "categoryId": "'"${CATEGORY_ID}"'",
    "dueDate": "2024-12-31T23:59:59Z",
    "tags": ["documentation", "api", "important"]
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s)

echo "$TODO_RESPONSE"
TODO_ID=$(echo "$TODO_RESPONSE" | grep -o '"id":"[^"]*' | cut -d'"' -f4)
echo -e "Todo ID: $TODO_ID\n"

# 3. Get All Todos
print_test "Get All Todos"
curl -X GET "${API_BASE}/todos" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 4. Get Todos with Filters
print_test "Get Todos with Filters (Priority: high)"
curl -X GET "${API_BASE}/todos?priority=high&limit=10&page=1" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 5. Get Single Todo
print_test "Get Single Todo"
curl -X GET "${API_BASE}/todos/${TODO_ID}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 6. Update Todo
print_test "Update Todo"
curl -X PUT "${API_BASE}/todos/${TODO_ID}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "title": "Complete API Documentation (Updated)",
    "description": "Write comprehensive API documentation for the todo app with examples",
    "priority": "medium",
    "status": "in-progress",
    "progress": 50,
    "tags": ["documentation", "api", "important", "updated"]
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 7. Update Todo Status
print_test "Update Todo Status"
curl -X PATCH "${API_BASE}/todos/${TODO_ID}/status" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "status": "completed",
    "progress": 100
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 8. Create Multiple Todos for Bulk Operations
print_test "Create Additional Todos"
TODO_IDS=()

for i in {1..3}; do
    BULK_TODO_RESPONSE=$(curl -X POST "${API_BASE}/todos" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer ${TOKEN}" \
      -d '{
        "title": "Bulk Todo '"$i"'",
        "description": "Todo for bulk operations testing",
        "priority": "low"
      }' \
      -s)
    
    BULK_TODO_ID=$(echo "$BULK_TODO_RESPONSE" | grep -o '"id":"[^"]*' | cut -d'"' -f4)
    TODO_IDS+=("$BULK_TODO_ID")
    echo "Created Todo $i with ID: $BULK_TODO_ID"
done
echo -e "\n"

# 9. Bulk Update Todos
print_test "Bulk Update Todos"
curl -X PATCH "${API_BASE}/todos/bulk" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "ids": ["'"${TODO_IDS[0]}"'", "'"${TODO_IDS[1]}"'", "'"${TODO_IDS[2]}"'"],
    "updates": {
      "status": "in-progress",
      "priority": "medium"
    }
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 10. Get Todos by Status
print_test "Get Todos by Status (in-progress)"
curl -X GET "${API_BASE}/todos?status=in-progress" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 11. Search Todos
print_test "Search Todos"
curl -X GET "${API_BASE}/todos/search?q=documentation" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 12. Get Todos by Category
print_test "Get Todos by Category"
curl -X GET "${API_BASE}/todos?categoryId=${CATEGORY_ID}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 13. Get Overdue Todos
print_test "Get Overdue Todos"
curl -X GET "${API_BASE}/todos/overdue" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 14. Add Todo Attachment (Mock)
print_test "Add Todo Attachment"
echo "Mock attachment content" > /tmp/todo-attachment.txt
curl -X POST "${API_BASE}/todos/${TODO_ID}/attachments" \
  -H "Authorization: Bearer ${TOKEN}" \
  -F "file=@/tmp/todo-attachment.txt" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 15. Bulk Delete Todos
print_test "Bulk Delete Todos"
curl -X DELETE "${API_BASE}/todos/bulk" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "ids": ["'"${TODO_IDS[0]}"'", "'"${TODO_IDS[1]}"'", "'"${TODO_IDS[2]}"'"]
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 16. Delete Single Todo
print_test "Delete Single Todo"
curl -X DELETE "${API_BASE}/todos/${TODO_ID}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 17. Try to Get Deleted Todo
print_test "Try to Get Deleted Todo"
curl -X GET "${API_BASE}/todos/${TODO_ID}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 18. Test Invalid Todo Creation
print_test "Test Invalid Todo Creation (Missing Title)"
curl -X POST "${API_BASE}/todos" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "description": "Todo without title"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# Cleanup
rm -f /tmp/todo-attachment.txt

echo -e "${GREEN}✅ Todo management tests completed!${NC}\n"