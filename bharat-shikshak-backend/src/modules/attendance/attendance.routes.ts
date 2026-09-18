import { Router } from 'express';
import { AttendanceController } from './attendance.controller';
import { protect } from '../../middlewares/auth.middleware';
import { validate } from '../../middlewares/validate.middleware';
import { classAttendanceSchema, markAttendanceSchema } from './attendance.schema';

const router = Router();
router.use(protect);
router.post('/mark', validate(markAttendanceSchema), AttendanceController.mark);
router.get('/class', validate(classAttendanceSchema), AttendanceController.getClass);
export default router;
