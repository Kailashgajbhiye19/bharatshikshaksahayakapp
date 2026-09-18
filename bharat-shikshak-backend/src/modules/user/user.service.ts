import { prisma } from '../../config/db';
import { AppError } from '../../utils/AppError';

export class UserService {
  static async getProfile(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, fullName: true, employeeId: true, schoolName: true, email: true, role: true }
    });
    if (!user) throw new AppError('User not found', 404);
    return user;
  }
}