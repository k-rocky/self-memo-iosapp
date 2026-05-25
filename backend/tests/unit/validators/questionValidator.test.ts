import { describe, it, expect } from 'vitest';
import {
  validateQuestionRequest,
  ValidationError,
} from '../../../src/validators/questionValidator.js';

describe('validateQuestionRequest', () => {
  describe('正常ケース', () => {
    it('有効なmemoでQuestionRequestを返す', () => {
      const result = validateQuestionRequest({
        memo: '結婚式で友達の熱量に嫉妬した',
      });
      expect(result).toEqual({ memo: '結婚式で友達の熱量に嫉妬した' });
    });

    it('1文字のmemoを受け付ける', () => {
      const result = validateQuestionRequest({ memo: 'a' });
      expect(result.memo).toBe('a');
    });

    it('余分なフィールドは無視してmemoのみ返す', () => {
      const result = validateQuestionRequest({
        memo: 'テスト',
        extra: 'ignored',
      });
      expect(result).toEqual({ memo: 'テスト' });
    });
  });

  describe('異常ケース', () => {
    it('bodyがnullのとき ValidationError をスロー', () => {
      expect(() => validateQuestionRequest(null)).toThrow(ValidationError);
      expect(() => validateQuestionRequest(null)).toThrow(
        'Request body must be a JSON object'
      );
    });

    it('bodyが文字列のとき ValidationError をスロー', () => {
      expect(() => validateQuestionRequest('string')).toThrow(ValidationError);
    });

    it('memoが未指定のとき ValidationError をスロー', () => {
      expect(() => validateQuestionRequest({})).toThrow(ValidationError);
      expect(() => validateQuestionRequest({})).toThrow('memo is required');
    });

    it('memoがnullのとき ValidationError をスロー', () => {
      expect(() => validateQuestionRequest({ memo: null })).toThrow(
        ValidationError
      );
      expect(() => validateQuestionRequest({ memo: null })).toThrow(
        'memo is required'
      );
    });

    it('memoが数値のとき ValidationError をスロー', () => {
      expect(() => validateQuestionRequest({ memo: 123 })).toThrow(
        ValidationError
      );
      expect(() => validateQuestionRequest({ memo: 123 })).toThrow(
        'memo must be a string'
      );
    });

    it('memoが空文字のとき ValidationError をスロー', () => {
      expect(() => validateQuestionRequest({ memo: '' })).toThrow(
        ValidationError
      );
      expect(() => validateQuestionRequest({ memo: '' })).toThrow(
        'memo must not be empty'
      );
    });

    it('memoが空白のみのとき ValidationError をスロー', () => {
      expect(() => validateQuestionRequest({ memo: '   ' })).toThrow(
        ValidationError
      );
      expect(() => validateQuestionRequest({ memo: '   ' })).toThrow(
        'memo must not be empty'
      );
    });

    it('ValidationError の status が 400', () => {
      try {
        validateQuestionRequest({});
      } catch (e) {
        expect(e).toBeInstanceOf(ValidationError);
        expect((e as ValidationError).status).toBe(400);
      }
    });
  });
});
