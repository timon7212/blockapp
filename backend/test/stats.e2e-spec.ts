import * as request from 'supertest';
import { setupTestApp, getApp, getAccessToken } from './setup';

describe('Stats (e2e)', () => {
  beforeAll(() => setupTestApp());

  it('GET /api/stats/daily — returns daily stats', () => {
    return request(getApp().getHttpServer())
      .get('/api/stats/daily')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .expect(200)
      .expect((res) => {
        expect(typeof res.body.screenTimeMinutes).toBe('number');
        expect(res.body.screenTimeMinutes).toBeGreaterThan(0);
        expect(res.body.appBreakdown).toBeInstanceOf(Array);
        expect(res.body.date).toBeDefined();
      });
  });

  it('GET /api/stats/weekly — returns 7-day breakdown', () => {
    return request(getApp().getHttpServer())
      .get('/api/stats/weekly')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .expect(200)
      .expect((res) => {
        expect(res.body).toBeInstanceOf(Array);
        expect(res.body.length).toBe(7);
        expect(res.body[0].dayLabel).toBeDefined();
        const today = res.body.find((d) => d.isToday);
        expect(today).toBeDefined();
        expect(today.minutes).toBeGreaterThan(0);
      });
  });

  it('GET /api/streak — returns streak info', () => {
    return request(getApp().getHttpServer())
      .get('/api/streak')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .expect(200)
      .expect((res) => {
        expect(res.body.currentStreak).toBeGreaterThanOrEqual(1);
        expect(res.body.longestStreak).toBeGreaterThanOrEqual(1);
        expect(res.body.collectedToday).toBe(true);
        expect(res.body.nextMilestoneLabel).toBeDefined();
      });
  });
});
