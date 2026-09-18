import { z } from 'zod';
import dotenv from 'dotenv';
dotenv.config();

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  // A number makes Express bind a TCP port; a string can be interpreted as a socket path.
  PORT: z.coerce.number().int().min(1).max(65535).default(5000),
  DATABASE_URL: z.string(),
  JWT_SECRET: z.string().min(32, 'JWT_SECRET must be at least 32 characters'),
  JWT_EXPIRES_IN: z.string().default('7d'),
  CORS_ORIGIN: z.string().url().optional(),
});

export const env = envSchema.parse(process.env);
