import { Request, Response, NextFunction } from 'express';
import { AuthService } from './auth.service';
import { env } from '../../config/env';

const sessionCookie = {
  httpOnly: true,
  secure: env.NODE_ENV === 'production',
  sameSite: 'lax' as const,
  path: '/',
  maxAge: 7 * 24 * 60 * 60 * 1000,
};

export class AuthController {
  static async register(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await AuthService.register(req.body);
      // HTTP-only prevents browser JavaScript from reading the session token.
      res.cookie('accessToken', result.token, sessionCookie);
      res.status(201).json({ success: true, ...result });
    }
    catch (error) { next(error); }
  }
  static async login(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await AuthService.login(req.body);
      res.cookie('accessToken', result.token, sessionCookie);
      res.status(200).json({ success: true, ...result });
    }
    catch (error) { next(error); }
  }

  static logout(req: Request, res: Response, next: NextFunction) {
    try {
      res.clearCookie('accessToken', { httpOnly: true, secure: env.NODE_ENV === 'production', sameSite: 'lax', path: '/' });
      res.status(200).json({ success: true, message: 'Logged out successfully' });
    } catch (error) { next(error); }
  }
}
