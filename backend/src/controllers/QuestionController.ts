import type { Request, Response } from 'express';
import {
  validateQuestionRequest,
  ValidationError,
} from '../validators/questionValidator.js';
import { QuestionGenerationService } from '../services/QuestionGenerationService.js';
import type { QuestionResponse, ErrorResponse } from '../types/api.js';

export class QuestionController {
  private readonly service: QuestionGenerationService;

  constructor(service?: QuestionGenerationService) {
    this.service = service ?? new QuestionGenerationService();
  }

  handleQuestion = async (
    req: Request,
    res: Response<QuestionResponse | ErrorResponse>
  ): Promise<void> => {
    try {
      const { memo } = validateQuestionRequest(req.body);
      const question = await this.service.generateQuestion(memo);
      res.status(200).json({ question });
    } catch (err) {
      if (err instanceof ValidationError) {
        res.status(400).json({ error: err.message });
        return;
      }
      console.error('QuestionController error:', err);
      res.status(500).json({ error: 'Internal server error' });
    }
  };
}
