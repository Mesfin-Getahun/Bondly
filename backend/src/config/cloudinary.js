const cloudinary = require('cloudinary').v2;
require('dotenv').config();

const cloudName = process.env.CLOUDINARY_CLOUD_NAME || '';
const apiKey = process.env.CLOUDINARY_API_KEY || '';
const apiSecret = process.env.CLOUDINARY_API_SECRET || '';

const isCloudinaryConfigured =
  cloudName.trim() !== '' &&
  apiKey.trim() !== '' &&
  apiSecret.trim() !== '' &&
  cloudName !== 'your_cloud_name' &&
  apiKey !== 'your_api_key' &&
  cloudName !== 'demo';

cloudinary.config({
  cloud_name: cloudName,
  api_key: apiKey,
  api_secret: apiSecret,
  secure: true,
});

/**
 * Uploads a file buffer or local path to Cloudinary
 * @param {Buffer|string} fileSource - Buffer or filepath
 * @param {Object} options - Upload options (folder, transformations, etc.)
 */
async function uploadToCloudinary(fileBuffer, options = {}) {
  if (!isCloudinaryConfigured) {
    // Development / demo fallback: return mock cloudinary payload
    const mockId = 'sample_' + Date.now();
    return {
      public_id: mockId,
      secure_url: `https://res.cloudinary.com/demo/image/upload/sample.jpg`,
      format: 'jpg',
      bytes: fileBuffer ? fileBuffer.length : 1024,
      isMock: true,
    };
  }

  return new Promise((resolve, reject) => {
    const uploadStream = cloudinary.uploader.upload_stream(
      {
        folder: options.folder || 'bondly_uploads',
        resource_type: options.resourceType || 'auto',
        ...options,
      },
      (error, result) => {
        if (error) return reject(error);
        resolve(result);
      }
    );

    uploadStream.end(fileBuffer);
  });
}

/**
 * Delete asset from Cloudinary
 * @param {string} publicId
 */
async function deleteFromCloudinary(publicId) {
  if (!isCloudinaryConfigured || !publicId || publicId.startsWith('sample_')) {
    return { result: 'ok', mock: true };
  }
  return cloudinary.uploader.destroy(publicId);
}

/**
 * Generate transformed / optimized URL using Cloudinary SDK
 */
function getTransformedUrl(publicId, options = {}) {
  if (!isCloudinaryConfigured || !publicId) {
    return `https://res.cloudinary.com/demo/image/upload/sample.jpg`;
  }
  return cloudinary.url(publicId, {
    quality: 'auto',
    fetch_format: 'auto',
    width: options.width || 800,
    crop: options.crop || 'limit',
    ...options,
  });
}

function getCloudinaryStatus() {
  return {
    configured: isCloudinaryConfigured,
    cloudName: cloudName || 'not set',
  };
}

module.exports = {
  cloudinary,
  isCloudinaryConfigured,
  uploadToCloudinary,
  deleteFromCloudinary,
  getTransformedUrl,
  getCloudinaryStatus,
};
