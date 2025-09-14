const express = require('express');
const { body, validationResult } = require('express-validator');
const auth = require('../middleware/auth');
const db = require('../services/database');

const router = express.Router();

// @route   GET /api/users/profile
// @desc    Get current user profile
// @access  Private
router.get('/profile', auth, (req, res) => {
  const { password, ...userWithoutPassword } = req.user;
  
  res.json({
    success: true,
    data: {
      user: userWithoutPassword
    }
  });
});

// @route   PUT /api/users/profile
// @desc    Update user profile
// @access  Private
router.put('/profile', auth, [
  body('firstName')
    .optional()
    .isLength({ min: 1, max: 50 })
    .withMessage('First name must be 1-50 characters long')
    .trim(),
  body('lastName')
    .optional()
    .isLength({ min: 1, max: 50 })
    .withMessage('Last name must be 1-50 characters long')
    .trim(),
  body('email')
    .optional()
    .isEmail()
    .withMessage('Please provide a valid email')
    .normalizeEmail()
], async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: { 
          message: 'Validation failed',
          details: errors.array()
        }
      });
    }

    const { firstName, lastName, email } = req.body;

    // Check if email is being changed and if it already exists
    if (email && email !== req.user.email) {
      const existingUser = await db.findUserByEmail(email);
      if (existingUser) {
        return res.status(400).json({
          success: false,
          error: { message: 'Email is already in use' }
        });
      }
    }

    const updateData = {};
    if (firstName !== undefined) updateData.firstName = firstName;
    if (lastName !== undefined) updateData.lastName = lastName;
    if (email !== undefined) updateData.email = email;

    const updatedUser = await db.partialUpdate('users', req.userId, updateData);
    
    // Remove password from response
    const { password, ...userWithoutPassword } = updatedUser;

    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: {
        user: userWithoutPassword
      }
    });

  } catch (error) {
    next(error);
  }
});

// @route   PATCH /api/users/preferences
// @desc    Update user preferences
// @access  Private
router.patch('/preferences', auth, [
  body('preferences.theme')
    .optional()
    .isIn(['light', 'dark', 'system'])
    .withMessage('Theme must be light, dark, or system'),
  body('preferences.language')
    .optional()
    .isLength({ min: 2, max: 5 })
    .withMessage('Language code must be 2-5 characters'),
  body('preferences.timezone')
    .optional()
    .isLength({ min: 1, max: 50 })
    .withMessage('Timezone must be 1-50 characters'),
  body('preferences.notifications.browser')
    .optional()
    .isBoolean()
    .withMessage('Browser notifications preference must be boolean'),
  body('preferences.notifications.inApp')
    .optional()
    .isBoolean()
    .withMessage('In-app notifications preference must be boolean')
], async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: { 
          message: 'Validation failed',
          details: errors.array()
        }
      });
    }

    const { preferences } = req.body;
    
    // Merge with existing preferences
    const updatedPreferences = {
      ...req.user.preferences,
      ...preferences,
      notifications: {
        ...req.user.preferences.notifications,
        ...preferences.notifications
      }
    };

    const updatedUser = await db.partialUpdate('users', req.userId, {
      preferences: updatedPreferences
    });
    
    // Remove password from response
    const { password, ...userWithoutPassword } = updatedUser;

    res.json({
      success: true,
      message: 'Preferences updated successfully',
      data: {
        user: userWithoutPassword
      }
    });

  } catch (error) {
    next(error);
  }
});

// @route   POST /api/users/deactivate
// @desc    Deactivate user account
// @access  Private
router.post('/deactivate', auth, async (req, res, next) => {
  try {
    await db.partialUpdate('users', req.userId, {
      isActive: false,
      deactivatedAt: new Date().toISOString()
    });

    res.json({
      success: true,
      message: 'Account deactivated successfully'
    });

  } catch (error) {
    next(error);
  }
});

// @route   DELETE /api/users/account
// @desc    Permanently delete user account and all data
// @access  Private
router.delete('/account', auth, async (req, res, next) => {
  try {
    // Delete all user's todos
    const userTodos = await db.findTodosByUser(req.userId);
    for (const todo of userTodos) {
      await db.delete('todos', todo.id);
    }

    // Delete user account
    await db.delete('users', req.userId);

    res.json({
      success: true,
      message: 'Account and all associated data deleted successfully'
    });

  } catch (error) {
    next(error);
  }
});

// @route   GET /api/users/stats
// @desc    Get user statistics
// @access  Private
router.get('/stats', auth, async (req, res, next) => {
  try {
    const todos = await db.findTodosByUser(req.userId);
    
    const stats = {
      totalTodos: todos.length,
      completedTodos: todos.filter(todo => todo.status === 'completed').length,
      pendingTodos: todos.filter(todo => todo.status === 'pending').length,
      inProgressTodos: todos.filter(todo => todo.status === 'in-progress').length,
      overdueTodos: todos.filter(todo => 
        todo.dueDate && 
        new Date(todo.dueDate) < new Date() && 
        todo.status !== 'completed'
      ).length,
      completionRate: todos.length > 0 ? 
        Math.round((todos.filter(todo => todo.status === 'completed').length / todos.length) * 100) : 0,
      categoryCounts: todos.reduce((acc, todo) => {
        acc[todo.category] = (acc[todo.category] || 0) + 1;
        return acc;
      }, {}),
      priorityCounts: todos.reduce((acc, todo) => {
        acc[todo.priority] = (acc[todo.priority] || 0) + 1;
        return acc;
      }, {})
    };

    res.json({
      success: true,
      data: { stats }
    });

  } catch (error) {
    next(error);
  }
});

module.exports = router;