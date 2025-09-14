const requestLogger = (req, res, next) => {
  const start = Date.now();
  
  // Log request
  console.log(`📥 ${req.method} ${req.url} - ${new Date().toISOString()}`);
  
  // Log request body (excluding sensitive data)
  if (req.body && Object.keys(req.body).length > 0) {
    const sanitizedBody = { ...req.body };
    
    // Remove sensitive fields from logs
    delete sanitizedBody.password;
    delete sanitizedBody.token;
    
    console.log('📋 Request Body:', JSON.stringify(sanitizedBody, null, 2));
  }

  // Override res.json to log response
  const originalJson = res.json;
  res.json = function(body) {
    const duration = Date.now() - start;
    
    console.log(`📤 ${req.method} ${req.url} - ${res.statusCode} - ${duration}ms`);
    
    // Log response body (excluding sensitive data) 
    if (body && typeof body === 'object') {
      const sanitizedResponse = { ...body };
      
      // Remove sensitive fields from logs
      if (sanitizedResponse.data?.password) delete sanitizedResponse.data.password;
      if (sanitizedResponse.token) sanitizedResponse.token = '[REDACTED]';
      
      console.log('📋 Response:', JSON.stringify(sanitizedResponse, null, 2));
    }
    
    return originalJson.call(this, body);
  };

  next();
};

module.exports = requestLogger;