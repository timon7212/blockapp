import * as request from 'supertest';
import { setupTestApp, getApp, getAccessToken } from './setup';

describe('Devices (e2e)', () => {
  beforeAll(() => setupTestApp());

  it('POST /api/devices — registers push token', () => {
    return request(getApp().getHttpServer())
      .post('/api/devices')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .send({ platform: 'ios', pushToken: 'fake-apns-token-abc123' })
      .expect(201)
      .expect((res) => {
        expect(res.body.deviceId).toBeDefined();
        expect(res.body.platform).toBe('ios');
        expect(res.body.registered).toBe(true);
      });
  });

  it('POST /api/devices — upserts same platform', () => {
    return request(getApp().getHttpServer())
      .post('/api/devices')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .send({ platform: 'ios', pushToken: 'updated-token-xyz789' })
      .expect(201)
      .expect((res) => {
        expect(res.body.registered).toBe(true);
      });
  });
});
