import { z } from 'zod';
export const registerSchema = z.object({
  body: z.object({
    employeeId: z.string().trim().min(3).max(100),
    email: z.string().trim().email().max(255).optional(),
    // bcrypt only uses the first 72 bytes; reject longer values rather than silently truncating them.
    password: z.string().min(6).max(72),
    fullName: z.string().trim().min(2).max(200),
    schoolName: z.string().trim().min(2).max(200),
  }),
});
export const loginSchema = z.object({
  body: z.object({
    employeeId: z.string().trim().min(1).max(100).optional(),
    email: z.string().trim().email().max(255).optional(),
    password: z.string().min(1).max(72),
  }).strict().superRefine((data, ctx) => {
    if (!data.employeeId && !data.email) {
      ctx.addIssue({ code: z.ZodIssueCode.custom, path: ['employeeId'], message: 'Provide an employee ID or email address' });
    }
    if (data.employeeId && data.email) {
      ctx.addIssue({ code: z.ZodIssueCode.custom, path: ['email'], message: 'Provide either employee ID or email, not both' });
    }
  }),
});
