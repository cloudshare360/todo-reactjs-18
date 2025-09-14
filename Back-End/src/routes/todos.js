const express = require('express');
const { body, query, validationResult } = require('express-validator');
const auth = require('../middleware/auth');
const db = require('../services/database');

const router = express.Router();

// Validation rules
const todoValidation = [
  body('title')
    .isLength({ min: 1, max: 200 })
    .withMessage('Title is required and must be less than 200 characters')
    .trim(),
  body('description')
    .optional()
    .isLength({ max: 1000 })
    .withMessage('Description must be less than 1000 characters')
    .trim(),
  body('status')
    .optional()
    .isIn(['pending', 'in-progress', 'completed'])
    .withMessage('Status must be pending, in-progress, or completed'),
  body('priority')
    .optional()
    .isIn(['low', 'medium', 'high', 'urgent'])
    .withMessage('Priority must be low, medium, high, or urgent'),
  body('category')
    .optional()
    .isLength({ max: 50 })
    .withMessage('Category must be less than 50 characters')
    .trim(),
  body('dueDate')
    .optional()
    .isISO8601()
    .withMessage('Due date must be a valid ISO 8601 date'),
  body('tags')
    .optional()
    .isArray()
    .withMessage('Tags must be an array'),
  body('tags.*')
    .optional()
    .isLength({ min: 1, max: 30 })
    .withMessage('Each tag must be 1-30 characters long')
];

// @route   GET /api/todos
// @desc    Get all todos for the authenticated user
// @access  Private
router.get('/', auth, [
  query('status').optional().isIn(['pending', 'in-progress', 'completed']),
  query('priority').optional().isIn(['low', 'medium', 'high', 'urgent']),
  query('category').optional().isLength({ max: 50 }),
  query('page').optional().isInt({ min: 1 }),
  query('limit').optional().isInt({ min: 1, max: 100 }),
  query('search').optional().isLength({ max: 100 })
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

    const { 
      status, 
      priority, 
      category, 
      search,
      page = 1, 
      limit = 10,
      sortBy = 'createdAt',
      sortOrder = 'desc'
    } = req.query;

    // Build query parameters
    let params = { userId: req.userId };
    
    if (status) params.status = status;
    if (priority) params.priority = priority;
    if (category) params.category = category;

    // Get todos from database
    let todos = await db.findTodosByUser(req.userId, params);

    // Apply search filter if provided
    if (search) {
      const searchLower = search.toLowerCase();
      todos = todos.filter(todo => 
        todo.title.toLowerCase().includes(searchLower) ||
        (todo.description && todo.description.toLowerCase().includes(searchLower)) ||
        (todo.tags && todo.tags.some(tag => tag.toLowerCase().includes(searchLower)))
      );
    }

    // Sort todos
    todos.sort((a, b) => {
      let aValue = a[sortBy];
      let bValue = b[sortBy];

      if (sortBy === 'createdAt' || sortBy === 'updatedAt' || sortBy === 'dueDate') {
        aValue = new Date(aValue);
        bValue = new Date(bValue);
      }

      if (sortOrder === 'desc') {
        return bValue > aValue ? 1 : -1;
      } else {
        return aValue > bValue ? 1 : -1;
      }
    });

    // Apply pagination
    const startIndex = (parseInt(page) - 1) * parseInt(limit);
    const endIndex = startIndex + parseInt(limit);
    const paginatedTodos = todos.slice(startIndex, endIndex);

    res.json({
      success: true,
      data: {
        todos: paginatedTodos,
        pagination: {
          currentPage: parseInt(page),
          totalPages: Math.ceil(todos.length / parseInt(limit)),
          totalItems: todos.length,
          limit: parseInt(limit)
        },
        filters: {
          status,
          priority,
          category,
          search
        }
      }
    });

  } catch (error) {
    next(error);
  }
});

// @route   GET /api/todos/:id
// @desc    Get todo by ID
// @access  Private
router.get('/:id', auth, async (req, res, next) => {
  try {
    const todo = await db.findById('todos', req.params.id);
    
    if (!todo) {
      return res.status(404).json({
        success: false,
        error: { message: 'Todo not found' }
      });
    }

    // Check if todo belongs to the authenticated user
    if (todo.userId !== req.userId) {
      return res.status(403).json({
        success: false,
        error: { message: 'Access denied' }
      });
    }

    res.json({
      success: true,
      data: { todo }
    });

  } catch (error) {
    next(error);
  }
});

// @route   POST /api/todos
// @desc    Create a new todo
// @access  Private
router.post('/', auth, todoValidation, async (req, res, next) => {
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

    const todoData = {
      userId: req.userId,
      title: req.body.title,
      description: req.body.description || '',
      status: req.body.status || 'pending',
      priority: req.body.priority || 'medium',
      category: req.body.category || 'General',
      tags: req.body.tags || [],
      dueDate: req.body.dueDate || null,
      reminderDate: req.body.reminderDate || null,
      estimatedTime: req.body.estimatedTime || null,
      actualTime: null,
      isRecurring: req.body.isRecurring || false,
      recurringPattern: req.body.recurringPattern || null,
      parentTodoId: req.body.parentTodoId || null,
      attachments: [],
      comments: [],
      dependencies: {
        blockedBy: [],
        blocking: []
      },
      completedAt: null,
      isArchived: false
    };

    const createdTodo = await db.create('todos', todoData);

    res.status(201).json({
      success: true,
      message: 'Todo created successfully',
      data: { todo: createdTodo }
    });

  } catch (error) {
    next(error);
  }
});

// @route   PUT /api/todos/:id
// @desc    Update todo
// @access  Private
router.put('/:id', auth, todoValidation, async (req, res, next) => {
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

    const todo = await db.findById('todos', req.params.id);
    
    if (!todo) {
      return res.status(404).json({
        success: false,
        error: { message: 'Todo not found' }
      });
    }

    // Check if todo belongs to the authenticated user
    if (todo.userId !== req.userId) {
      return res.status(403).json({
        success: false,
        error: { message: 'Access denied' }
      });
    }

    const updateData = {
      ...todo,
      title: req.body.title,
      description: req.body.description || '',
      status: req.body.status || todo.status,
      priority: req.body.priority || todo.priority,
      category: req.body.category || todo.category,
      tags: req.body.tags || todo.tags,
      dueDate: req.body.dueDate || todo.dueDate,
      reminderDate: req.body.reminderDate || todo.reminderDate,
      estimatedTime: req.body.estimatedTime || todo.estimatedTime
    };

    // Set completed date if status changed to completed
    if (updateData.status === 'completed' && todo.status !== 'completed') {
      updateData.completedAt = new Date().toISOString();
    } else if (updateData.status !== 'completed') {
      updateData.completedAt = null;
    }

    const updatedTodo = await db.update('todos', req.params.id, updateData);

    res.json({
      success: true,
      message: 'Todo updated successfully',
      data: { todo: updatedTodo }
    });

  } catch (error) {
    next(error);
  }
});

// @route   PATCH /api/todos/:id/status
// @desc    Update todo status
// @access  Private
router.patch('/:id/status', auth, [
  body('status').isIn(['pending', 'in-progress', 'completed']).withMessage('Invalid status')
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

    const todo = await db.findById('todos', req.params.id);
    
    if (!todo) {
      return res.status(404).json({
        success: false,
        error: { message: 'Todo not found' }
      });
    }

    // Check if todo belongs to the authenticated user
    if (todo.userId !== req.userId) {
      return res.status(403).json({
        success: false,
        error: { message: 'Access denied' }
      });
    }

    const updateData = { status: req.body.status };

    // Set completed date if status changed to completed
    if (req.body.status === 'completed' && todo.status !== 'completed') {
      updateData.completedAt = new Date().toISOString();
    } else if (req.body.status !== 'completed') {
      updateData.completedAt = null;
    }

    const updatedTodo = await db.partialUpdate('todos', req.params.id, updateData);

    res.json({
      success: true,
      message: 'Todo status updated successfully',
      data: { todo: updatedTodo }
    });

  } catch (error) {
    next(error);
  }
});

// @route   DELETE /api/todos/:id
// @desc    Delete todo
// @access  Private
router.delete('/:id', auth, async (req, res, next) => {
  try {
    const todo = await db.findById('todos', req.params.id);
    
    if (!todo) {
      return res.status(404).json({
        success: false,
        error: { message: 'Todo not found' }
      });
    }

    // Check if todo belongs to the authenticated user
    if (todo.userId !== req.userId) {
      return res.status(403).json({
        success: false,
        error: { message: 'Access denied' }
      });
    }

    await db.delete('todos', req.params.id);

    res.json({
      success: true,
      message: 'Todo deleted successfully'
    });

  } catch (error) {
    next(error);
  }
});

// @route   POST /api/todos/bulk-delete
// @desc    Delete multiple todos
// @access  Private
router.post('/bulk-delete', auth, [
  body('todoIds').isArray().withMessage('todoIds must be an array'),
  body('todoIds.*').isString().withMessage('Each todo ID must be a string')
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

    const { todoIds } = req.body;
    const deletedTodos = [];
    const deleteErrors = [];

    for (const todoId of todoIds) {
      try {
        const todo = await db.findById('todos', todoId);
        
        if (!todo) {
          deleteErrors.push({ id: todoId, message: 'Todo not found' });
          continue;
        }

        if (todo.userId !== req.userId) {
          deleteErrors.push({ id: todoId, message: 'Access denied' });
          continue;
        }

        await db.delete('todos', todoId);
        deletedTodos.push(todoId);
      } catch (error) {
        deleteErrors.push({ id: todoId, message: error.message });
      }
    }

    res.json({
      success: true,
      message: `Successfully deleted ${deletedTodos.length} todos`,
      data: {
        deleted: deletedTodos,
        errors: deleteErrors
      }
    });

  } catch (error) {
    next(error);
  }
});

module.exports = router;