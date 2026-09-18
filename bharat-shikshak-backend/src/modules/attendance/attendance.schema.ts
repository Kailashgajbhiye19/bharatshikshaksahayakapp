import { z } from 'zod';
export const markAttendanceSchema = z.object({
  body: z.object({
    classId: z.string().uuid(),
    // Accept a calendar date from the mobile app, or an ISO timestamp from offline sync.
    date: z.string().regex(/^\d{4}-\d{2}-\d{2}(?:T.*)?$/, 'Use YYYY-MM-DD or an ISO date-time'),
    records: z.array(z.object({
      studentId: z.string().uuid(),
      status: z.enum(['PRESENT', 'ABSENT', 'LATE']),
    })).min(1).superRefine((records, ctx) => {
      const seen = new Set<string>();
      records.forEach((record, index) => {
        if (seen.has(record.studentId)) ctx.addIssue({ code: z.ZodIssueCode.custom, path: [index, 'studentId'], message: 'Each student can appear only once' });
        seen.add(record.studentId);
      });
    }),
  }).strict(),
});

export const classAttendanceSchema = z.object({
  query: z.object({
    classId: z.string().uuid(),
    date: z.string().regex(/^\d{4}-\d{2}-\d{2}(?:T.*)?$/, 'Use YYYY-MM-DD or an ISO date-time'),
  }).strict(),
});
