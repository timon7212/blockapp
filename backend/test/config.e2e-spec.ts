import * as request from 'supertest';
import { setupTestApp, getApp } from './setup';

describe('Config (e2e)', () => {
  beforeAll(() => setupTestApp());

  it('GET /api/config — returns app configuration', () => {
    return request(getApp().getHttpServer())
      .get('/api/config')
      .expect(200)
      .expect((res) => {
        expect(res.body.pointsPerMinute).toBe(1);
        expect(res.body.pointCap).toBe(1000);
        expect(res.body.spinWheel).toBeDefined();
        expect(res.body.spinWheel.intervalMinutes).toBe(30);
        expect(res.body.spinWheel.maxSpins).toBe(4);
        expect(res.body.spinWheel.prizes).toBeInstanceOf(Array);
        expect(res.body.referral).toBeDefined();
        expect(res.body.minAppVersion).toBeDefined();
      });
  });
});
