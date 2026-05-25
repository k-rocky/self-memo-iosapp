export interface QuestionRequest {
  memo: string;
}

export interface QuestionResponse {
  question: string;
}

export interface HealthResponse {
  status: 'ok';
}

export interface ErrorResponse {
  error: string;
}
