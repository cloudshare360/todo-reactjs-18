// Dynamic CORS middleware for JSON Server
module.exports = (req, res, next) => {
  const getDynamicOrigins = () => {
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
      
      const ports = ['3000', '3001', '5000', '8080', '4173', '5173'];
      ports.forEach(port => {
        // Try both URL patterns that GitHub Codespaces might use
        origins.push(`https://${codespaceBase.replace(/\{\{port\}\}/, port)}`);
        origins.push(`https://${codespaceBase}-${port}`);
        origins.push(`https://${process.env.CODESPACE_NAME}-${port}.${process.env.GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}`);
      });
    }

    return origins;
  };

  const allowedOrigins = getDynamicOrigins();
  const origin = req.headers.origin;
  
  // Check if origin is allowed
  const isOriginAllowed = !origin || 
    allowedOrigins.includes(origin) || 
    /^https:\/\/.*\.app\.github\.dev$/.test(origin) ||
    /^http:\/\/.*\.app\.github\.dev$/.test(origin) ||
    /^https:\/\/.*\.githubpreview\.dev$/.test(origin) ||
    /^https:\/\/.*\.preview\.app\.github\.dev$/.test(origin);

  if (isOriginAllowed) {
    res.header('Access-Control-Allow-Origin', origin || '*');
  }

  res.header('Access-Control-Allow-Credentials', 'true');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS, HEAD');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization, Cache-Control, Pragma');
  res.header('Access-Control-Expose-Headers', 'Content-Length, Content-Range, X-Total-Count');

  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    res.sendStatus(200);
  } else {
    next();
  }
};