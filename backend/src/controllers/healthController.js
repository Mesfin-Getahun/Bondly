const { getStatus: getDbStatus } = require('../config/db');
const { getCloudinaryStatus } = require('../config/cloudinary');

function getHealth(req, res) {
  const dbStatus = getDbStatus();
  const cloudinaryStatus = getCloudinaryStatus();

  const isHealthy = true; // Express is running

  res.status(200).json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    service: 'Bondly Express API',
    version: '1.0.0',
    database: {
      provider: 'PostgreSQL (pg)',
      connected: dbStatus.connected,
      host: dbStatus.host,
      port: dbStatus.port,
      database: dbStatus.database,
      user: dbStatus.user,
      error: dbStatus.error,
    },
    cloudinary: {
      provider: 'Cloudinary',
      configured: cloudinaryStatus.configured,
      cloudName: cloudinaryStatus.cloudName,
    },
  });
}

module.exports = {
  getHealth,
};
