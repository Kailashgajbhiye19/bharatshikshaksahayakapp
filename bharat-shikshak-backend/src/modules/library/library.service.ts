import { prisma } from '../../config/db';
import { Role } from '@prisma/client';
import { ClassService } from '../class/class.service';

export class LibraryService {
  static async getResources(userId: string, role: Role, classId: string) {
    await ClassService.assertClassAccess(classId, userId, role);
    return await prisma.resource.findMany({ where: { classId }, orderBy: { uploadedAt: 'desc' } });
  }
  static async addResource(userId: string, role: Role, data: { title: string; fileUrl: string; fileType: string; classId: string }) {
    await ClassService.assertClassAccess(data.classId, userId, role);
    return await prisma.resource.create({ data });
  }
}
