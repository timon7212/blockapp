import * as request from 'supertest';
import {
  setupTestApp,
  getApp,
  getAccessToken,
  getAdminAccessToken,
} from './setup';

describe('Admin (e2e)', () => {
  beforeAll(() => setupTestApp());

  const srv = () => getApp().getHttpServer();

  it('POST /api/admin/raffles — forbidden for regular users', () => {
    return request(srv())
      .post('/api/admin/raffles')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .send({
        title: 'Test',
        type: 'daily',
        prizeAmount: 100,
        drawDate: new Date(Date.now() + 86400000).toISOString(),
      })
      .expect(403);
  });

  describe('Raffle CRUD', () => {
    let raffleId: string;

    it('POST /api/admin/raffles — creates raffle', async () => {
      const res = await request(srv())
        .post('/api/admin/raffles')
        .set('Authorization', `Bearer ${getAdminAccessToken()}`)
        .send({
          title: 'Admin Test Raffle',
          type: 'daily',
          prizeAmount: 100,
          drawDate: new Date(Date.now() + 86400000).toISOString(),
        })
        .expect(201);

      expect(res.body.id).toBeDefined();
      expect(res.body.title).toBe('Admin Test Raffle');
      raffleId = res.body.id;
    });

    it('GET /api/admin/raffles/:id — gets raffle with prerequisites', async () => {
      const res = await request(srv())
        .get(`/api/admin/raffles/${raffleId}`)
        .set('Authorization', `Bearer ${getAdminAccessToken()}`)
        .expect(200);

      expect(res.body.id).toBe(raffleId);
      expect(res.body.prerequisites).toBeInstanceOf(Array);
      expect(res.body.prerequisites.length).toBe(0);
    });

    it('PUT /api/admin/raffles/:id — updates raffle', async () => {
      const res = await request(srv())
        .put(`/api/admin/raffles/${raffleId}`)
        .set('Authorization', `Bearer ${getAdminAccessToken()}`)
        .send({ title: 'Updated Raffle', prizeAmount: 999 })
        .expect(200);

      expect(res.body.title).toBe('Updated Raffle');
      expect(res.body.prizeAmount).toBe(999);
    });

    it('POST /api/admin/raffles/:id/prerequisites — adds prerequisite', async () => {
      const res = await request(srv())
        .post(`/api/admin/raffles/${raffleId}/prerequisites`)
        .set('Authorization', `Bearer ${getAdminAccessToken()}`)
        .send({ type: 'ads_watched', requiredCount: 3 })
        .expect(201);

      expect(res.body.type).toBe('ads_watched');
      expect(res.body.requiredCount).toBe(3);
    });

    it('POST /api/admin/raffles/:id/prerequisites — adds second prerequisite', async () => {
      const res = await request(srv())
        .post(`/api/admin/raffles/${raffleId}/prerequisites`)
        .set('Authorization', `Bearer ${getAdminAccessToken()}`)
        .send({ type: 'tasks_completed', requiredCount: 2 })
        .expect(201);

      expect(res.body.type).toBe('tasks_completed');
    });

    it('GET /api/admin/raffles/:id — shows both prerequisites', async () => {
      const res = await request(srv())
        .get(`/api/admin/raffles/${raffleId}`)
        .set('Authorization', `Bearer ${getAdminAccessToken()}`)
        .expect(200);

      expect(res.body.prerequisites.length).toBe(2);
    });

    it('DELETE /api/admin/raffles/:id/prerequisites/:prereqId — removes prerequisite', async () => {
      const raffle = await request(srv())
        .get(`/api/admin/raffles/${raffleId}`)
        .set('Authorization', `Bearer ${getAdminAccessToken()}`)
        .expect(200);

      const prereqId = raffle.body.prerequisites[0].id;

      await request(srv())
        .delete(`/api/admin/raffles/${raffleId}/prerequisites/${prereqId}`)
        .set('Authorization', `Bearer ${getAdminAccessToken()}`)
        .expect(200);

      const updated = await request(srv())
        .get(`/api/admin/raffles/${raffleId}`)
        .set('Authorization', `Bearer ${getAdminAccessToken()}`)
        .expect(200);

      expect(updated.body.prerequisites.length).toBe(1);
    });

    it('DELETE /api/admin/raffles/:id — deletes raffle', async () => {
      await request(srv())
        .delete(`/api/admin/raffles/${raffleId}`)
        .set('Authorization', `Bearer ${getAdminAccessToken()}`)
        .expect(200);
    });
  });

  describe('Game CRUD', () => {
    let gameId: string;

    it('POST /api/admin/games — creates game', async () => {
      const res = await request(srv())
        .post('/api/admin/games')
        .set('Authorization', `Bearer ${getAdminAccessToken()}`)
        .send({
          title: 'Admin Game',
          description: 'Test game',
          pointsReward: 50,
          estimatedMinutes: 5,
          url: 'https://example.com/game',
        })
        .expect(201);

      expect(res.body.id).toBeDefined();
      gameId = res.body.id;
    });

    it('PUT /api/admin/games/:id — updates game', async () => {
      const res = await request(srv())
        .put(`/api/admin/games/${gameId}`)
        .set('Authorization', `Bearer ${getAdminAccessToken()}`)
        .send({ title: 'Updated Game' })
        .expect(200);

      expect(res.body.title).toBe('Updated Game');
    });

    it('DELETE /api/admin/games/:id — deactivates game', async () => {
      await request(srv())
        .delete(`/api/admin/games/${gameId}`)
        .set('Authorization', `Bearer ${getAdminAccessToken()}`)
        .expect(200);
    });
  });

  describe('Task CRUD', () => {
    let taskId: string;

    it('POST /api/admin/tasks — creates task', async () => {
      const res = await request(srv())
        .post('/api/admin/tasks')
        .set('Authorization', `Bearer ${getAdminAccessToken()}`)
        .send({
          title: 'Admin Task',
          description: 'Test task',
          pointsReward: 30,
          category: 'download',
          url: 'https://example.com/task',
        })
        .expect(201);

      expect(res.body.id).toBeDefined();
      taskId = res.body.id;
    });

    it('PUT /api/admin/tasks/:id — updates task', async () => {
      const res = await request(srv())
        .put(`/api/admin/tasks/${taskId}`)
        .set('Authorization', `Bearer ${getAdminAccessToken()}`)
        .send({ title: 'Updated Task' })
        .expect(200);

      expect(res.body.title).toBe('Updated Task');
    });

    it('DELETE /api/admin/tasks/:id — deactivates task', async () => {
      await request(srv())
        .delete(`/api/admin/tasks/${taskId}`)
        .set('Authorization', `Bearer ${getAdminAccessToken()}`)
        .expect(200);
    });
  });

  describe('Survey CRUD', () => {
    let surveyId: string;

    it('POST /api/admin/surveys — creates survey', async () => {
      const res = await request(srv())
        .post('/api/admin/surveys')
        .set('Authorization', `Bearer ${getAdminAccessToken()}`)
        .send({
          title: 'Admin Survey',
          description: 'Test survey',
          pointsReward: 40,
          estimatedMinutes: 10,
          questionCount: 5,
        })
        .expect(201);

      expect(res.body.id).toBeDefined();
      surveyId = res.body.id;
    });

    it('PUT /api/admin/surveys/:id — updates survey', async () => {
      const res = await request(srv())
        .put(`/api/admin/surveys/${surveyId}`)
        .set('Authorization', `Bearer ${getAdminAccessToken()}`)
        .send({ title: 'Updated Survey' })
        .expect(200);

      expect(res.body.title).toBe('Updated Survey');
    });

    it('DELETE /api/admin/surveys/:id — deactivates survey', async () => {
      await request(srv())
        .delete(`/api/admin/surveys/${surveyId}`)
        .set('Authorization', `Bearer ${getAdminAccessToken()}`)
        .expect(200);
    });
  });

  describe('Spin Prize CRUD', () => {
    let prizeId: string;

    it('POST /api/admin/spin-prizes — creates spin prize', async () => {
      const res = await request(srv())
        .post('/api/admin/spin-prizes')
        .set('Authorization', `Bearer ${getAdminAccessToken()}`)
        .send({
          label: '500 Points',
          type: 'points',
          value: 500,
          weight: 10,
        })
        .expect(201);

      expect(res.body.id).toBeDefined();
      expect(res.body.label).toBe('500 Points');
      expect(res.body.type).toBe('points');
      expect(res.body.value).toBe(500);
      expect(res.body.weight).toBe(10);
      prizeId = res.body.id;
    });

    it('GET /api/admin/spin-prizes — lists prizes', async () => {
      const res = await request(srv())
        .get('/api/admin/spin-prizes')
        .set('Authorization', `Bearer ${getAdminAccessToken()}`)
        .expect(200);

      expect(res.body).toBeInstanceOf(Array);
      expect(res.body.length).toBeGreaterThanOrEqual(1);
    });

    it('PUT /api/admin/spin-prizes/:id — updates spin prize', async () => {
      const res = await request(srv())
        .put(`/api/admin/spin-prizes/${prizeId}`)
        .set('Authorization', `Bearer ${getAdminAccessToken()}`)
        .send({ label: 'Updated Prize', weight: 20 })
        .expect(200);

      expect(res.body.label).toBe('Updated Prize');
      expect(res.body.weight).toBe(20);
    });

    it('DELETE /api/admin/spin-prizes/:id — deletes spin prize', async () => {
      await request(srv())
        .delete(`/api/admin/spin-prizes/${prizeId}`)
        .set('Authorization', `Bearer ${getAdminAccessToken()}`)
        .expect(200);
    });

    it('POST /api/admin/spin-prizes — forbidden for regular users', () => {
      return request(srv())
        .post('/api/admin/spin-prizes')
        .set('Authorization', `Bearer ${getAccessToken()}`)
        .send({
          label: 'Hacker Prize',
          type: 'points',
          value: 9999,
          weight: 100,
        })
        .expect(403);
    });
  });
});
