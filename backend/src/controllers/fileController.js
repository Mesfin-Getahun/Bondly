const { uploadToCloudinary, deleteFromCloudinary, getTransformedUrl } = require('../config/cloudinary');
const { saveFileRecord, getAllFiles, deleteFileRecord } = require('../config/db');

async function handleFileUpload(req, res, next) {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No file provided in request. Field name should be "file".',
      });
    }

    const { title } = req.body;
    const originalName = req.file.originalname;

    // Upload to Cloudinary
    const cloudinaryResult = await uploadToCloudinary(req.file.buffer, {
      folder: 'bondly_uploads',
      resourceType: 'auto',
    });

    const fileUrl = cloudinaryResult.secure_url || cloudinaryResult.url;
    const publicId = cloudinaryResult.public_id;
    const format = cloudinaryResult.format || req.file.mimetype.split('/')[1] || 'unknown';
    const bytes = cloudinaryResult.bytes || req.file.size;

    // Generate optimized thumbnail URL using Cloudinary transformation
    const thumbnailUrl = getTransformedUrl(publicId, {
      width: 300,
      height: 300,
      crop: 'fill',
    });

    // Save record to Database (PostgreSQL)
    const savedRecord = await saveFileRecord({
      title: title || originalName,
      fileName: originalName,
      fileUrl,
      publicId,
      format,
      bytes,
    });

    return res.status(201).json({
      success: true,
      message: 'File uploaded and processed successfully!',
      data: {
        ...savedRecord,
        thumbnail_url: thumbnailUrl,
      },
    });
  } catch (error) {
    next(error);
  }
}

async function handleGetFiles(req, res, next) {
  try {
    const files = await getAllFiles();
    const enrichedFiles = files.map((file) => ({
      ...file,
      thumbnail_url: getTransformedUrl(file.public_id, {
        width: 300,
        height: 300,
        crop: 'fill',
      }),
    }));

    return res.json({
      success: true,
      count: files.length,
      data: enrichedFiles,
    });
  } catch (error) {
    next(error);
  }
}

async function handleDeleteFile(req, res, next) {
  try {
    const { id } = req.params;
    const deletedRecord = await deleteFileRecord(id);

    if (!deletedRecord) {
      return res.status(404).json({
        success: false,
        message: `File with id ${id} not found.`,
      });
    }

    if (deletedRecord.public_id) {
      await deleteFromCloudinary(deletedRecord.public_id);
    }

    return res.json({
      success: true,
      message: `File with id ${id} deleted successfully.`,
      data: deletedRecord,
    });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  handleFileUpload,
  handleGetFiles,
  handleDeleteFile,
};
