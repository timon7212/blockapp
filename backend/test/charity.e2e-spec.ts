import * as request from 'supertest';
import { setupTestApp, getApp, getAccessToken, getDataSource } from './setup';

describe('Charity (e2e)', () => {
  let charityId: string;

  beforeAll(async () => {
    await setupTestApp();
    const ds = getDataSource();
    const result = await ds.query(
      `INSERT INTO charities (name, emoji, description, color, active)
       VALUES ('E2E Charity', '🌳', 'Plant trees', '#2d8a4e', true)
       RETURNING id`,
    );
    charityId = result[0].id;
  });

  it('GET /api/charities — lists charities', () => {
    return request(getApp().getHttpServer())
      .get('/api/charities')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .expect(200)
      .expect((res) => {
        expect(res.body).toBeInstanceOf(Array);
        expect(res.body.length).toBeGreaterThan(0);
      });
  });

  it('POST /api/charities/:id/donate — donates points', () => {
    return request(getApp().getHttpServer())
      .post(`/api/charities/${charityId}/donate`)
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .send({ amount: 5 })
      .expect(201)
      .expect((res) => {
        expect(res.body.success).toBe(true);
        expect(res.body.amount).toBe(5);
        expect(res.body.newBalance).toBeDefined();
      });
  });

  it('POST /api/charities/:id/donate — fails with insufficient balance', () => {
    return request(getApp().getHttpServer())
      .post(`/api/charities/${charityId}/donate`)
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .send({ amount: 999999999 })
      .expect(400);
  });
});
