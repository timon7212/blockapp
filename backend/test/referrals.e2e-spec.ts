import * as request from 'supertest';
import { setupTestApp, getApp, getAccessToken, getReferralCode } from './setup';

describe('Referrals (e2e)', () => {
  beforeAll(() => setupTestApp());

  it('GET /api/referrals — returns referral stats with both levels', () => {
    return request(getApp().getHttpServer())
      .get('/api/referrals')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .expect(200)
      .expect((res) => {
        expect(res.body.directInvites).toBeGreaterThanOrEqual(1);
        expect(typeof res.body.grandChildInvites).toBe('number');
        expect(typeof res.body.childCommissionPercent).toBe('number');
        expect(typeof res.body.grandChildCommissionPercent).toBe('number');
        expect(typeof res.body.pendingChildPoints).toBe('number');
        expect(typeof res.body.pendingGrandChildPoints).toBe('number');
        expect(typeof res.body.totalCollected).toBe('number');
      });
  });

  it('GET /api/referrals/invitees — lists invitees with level', () => {
    return request(getApp().getHttpServer())
      .get('/api/referrals/invitees')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .expect(200)
      .expect((res) => {
        expect(res.body).toBeInstanceOf(Array);
        expect(res.body.length).toBeGreaterThanOrEqual(1);
        expect(res.body[0].displayName).toBe('Bob');
        expect(res.body[0].level).toBe('child');
      });
  });

  it('POST /api/referrals/collect/children — 400 when no pending child points', () => {
    return request(getApp().getHttpServer())
      .post('/api/referrals/collect/children')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .expect(400);
  });

  it('POST /api/referrals/collect/grandchildren — 400 when no pending grandchild points', () => {
    return request(getApp().getHttpServer())
      .post('/api/referrals/collect/grandchildren')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .expect(400);
  });

  it('GET /api/referrals/invite-link — returns invite link', () => {
    return request(getApp().getHttpServer())
      .get('/api/referrals/invite-link')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .expect(200)
      .expect((res) => {
        expect(res.body.referralCode).toBe(getReferralCode());
        expect(res.body.inviteLink).toContain(getReferralCode());
      });
  });
});
