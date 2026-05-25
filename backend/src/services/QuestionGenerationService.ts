import Anthropic from '@anthropic-ai/sdk';
import { buildQuestionPrompt } from '../prompts/questionPrompt.js';

export class QuestionGenerationService {
  private readonly client: Anthropic;
  private readonly model: string;

  constructor(client?: Anthropic) {
    this.client =
      client ??
      new Anthropic({
        apiKey: process.env.ANTHROPIC_API_KEY,
        timeout: 10_000,
      });
    this.model = process.env.CLAUDE_MODEL ?? 'claude-sonnet-4-6';
  }

  async generateQuestion(memo: string): Promise<string> {
    const prompt = buildQuestionPrompt(memo);

    const message = await this.client.messages.create({
      model: this.model,
      max_tokens: 256,
      messages: [{ role: 'user', content: prompt }],
    });

    if (!message.content.length) {
      throw new Error('Empty response from Claude API');
    }

    const block = message.content[0];
    if (block.type !== 'text') {
      throw new Error('Unexpected response type from Claude API');
    }

    return block.text.trim();
  }
}
