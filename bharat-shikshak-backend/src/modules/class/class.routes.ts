import { Router } from 'express';
import { ClassController } from './class.controller';
import { protect } from '../../middlewares/auth.middleware';
import { validate } from '../../middlewares/validate.middleware';
import { z } from 'zod';

const router = Router();
router.use(protect);
router.get('/', ClassController.getMyClasses);
router.get('/:classId/students', validate(z.object({ params: z.object({ classId: z.string().uuid() }) })), ClassController.getStudents);
export default router;
