const express = require('express');
const router = express.Router();
const upload = require('../middleware/uploadMiddleware');
const { handleFileUpload, handleGetFiles, handleDeleteFile } = require('../controllers/fileController');

// Upload file route
router.post('/upload', upload.single('file'), handleFileUpload);

// List files route
router.get('/', handleGetFiles);

// Delete file route
router.delete('/:id', handleDeleteFile);

module.exports = router;
