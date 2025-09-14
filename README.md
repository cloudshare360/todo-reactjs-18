# Todo ReactJS 18 Application

A modern, full-stack todo application built with ReactJS 18, featuring user authentication, profile management, and comprehensive CRUD operations.

## 📋 Overview

This project is a complete todo management system that allows users to create accounts, manage their personal todo lists, and update their profiles. The application follows modern web development practices with a React frontend, Express.js backend, and JSON Server for data persistence.

## ✨ Features

### User Management
- **User Registration**: New users can create accounts with email validation
- **User Authentication**: Secure login/logout functionality with session management
- **Password Reset**: Users can reset their passwords via email or security questions
- **Profile Management**: Users can view and update their personal information
- **Authorization**: Role-based access control ensuring users only access their own data

### Todo Management
- **Create Todos**: Add new tasks with title, description, due date, and priority
- **Read Todos**: View all personal todos with filtering and sorting options
- **Update Todos**: Edit existing todos including status changes (pending/completed)
- **Delete Todos**: Remove todos individually or in bulk
- **Search & Filter**: Find todos by title, status, priority, or due date
- **Categories**: Organize todos into custom categories

### User Experience
- **Responsive Design**: Mobile-first, responsive UI that works on all devices
- **Real-time Updates**: Instant feedback for all user actions
- **Data Persistence**: All changes are automatically saved
- **Secure Access**: Protected routes ensuring only authenticated users access their data

## 🛠 Tech Stack

### Frontend
- **React 18** - Latest React with concurrent features
- **React Router** - Client-side routing and navigation
- **Axios** - HTTP client for API requests
- **CSS Modules/Styled Components** - Component styling
- **React Hook Form** - Form validation and management

### Backend
- **Node.js** - JavaScript runtime environment
- **Express.js** - Web application framework
- **JSON Server** - Mock REST API and database
- **JWT** - JSON Web Tokens for authentication
- **bcrypt** - Password hashing and security
- **CORS** - Cross-origin resource sharing
- **Morgan** - HTTP request logger

### Database
- **JSON Server** - File-based database using JSON
- **File Structure**: Separate JSON files for users and todos
- **Data Validation**: Schema validation for all data operations

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
  "status": "pending|completed",
  "priority": "low|medium|high",
  "category": "string (optional)",
  "dueDate": "timestamp (optional)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## 🚀 API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout
- `POST /api/auth/reset-password` - Password reset

### User Management
- `GET /api/users/profile` - Get current user profile
- `PUT /api/users/profile` - Update user profile
- `DELETE /api/users/account` - Delete user account

### Todo Operations
- `GET /api/todos` - Get all user todos (with query parameters for filtering)
- `POST /api/todos` - Create new todo
- `GET /api/todos/:id` - Get specific todo
- `PUT /api/todos/:id` - Update todo
- `DELETE /api/todos/:id` - Delete todo
- `PATCH /api/todos/:id/status` - Update todo status

## 📁 Project Structure

```
todo-reactjs-18/
├── client/                 # React frontend
│   ├── public/
│   ├── src/
│   │   ├── components/     # Reusable UI components
│   │   ├── pages/         # Route components
│   │   ├── hooks/         # Custom React hooks
│   │   ├── services/      # API service functions
│   │   ├── contexts/      # React contexts
│   │   ├── utils/         # Utility functions
│   │   └── styles/        # CSS/styling files
│   └── package.json
├── server/                # Express backend
│   ├── routes/           # API route handlers
│   ├── middleware/       # Custom middleware
│   ├── controllers/      # Route controllers
│   ├── models/          # Data models
│   ├── utils/           # Server utilities
│   └── package.json
├── database/            # JSON Server database
│   ├── users.json      # User data
│   └── todos.json      # Todo data
├── docs/               # Documentation
└── README.md
```

## 🔧 Installation & Setup

### Prerequisites
- Node.js (v16 or higher)
- npm or yarn
- Git

### Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/cloudshare360/todo-reactjs-18.git
   cd todo-reactjs-18
   ```

2. **Install dependencies**
   ```bash
   # Install server dependencies
   cd server && npm install

   # Install client dependencies
   cd ../client && npm install

   # Install JSON Server globally (optional)
   npm install -g json-server
   ```

3. **Setup environment variables**
   ```bash
   # Create .env file in server directory
   cp server/.env.example server/.env
   
   # Update environment variables
   JWT_SECRET=your_jwt_secret_key
   PORT=5000
   CLIENT_URL=http://localhost:3000
   ```

4. **Initialize database**
   ```bash
   # Create initial JSON files
   mkdir database
   echo '[]' > database/users.json
   echo '[]' > database/todos.json
   ```

5. **Start development servers**
   ```bash
   # Terminal 1: Start JSON Server (Port 3001)
   cd database && json-server --watch users.json todos.json --port 3001

   # Terminal 2: Start Express Server (Port 5000)
   cd server && npm run dev

   # Terminal 3: Start React Client (Port 3000)
   cd client && npm start
   ```

6. **Access the application**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:5000
   - JSON Server: http://localhost:3001

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

- Real-time collaboration
- Todo sharing between users
- Email notifications for due dates
- Mobile app version
- Integration with calendar applications
- Advanced analytics and reporting