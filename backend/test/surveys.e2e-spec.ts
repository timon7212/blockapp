import * as request from 'supertest';
import { setupTestApp, getApp, getAccessToken, getDataSource } from './setup';

describe('Surveys (e2e)', () => {
  let surveyId: string;

  beforeAll(async () => {
    await setupTestApp();
    const ds = getDataSource();
    const result = await ds.query(
      `INSERT INTO surveys (title, description, "pointsReward", "estimatedMinutes", "questionCount", active)
       VALUES ('E2E Survey', 'A quick survey', 80, 5, 3, true)
       RETURNING id`,
    );
    surveyId = result[0].id;
  });

  it('GET /api/surveys — lists surveys', () => {
    return request(getApp().getHttpServer())
      .get('/api/surveys?page=1&limit=10')
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .expect(200)
      .expect((res) => {
        expect(res.body.data).toBeInstanceOf(Array);
        expect(res.body.data.length).toBeGreaterThan(0);
      });
  });

  it('POST /api/surveys/:id/submit — submits and earns points', () => {
    return request(getApp().getHttpServer())
      .post(`/api/surveys/${surveyId}/submit`)
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .send({
        answers: [
          { questionId: 'q1', answer: 'option_a' },
          { questionId: 'q2', answer: 'option_c' },
        ],
      })
      .expect(201)
      .expect((res) => {
        expect(res.body.pointsEarned).toBe(80);
        expect(res.body.newBalance).toBeDefined();
      });
  });

  it('POST /api/surveys/:id/submit — prevents duplicate', () => {
    return request(getApp().getHttpServer())
      .post(`/api/surveys/${surveyId}/submit`)
      .set('Authorization', `Bearer ${getAccessToken()}`)
      .send({ answers: [{ questionId: 'q1', answer: 'a' }] })
      .expect((res) => {
        expect([400, 409]).toContain(res.status);
      });
  });
});
