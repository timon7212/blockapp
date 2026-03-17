import * as request from 'supertest';
import { setupTestApp, getApp, getAccessToken, getDataSource } from './setup';

describe('Games (e2e)', () => {
  let gameId: string;

  beforeAll(async () => {
    await setupTestApp();
    const ds = getDataSource();
    const result = await ds.query(
      `INSERT INTO games (title, description, "iconUrl", "bannerUrl", "pointsReward", "estimatedMinutes", url, active)
       VALUES ('E2E Trivia', 'A test game', 'https://example.com/icon.png', 'https://example.com/banner.png', 50, 5, 'https://example.com/game', true)
       RETURNING id`,
    );
    gameId = result[0].id;
  });

  it('GET /api/games — lists games', () => {
    return request(getApp().getHttpServer())
      .get('/api/games?page=1&limit=10')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .expect(200)
      .expect((res) => {
        expect(res.body.data).toBeInstanceOf(Array);
        expect(res.body.data.length).toBeGreaterThan(0);
        expect(res.body.meta).toBeDefined();
      });
  });

  it('POST /api/games/complete — completes game and earns points', async () => {
    const walletBefore = await request(getApp().getHttpServer())
      .get('/api/wallet')
      .set('Authorization', `Bearer ${getAccessToken()}`);

    const res = await request(getApp().getHttpServer())
      .post('/api/games/complete')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .send({ gameId, score: 100 })
      .expect(201);

    expect(res.body.pointsEarned).toBe(50);
    expect(res.body.newBalance).toBe(walletBefore.body.totalPoints + 50);
  });

  it('POST /api/games/complete — prevents playing same game twice today', () => {
    return request(getApp().getHttpServer())
      .post('/api/games/complete')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .send({ gameId, score: 200 })
      .expect((res) => {
        expect([400, 409]).toContain(res.status);
      });
  });
});
