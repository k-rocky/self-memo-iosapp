import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import request from 'supertest';
import app from '../../src/app.js';

vi.mock('../../src/services/QuestionGenerationService.js', () => ({
  QuestionGenerationService: vi.fn().mockImplementation(() => ({
    generateQuestion: vi
      .fn()
      .mockResolvedValue('あなたが羨ましかったのは何ですか？'),
  })),
}));

const TEST_TOKEN = 'test-secret-token';

describe('POST /api/question', () => {
  beforeEach(() => {
    process.env.APP_SECRET_TOKEN = TEST_TOKEN;
    process.env.NODE_ENV = 'test';
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  describe('正常ケース', () => {
    it('有効なリクエストで200と問いを返す', async () => {
      const res = await request(app)
        .post('/api/question')
        .set('Authorization', `Bearer ${TEST_TOKEN}`)
        .send({ memo: '結婚式で友達の熱量に嫉妬した' });

      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('question');
      expect(typeof res.body.question).toBe('string');
      expect(res.body.question.length).toBeGreaterThan(0);
    });
  });

  describe('認証エラー', () => {
    it('Authorizationヘッダーなしで401を返す', async () => {
      const res = await request(app)
        .post('/api/question')
        .send({ memo: 'テスト' });

      expect(res.status).toBe(401);
      expect(res.body).toEqual({ error: 'Unauthorized' });
    });

    it('Bearerスキームなしで401を返す', async () => {
      const res = await request(app)
        .post('/api/question')
        .set('Authorization', TEST_TOKEN)
        .send({ memo: 'テスト' });

      expect(res.status).toBe(401);
    });

    it('誤ったトークンで401を返す', async () => {
      const res = await request(app)
        .post('/api/question')
        .set('Authorization', 'Bearer wrong-token')
        .send({ memo: 'テスト' });

      expect(res.status).toBe(401);
    });
  });

  describe('バリデーションエラー', () => {
    it('memoなしで400を返す', async () => {
      const res = await request(app)
        .post('/api/question')
        .set('Authorization', `Bearer ${TEST_TOKEN}`)
        .send({});

      expect(res.status).toBe(400);
      expect(res.body).toHaveProperty('error');
    });

    it('memo空文字で400を返す', async () => {
      const res = await request(app)
        .post('/api/question')
        .set('Authorization', `Bearer ${TEST_TOKEN}`)
        .send({ memo: '' });

      expect(res.status).toBe(400);
    });
  });
});

describe('GET /health', () => {
  it('200と{status: "ok"}を返す', async () => {
    const res = await request(app).get('/health');

    expect(res.status).toBe(200);
    expect(res.body).toEqual({ status: 'ok' });
  });
});
