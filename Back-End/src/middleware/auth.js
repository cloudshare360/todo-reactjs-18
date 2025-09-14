const jwt = require('jsonwebtoken');
const axios = require('axios');

const auth = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({
        success: false,
        error: { message: 'Access denied. No token provided.' }
      });
    }

    // Verify JWT token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Fetch user from JSON Server to ensure user still exists
    try {
      const response = await axios.get(`${process.env.DATABASE_URL}/users/${decoded.userId}`);
      
      if (!response.data || !response.data.isActive) {
        return res.status(401).json({
          success: false,
          error: { message: 'User account is inactive or not found.' }
        });
      }

      req.user = response.data;
      req.userId = decoded.userId;
      next();
    } catch (dbError) {
      return res.status(401).json({
        success: false,
        error: { message: 'User not found.' }
      });
    }

  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        error: { message: 'Invalid token.' }
      });
    }
    
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        error: { message: 'Token expired.' }
      });
    }

    res.status(500).json({
      success: false,
      error: { message: 'Server error during authentication.' }
    });
  }
};

module.exports = auth;