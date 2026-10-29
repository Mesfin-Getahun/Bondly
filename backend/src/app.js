const express = require('express');
const cors = require('cors');
const healthRoutes = require('./routes/healthRoutes');
const fileRoutes = require('./routes/fileRoutes');
const errorHandler = require('./middleware/errorHandler');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Root welcome route
app.get('/', (req, res) => {
  res.json({
    message: 'Welcome to Bondly API',
    endpoints: {
      health: 'GET /api/health',
      upload: 'POST /api/files/upload (multipart: file, title)',
      listFiles: 'GET /api/files',
      deleteFile: 'DELETE /api/files/:id',
    },
  });
});

// API Routes
app.use('/api', healthRoutes);
app.use('/api/files', fileRoutes);

// Error Handling Middleware
app.use(errorHandler);

module.exports = app;
