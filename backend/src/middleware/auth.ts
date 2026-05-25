import type { Request, Response, NextFunction } from 'express';
import type { ErrorResponse } from '../types/api.js';

export function requireAuth(
  req: Request,
  res: Response<ErrorResponse>,
  next: NextFunction
): void {
  const token = process.env.APP_SECRET_TOKEN;
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    res.status(401).json({ error: 'Unauthorized' });
    return;
  }

  const provided = authHeader.slice('Bearer '.length);

  if (!token || provided !== token) {
    res.status(401).json({ error: 'Unauthorized' });
    return;
  }

  next();
}
