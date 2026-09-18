import { Role } from '@prisma/client';
import { prisma } from '../../config/db';
import { AppError } from '../../utils/AppError';

export class ClassService {
  static async getTeacherClasses(teacherId: string) {
    return await prisma.class.findMany({
      where: { teacherId },
      include: { _count: { select: { students: true } } }
    });
  }

  static async getClassStudents(classId: string) {
    return await prisma.student.findMany({
      where: { classId },
      orderBy: { rollNo: 'asc' }
    });
  }

  /** Ensures teachers can only read or change classes assigned to them. */
  static async assertClassAccess(classId: string, userId: string, role: Role) {
    const classroom = await prisma.class.findUnique({ where: { id: classId }, select: { id: true, teacherId: true } });
    if (!classroom) throw new AppError('Class not found', 404);
    if (role !== Role.ADMIN && classroom.teacherId !== userId) throw new AppError('You do not have access to this class', 403);
    return classroom;
  }
}
