const express = require('express');
const path = require('path');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();
const PORT = 8080;

// Dynamic CORS Configuration for GitHub Codespaces
const getDynamicOrigins = () => {
  const origins = [];

  // Environment variables
  if (process.env.CLIENT_URL) {
    origins.push(process.env.CLIENT_URL);
  }

  // GitHub Codespaces dynamic resolution
  if (process.env.CODESPACE_NAME && process.env.GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN) {
    const codespaceBase = `${process.env.CODESPACE_NAME}.${process.env.GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}`;
    console.log(`🔗 Swagger Proxy: Detected GitHub Codespace: ${codespaceBase}`);
    
    const ports = ['3000', '3001', '5000', '8080', '4173', '5173'];
    ports.forEach(port => {
      origins.push(`https://${process.env.CODESPACE_NAME}-${port}.${process.env.GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}`);
    });
  }

  return origins;
};

app.use((req, res, next) => {
  const origin = req.headers.origin;
  const dynamicOrigins = getDynamicOrigins();
  
  // Allow requests from dynamic origins, GitHub Codespaces domains, or local development
  const allowedPatterns = [
    /^https:\/\/.*\.app\.github\.dev$/,
    /^http:\/\/.*\.app\.github\.dev$/,
    /^https:\/\/.*\.githubpreview\.dev$/,
    /^https:\/\/.*\.preview\.app\.github\.dev$/,
    /^http:\/\/localhost:\d+$/,
    /^http:\/\/127\.0\.0\.1:\d+$/
  ];

  const isOriginAllowed = !origin || 
    origin.includes('localhost') || 
    origin.includes('127.0.0.1') ||
    dynamicOrigins.includes(origin) ||
    allowedPatterns.some(pattern => pattern.test(origin));

  if (isOriginAllowed) {
    res.header('Access-Control-Allow-Origin', origin || '*');
  }

  res.header('Access-Control-Allow-Credentials', 'true');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS, HEAD');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization, Cache-Control');

  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }
  
  next();
});

// Serve static files from swagger-ui directory
app.use(express.static(path.join(__dirname)));

// Proxy API requests to the Express server
app.use('/api-proxy', createProxyMiddleware({
  target: 'http://localhost:5000',
  changeOrigin: true,
  pathRewrite: {
    '^/api-proxy': '', // Remove /api-proxy from the path
  },
  onError: (err, req, res) => {
    console.error('Proxy error:', err);
    res.status(500).json({ 
      error: 'Proxy error', 
      message: 'Unable to connect to API server. Make sure Express server is running on port 5000.',
      details: err.message 
    });
  },
  logLevel: 'debug'
}));

// Health check for the proxy server itself
app.get('/proxy-health', (req, res) => {
  res.json({
    status: 'OK',
    message: 'Swagger UI Proxy Server',
    timestamp: new Date().toISOString(),
    apiTarget: 'http://localhost:5000'
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🌐 Swagger UI Proxy Server running on http://0.0.0.0:${PORT}`);
  console.log(`📖 Swagger UI: http://localhost:${PORT}`);
  console.log(`🔗 API Proxy: http://localhost:${PORT}/api-proxy`);
  console.log(`❤️ Health Check: http://localhost:${PORT}/proxy-health`);
  console.log(`🌍 External access: Available on GitHub Codespaces forwarded port`);
});