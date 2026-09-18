import { Router } from 'express';
import { LibraryController } from './library.controller';
import { protect } from '../../middlewares/auth.middleware';
import { validate } from '../../middlewares/validate.middleware';
import { addResourceSchema, getResourcesSchema } from './library.schema';

const router = Router();
router.use(protect);
router.get('/', validate(getResourcesSchema), LibraryController.getResources);
router.post('/', validate(addResourceSchema), LibraryController.addResource);
export default router;
