import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';
import { DataSource } from 'typeorm';

let app: INestApplication;
let dataSource: DataSource;
let _accessToken: string;
let _refreshToken: string;
let _userId: string;
let _referralCode: string;
let _adminAccessToken: string;
let _adminUserId: string;

export async function setupTestApp(): Promise<INestApplication> {
  if (app) return app;

  const moduleFixture: TestingModule = await Test.createTestingModule({
    imports: [AppModule],
  }).compile();

  app = moduleFixture.createNestApplication();
  app.setGlobalPrefix('api');
  app.useGlobalPipes(
    new ValidationPipe({ whitelist: true, transform: true }),
  );
  await app.init();

  dataSource = app.get(DataSource);

  const entities = dataSource.entityMetadatas;
  for (const entity of entities) {
    const repo = dataSource.getRepository(entity.name);
    await repo.query(`TRUNCATE TABLE "${entity.tableName}" CASCADE`);
  }

  // Register + verify primary test user (Alice)
  const regRes = await request(app.getHttpServer())
    .post('/api/auth/register')
    .send({
      email: 'alice@test.com',
      password: 'StrongPass1!',
      displayName: 'Alice',
    });

  _userId = regRes.body.user.id;
  _referralCode = regRes.body.user.referralCode;

  await dataSource.query(
    `UPDATE users SET "emailVerified" = true WHERE id = $1`,
    [_userId],
  );

  const loginRes = await request(app.getHttpServer())
    .post('/api/auth/login')
    .send({ email: 'alice@test.com', password: 'StrongPass1!' });

  _accessToken = loginRes.body.accessToken;
  _refreshToken = loginRes.body.refreshToken;

  // Register + verify referred user (Bob)
  await request(app.getHttpServer())
    .post('/api/auth/register')
    .send({
      email: 'bob@test.com',
      password: 'BobPass123!',
      displayName: 'Bob',
      referralCode: _referralCode,
    });

  await dataSource.query(
    `UPDATE users SET "emailVerified" = true WHERE email = 'bob@test.com'`,
  );

  // Register + verify admin user
  const adminReg = await request(app.getHttpServer())
    .post('/api/auth/register')
    .send({
      email: 'admin@test.com',
      password: 'AdminPass1!',
      displayName: 'Admin',
    });

  _adminUserId = adminReg.body.user.id;

  await dataSource.query(
    `UPDATE users SET "emailVerified" = true, role = 'admin' WHERE id = $1`,
    [_adminUserId],
  );

  const adminLogin = await request(app.getHttpServer())
    .post('/api/auth/login')
    .send({ email: 'admin@test.com', password: 'AdminPass1!' });

  _adminAccessToken = adminLogin.body.accessToken;

  // Seed screen time so Alice has points
  await request(app.getHttpServer())
    .post('/api/events/screen-time')
    .set('Authorization', `Bearer ${_accessToken}`)
    .send({
      usage: [
        { appId: 'com.instagram.android', minutes: 40 },
        { appId: 'com.tiktok.android', minutes: 25 },
      ],
    });

  // Collect points so wallet has a balance
  await request(app.getHttpServer())
    .post('/api/events/collect')
    .set('Authorization', `Bearer ${_accessToken}`)
    .send({ adType: 'rewarded' });

  return app;
}

export function getApp(): INestApplication {
  return app;
}

export function getDataSource(): DataSource {
  return dataSource;
}

export function getAccessToken(): string {
  return _accessToken;
}

export function setAccessToken(token: string): void {
  _accessToken = token;
}

export function getRefreshToken(): string {
  return _refreshToken;
}

export function setRefreshToken(token: string): void {
  _refreshToken = token;
}

export function getUserId(): string {
  return _userId;
}

export function getReferralCode(): string {
  return _referralCode;
}

export function getAdminAccessToken(): string {
  return _adminAccessToken;
}

export function getAdminUserId(): string {
  return _adminUserId;
}
