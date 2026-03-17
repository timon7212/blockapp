import * as request from 'supertest';
import { setupTestApp, getApp, getAccessToken } from './setup';

describe('Gift Cards (e2e)', () => {
  beforeAll(() => setupTestApp());

  it('GET /api/gift-cards — returns catalog', () => {
    return request(getApp().getHttpServer())
      .get('/api/gift-cards?page=1&limit=5')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .expect(200)
      .expect((res) => {
        expect(res.body.data).toBeInstanceOf(Array);
        expect(res.body.meta).toBeDefined();
      });
  });

  it('GET /api/gift-cards/history — returns empty history', () => {
    return request(getApp().getHttpServer())
      .get('/api/gift-cards/history?page=1&limit=10')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .expect(200)
      .expect((res) => {
        expect(res.body.data).toBeInstanceOf(Array);
        expect(res.body.meta).toBeDefined();
      });
  });
});
