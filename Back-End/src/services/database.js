const axios = require('axios');

class DatabaseService {
  constructor() {
    this.baseURL = process.env.DATABASE_URL || 'http://localhost:3001';
    this.axios = axios.create({
      baseURL: this.baseURL,
      timeout: 5000,
      headers: {
        'Content-Type': 'application/json'
      }
    });

    // Add request/response interceptors for logging
    this.axios.interceptors.request.use(
      (config) => {
        console.log(`🔗 DB Request: ${config.method?.toUpperCase()} ${config.url}`);
        return config;
      },
      (error) => {
        console.error('🔴 DB Request Error:', error.message);
        return Promise.reject(error);
      }
    );

    this.axios.interceptors.response.use(
      (response) => {
        console.log(`✅ DB Response: ${response.status} ${response.config.url}`);
        return response;
      },
      (error) => {
        console.error(`❌ DB Response Error: ${error.response?.status} ${error.config?.url}`, error.response?.data);
        return Promise.reject(error);
      }
    );
  }

  // Generic CRUD operations
  async findAll(resource, params = {}) {
    try {
      const response = await this.axios.get(`/${resource}`, { params });
      return response.data;
    } catch (error) {
      throw this.handleError(error, `Failed to fetch ${resource}`);
    }
  }

  async findById(resource, id) {
    try {
      const response = await this.axios.get(`/${resource}/${id}`);
      return response.data;
    } catch (error) {
      if (error.response?.status === 404) {
        return null;
      }
      throw this.handleError(error, `Failed to fetch ${resource} with id ${id}`);
    }
  }

  async create(resource, data) {
    try {
      const response = await this.axios.post(`/${resource}`, {
        ...data,
        id: this.generateId(),
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      });
      return response.data;
    } catch (error) {
      throw this.handleError(error, `Failed to create ${resource}`);
    }
  }

  async update(resource, id, data) {
    try {
      const response = await this.axios.put(`/${resource}/${id}`, {
        ...data,
        updatedAt: new Date().toISOString()
      });
      return response.data;
    } catch (error) {
      throw this.handleError(error, `Failed to update ${resource} with id ${id}`);
    }
  }

  async partialUpdate(resource, id, data) {
    try {
      const response = await this.axios.patch(`/${resource}/${id}`, {
        ...data,
        updatedAt: new Date().toISOString()
      });
      return response.data;
    } catch (error) {
      throw this.handleError(error, `Failed to update ${resource} with id ${id}`);
    }
  }

  async delete(resource, id) {
    try {
      await this.axios.delete(`/${resource}/${id}`);
      return { success: true, id };
    } catch (error) {
      throw this.handleError(error, `Failed to delete ${resource} with id ${id}`);
    }
  }

  // User-specific operations
  async findUserByEmail(email) {
    try {
      const users = await this.findAll('users', { email });
      return users.length > 0 ? users[0] : null;
    } catch (error) {
      throw this.handleError(error, `Failed to find user with email ${email}`);
    }
  }

  async findUserByUsername(username) {
    try {
      const users = await this.findAll('users', { username });
      return users.length > 0 ? users[0] : null;
    } catch (error) {
      throw this.handleError(error, `Failed to find user with username ${username}`);
    }
  }

  // Todo-specific operations
  async findTodosByUser(userId, params = {}) {
    try {
      return await this.findAll('todos', { userId, ...params });
    } catch (error) {
      throw this.handleError(error, `Failed to fetch todos for user ${userId}`);
    }
  }

  // Category-specific operations
  async findCategoriesByUser(userId) {
    try {
      const response = await this.axios.get('/user-todo-relations', { 
        params: { userId } 
      });
      return response.data.categories || [];
    } catch (error) {
      throw this.handleError(error, `Failed to fetch categories for user ${userId}`);
    }
  }

  // Utility methods
  generateId() {
    return Date.now().toString() + Math.random().toString(36).substr(2, 9);
  }

  handleError(error, message) {
    const err = new Error(message);
    err.status = error.response?.status || 500;
    err.originalError = error;
    return err;
  }

  // Health check
  async isHealthy() {
    try {
      await this.axios.get('/users?_limit=1');
      return true;
    } catch (error) {
      return false;
    }
  }
}

module.exports = new DatabaseService();