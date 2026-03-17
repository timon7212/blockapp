import * as request from 'supertest';
import { setupTestApp, getApp, getAccessToken, getUserId, getReferralCode } from './setup';

describe('Users (e2e)', () => {
  beforeAll(() => setupTestApp());

  it('GET /api/users/me — returns profile', () => {
    return request(getApp().getHttpServer())
      .get('/api/users/me')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .expect(200)
      .expect((res) => {
        expect(res.body.id).toBe(getUserId());
        expect(res.body.email).toBe('alice@test.com');
        expect(res.body.referralCode).toBe(getReferralCode());
        expect(res.body.directInvites).toBeGreaterThanOrEqual(1);
      });
  });

  it('PATCH /api/users/me — updates profile', () => {
    return request(getApp().getHttpServer())
      .patch('/api/users/me')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .send({ displayName: 'Alice Updated' })
      .expect(200)
      .expect((res) => {
        expect(res.body.displayName).toBe('Alice Updated');
      });
  });

  it('POST /api/users/me/onboarding — submits onboarding', () => {
    return request(getApp().getHttpServer())
      .post('/api/users/me/onboarding')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .send({
        trackedAppIds: ['com.instagram.android', 'com.tiktok.android'],
        goal: 'earn_rewards',
      })
      .expect(201)
      .expect((res) => {
        expect(res.body.onboardingComplete).toBe(true);
        expect(res.body.trackedAppIds).toContain('com.instagram.android');
      });
  });
});
