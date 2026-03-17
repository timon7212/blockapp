import * as request from 'supertest';
import { setupTestApp, getApp, getAccessToken } from './setup';

describe('Events (e2e)', () => {
  beforeAll(() => setupTestApp());

  describe('Screen Time', () => {
    it('POST /api/events/screen-time — syncs usage and awards points', () => {
      return request(getApp().getHttpServer())
        .post('/api/events/screen-time')
        .set('Authorization', `Bearer ${getAccessToken()}`)
        .send({
          usage: [
            { appId: 'com.snapchat.android', minutes: 10 },
            { appId: 'com.facebook.katana', minutes: 5 },
          ],
        })
        .expect(201)
        .expect((res) => {
          expect(res.body.totalMinutes).toBe(15);
          expect(typeof res.body.pointsEarned).toBe('number');
          expect(typeof res.body.uncollectedPoints).toBe('number');
          expect(typeof res.body.capReached).toBe('boolean');
          expect(typeof res.body.spinsAvailable).toBe('number');
        });
    });

    it('POST /api/events/screen-time — validates input', () => {
      return request(getApp().getHttpServer())
        .post('/api/events/screen-time')
        .set('Authorization', `Bearer ${getAccessToken()}`)
        .send({ usage: [{ appId: 123, minutes: -1 }] })
        .expect(400);
    });
  });

  describe('Collect Points', () => {
    beforeAll(async () => {
      await request(getApp().getHttpServer())
        .post('/api/events/screen-time')
        .set('Authorization', `Bearer ${getAccessToken()}`)
        .send({ usage: [{ appId: 'com.test.app', minutes: 50 }] });
    });

    it('POST /api/events/collect — collects points after ad', () => {
      return request(getApp().getHttpServer())
        .post('/api/events/collect')
        .set('Authorization', `Bearer ${getAccessToken()}`)
        .send({ adType: 'rewarded' })
        .expect(201)
        .expect((res) => {
          expect(res.body.pointsCollected).toBeGreaterThan(0);
          expect(res.body.newBalance).toBeGreaterThan(0);
          expect(res.body.uncollectedPoints).toBe(0);
        });
    });

    it('POST /api/events/collect — fails when no uncollected points', () => {
      return request(getApp().getHttpServer())
        .post('/api/events/collect')
        .set('Authorization', `Bearer ${getAccessToken()}`)
        .send({ adType: 'rewarded' })
        .expect(400);
    });
  });

  describe('Ad View', () => {
    it('POST /api/events/ad-view — records an ad view', () => {
      return request(getApp().getHttpServer())
        .post('/api/events/ad-view')
        .set('Authorization', `Bearer ${getAccessToken()}`)
        .send({ adType: 'rewarded', context: 'standalone' })
        .expect(201)
        .expect((res) => {
          expect(res.body.recorded).toBe(true);
          expect(typeof res.body.totalAdViews).toBe('number');
        });
    });

    it('POST /api/events/ad-view — validates input', () => {
      return request(getApp().getHttpServer())
        .post('/api/events/ad-view')
        .set('Authorization', `Bearer ${getAccessToken()}`)
        .send({})
        .expect(400);
    });
  });

  describe('Spin Wheel', () => {
    it('POST /api/events/spin — spins the wheel if available', async () => {
      await request(getApp().getHttpServer())
        .post('/api/events/screen-time')
        .set('Authorization', `Bearer ${getAccessToken()}`)
        .send({ usage: [{ appId: 'com.test.app', minutes: 60 }] });

      const res = await request(getApp().getHttpServer())
        .post('/api/events/spin')
        .set('Authorization', `Bearer ${getAccessToken()}`)
        .send({ adType: 'rewarded' });

      if (res.status === 201) {
        expect(res.body.prizeType).toBeDefined();
        expect(res.body.prizeLabel).toBeDefined();
        expect(typeof res.body.spinsRemaining).toBe('number');
      } else {
        expect(res.status).toBe(400);
      }
    });
  });
});
