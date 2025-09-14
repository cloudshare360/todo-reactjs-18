#!/bin/bash

# =============================================================================
# Todo App API Testing - JSON Server Direct Access & Relations
# =============================================================================

# Configuration
JSON_SERVER="http://localhost:3001"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Todo App API - JSON Server & Relations Tests ===${NC}\n"

# Function to print test headers
print_test() {
    echo -e "${YELLOW}🔗 $1${NC}"
    echo "-------------------------------------------"
}

# 1. Check JSON Server Health
print_test "JSON Server Health Check"
curl -X GET "${JSON_SERVER}/db" \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 2. Get All Users (JSON Server Direct)
print_test "Get All Users (JSON Server)"
curl -X GET "${JSON_SERVER}/users" \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 3. Get All Todos (JSON Server Direct)
print_test "Get All Todos (JSON Server)"
curl -X GET "${JSON_SERVER}/todos" \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 4. Get All Categories (JSON Server Direct)
print_test "Get All Categories (JSON Server)"
curl -X GET "${JSON_SERVER}/categories" \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 5. Get User-Todo Relations
print_test "Get User-Todo Relations"
curl -X GET "${JSON_SERVER}/user-todo-relations" \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 6. Create a New User (JSON Server Direct)
print_test "Create User via JSON Server"
USER_RESPONSE=$(curl -X POST "${JSON_SERVER}/users" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "JSON Server User",
    "email": "jsonserver@example.com",
    "password": "hashedpassword123",
    "createdAt": "2024-01-15T10:00:00Z",
    "updatedAt": "2024-01-15T10:00:00Z",
    "isActive": true,
    "preferences": {
      "theme": "dark",
      "notifications": true,
      "language": "en"
    }
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s)

echo "$USER_RESPONSE"
USER_ID=$(echo "$USER_RESPONSE" | grep -o '"id":[^,}]*' | head -1 | cut -d':' -f2 | tr -d ' ')
echo -e "Created User ID: $USER_ID\n"

# 7. Create Categories (JSON Server Direct)
print_test "Create Category via JSON Server"
CATEGORY_RESPONSE=$(curl -X POST "${JSON_SERVER}/categories" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "JSON Test Category",
    "color": "#8E44AD",
    "description": "Category created via JSON Server",
    "icon": "🧪",
    "userId": '"${USER_ID}"',
    "createdAt": "2024-01-15T10:00:00Z",
    "updatedAt": "2024-01-15T10:00:00Z"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s)

echo "$CATEGORY_RESPONSE"
CATEGORY_ID=$(echo "$CATEGORY_RESPONSE" | grep -o '"id":[^,}]*' | head -1 | cut -d':' -f2 | tr -d ' ')
echo -e "Created Category ID: $CATEGORY_ID\n"

# 8. Create Todos (JSON Server Direct)
TODO_IDS=()

for i in {1..3}; do
    print_test "Create Todo $i via JSON Server"
    TODO_RESPONSE=$(curl -X POST "${JSON_SERVER}/todos" \
      -H "Content-Type: application/json" \
      -d '{
        "title": "JSON Server Todo '"$i"'",
        "description": "Todo created directly via JSON Server",
        "status": "pending",
        "priority": "medium",
        "userId": '"${USER_ID}"',
        "categoryId": '"${CATEGORY_ID}"',
        "createdAt": "2024-01-15T10:0'"$i"':00Z",
        "updatedAt": "2024-01-15T10:0'"$i"':00Z",
        "dueDate": "2024-12-3'"$i"'T23:59:59Z",
        "tags": ["json", "server", "test"],
        "progress": 0
      }' \
      -w "\nStatus: %{http_code}\n" \
      -s)
    
    echo "$TODO_RESPONSE"
    TODO_ID=$(echo "$TODO_RESPONSE" | grep -o '"id":[^,}]*' | head -1 | cut -d':' -f2 | tr -d ' ')
    TODO_IDS+=("$TODO_ID")
    echo -e "Created Todo $i ID: $TODO_ID\n"
done

# 9. Create User-Todo Relations
print_test "Create User-Todo Relations"
for todo_id in "${TODO_IDS[@]}"; do
    RELATION_RESPONSE=$(curl -X POST "${JSON_SERVER}/user-todo-relations" \
      -H "Content-Type: application/json" \
      -d '{
        "userId": '"${USER_ID}"',
        "todoId": '"${todo_id}"',
        "relationshipType": "owner",
        "createdAt": "2024-01-15T10:00:00Z"
      }' \
      -s)
    
    RELATION_ID=$(echo "$RELATION_RESPONSE" | grep -o '"id":[^,}]*' | head -1 | cut -d':' -f2 | tr -d ' ')
    echo "Created relation for Todo $todo_id: Relation ID $RELATION_ID"
done
echo -e "\n"

# 10. Query Relations - Get Todos for User
print_test "Get Todos for User (via Relations)"
curl -X GET "${JSON_SERVER}/user-todo-relations?userId=${USER_ID}" \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 11. Query with JSON Server Filters and Pagination
print_test "Get Todos with Filters (High Priority)"
curl -X GET "${JSON_SERVER}/todos?priority=high&_limit=5&_page=1" \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 12. Full-text Search in JSON Server
print_test "Search Todos by Title"
curl -X GET "${JSON_SERVER}/todos?q=JSON" \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 13. Get Todos with Embed (User and Category data)
print_test "Get Todos with Embedded User Data"
curl -X GET "${JSON_SERVER}/todos?_embed=user&_embed=category" \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 14. Get User with Expanded Todos
print_test "Get User with Expanded Todos"
curl -X GET "${JSON_SERVER}/users/${USER_ID}?_embed=todos" \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 15. Update Todo Status (JSON Server Direct)
print_test "Update Todo Status via JSON Server"
curl -X PATCH "${JSON_SERVER}/todos/${TODO_IDS[0]}" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "completed",
    "progress": 100,
    "updatedAt": "2024-01-15T11:00:00Z",
    "completedAt": "2024-01-15T11:00:00Z"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 16. Bulk Operations - Get Multiple Resources
print_test "Get Multiple Todos by IDs"
TODO_IDS_STRING=$(IFS=,; echo "${TODO_IDS[*]}")
curl -X GET "${JSON_SERVER}/todos?id=${TODO_IDS[0]}&id=${TODO_IDS[1]}&id=${TODO_IDS[2]}" \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 17. Complex Query - Todos by Category and Status
print_test "Get Pending Todos in Category"
curl -X GET "${JSON_SERVER}/todos?categoryId=${CATEGORY_ID}&status=pending&_sort=createdAt&_order=desc" \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 18. Test Data Integrity - Verify Relations
print_test "Verify User-Todo Relationships"
echo "Checking if all todos belong to the created user..."
curl -X GET "${JSON_SERVER}/todos?userId=${USER_ID}" \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n" \
  -s
echo -e "\n"

# 19. Analytics Query - Count Todos by Status
print_test "Count Todos by Status"
echo "Pending todos:"
curl -X GET "${JSON_SERVER}/todos?status=pending&userId=${USER_ID}" \
  -H "Content-Type: application/json" \
  -s | grep -o '"id"' | wc -l
echo "Completed todos:"
curl -X GET "${JSON_SERVER}/todos?status=completed&userId=${USER_ID}" \
  -H "Content-Type: application/json" \
  -s | grep -o '"id"' | wc -l
echo -e "\n"

# 20. Cleanup - Delete Created Resources
print_test "Cleanup - Delete Created Resources"

# Delete relations first
echo "Deleting user-todo relations..."
RELATION_IDS=$(curl -s "${JSON_SERVER}/user-todo-relations?userId=${USER_ID}" | grep -o '"id":[^,}]*' | cut -d':' -f2 | tr -d ' ')
for relation_id in $RELATION_IDS; do
    curl -X DELETE "${JSON_SERVER}/user-todo-relations/${relation_id}" -s
    echo "Deleted relation $relation_id"
done

# Delete todos
echo "Deleting todos..."
for todo_id in "${TODO_IDS[@]}"; do
    curl -X DELETE "${JSON_SERVER}/todos/${todo_id}" \
      -H "Content-Type: application/json" \
      -w "Deleted Todo ${todo_id} - Status: %{http_code}\n" \
      -s
done

# Delete category
echo "Deleting category..."
curl -X DELETE "${JSON_SERVER}/categories/${CATEGORY_ID}" \
  -H "Content-Type: application/json" \
  -w "Deleted Category ${CATEGORY_ID} - Status: %{http_code}\n" \
  -s

# Delete user
echo "Deleting user..."
curl -X DELETE "${JSON_SERVER}/users/${USER_ID}" \
  -H "Content-Type: application/json" \
  -w "Deleted User ${USER_ID} - Status: %{http_code}\n" \
  -s

echo -e "\n"

echo -e "${GREEN}✅ JSON Server and relations tests completed!${NC}\n"