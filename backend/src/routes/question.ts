import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';
import { QuestionController } from '../controllers/QuestionController.js';

const router = Router();
const controller = new QuestionController();

router.post('/', requireAuth, controller.handleQuestion);

export default router;
