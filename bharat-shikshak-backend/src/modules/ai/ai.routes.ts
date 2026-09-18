import { Router } from 'express';
import { AIController } from './ai.controller';
import { protect } from '../../middlewares/auth.middleware';
import { validate } from '../../middlewares/validate.middleware';
import { z } from 'zod';

const router = Router();
router.use(protect);
const askSchema = z.object({
  body: z.object({
    prompt: z.string().trim().min(1).max(4_000),
    gradeLevel: z.string().trim().min(1).max(50),
  }).strict(),
});
router.post('/ask', validate(askSchema), AIController.askSahayak);
export default router;
