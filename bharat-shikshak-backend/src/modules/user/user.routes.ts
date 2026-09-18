import { Router } from 'express';
import { UserController } from './user.controller';
import { protect } from '../../middlewares/auth.middleware';

const router = Router();
router.use(protect);
router.get('/me', UserController.getProfile);
export default router;