import * as request from 'supertest';
import { setupTestApp, getApp, getAccessToken, getDataSource } from './setup';

describe('Tasks (e2e)', () => {
  let taskId: string;

  beforeAll(async () => {
    await setupTestApp();
    const ds = getDataSource();
    const result = await ds.query(
      `INSERT INTO tasks (title, description, "iconUrl", "pointsReward", category, url, active)
       VALUES ('E2E Task', 'Install the app', 'https://example.com/icon.png', 100, 'Download app', 'https://example.com/task', true)
       RETURNING id`,
    );
    taskId = result[0].id;
  });

  it('GET /api/tasks — lists tasks', () => {
    return request(getApp().getHttpServer())
      .get('/api/tasks?page=1&limit=10')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .expect(200)
      .expect((res) => {
        expect(res.body.data).toBeInstanceOf(Array);
        expect(res.body.data.length).toBeGreaterThan(0);
      });
  });

  it('POST /api/tasks/start — starts a task', () => {
    return request(getApp().getHttpServer())
      .post('/api/tasks/start')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .send({ taskId })
      .expect(201)
      .expect((res) => {
        expect(res.body.status).toBe('in_progress');
      });
  });

  it('POST /api/tasks/:id/complete — completes and earns points', () => {
    return request(getApp().getHttpServer())
      .post(`/api/tasks/${taskId}/complete`)
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .expect(201)
      .expect((res) => {
        expect(res.body.pointsEarned).toBe(100);
        expect(res.body.newBalance).toBeDefined();
      });
  });
});
