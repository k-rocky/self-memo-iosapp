import { describe, it, expect, vi, beforeEach } from 'vitest';
import { QuestionGenerationService } from '../../../src/services/QuestionGenerationService.js';

const mockCreate = vi.fn();

const mockClient = {
  messages: {
    create: mockCreate,
  },
} as unknown as import('@anthropic-ai/sdk').default;

describe('QuestionGenerationService', () => {
  let service: QuestionGenerationService;

  beforeEach(() => {
    vi.clearAllMocks();
    service = new QuestionGenerationService(mockClient);
  });

  describe('generateQuestion', () => {
    it('メモを渡すとClaudeAPIが返した問いテキストを返す', async () => {
      const expectedQuestion =
        'あなたが羨ましかったのは、才能ですか？それとも自由ですか？';
      mockCreate.mockResolvedValue({
        content: [{ type: 'text', text: `  ${expectedQuestion}  ` }],
      });

      const result = await service.generateQuestion('友達の熱量に嫉妬した');

      expect(result).toBe(expectedQuestion);
      expect(mockCreate).toHaveBeenCalledOnce();
    });

    it('Claude APIへのリクエストに正しいパラメータが渡される', async () => {
      mockCreate.mockResolvedValue({
        content: [{ type: 'text', text: 'テスト問い？' }],
      });

      await service.generateQuestion('宇宙のことを考えるとワクワクする');

      const callArgs = mockCreate.mock.calls[0][0];
      expect(callArgs.max_tokens).toBe(256);
      expect(callArgs.messages[0].role).toBe('user');
      expect(callArgs.messages[0].content).toContain(
        '宇宙のことを考えるとワクワクする'
      );
    });

    it('レスポンスのtypeがtextでない場合エラーをスロー', async () => {
      mockCreate.mockResolvedValue({
        content: [{ type: 'tool_use', id: 'test', name: 'test', input: {} }],
      });

      await expect(service.generateQuestion('テスト')).rejects.toThrow(
        'Unexpected response type from Claude API'
      );
    });

    it('Claude APIがエラーを返した場合エラーが伝播する', async () => {
      mockCreate.mockRejectedValue(new Error('API Error'));

      await expect(service.generateQuestion('テスト')).rejects.toThrow(
        'API Error'
      );
    });

    it('contentが空配列の場合エラーをスロー', async () => {
      mockCreate.mockResolvedValue({ content: [] });

      await expect(service.generateQuestion('テスト')).rejects.toThrow(
        'Empty response from Claude API'
      );
    });
  });
});
