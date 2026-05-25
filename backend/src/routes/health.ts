import { Router } from 'express';
import type { HealthResponse } from '../types/api.js';

const router = Router();

router.get('/', (_req, res: import('express').Response<HealthResponse>) => {
  res.status(200).json({ status: 'ok' });
});

export default router;
