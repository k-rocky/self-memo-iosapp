import type { QuestionRequest } from '../types/api.js';

export class ValidationError extends Error {
  status = 400;
  constructor(message: string) {
    super(message);
    this.name = 'ValidationError';
  }
}

export function validateQuestionRequest(body: unknown): QuestionRequest {
  if (typeof body !== 'object' || body === null) {
    throw new ValidationError('Request body must be a JSON object');
  }

  const { memo } = body as Record<string, unknown>;

  if (memo === undefined || memo === null) {
    throw new ValidationError('memo is required');
  }

  if (typeof memo !== 'string') {
    throw new ValidationError('memo must be a string');
  }

  if (memo.trim().length === 0) {
    throw new ValidationError('memo must not be empty');
  }

  return { memo };
}
