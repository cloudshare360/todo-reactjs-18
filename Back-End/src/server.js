const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const path = require('path');
require('dotenv').config();

// Import routes
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const todoRoutes = require('./routes/todos');
const categoryRoutes = require('./routes/categories');

// Import middleware
const errorHandler = require('./middleware/errorHandler');
const requestLogger = require('./middleware/requestLogger');

const app = express();
const PORT = process.env.PORT || 5000;

// Dynamic CORS Configuration - Resolves current environment
const getDynamicAllowedOrigins = () => {
  const origins = [
    // Local development
    'http://localhost:3000',
    'http://localhost:3001', 
    'http://localhost:5000',
    'http://localhost:8080',
    'http://127.0.0.1:3000',
    'http://127.0.0.1:3001',
    'http://127.0.0.1:5000',
    'http://127.0.0.1:8080'
  ];

  // Environment variables
  if (process.env.CLIENT_URL) {
    origins.push(process.env.CLIENT_URL);
  }

  // GitHub Codespaces dynamic resolution
  if (process.env.CODESPACE_NAME && process.env.GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN) {
    const codespaceBase = `${process.env.CODESPACE_NAME}.${process.env.GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}`;
    console.log(`🔗 Detected GitHub Codespace: ${codespaceBase}`);
    
    // Add specific ports for this codespace
    const ports = ['3000', '3001', '5000', '8080', '4173', '5173'];
    ports.forEach(port => {
      origins.push(`https://${codespaceBase.replace(/\{\{port\}\}/, port)}`);
      origins.push(`https://${codespaceBase}-${port}`);
    });
  }

  // Generic patterns as fallback
  const patterns = [
    /^https:\/\/.*\.app\.github\.dev$/,
    /^http:\/\/.*\.app\.github\.dev$/,
    /^https:\/\/.*\.githubpreview\.dev$/,
    /^https:\/\/.*\.preview\.app\.github\.dev$/,
    /^https:\/\/.*\.ngrok\.io$/,
    /^https:\/\/.*\.vercel\.app$/
  ];

  return [...origins, ...patterns];
};

const allowedOrigins = getDynamicAllowedOrigins();

app.use(cors({
  origin: function (origin, callback) {
    // Always allow requests with no origin (like mobile apps, curl, Postman, etc.)
    if (!origin) return callback(null, true);
    
    // Check if origin matches any allowed pattern
    if (allowedOrigins.some(allowed => 
      allowed instanceof RegExp ? allowed.test(origin) : allowed === origin
    )) {
      callback(null, true);
    } else {
      // Log the rejected origin for debugging
      console.log(`🚫 CORS blocked origin: ${origin}`);
      callback(null, true); // Allow all origins in development (change to false in production)
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS', 'HEAD'],
  allowedHeaders: [
    'Content-Type', 
    'Authorization', 
    'X-Requested-With',
    'Accept',
    'Origin',
    'Access-Control-Request-Method',
    'Access-Control-Request-Headers'
  ],
  exposedHeaders: ['X-RateLimit-Limit', 'X-RateLimit-Remaining', 'X-RateLimit-Reset']
}));

app.use(morgan('combined'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(requestLogger);

// Static files for uploads
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    version: process.env.npm_package_version || '1.0.0'
  });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/todos', todoRoutes);
app.use('/api/categories', categoryRoutes);

// Default route
app.get('/', (req, res) => {
  res.json({
    message: 'Todo App REST API Server',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      auth: '/api/auth',
      users: '/api/users', 
      todos: '/api/todos',
      categories: '/api/categories'
    },
    documentation: '/api/docs'
  });
});

// Handle 404 routes
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Route not found',
    message: `The requested route ${req.originalUrl} does not exist`,
    availableRoutes: [
      '/api/auth/*',
      '/api/users/*',
      '/api/todos/*',
      '/api/categories/*'
    ]
  });
});

// Error handling middleware (should be last)
app.use(errorHandler);

// Start server
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
  console.log(`📖 API docs: http://localhost:${PORT}/`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received. Shutting down gracefully...');
  server.close(() => {
    console.log('Process terminated');
  });
});

module.exports = app;