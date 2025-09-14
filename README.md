# Todo ReactJS 18 Application

A simple, full-stack todo application built with ReactJS 18 frontend, Express.js backend, and JSON Server database, featuring user authentication, profile management, and comprehensive CRUD operations.

## 📋 Overview

This project is a complete todo management system organized into three main folders:
1. **Front-End** - React 18 application
2. **Back-End** - Express.js REST API server 
3. **Database** - JSON Server with data files and management scripts

The application allows users to create accounts, manage their personal todo lists, and update their profiles using a simple file-based database system.

## ✨ Features

### User Management
- **User Registration**: New users can create accounts with basic validation
- **User Authentication**: Secure login/logout functionality with session management
- **Password Management**: 
  - Password strength requirements and client-side validation
  - Password change functionality for logged-in users
- **Account Security**:
  - Account lockout after multiple failed login attempts
  - Session timeout and automatic logout for inactive users
  - Login attempt tracking
- **Profile Management**: Users can view and update their personal information
- **Account Management**: Users can deactivate or permanently delete accounts
- **Authorization**: Role-based access control ensuring users only access their own data

### Todo Management
- **Create Todos**: Add new tasks with title, description, due date, and priority
- **Read Todos**: View all personal todos with filtering and sorting options
- **Update Todos**: Edit existing todos including status changes (pending/completed/in-progress)
- **Delete Todos**: Remove todos individually or in bulk with confirmation dialogs
- **Search & Filter**: 
  - Advanced search by title, description, category, priority, or due date
  - Filter by date ranges, completion status, and custom tags
  - Saved search queries and filters
- **Categories & Tags**: 
  - Organize todos into custom categories with color coding
  - Add multiple tags to todos for flexible organization
  - Category and tag management (create, edit, delete)
- **Advanced Features**:
  - **Subtasks**: Break down todos into smaller, manageable subtasks
  - **Recurring Todos**: Set up daily, weekly, monthly, or custom recurring tasks
  - **Todo Templates**: Save frequently used todo patterns as reusable templates
  - **File Attachments**: Attach files, images, or links to todos
  - **Comments & Notes**: Add timestamped comments and additional notes to todos
  - **Todo Dependencies**: Set dependencies between todos (blocking/blocked by)
- **Bulk Operations**:
  - Select multiple todos for bulk status updates, category changes, or deletion
  - Import todos from CSV/JSON files
  - Export todos to various formats (CSV, JSON, PDF)

### User Experience
- **Responsive Design**: Mobile-first, responsive UI that works on all devices
- **Real-time Updates**: Instant feedback for all user actions with loading states
- **Data Persistence**: All changes are automatically saved with conflict resolution
- **Secure Access**: Protected routes ensuring only authenticated users access their data
- **Accessibility**: WCAG 2.1 compliant interface with keyboard navigation and screen reader support
- **Localization**: Basic multi-language support with locale-specific date/time formatting
- **Themes**: Light and dark mode themes with user preference persistence
- **Offline Support**: Basic offline functionality with data synchronization when reconnected
- **Performance**: Optimized loading with pagination, lazy loading, and caching strategies
- **Error Handling**: Comprehensive error messages with user-friendly recovery suggestions
- **Notifications**: 
  - In-app notifications for todo reminders and due dates
  - Browser-based notifications for important events
- **Customization**:
  - Customizable dashboard layout and widget arrangement
  - Personalized color schemes and themes
  - Configurable notification preferences

### Data Management & Analytics
- **Data Export/Import**: 
  - Export user data and todos in multiple formats (JSON, CSV)
  - Import todos from standard formats (CSV, JSON)
  - Bulk data operations for local data management
- **Backup & Recovery**:
  - Automated daily backups of user data
  - Point-in-time recovery for accidental data loss
  - Data versioning for tracking changes over time
- **Analytics & Reporting**:
  - Personal productivity analytics and insights
  - Todo completion rates and time tracking
  - Category-wise task distribution reports
  - Productivity trends and goal tracking
- **Data Privacy & Security**:
  - Data encryption for sensitive information
  - User data portability and deletion rights
  - Secure data handling and storage practices

### System Requirements & Performance
- **Performance Standards**:
  - Page load times under 2 seconds on 3G networks
  - Support for 1000+ todos per user without performance degradation
  - 99.9% uptime availability target
  - Concurrent user support (minimum 100 active users)
- **Error Handling & Logging**:
  - Comprehensive error logging and monitoring
  - Graceful error recovery with user-friendly messages
  - Application health monitoring and alerting
  - Performance metrics tracking and optimization
- **API Rate Limiting**:
  - Rate limiting to prevent API abuse
  - Request throttling for heavy operations
  - Fair usage policies and quota management
- **Data Validation & Integrity**:
  - Client-side and server-side input validation
  - Data sanitization to prevent XSS and injection attacks
  - Database constraints and referential integrity
  - Automated data consistency checks

## 🛠 Tech Stack

### Front-End (Port 3000)
- **React 18** - Latest React with concurrent features
- **React Router** - Client-side routing and navigation
- **Axios** - HTTP client for API requests
- **CSS Modules** - Component styling
- **React Hook Form** - Form validation and management

### Back-End (Port 5000)
- **Node.js** - JavaScript runtime environment
- **Express.js** - Web application framework
- **JWT** - JSON Web Tokens for authentication
- **bcryptjs** - Password hashing and security
- **CORS** - Cross-origin resource sharing
- **Morgan** - HTTP request logger
- **Express Validator** - Request validation
- **Axios** - HTTP client to communicate with JSON Server

### Database (Port 3001)
- **JSON Server** - File-based REST API database
- **JSON Files**: users.json, todos.json, user-todo-relations.json
- **Management Scripts**: Start, stop, restart server scripts

## 📊 Data Models

### User Model
```json
{
  "id": "uuid",
  "email": "string (unique)",
  "username": "string (unique)", 
  "password": "string (hashed)",
  "firstName": "string",
  "lastName": "string",
  "avatar": "string (optional)",
  "lastLoginAt": "timestamp (optional)",
  "loginAttempts": "number",
  "accountLockedUntil": "timestamp (optional)",
  "isActive": "boolean",
  "preferences": {
    "theme": "light|dark|system",
    "language": "string",
    "notifications": {
      "browser": "boolean",
      "inApp": "boolean"
    },
    "timezone": "string"
  },
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Todo Model
```json
{
  "id": "uuid",
  "userId": "string (foreign key)",
  "title": "string",
  "description": "string (optional)",
  "status": "pending|in-progress|completed",
  "priority": "low|medium|high|urgent",
  "category": "string (optional)",
  "tags": "array of strings",
  "dueDate": "timestamp (optional)",
  "reminderDate": "timestamp (optional)",
  "estimatedTime": "number (minutes, optional)",
  "actualTime": "number (minutes, optional)",
  "isRecurring": "boolean",
  "recurringPattern": {
    "type": "daily|weekly|monthly|yearly|custom",
    "interval": "number",
    "endDate": "timestamp (optional)",
    "daysOfWeek": "array (for weekly)"
  },
  "parentTodoId": "string (optional, for subtasks)",
  "attachments": [
    {
      "id": "uuid",
      "fileName": "string",
      "fileUrl": "string",
      "fileSize": "number",
      "mimeType": "string",
      "uploadedAt": "timestamp"
    }
  ],
  "comments": [
    {
      "id": "uuid",
      "text": "string",
      "createdAt": "timestamp"
    }
  ],
  "dependencies": {
    "blockedBy": "array of todo IDs",
    "blocking": "array of todo IDs"
  },
  "completedAt": "timestamp (optional)",
  "isArchived": "boolean",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Category Model
```json
{
  "id": "uuid",
  "userId": "string (foreign key)",
  "name": "string",
  "description": "string (optional)",
  "color": "string (hex color)",
  "icon": "string (optional)",
  "isDefault": "boolean",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Template Model
```json
{
  "id": "uuid",
  "userId": "string (foreign key)",
  "name": "string",
  "description": "string (optional)",
  "todoTemplate": {
    "title": "string",
    "description": "string (optional)",
    "priority": "low|medium|high|urgent",
    "category": "string (optional)",
    "tags": "array of strings",
    "estimatedTime": "number (optional)"
  },
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## 🚀 API Endpoints

### Authentication & Security
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout (invalidate session)
- `POST /api/auth/logout-all` - Logout from all devices
- `POST /api/auth/change-password` - Change password (authenticated)
- `GET /api/auth/sessions` - Get active login sessions
- `DELETE /api/auth/sessions/:id` - Revoke specific session

### User Management
- `GET /api/users/profile` - Get current user profile
- `PUT /api/users/profile` - Update user profile
- `PATCH /api/users/preferences` - Update user preferences
- `GET /api/users/login-history` - Get login history
- `POST /api/users/deactivate` - Deactivate account
- `DELETE /api/users/account` - Permanently delete account
- `GET /api/users/export` - Export user data
- `POST /api/users/import` - Import user data

### Todo Operations
- `GET /api/todos` - Get todos with advanced filtering and pagination
- `POST /api/todos` - Create new todo
- `GET /api/todos/:id` - Get specific todo with subtasks and comments
- `PUT /api/todos/:id` - Update todo completely
- `PATCH /api/todos/:id` - Partially update todo
- `DELETE /api/todos/:id` - Delete todo
- `POST /api/todos/:id/duplicate` - Duplicate todo
- `PATCH /api/todos/:id/status` - Update todo status
- `POST /api/todos/bulk` - Bulk operations (create, update, delete)
- `GET /api/todos/search` - Advanced search with complex queries
- `GET /api/todos/archive` - Get archived todos
- `PATCH /api/todos/:id/archive` - Archive/unarchive todo

### Subtasks
- `GET /api/todos/:id/subtasks` - Get subtasks for a todo
- `POST /api/todos/:id/subtasks` - Create subtask
- `PUT /api/subtasks/:id` - Update subtask
- `DELETE /api/subtasks/:id` - Delete subtask
- `PATCH /api/subtasks/:id/status` - Update subtask status

### Categories & Tags
- `GET /api/categories` - Get user categories
- `POST /api/categories` - Create category
- `PUT /api/categories/:id` - Update category
- `DELETE /api/categories/:id` - Delete category
- `GET /api/tags` - Get user tags with usage statistics
- `POST /api/tags` - Create tag
- `DELETE /api/tags/:id` - Delete tag

### Templates
- `GET /api/templates` - Get user templates
- `POST /api/templates` - Create template
- `PUT /api/templates/:id` - Update template
- `DELETE /api/templates/:id` - Delete template
- `POST /api/templates/:id/use` - Create todo from template

### File Management
- `POST /api/todos/:id/attachments` - Upload file attachment
- `GET /api/todos/:id/attachments` - Get todo attachments
- `DELETE /api/attachments/:id` - Delete attachment
- `GET /api/attachments/:id/download` - Download attachment

### Comments & Notes
- `GET /api/todos/:id/comments` - Get todo comments
- `POST /api/todos/:id/comments` - Add comment to todo
- `PUT /api/comments/:id` - Update comment
- `DELETE /api/comments/:id` - Delete comment

### Analytics & Reports
- `GET /api/analytics/dashboard` - Get dashboard analytics
- `GET /api/analytics/productivity` - Get productivity metrics
- `GET /api/analytics/categories` - Get category statistics
- `GET /api/reports/completion-rates` - Get completion rate reports
- `GET /api/reports/time-tracking` - Get time tracking reports
- `POST /api/reports/export` - Export reports in various formats

### Data Management
- `POST /api/data/backup` - Create data backup
- `GET /api/data/backups` - List available backups
- `POST /api/data/restore` - Restore from backup
- `POST /api/data/export` - Export user data
- `POST /api/data/import` - Import data from local files

### System & Health
- `GET /api/health` - System health check
- `GET /api/version` - API version information
- `GET /api/stats` - System statistics (admin only)

## 📁 Project Structure

```
todo-reactjs-18/
├── client/                     # React frontend
│   ├── public/
│   │   ├── manifest.json      # PWA manifest
│   │   └── sw.js             # Service worker for offline support
│   ├── src/
│   │   ├── components/        # Reusable UI components
│   │   │   ├── auth/         # Authentication components
│   │   │   ├── todo/         # Todo-related components
│   │   │   ├── common/       # Shared UI components
│   │   │   └── layout/       # Layout components
│   │   ├── pages/            # Route/page components
│   │   │   ├── auth/         # Login, register, verify pages
│   │   │   ├── dashboard/    # Main dashboard
│   │   │   ├── todos/        # Todo management pages
│   │   │   ├── profile/      # User profile pages
│   │   │   └── analytics/    # Analytics and reports
│   │   ├── hooks/            # Custom React hooks
│   │   │   ├── useAuth.js    # Authentication hook
│   │   │   ├── useTodos.js   # Todo management hook
│   │   │   └── useLocalStorage.js # Local storage hook
│   │   ├── services/         # API service functions
│   │   │   ├── api.js        # Base API configuration
│   │   │   ├── auth.js       # Authentication services
│   │   │   ├── todos.js      # Todo CRUD services
│   │   │   └── analytics.js  # Analytics services
│   │   ├── contexts/         # React contexts
│   │   │   ├── AuthContext.js
│   │   │   ├── TodoContext.js
│   │   │   └── ThemeContext.js
│   │   ├── utils/            # Utility functions
│   │   │   ├── validation.js # Input validation
│   │   │   ├── dateUtils.js  # Date/time utilities
│   │   │   ├── storage.js    # Storage utilities
│   │   │   └── constants.js  # App constants
│   │   ├── styles/           # CSS/styling files
│   │   │   ├── globals.css
│   │   │   ├── themes/       # Light/dark themes
│   │   │   └── components/   # Component styles
│   │   ├── assets/           # Static assets
│   │   │   ├── images/
│   │   │   ├── icons/
│   │   │   └── fonts/
│   │   └── i18n/            # Internationalization
│   │       ├── en.json
│   │       ├── es.json
│   │       └── fr.json
│   ├── tests/               # Frontend tests
│   │   ├── components/
│   │   ├── pages/
│   │   └── utils/
│   └── package.json
├── server/                  # Express backend
│   ├── src/
│   │   ├── routes/          # API route handlers
│   │   │   ├── auth.js
│   │   │   ├── users.js
│   │   │   ├── todos.js
│   │   │   ├── categories.js
│   │   │   ├── templates.js
│   │   │   └── analytics.js
│   │   ├── controllers/     # Route controllers
│   │   │   ├── authController.js
│   │   │   ├── userController.js
│   │   │   ├── todoController.js
│   │   │   └── analyticsController.js
│   │   ├── middleware/      # Custom middleware
│   │   │   ├── auth.js      # Authentication middleware
│   │   │   ├── validation.js # Request validation
│   │   │   ├── rateLimit.js # Rate limiting
│   │   │   ├── cors.js      # CORS configuration
│   │   │   └── errorHandler.js # Error handling
│   │   ├── models/          # Data models and schemas
│   │   │   ├── User.js
│   │   │   ├── Todo.js
│   │   │   ├── Category.js
│   │   │   └── Template.js
│   │   ├── services/        # Business logic services
│   │   │   ├── authService.js
│   │   │   ├── todoService.js
│   │   │   ├── fileService.js
│   │   │   └── analyticsService.js
│   │   ├── utils/           # Server utilities
│   │   │   ├── database.js  # Database operations
│   │   │   ├── encryption.js # Encryption utilities
│   │   │   ├── logger.js    # Logging configuration
│   │   │   ├── validation.js # Data validation
│   │   │   └── helpers.js   # General helpers
│   │   └── config/          # Configuration files
│   │       ├── database.js
│   │       ├── jwt.js
│   │       └── storage.js
│   ├── tests/              # Backend tests
│   │   ├── unit/
│   │   ├── integration/
│   │   └── fixtures/
│   ├── logs/               # Application logs
│   └── package.json
├── database/               # JSON Server database
│   ├── users.json         # User data
│   ├── todos.json         # Todo data
│   ├── categories.json    # Category data
│   ├── templates.json     # Template data
│   ├── attachments/       # File attachments
│   └── backups/           # Database backups
├── docs/                  # Documentation
│   ├── api.md            # API documentation
│   ├── setup.md          # Setup guide
│   ├── deployment.md     # Deployment guide
│   └── architecture.md   # Architecture overview
├── scripts/              # Build and deployment scripts
│   ├── build.sh
│   ├── deploy.sh
│   └── backup.sh
├── docker/              # Docker configuration
│   ├── Dockerfile.client
│   ├── Dockerfile.server
│   └── docker-compose.yml
├── .github/             # GitHub workflows
│   └── workflows/
│       ├── ci.yml
│       └── deploy.yml
├── .env.example         # Environment variables template
├── .gitignore
├── LICENSE
└── README.md
```

## 📚 Documentation & Setup Guides

### Comprehensive Server Setup and Testing Guides

This project includes detailed setup and testing documentation for each component:

#### 🚀 **[Master Startup Guide](STARTUP_GUIDE.md)** - **START HERE**
Complete setup instructions for all servers with comprehensive testing workflow including mock data examples for every operation.

#### 📊 **[JSON Server Guide](JSON_SERVER_GUIDE.md)** 
Detailed setup and testing guide for the JSON Server database layer (port 3001):
- Installation and configuration
- Database schema and relationships  
- Direct API testing with CURL
- Query parameters and filtering
- Troubleshooting and monitoring

#### 🖥️ **[Express API Guide](EXPRESS_API_GUIDE.md)**
Complete setup and testing guide for the Express REST API (port 5000):
- Authentication and JWT setup
- All API endpoints with examples
- Security features and rate limiting
- Error handling and validation
- Performance optimization

#### 📖 **[Swagger UI Guide](SWAGGER_UI_GUIDE.md)**
Interactive API documentation and testing interface (port 8080):
- Swagger UI setup and configuration
- Interactive endpoint testing
- Authentication workflow
- CURL command generation
- CORS configuration for external access

#### 🧪 **[CURL Testing Guide](CURL_TESTING_GUIDE.md)**
Comprehensive command-line API testing with mock data:
- Complete CURL testing procedures for all endpoints
- Mock data examples for every operation
- Authentication flow testing with real examples
- Performance testing and error scenario validation
- Automated test scripts and troubleshooting

#### 📋 **[Project Status Checklist](PROJECT_STATUS_CHECKLIST.md)**
Complete project status tracking and development roadmap:
- Detailed checklist of completed and pending tasks
- Current development phase (Backend complete, Frontend pending)
- Next steps and priority recommendations
- Project metrics and completion statistics
- Technical considerations and known issues

### Quick Reference Commands

```bash
# Start all servers (automated)
./start-servers.sh

# Or start individually:
cd Database && npm start        # Port 3001 - JSON Server
cd Back-End && npm start        # Port 5000 - Express API  
cd swagger-ui && npm start      # Port 8080 - Swagger UI

# Run comprehensive tests
cd curl-scripts && ./run-all-tests.sh

# Access services:
# Swagger UI:     http://localhost:8080
# Express API:    http://localhost:5000/api/health
# JSON Server:    http://localhost:3001/users
```

## � Quick Start Guide

### Prerequisites
- Node.js (v16 or higher)
- npm or yarn
- Git

### 📂 3-Server Architecture

This application is organized into three main servers:
1. **Database** - JSON Server (Port 3001) - File-based database with management scripts
2. **Back-End** - Express.js API (Port 5000) - REST API server with JWT authentication  
3. **Swagger UI** - Documentation & Testing (Port 8080) - Interactive API documentation

### Development Workflow

The development follows this sequence:
1. **First**: Start Database (JSON Server)
2. **Second**: Start Back-End (Express.js REST API)  
3. **Third**: Start Swagger UI (Documentation & Testing)

### Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/cloudshare360/todo-reactjs-18.git
   cd todo-reactjs-18
   ```

2. **Setup Database (JSON Server)**
   ```bash
   # Install JSON Server dependencies
   cd Database
   npm install
   
   # Start JSON Server (Port 3001)
   npm start
   # OR using scripts
   cd scripts && ./start-server.sh
   ```

3. **Setup Back-End (Express.js API)**
   ```bash
   # Install backend dependencies
   cd Back-End
   npm install
   
   # Create environment file
   cp .env.example .env
   # Edit .env with your configuration
   
   # Start Express server (Port 5000)
   npm run dev
   ```

4. **Setup Front-End (React App)**
   ```bash
   # Install frontend dependencies (will be created next)
   cd Front-End
   npm install
   
   # Start React development server (Port 3000)
   npm start
   ```

5. **Start All Services (3 Terminals)**
   ```bash
   # Terminal 1: Database (Port 3001)
   cd Database && npm start

   # Terminal 2: Back-End API (Port 5000)  
   cd Back-End && npm run dev

   # Terminal 3: Front-End React (Port 3000)
   cd Front-End && npm start
   ```

6. **Access the application**
   - Frontend React App: http://localhost:3000
   - Backend Express API: http://localhost:5000  
   - JSON Server Database: http://localhost:3001
   - Health Check: http://localhost:5000/health

## 🔄 Implementation Status

### ✅ Completed
- **Database Folder**: ✅ Complete
  - JSON data files (users, todos, relations)
  - Management scripts (start, stop, restart)
  - Sample data and documentation
  
- **Back-End Folder**: ✅ Complete  
  - Express.js server with JWT authentication
  - REST API routes (auth, users, todos, categories)
  - Middleware (auth, error handling, logging)
  - Database service for JSON Server integration

### 🔄 In Progress  
- **Front-End Folder**: 🚧 Next Step
  - React 18 application to be created
  - Components, pages, and services
  - Integration with Back-End API

## 🧪 Testing

```bash
# Run frontend tests
cd client && npm test

# Run backend tests
cd server && npm test

# Run all tests
npm run test:all
```

## 🚀 Production Deployment

### Build for Production
```bash
# Build React app
cd client && npm run build

# The build files will be in client/build/
```

### Environment Configuration
- Set production environment variables
- Configure proper CORS settings
- Set up SSL certificates
- Configure database backup strategy

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔒 Security Considerations

- Passwords are hashed using bcrypt
- JWT tokens for secure authentication
- Input validation and sanitization
- Protected API routes
- CORS configuration for cross-origin requests

## 🎯 Future Enhancements

- Real-time collaboration between users
- Todo sharing and team workspaces  
- Mobile app version (PWA enhancement)
- Advanced analytics and reporting dashboard
- Drag-and-drop todo organization
- Custom todo views and layouts