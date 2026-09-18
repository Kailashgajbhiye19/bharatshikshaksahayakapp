import { Response, NextFunction } from 'express';
import { UserService } from './user.service';
import { AuthRequest } from '../../middlewares/auth.middleware';

export class UserController {
  static async getProfile(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const user = await UserService.getProfile(req.user!.id);
      res.status(200).json({ success: true, data: user });
    } catch (error) { next(error); }
  }
}