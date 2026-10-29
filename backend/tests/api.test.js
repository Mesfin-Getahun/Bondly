const request = require('supertest');
const app = require('../src/app');

describe('Bondly Express API Tests', () => {
  it('GET / should return welcome message and endpoint index', async () => {
    const res = await request(app).get('/');
    expect(res.status).toBe(200);
    expect(res.body.message).toContain('Welcome to Bondly API');
  });

  it('GET /api/health should report server status and database/cloudinary info', async () => {
    const res = await request(app).get('/api/health');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('ok');
    expect(res.body.database).toHaveProperty('provider', 'PostgreSQL (pg)');
    expect(res.body.cloudinary).toHaveProperty('provider', 'Cloudinary');
  });

  it('POST /api/files/upload without file should return 400', async () => {
    const res = await request(app).post('/api/files/upload').send({});
    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
  });

  it('POST /api/files/upload with file should succeed and return file info', async () => {
    const fakeFileBuffer = Buffer.from('fake image content');
    const res = await request(app)
      .post('/api/files/upload')
      .field('title', 'Test Upload')
      .attach('file', fakeFileBuffer, 'test-image.png');

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data).toHaveProperty('id');
    expect(res.body.data.title).toBe('Test Upload');
    expect(res.body.data).toHaveProperty('file_url');
  });

  it('GET /api/files should return list of uploaded files', async () => {
    const res = await request(app).get('/api/files');
    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(Array.isArray(res.body.data)).toBe(true);
    expect(res.body.data.length).toBeGreaterThan(0);
  });

  it('DELETE /api/files/:id should delete uploaded file', async () => {
    const listRes = await request(app).get('/api/files');
    const firstId = listRes.body.data[0].id;

    const delRes = await request(app).delete(`/api/files/${firstId}`);
    expect(delRes.status).toBe(200);
    expect(delRes.body.success).toBe(true);
  });
});
