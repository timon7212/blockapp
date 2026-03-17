import * as request from 'supertest';
import {
  setupTestApp,
  getApp,
  getAccessToken,
  getAdminAccessToken,
  getDataSource,
  getUserId,
} from './setup';

describe('Raffles (e2e)', () => {
  let openRaffleId: string;
  let prereqRaffleId: string;
  let expiredRaffleId: string;

  beforeAll(async () => {
    await setupTestApp();
    const ds = getDataSource();
    const token = getAdminAccessToken();
    const srv = getApp().getHttpServer();

    const drawDate = new Date();
    drawDate.setDate(drawDate.getDate() + 1);

    // Create raffle with no prerequisites via admin
    const openRes = await request(srv)
      .post('/api/admin/raffles')
      .set('Authorization', `Bearer ${token}`)
      .send({
        title: 'Open Raffle',
        type: 'daily',
        prizeAmount: 500,
        drawDate: drawDate.toISOString(),
      })
      .expect(201);

    openRaffleId = openRes.body.id;

    // Create raffle with ads_watched prerequisite
    const prereqRes = await request(srv)
      .post('/api/admin/raffles')
      .set('Authorization', `Bearer ${token}`)
      .send({
        title: 'Premium Raffle',
        type: 'monthly',
        prizeAmount: 5000,
        drawDate: drawDate.toISOString(),
      })
      .expect(201);

    prereqRaffleId = prereqRes.body.id;

    await request(srv)
      .post(`/api/admin/raffles/${prereqRaffleId}/prerequisites`)
      .set('Authorization', `Bearer ${token}`)
      .send({ type: 'ads_watched', requiredCount: 5 })
      .expect(201);

    // Create expired raffle for draw tests
    const pastDate = new Date();
    pastDate.setHours(pastDate.getHours() - 1);

    const expiredRes = await request(srv)
      .post('/api/admin/raffles')
      .set('Authorization', `Bearer ${token}`)
      .send({
        title: 'Expired Raffle',
        type: 'weekly',
        prizeAmount: 1000,
        drawDate: pastDate.toISOString(),
      })
      .expect(201);

    expiredRaffleId = expiredRes.body.id;

    await request(srv)
      .post(`/api/admin/raffles/${expiredRaffleId}/prerequisites`)
      .set('Authorization', `Bearer ${token}`)
      .send({ type: 'ads_watched', requiredCount: 1 })
      .expect(201);
  });

  it('GET /api/raffles — lists active raffles with prerequisites array', () => {
    return request(getApp().getHttpServer())
      .get('/api/raffles')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .expect(200)
      .expect((res) => {
        expect(res.body).toBeInstanceOf(Array);
        expect(res.body.length).toBeGreaterThanOrEqual(2);
        const open = res.body.find((r) => r.id === openRaffleId);
        expect(open.prerequisites).toBeInstanceOf(Array);
        expect(open.prerequisites.length).toBe(0);
        expect(open.isEligible).toBe(true);
      });
  });

  it('GET /api/raffles/:id — returns prerequisite details', () => {
    return request(getApp().getHttpServer())
      .get(`/api/raffles/${prereqRaffleId}`)
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .expect(200)
      .expect((res) => {
        expect(res.body.prerequisites.length).toBe(1);
        expect(res.body.prerequisites[0].type).toBe('ads_watched');
        expect(res.body.prerequisites[0].requiredCount).toBe(5);
        expect(res.body.prerequisites[0].met).toBe(false);
        expect(res.body.isEligible).toBe(false);
      });
  });

  it('POST /api/raffles/:id/enter — enters raffle with no prerequisites', () => {
    return request(getApp().getHttpServer())
      .post(`/api/raffles/${openRaffleId}/enter`)
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .send({ adType: 'rewarded' })
      .expect(201)
      .expect((res) => {
        expect(res.body.success).toBe(true);
        expect(res.body.entryId).toBeDefined();
      });
  });

  it('POST /api/raffles/:id/enter — prevents duplicate entry', () => {
    return request(getApp().getHttpServer())
      .post(`/api/raffles/${openRaffleId}/enter`)
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .send({ adType: 'rewarded' })
      .expect(409);
  });

  it('POST /api/raffles/:id/enter — rejects when prerequisite not met', () => {
    return request(getApp().getHttpServer())
      .post(`/api/raffles/${prereqRaffleId}/enter`)
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .send({ adType: 'rewarded' })
      .expect(400);
  });

  it('POST /api/raffles/:id/enter — allows entry after meeting prerequisites', async () => {
    const srv = getApp().getHttpServer();
    const token = getAccessToken();

    // Record 5 ad views to satisfy prerequisite
    for (let i = 0; i < 5; i++) {
      await request(srv)
        .post('/api/events/ad-view')
        .set('Authorization', `Bearer ${token}`)
        .send({ adType: 'rewarded', context: 'test' })
        .expect(201);
    }

    // Now should be eligible
    const detail = await request(srv)
      .get(`/api/raffles/${prereqRaffleId}`)
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(detail.body.prerequisites[0].met).toBe(true);
    expect(detail.body.isEligible).toBe(true);

    await request(srv)
      .post(`/api/raffles/${prereqRaffleId}/enter`)
      .set('Authorization', `Bearer ${token}`)
      .send({ adType: 'rewarded' })
      .expect(201);
  });

  it('POST /api/raffles/draw — draws expired raffle and awards prize', async () => {
    const srv = getApp().getHttpServer();
    const token = getAccessToken();

    // Enter the expired raffle (prereq is 1 ad view, already satisfied)
    await request(srv)
      .post(`/api/raffles/${expiredRaffleId}/enter`)
      .set('Authorization', `Bearer ${token}`)
      .send({ adType: 'rewarded' })
      .expect(201);

    const balanceBefore = await request(srv)
      .get('/api/wallet')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    await request(srv)
      .post('/api/raffles/draw')
      .set('Authorization', `Bearer ${token}`)
      .expect(201)
      .expect((res) => {
        expect(res.body.triggered).toBe(true);
      });

    const result = await request(srv)
      .get(`/api/raffles/${expiredRaffleId}/result`)
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(result.body.winnerId).toBe(getUserId());
    expect(result.body.isCurrentUserWinner).toBe(true);
    expect(result.body.prizeAmount).toBe(1000);

    const balanceAfter = await request(srv)
      .get('/api/wallet')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(balanceAfter.body.totalPoints).toBe(
      balanceBefore.body.totalPoints + 1000,
    );
  });

  it('POST /api/raffles/draw — creates next raffle with same prerequisites', async () => {
    const ds = getDataSource();
    const nextRaffles = await ds.query(
      `SELECT r.*, (SELECT COUNT(*) FROM raffle_prerequisites WHERE "raffleId" = r.id) AS prereq_count
       FROM raffles r
       WHERE r.title = 'Expired Raffle' AND r.active = true`,
    );
    expect(nextRaffles.length).toBe(1);
    expect(nextRaffles[0].type).toBe('weekly');
    expect(nextRaffles[0].prizeAmount).toBe(1000);
    expect(Number(nextRaffles[0].prereq_count)).toBe(1);
  });

  it('GET /api/raffles/winners — returns past winners', () => {
    return request(getApp().getHttpServer())
      .get('/api/raffles/winners?page=1&limit=10')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .expect(200)
      .expect((res) => {
        expect(res.body.data).toBeInstanceOf(Array);
        expect(res.body.meta).toBeDefined();
        expect(res.body.data.length).toBeGreaterThanOrEqual(1);
        const winner = res.body.data[0];
        expect(winner.winnerId).toBeDefined();
        expect(winner.winnerUsername).toBeDefined();
        expect(winner.prizeAmount).toBeDefined();
        expect(winner.raffleTitle).toBeDefined();
      });
  });

  it('GET /api/raffles/winners?type=weekly — filters by type', () => {
    return request(getApp().getHttpServer())
      .get('/api/raffles/winners?type=weekly')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .expect(200)
      .expect((res) => {
        expect(res.body.data.length).toBeGreaterThanOrEqual(1);
      });
  });

  it('GET /api/raffles/history/me — returns history with wins', () => {
    return request(getApp().getHttpServer())
      .get('/api/raffles/history/me?page=1&limit=10')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .expect(200)
      .expect((res) => {
        expect(res.body.data).toBeInstanceOf(Array);
        expect(res.body.meta).toBeDefined();
        const won = res.body.data.find((d) => d.isCurrentUserWinner);
        expect(won).toBeDefined();
        expect(won.prizeAmount).toBe(1000);
      });
  });
});
