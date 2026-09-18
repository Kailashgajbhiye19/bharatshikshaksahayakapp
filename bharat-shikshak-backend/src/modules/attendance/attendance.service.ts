import { prisma } from '../../config/db';
import { AttendanceStatus, Role } from '@prisma/client';
import { AppError } from '../../utils/AppError';
import { ClassService } from '../class/class.service';

/** Converts any accepted client date to the one UTC calendar-day key stored in PostgreSQL. */
const attendanceDay = (value: string) => {
  const calendarPart = value.slice(0, 10);
  const [year, month, day] = calendarPart.split('-').map(Number);
  const date = new Date(Date.UTC(year, month - 1, day));
  // Date normalizes impossible values (for example 2026-02-30), so verify each part.
  if (date.getUTCFullYear() !== year || date.getUTCMonth() !== month - 1 || date.getUTCDate() !== day) {
    throw new AppError('Invalid attendance date', 400);
  }
  return date;
};

export class AttendanceService {
  static async markAttendance(teacherId: string, role: Role, data: { classId: string; date: string; records: { studentId: string; status: AttendanceStatus }[] }) {
    await ClassService.assertClassAccess(data.classId, teacherId, role);
    const dateObj = attendanceDay(data.date);
    // Checking ownership before writes prevents a valid student ID from another class being marked.
    const validStudents = await prisma.student.findMany({
      where: { classId: data.classId, id: { in: data.records.map(record => record.studentId) } },
      select: { id: true },
    });
    if (validStudents.length !== data.records.length) throw new AppError('One or more students do not belong to this class', 400);
    const results = await prisma.$transaction(
      data.records.map(record =>
        prisma.attendanceRecord.upsert({
          where: { studentId_date: { studentId: record.studentId, date: dateObj } },
          update: { status: record.status, markedById: teacherId, syncedAt: new Date() },
          create: {
            studentId: record.studentId,
            status: record.status,
            date: dateObj,
            markedById: teacherId,
          }
        })
      )
    );
    return results.length;
  }

  static async getClassAttendance(userId: string, role: Role, classId: string, dateStr: string) {
    await ClassService.assertClassAccess(classId, userId, role);
    const dateObj = attendanceDay(dateStr);
    const students = await prisma.student.findMany({
      where: { classId },
      include: { attendanceRecords: { where: { date: dateObj } } },
      orderBy: { rollNo: 'asc' }
    });
    return students.map(s => ({
      id: s.id, name: s.name, rollNo: s.rollNo,
      status: s.attendanceRecords[0]?.status || 'NOT_MARKED'
    }));
  }
}
