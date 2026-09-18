import { z } from 'zod';

export const getResourcesSchema = z.object({
  query: z.object({ classId: z.string().uuid() }).strict(),
});

export const addResourceSchema = z.object({
  body: z.object({
    title: z.string().trim().min(1).max(200),
    fileUrl: z.string().trim().url().max(2_000),
    fileType: z.string().trim().min(1).max(50),
    classId: z.string().uuid(),
  }).strict(),
});
