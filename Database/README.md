# Database - JSON Server

This folder contains the JSON Server database configuration and data files for the Todo Application.

## 📁 Structure

```
Database/
├── users.json              # User data
├── todos.json              # Todo items data  
├── user-todo-relations.json # User-Todo relationships and categories
├── routes.json             # API route mappings
├── package.json            # Dependencies and scripts
├── scripts/                # Server management scripts
│   ├── start-server.sh     # Start JSON Server
│   ├── stop-server.sh      # Stop JSON Server
│   └── restart-server.sh   # Restart JSON Server
└── README.md              # This file
```

## 🚀 Quick Start

### Install Dependencies
```bash
cd Database
npm install
```

### Start the JSON Server
```bash
# Method 1: Using npm script
npm start

# Method 2: Using shell script
cd scripts
./start-server.sh

# Method 3: Direct command
json-server --watch users.json todos.json user-todo-relations.json --port 3001
```

### Stop the Server
```bash
# Using shell script
cd scripts
./stop-server.sh
```

## 🔗 API Endpoints

Once started, the JSON Server will be available at `http://localhost:3001`

### Users
- `GET /users` - Get all users
- `GET /users/:id` - Get user by ID
- `POST /users` - Create new user
- `PUT /users/:id` - Update user
- `DELETE /users/:id` - Delete user

### Todos
- `GET /todos` - Get all todos
- `GET /todos/:id` - Get todo by ID
- `GET /todos?userId=:userId` - Get todos by user
- `POST /todos` - Create new todo
- `PUT /todos/:id` - Update todo
- `DELETE /todos/:id` - Delete todo

### User-Todo Relations
- `GET /userTodoRelations` - Get all relations
- `GET /userTodoRelations?userId=:userId` - Get relations by user
- `POST /userTodoRelations` - Create new relation

### Categories
- `GET /categories` - Get all categories
- `GET /categories?userId=:userId` - Get categories by user
- `POST /categories` - Create new category
- `PUT /categories/:id` - Update category
- `DELETE /categories/:id` - Delete category

## 📊 Data Models

### User
```json
{
  "id": "string",
  "username": "string",
  "email": "string", 
  "password": "string (hashed)",
  "firstName": "string",
  "lastName": "string",
  "avatar": "string",
  "preferences": "object",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Todo
```json
{
  "id": "string",
  "userId": "string",
  "title": "string",
  "description": "string",
  "status": "pending|in-progress|completed",
  "priority": "low|medium|high|urgent",
  "category": "string",
  "tags": "array",
  "dueDate": "timestamp",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## 🔧 Configuration

### Custom Routes
Edit `routes.json` to customize API endpoints:
```json
{
  "/api/users/*": "/users/$1",
  "/api/todos/*": "/todos/$1"
}
```

### Server Options
- **Port**: 3001 (configurable)
- **Host**: 0.0.0.0 (accessible from network)
- **Watch**: Auto-reload on file changes
- **Delay**: Optional response delay for testing

## 💾 Data Management

### Backup Data
```bash
npm run backup
```

### Reset Data
```bash
npm run reset
```

### Sample Data
The database comes pre-populated with sample data:
- 1 admin user (username: admin, password: password)
- 1 sample todo
- 3 default categories

## 🔒 Security Notes

- Passwords are stored hashed (bcrypt)
- No authentication middleware (handled by Express backend)
- CORS enabled for development
- File-based storage (not for production)