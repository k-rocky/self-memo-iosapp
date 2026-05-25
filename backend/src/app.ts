import 'dotenv/config';
import express from 'express';
import questionRouter from './routes/question.js';
import healthRouter from './routes/health.js';

const app = express();

app.use(express.json({ limit: '50kb' }));

app.use('/health', healthRouter);
app.use('/api/question', questionRouter);

const port = process.env.PORT ?? 3000;

if (process.env.NODE_ENV !== 'test') {
  app.listen(port, () => {
    console.log(`Inner Orbit backend listening on port ${port}`);
  });
}

export default app;
