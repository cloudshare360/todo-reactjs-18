const jsonServer = require('json-server');
const cors = require('./cors-middleware');
const path = require('path');

const server = jsonServer.create();
const router = jsonServer.router('db.json');
const middlewares = jsonServer.defaults({
  static: './public'
});

// Custom CORS middleware
server.use(cors);

// Default middlewares (logger, static, cors and no-cache)
server.use(middlewares);

// Custom routes (if routes.json exists)
const routesPath = path.join(__dirname, 'routes.json');
try {
  const routes = require(routesPath);
  const rewriter = jsonServer.rewriter(routes);
  server.use(rewriter);
  console.log('📝 Custom routes loaded from routes.json');
} catch (error) {
  console.log('ℹ️  No custom routes file found, using default routes');
}

// Use default router
server.use(router);

// Start server
const PORT = process.env.PORT || 3001;
const HOST = process.env.HOST || '0.0.0.0';

server.listen(PORT, HOST, () => {
  console.log(`🚀 JSON Server running on http://${HOST}:${PORT}`);
  console.log('📋 Available resources:');
  console.log('  - GET    /users');
  console.log('  - GET    /todos'); 
  console.log('  - GET    /categories');
  console.log('  - GET    /user-todo-relations');
  console.log('  - GET    /db (full database)');
  console.log('🌐 CORS enabled for GitHub Codespaces and local development');
});

module.exports = server;