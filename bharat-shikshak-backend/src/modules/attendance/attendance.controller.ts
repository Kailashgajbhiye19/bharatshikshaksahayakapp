import { Response, NextFunction } from 'express';
import { AttendanceService } from './attendance.service';
import { AuthRequest } from '../../middlewares/auth.middleware';

export class AttendanceController {
  static async mark(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const count = await AttendanceService.markAttendance(req.user!.id, req.user!.role, req.body);
      res.status(200).json({ success: true, syncedCount: count });
    } catch (error) { next(error); }
  }
  static async getClass(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { classId, date } = req.query;
      const data = await AttendanceService.getClassAttendance(req.user!.id, req.user!.role, classId as string, date as string);
      res.status(200).json({ success: true, data });
    } catch (error) { next(error); }
  }
}
