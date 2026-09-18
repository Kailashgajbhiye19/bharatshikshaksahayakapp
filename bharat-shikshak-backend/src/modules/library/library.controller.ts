import { Response, NextFunction } from 'express';
import { LibraryService } from './library.service';
import { AuthRequest } from '../../middlewares/auth.middleware';

export class LibraryController {
  static async getResources(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { classId } = req.query;
      const data = await LibraryService.getResources(req.user!.id, req.user!.role, classId as string);
      res.status(200).json({ success: true, data });
    } catch (error) { next(error); }
  }
  static async addResource(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      // Files are uploaded by a storage provider; this endpoint stores its resulting public URL.
      const data = await LibraryService.addResource(req.user!.id, req.user!.role, req.body);
      res.status(201).json({ success: true, data });
    } catch (error) { next(error); }
  }
}
