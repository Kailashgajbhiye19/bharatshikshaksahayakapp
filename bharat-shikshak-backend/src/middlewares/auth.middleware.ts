import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { Role } from '@prisma/client';
import { env } from '../config/env';
import { AppError } from '../utils/AppError';

export interface AuthRequest extends Request {
  user?: { id: string; role: Role };
}

export const protect = (req: AuthRequest, res: Response, next: NextFunction) => {
  const [scheme, headerToken] = req.headers.authorization?.split(' ') ?? [];
  const rawCookieToken = req.headers.cookie
    ?.split(';')
    .map(cookie => cookie.trim().split('='))
    .find(([name]) => name === 'accessToken')?.[1];

  let cookieToken: string | undefined;
  try { cookieToken = rawCookieToken ? decodeURIComponent(rawCookieToken) : undefined; }
  catch { return next(new AppError('Not authorized, invalid session cookie', 401)); }

  // A stale Postman header must not prevent a valid HTTP-only browser session from working.
  const tokens = [scheme === 'Bearer' ? headerToken : undefined, cookieToken].filter((value): value is string => Boolean(value));
  if (!tokens.length) return next(new AppError('Not authorized, no session token provided', 401));

  for (const token of tokens) {
    try {
      const decoded = jwt.verify(token, env.JWT_SECRET) as { id?: unknown; role?: unknown };
      if (typeof decoded.id !== 'string' || !Object.values(Role).includes(decoded.role as Role)) continue;
      req.user = { id: decoded.id, role: decoded.role as Role };
      return next();
    } catch {
      // Try the next credential (for example, a cookie after an old header).
    }
  }
  return next(new AppError('Not authorized, token is expired or invalid', 401));
};
