import * as request from 'supertest';
import { setupTestApp, getApp, getAccessToken } from './setup';

describe('Wallet (e2e)', () => {
  beforeAll(() => setupTestApp());

  it('GET /api/wallet — returns balance', () => {
    return request(getApp().getHttpServer())
      .get('/api/wallet')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .expect(200)
      .expect((res) => {
        expect(typeof res.body.totalPoints).toBe('number');
        expect(res.body.totalPoints).toBeGreaterThan(0);
        expect(typeof res.body.uncollectedPoints).toBe('number');
        expect(typeof res.body.allTimePointsEarned).toBe('number');
        expect(res.body.allTimePointsEarned).toBeGreaterThanOrEqual(
          res.body.totalPoints,
        );
      });
  });

  it('GET /api/wallet/transactions — returns paginated ledger', () => {
    return request(getApp().getHttpServer())
      .get('/api/wallet/transactions?page=1&limit=10')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .expect(200)
      .expect((res) => {
        expect(res.body.data).toBeInstanceOf(Array);
        expect(res.body.data.length).toBeGreaterThan(0);
        expect(res.body.meta.page).toBe(1);
        expect(res.body.meta.total).toBeGreaterThan(0);
        expect(res.body.data[0].type).toBeDefined();
        expect(res.body.data[0].points).toBeDefined();
      });
  });
});
