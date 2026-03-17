import * as request from 'supertest';
import { setupTestApp, getApp, getAccessToken } from './setup';

describe('Leaderboard (e2e)', () => {
  beforeAll(() => setupTestApp());

  it('GET /api/leaderboard/weekly — returns leaderboard', () => {
    return request(getApp().getHttpServer())
      .get('/api/leaderboard/weekly?page=1&limit=10')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .expect(200)
      .expect((res) => {
        expect(res.body.data).toBeInstanceOf(Array);
        expect(res.body.data.length).toBeGreaterThan(0);
        expect(res.body.data[0].rank).toBe(1);
        expect(res.body.data[0].username).toBeDefined();
        expect(res.body.meta).toBeDefined();
      });
  });

  it('GET /api/leaderboard/weekly/me — returns user rank', () => {
    return request(getApp().getHttpServer())
      .get('/api/leaderboard/weekly/me')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .expect(200)
      .expect((res) => {
        expect(typeof res.body.rank).toBe('number');
        expect(typeof res.body.coins).toBe('number');
        expect(res.body.surrounding).toBeInstanceOf(Array);
      });
  });
});
