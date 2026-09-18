import { Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/AppError';
import { ZodError } from 'zod';
import { Prisma } from '@prisma/client';

export const errorHandler = (err: Error, req: Request, res: Response, next: NextFunction) => {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({ success: false, message: err.message });
  }
  if (err instanceof ZodError) {
    return res.status(400).json({
      success: false,
      message: 'Validation Error',
      errors: err.errors.map(e => ({ path: e.path.join('.'), message: e.message }))
    });
  }
  if (err instanceof Prisma.PrismaClientKnownRequestError) {
    if (err.code === 'P2002') return res.status(409).json({ success: false, message: 'A record with these details already exists' });
    if (err.code === 'P2003') return res.status(400).json({ success: false, message: 'A related record does not exist' });
    if (err.code === 'P2025') return res.status(404).json({ success: false, message: 'Record not found' });
  }
  console.error('❌ UNHANDLED ERROR:', err);
  res.status(500).json({ success: false, message: 'Internal Server Error' });
};
