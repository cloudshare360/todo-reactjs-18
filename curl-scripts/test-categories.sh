#!/bin/bash

# =============================================================================
# Todo App API Testing - Category Management Endpoints
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

echo -e "${BLUE}=== Todo App API - Category Management Tests ===${NC}\n"
echo -e "${YELLOW}🔑 Using Token: ${TOKEN:0:20}...${NC}\n"

# Function to print test headers
print_test() {
    echo -e "${YELLOW}🏷️ $1${NC}"
    echo "-------------------------------------------"
}

# Variables for created categories
CATEGORY_IDS=()

# 1. Create Categories
print_test "Create Work Category"
WORK_CATEGORY_RESPONSE=$(curl -X POST "${API_BASE}/categories" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "name": "Work",
    "color": "#FF5733",
    "description": "Work-related tasks and projects",
    "icon": "💼"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s)

echo "$WORK_CATEGORY_RESPONSE"
WORK_CATEGORY_ID=$(echo "$WORK_CATEGORY_RESPONSE" | grep -o '"id":"[^"]*' | cut -d'"' -f4)
CATEGORY_IDS+=("$WORK_CATEGORY_ID")
echo -e "Work Category ID: $WORK_CATEGORY_ID\n"

print_test "Create Personal Category"
PERSONAL_CATEGORY_RESPONSE=$(curl -X POST "${API_BASE}/categories" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "name": "Personal",
    "color": "#28A745",
    "description": "Personal tasks and activities",
    "icon": "🏠"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s)

echo "$PERSONAL_CATEGORY_RESPONSE"
PERSONAL_CATEGORY_ID=$(echo "$PERSONAL_CATEGORY_RESPONSE" | grep -o '"id":"[^"]*' | cut -d'"' -f4)
CATEGORY_IDS+=("$PERSONAL_CATEGORY_ID")
echo -e "Personal Category ID: $PERSONAL_CATEGORY_ID\n"

print_test "Create Shopping Category"
SHOPPING_CATEGORY_RESPONSE=$(curl -X POST "${API_BASE}/categories" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "name": "Shopping",
    "color": "#FFC107",
    "description": "Shopping lists and purchases",
    "icon": "🛒"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s)

echo "$SHOPPING_CATEGORY_RESPONSE"
SHOPPING_CATEGORY_ID=$(echo "$SHOPPING_CATEGORY_RESPONSE" | grep -o '"id":"[^"]*' | cut -d'"' -f4)
CATEGORY_IDS+=("$SHOPPING_CATEGORY_ID")
echo -e "Shopping Category ID: $SHOPPING_CATEGORY_ID\n"

# 2. Get All Categories
print_test "Get All Categories"
curl -X GET "${API_BASE}/categories" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 3. Get Single Category
print_test "Get Single Category (Work)"
curl -X GET "${API_BASE}/categories/${WORK_CATEGORY_ID}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 4. Update Category
print_test "Update Work Category"
curl -X PUT "${API_BASE}/categories/${WORK_CATEGORY_ID}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "name": "Work & Projects",
    "color": "#DC3545",
    "description": "Work-related tasks, projects, and professional activities",
    "icon": "💼"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 5. Create Todos in Categories
print_test "Create Todo in Work Category"
WORK_TODO_RESPONSE=$(curl -X POST "${API_BASE}/todos" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "title": "Prepare Monthly Report",
    "description": "Compile and analyze monthly performance metrics",
    "priority": "high",
    "categoryId": "'"${WORK_CATEGORY_ID}"'",
    "dueDate": "2024-12-15T17:00:00Z"
  }' \
  -s)

WORK_TODO_ID=$(echo "$WORK_TODO_RESPONSE" | grep -o '"id":"[^"]*' | cut -d'"' -f4)
echo "Created Work Todo ID: $WORK_TODO_ID"

print_test "Create Todo in Personal Category"
PERSONAL_TODO_RESPONSE=$(curl -X POST "${API_BASE}/todos" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "title": "Schedule Doctor Appointment",
    "description": "Annual health checkup",
    "priority": "medium",
    "categoryId": "'"${PERSONAL_CATEGORY_ID}"'",
    "dueDate": "2024-12-20T10:00:00Z"
  }' \
  -s)

PERSONAL_TODO_ID=$(echo "$PERSONAL_TODO_RESPONSE" | grep -o '"id":"[^"]*' | cut -d'"' -f4)
echo "Created Personal Todo ID: $PERSONAL_TODO_ID"

print_test "Create Todo in Shopping Category"
SHOPPING_TODO_RESPONSE=$(curl -X POST "${API_BASE}/todos" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "title": "Buy Groceries",
    "description": "Weekly grocery shopping",
    "priority": "low",
    "categoryId": "'"${SHOPPING_CATEGORY_ID}"'",
    "tags": ["groceries", "weekly", "food"]
  }' \
  -s)

SHOPPING_TODO_ID=$(echo "$SHOPPING_TODO_RESPONSE" | grep -o '"id":"[^"]*' | cut -d'"' -f4)
echo "Created Shopping Todo ID: $SHOPPING_TODO_ID"
echo -e "\n"

# 6. Get Category with Todos
print_test "Get Work Category with Todos"
curl -X GET "${API_BASE}/categories/${WORK_CATEGORY_ID}/todos" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 7. Get Category Statistics
print_test "Get Category Statistics"
curl -X GET "${API_BASE}/categories/${WORK_CATEGORY_ID}/stats" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 8. Get All Categories with Todo Counts
print_test "Get Categories with Todo Counts"
curl -X GET "${API_BASE}/categories?includeCounts=true" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 9. Search Categories
print_test "Search Categories"
curl -X GET "${API_BASE}/categories/search?q=work" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 10. Test Invalid Category Creation
print_test "Test Invalid Category Creation (Missing Name)"
curl -X POST "${API_BASE}/categories" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "color": "#000000",
    "description": "Category without name"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 11. Test Duplicate Category Name
print_test "Test Duplicate Category Name"
curl -X POST "${API_BASE}/categories" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "name": "Work & Projects",
    "color": "#000000",
    "description": "Duplicate category"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 12. Move Todos Between Categories
print_test "Move Shopping Todo to Personal Category"
curl -X PATCH "${API_BASE}/todos/${SHOPPING_TODO_ID}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "categoryId": "'"${PERSONAL_CATEGORY_ID}"'"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 13. Delete Category with Todos (Should handle gracefully)
print_test "Try to Delete Category with Todos"
curl -X DELETE "${API_BASE}/categories/${PERSONAL_CATEGORY_ID}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 14. Force Delete Category and Move Todos to Default
print_test "Force Delete Category (Move Todos to Default)"
curl -X DELETE "${API_BASE}/categories/${PERSONAL_CATEGORY_ID}?force=true" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 15. Delete Empty Category
print_test "Delete Empty Shopping Category"
curl -X DELETE "${API_BASE}/categories/${SHOPPING_CATEGORY_ID}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 16. Get Categories After Deletions
print_test "Get Categories After Deletions"
curl -X GET "${API_BASE}/categories" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

echo -e "${GREEN}✅ Category management tests completed!${NC}\n"