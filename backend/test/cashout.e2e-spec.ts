import * as request from 'supertest';
import { setupTestApp, getApp, getAccessToken } from './setup';

describe('Cash Out (e2e)', () => {
  beforeAll(() => setupTestApp());

  it('POST /api/cashout — fails with insufficient balance', () => {
    return request(getApp().getHttpServer())
      .post('/api/cashout')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .send({
        coinAmount: 10000000,
        paymentMethod: 'paypal',
        paymentDetails: 'alice@paypal.com',
      })
      .expect(400);
  });

  it('GET /api/cashout/history — returns paginated history', () => {
    return request(getApp().getHttpServer())
      .get('/api/cashout/history?page=1&limit=10')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .expect(200)
      .expect((res) => {
        expect(res.body.data).toBeInstanceOf(Array);
        expect(res.body.meta).toBeDefined();
      });
  });
});
