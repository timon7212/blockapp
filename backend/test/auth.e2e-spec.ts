import * as request from 'supertest';
import { INestApplication } from '@nestjs/common';
import { DataSource } from 'typeorm';
import { setupTestApp, getApp, getDataSource } from './setup';

describe('Auth (e2e)', () => {
  let app: INestApplication;
  let dataSource: DataSource;
  let accessToken: string;
  let refreshToken: string;
  let referralCode: string;

  beforeAll(async () => {
    await setupTestApp();
    app = getApp();
    dataSource = getDataSource();
  });

  it('POST /api/auth/register — creates a new user', async () => {
    await dataSource.query(`DELETE FROM users WHERE email = 'authtest@test.com'`);

    const res = await request(app.getHttpServer())
      .post('/api/auth/register')
      .send({
        email: 'authtest@test.com',
        password: 'StrongPass1!',
        displayName: 'AuthUser',
      })
      .expect(201);

    expect(res.body.accessToken).toBeDefined();
    expect(res.body.refreshToken).toBeDefined();
    expect(res.body.user.email).toBe('authtest@test.com');
    expect(res.body.user.referralCode).toBeDefined();
    accessToken = res.body.accessToken;
    refreshToken = res.body.refreshToken;
    referralCode = res.body.user.referralCode;
  });

  it('POST /api/auth/register — rejects duplicate email', () => {
    return request(app.getHttpServer())
      .post('/api/auth/register')
      .send({
        email: 'authtest@test.com',
        password: 'StrongPass1!',
        displayName: 'Dup',
      })
      .expect(409);
  });

  it('POST /api/auth/register — validates input', () => {
    return request(app.getHttpServer())
      .post('/api/auth/register')
      .send({ email: 'not-an-email', password: '123' })
      .expect(400);
  });

  it('POST /api/auth/login — rejects unverified email', () => {
    return request(app.getHttpServer())
      .post('/api/auth/login')
      .send({ email: 'authtest@test.com', password: 'StrongPass1!' })
      .expect(401);
  });

  it('GET /api/auth/verify-email — verifies email', async () => {
    const result = await dataSource.query(
      `SELECT "verificationToken" FROM users WHERE email = 'authtest@test.com'`,
    );

    return request(app.getHttpServer())
      .get(`/api/auth/verify-email?token=${result[0].verificationToken}`)
      .expect(200)
      .expect((res) => {
        expect(res.body.message).toContain('verified');
      });
  });

  it('POST /api/auth/login — succeeds after verification', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/auth/login')
      .send({ email: 'authtest@test.com', password: 'StrongPass1!' })
      .expect(200);

    expect(res.body.accessToken).toBeDefined();
    accessToken = res.body.accessToken;
    refreshToken = res.body.refreshToken;
  });

  it('POST /api/auth/login — rejects wrong password', () => {
    return request(app.getHttpServer())
      .post('/api/auth/login')
      .send({ email: 'authtest@test.com', password: 'WrongPass!' })
      .expect(401);
  });

  it('POST /api/auth/refresh — rotates tokens', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/auth/refresh')
      .send({ refreshToken })
      .expect(200);

    expect(res.body.accessToken).toBeDefined();
    expect(res.body.refreshToken).toBeDefined();
    accessToken = res.body.accessToken;
    refreshToken = res.body.refreshToken;
  });

  it('POST /api/auth/forgot-password — always succeeds', () => {
    return request(app.getHttpServer())
      .post('/api/auth/forgot-password')
      .send({ email: 'authtest@test.com' })
      .expect(200)
      .expect((res) => {
        expect(res.body.message).toBeDefined();
      });
  });

  it('POST /api/auth/change-password — changes password', () => {
    return request(app.getHttpServer())
      .post('/api/auth/change-password')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ currentPassword: 'StrongPass1!', newPassword: 'NewPass2!' })
      .expect(200);
  });

  it('POST /api/auth/register — referral linking works', async () => {
    await dataSource.query(`DELETE FROM users WHERE email = 'referred@test.com'`);

    const res = await request(app.getHttpServer())
      .post('/api/auth/register')
      .send({
        email: 'referred@test.com',
        password: 'RefPass123!',
        displayName: 'Referred',
        referralCode,
      })
      .expect(201);

    expect(res.body.user).toBeDefined();
  });

  it('rejects requests without token', () => {
    return request(app.getHttpServer())
      .get('/api/users/me')
      .expect(401);
  });

  it('rejects invalid token', () => {
    return request(app.getHttpServer())
      .get('/api/users/me')
      .set('Authorization', 'Bearer invalid-token')
      .expect(401);
  });

  it('POST /api/auth/logout — invalidates session', () => {
    return request(app.getHttpServer())
      .post('/api/auth/logout')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(204);
  });

  // ─── Google Sign-In ───

  it('POST /api/auth/google — rejects missing idToken', () => {
    return request(app.getHttpServer())
      .post('/api/auth/google')
      .send({})
      .expect(400);
  });

  it('POST /api/auth/google — rejects non-string idToken', () => {
    return request(app.getHttpServer())
      .post('/api/auth/google')
      .send({ idToken: 12345 })
      .expect(400);
  });

  it('POST /api/auth/google — rejects invalid Google token', () => {
    return request(app.getHttpServer())
      .post('/api/auth/google')
      .send({ idToken: 'not-a-real-google-token' })
      .expect(401);
  });

  it('POST /api/auth/login — rejects password login for Google-only account', async () => {
    await dataSource.query(
      `INSERT INTO users (id, email, "passwordHash", "displayName", "referralCode", "emailVerified", "googleId")
       VALUES (gen_random_uuid(), 'googleonly@test.com', NULL, 'GoogleUser', 'GOOG1234', true, 'google-sub-test')
       ON CONFLICT (email) DO NOTHING`,
    );

    return request(app.getHttpServer())
      .post('/api/auth/login')
      .send({ email: 'googleonly@test.com', password: 'SomePass1!' })
      .expect(401)
      .expect((res) => {
        expect(res.body.message).toContain('Google');
      });
  });
});
