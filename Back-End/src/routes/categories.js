const express = require('express');
const { body, validationResult } = require('express-validator');
const auth = require('../middleware/auth');
const db = require('../services/database');

const router = express.Router();

// Validation rules
const categoryValidation = [
  body('name')
    .isLength({ min: 1, max: 50 })
    .withMessage('Category name is required and must be less than 50 characters')
    .trim(),
  body('description')
    .optional()
    .isLength({ max: 200 })
    .withMessage('Description must be less than 200 characters')
    .trim(),
  body('color')
    .optional()
    .matches(/^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/)
    .withMessage('Color must be a valid hex color code'),
  body('icon')
    .optional()
    .isLength({ max: 10 })
    .withMessage('Icon must be less than 10 characters')
];

// @route   GET /api/categories
// @desc    Get all categories for the authenticated user
// @access  Private
router.get('/', auth, async (req, res, next) => {
  try {
    const categories = await db.findCategoriesByUser(req.userId);
    
    res.json({
      success: true,
      data: { categories }
    });

  } catch (error) {
    next(error);
  }
});

// @route   GET /api/categories/:id
// @desc    Get category by ID
// @access  Private
router.get('/:id', auth, async (req, res, next) => {
  try {
    // Get all categories for the user
    const categories = await db.findCategoriesByUser(req.userId);
    const category = categories.find(cat => cat.id === req.params.id);
    
    if (!category) {
      return res.status(404).json({
        success: false,
        error: { message: 'Category not found' }
      });
    }

    res.json({
      success: true,
      data: { category }
    });

  } catch (error) {
    next(error);
  }
});

// @route   POST /api/categories
// @desc    Create a new category
// @access  Private
router.post('/', auth, categoryValidation, async (req, res, next) => {
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

    // Check if category name already exists for this user
    const existingCategories = await db.findCategoriesByUser(req.userId);
    const nameExists = existingCategories.some(cat => 
      cat.name.toLowerCase() === req.body.name.toLowerCase()
    );

    if (nameExists) {
      return res.status(400).json({
        success: false,
        error: { message: 'Category name already exists' }
      });
    }

    const categoryData = {
      userId: req.userId,
      name: req.body.name,
      description: req.body.description || '',
      color: req.body.color || '#3498db',
      icon: req.body.icon || '📝',
      isDefault: false
    };

    // Get current relations data
    const relationsData = await db.findById('user-todo-relations', '1') || { 
      userTodoRelations: [], 
      categories: [] 
    };

    // Add new category to the categories array
    const newCategory = {
      id: db.generateId(),
      ...categoryData,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };

    relationsData.categories = relationsData.categories || [];
    relationsData.categories.push(newCategory);

    // Update the relations file
    await db.update('user-todo-relations', '1', relationsData);

    res.status(201).json({
      success: true,
      message: 'Category created successfully',
      data: { category: newCategory }
    });

  } catch (error) {
    next(error);
  }
});

// @route   PUT /api/categories/:id
// @desc    Update category
// @access  Private
router.put('/:id', auth, categoryValidation, async (req, res, next) => {
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

    // Get current relations data
    const relationsData = await db.findById('user-todo-relations', '1');
    if (!relationsData || !relationsData.categories) {
      return res.status(404).json({
        success: false,
        error: { message: 'Category not found' }
      });
    }

    const categoryIndex = relationsData.categories.findIndex(
      cat => cat.id === req.params.id && cat.userId === req.userId
    );

    if (categoryIndex === -1) {
      return res.status(404).json({
        success: false,
        error: { message: 'Category not found' }
      });
    }

    // Check if new name conflicts with existing categories (excluding current one)
    const nameExists = relationsData.categories.some((cat, index) => 
      index !== categoryIndex &&
      cat.userId === req.userId &&
      cat.name.toLowerCase() === req.body.name.toLowerCase()
    );

    if (nameExists) {
      return res.status(400).json({
        success: false,
        error: { message: 'Category name already exists' }
      });
    }

    // Update category
    const updatedCategory = {
      ...relationsData.categories[categoryIndex],
      name: req.body.name,
      description: req.body.description || relationsData.categories[categoryIndex].description,
      color: req.body.color || relationsData.categories[categoryIndex].color,
      icon: req.body.icon || relationsData.categories[categoryIndex].icon,
      updatedAt: new Date().toISOString()
    };

    relationsData.categories[categoryIndex] = updatedCategory;

    // Update the relations file
    await db.update('userTodoRelations', '1', relationsData);

    res.json({
      success: true,
      message: 'Category updated successfully',
      data: { category: updatedCategory }
    });

  } catch (error) {
    next(error);
  }
});

// @route   DELETE /api/categories/:id
// @desc    Delete category
// @access  Private
router.delete('/:id', auth, async (req, res, next) => {
  try {
    // Get current relations data
    const relationsData = await db.findById('userTodoRelations', '1');
    if (!relationsData || !relationsData.categories) {
      return res.status(404).json({
        success: false,
        error: { message: 'Category not found' }
      });
    }

    const categoryIndex = relationsData.categories.findIndex(
      cat => cat.id === req.params.id && cat.userId === req.userId
    );

    if (categoryIndex === -1) {
      return res.status(404).json({
        success: false,
        error: { message: 'Category not found' }
      });
    }

    const category = relationsData.categories[categoryIndex];

    // Check if it's a default category
    if (category.isDefault) {
      return res.status(400).json({
        success: false,
        error: { message: 'Cannot delete default category' }
      });
    }

    // Check if category is being used by any todos
    const todos = await db.findTodosByUser(req.userId);
    const categoryInUse = todos.some(todo => todo.category === category.name);

    if (categoryInUse) {
      return res.status(400).json({
        success: false,
        error: { 
          message: 'Cannot delete category that is being used by todos. Please reassign todos to another category first.' 
        }
      });
    }

    // Remove category from the array
    relationsData.categories.splice(categoryIndex, 1);

    // Update the relations file
    await db.update('userTodoRelations', '1', relationsData);

    res.json({
      success: true,
      message: 'Category deleted successfully'
    });

  } catch (error) {
    next(error);
  }
});

// @route   GET /api/categories/stats
// @desc    Get category usage statistics
// @access  Private
router.get('/stats', auth, async (req, res, next) => {
  try {
    const categories = await db.findCategoriesByUser(req.userId);
    const todos = await db.findTodosByUser(req.userId);

    const stats = categories.map(category => {
      const categoryTodos = todos.filter(todo => todo.category === category.name);
      return {
        ...category,
        todoCount: categoryTodos.length,
        completedCount: categoryTodos.filter(todo => todo.status === 'completed').length,
        pendingCount: categoryTodos.filter(todo => todo.status === 'pending').length,
        inProgressCount: categoryTodos.filter(todo => todo.status === 'in-progress').length
      };
    });

    res.json({
      success: true,
      data: { categoryStats: stats }
    });

  } catch (error) {
    next(error);
  }
});

module.exports = router;