import { Response, NextFunction } from 'express';
import { ClassService } from './class.service';
import { AuthRequest } from '../../middlewares/auth.middleware';

export class ClassController {
  static async getMyClasses(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const classes = await ClassService.getTeacherClasses(req.user!.id);
      res.status(200).json({ success: true, data: classes });
    } catch (error) { next(error); }
  }

  static async getStudents(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      await ClassService.assertClassAccess(req.params.classId, req.user!.id, req.user!.role);
      const students = await ClassService.getClassStudents(req.params.classId);
      res.status(200).json({ success: true, data: students });
    } catch (error) { next(error); }
  }
}
