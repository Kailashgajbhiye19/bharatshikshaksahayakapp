import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';

/** Validates and replaces request input with Zod's cleaned/coerced result. */
export const validate = (schema: z.ZodTypeAny) =>
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const parsed = await schema.parseAsync({ body: req.body, query: req.query, params: req.params });
      // Do not merely validate: handlers must receive trimmed and transformed values.
      if (parsed.body !== undefined) req.body = parsed.body;
      if (parsed.query !== undefined) req.query = parsed.query;
      if (parsed.params !== undefined) req.params = parsed.params;
      next();
    } catch (error) {
      next(error);
    }
  };
