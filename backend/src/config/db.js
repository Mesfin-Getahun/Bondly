const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.PGHOST || 'localhost',
  port: parseInt(process.env.PGPORT || '5432', 10),
  user: process.env.PGUSER || 'postgres',
  password: process.env.PGPASSWORD || 'postgres',
  database: process.env.PGDATABASE || 'postgres', // default to postgres if custom db not created
  connectionTimeoutMillis: 3000,
});

let isConnected = false;
let connectionError = null;

// In-memory fallback storage if PostgreSQL is not yet configured with valid credentials
const memoryFiles = [];
let nextMemoryId = 1;

async function initDb() {
  try {
    const client = await pool.connect();
    isConnected = true;
    connectionError = null;
    console.log('✅ PostgreSQL connected successfully');

    // Create table for uploaded files if it does not exist
    await client.query(`
      CREATE TABLE IF NOT EXISTS uploaded_files (
        id SERIAL PRIMARY KEY,
        title VARCHAR(255),
        file_name VARCHAR(255) NOT NULL,
        file_url TEXT NOT NULL,
        public_id VARCHAR(255),
        format VARCHAR(50),
        bytes INTEGER,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('✅ PostgreSQL "uploaded_files" table ready');
    client.release();
    return true;
  } catch (err) {
    isConnected = false;
    connectionError = err.message;
    console.warn(`⚠️ PostgreSQL connection warning: ${err.message}`);
    console.warn('ℹ️ Running with fallback memory store until valid PostgreSQL credentials are configured in .env');
    return false;
  }
}

// Database helper functions that use Postgres when connected or memory fallback
async function saveFileRecord({ title, fileName, fileUrl, publicId, format, bytes }) {
  if (isConnected) {
    const query = `
      INSERT INTO uploaded_files (title, file_name, file_url, public_id, format, bytes)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING *;
    `;
    const res = await pool.query(query, [title || 'Untitled', fileName, fileUrl, publicId, format, bytes]);
    return res.rows[0];
  } else {
    const record = {
      id: nextMemoryId++,
      title: title || 'Untitled',
      file_name: fileName,
      file_url: fileUrl,
      public_id: publicId,
      format,
      bytes,
      created_at: new Date().toISOString()
    };
    memoryFiles.unshift(record);
    return record;
  }
}

async function getAllFiles() {
  if (isConnected) {
    const res = await pool.query('SELECT * FROM uploaded_files ORDER BY created_at DESC;');
    return res.rows;
  }
  return [...memoryFiles];
}

async function deleteFileRecord(id) {
  if (isConnected) {
    const res = await pool.query('DELETE FROM uploaded_files WHERE id = $1 RETURNING *;', [id]);
    return res.rows[0] || null;
  }
  const index = memoryFiles.findIndex(f => f.id === parseInt(id, 10));
  if (index !== -1) {
    return memoryFiles.splice(index, 1)[0];
  }
  return null;
}

function getStatus() {
  return {
    connected: isConnected,
    error: connectionError,
    host: process.env.PGHOST || 'localhost',
    port: process.env.PGPORT || 5432,
    database: process.env.PGDATABASE || 'postgres',
    user: process.env.PGUSER || 'postgres',
  };
}

module.exports = {
  pool,
  initDb,
  saveFileRecord,
  getAllFiles,
  deleteFileRecord,
  getStatus,
};
