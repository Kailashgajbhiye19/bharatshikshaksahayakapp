import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { Prisma } from '@prisma/client';
import { prisma } from '../../config/db';
import { env } from '../../config/env';
import { AppError } from '../../utils/AppError';

export class AuthService {
  static async register(data: { employeeId: string; email?: string; password: string; fullName: string; schoolName: string }) {
    const identityFilters: Prisma.UserWhereInput[] = [{ employeeId: data.employeeId }];
    if (data.email) identityFilters.push({ email: data.email });
    const existingUser = await prisma.user.findFirst({ where: { OR: identityFilters } });
    if (existingUser) throw new AppError('User already exists', 400);
    const passwordHash = await bcrypt.hash(data.password, 10);
    // Passwords are never persisted directly; only the bcrypt hash belongs in User.
    const { password, ...userData } = data;
    const user = await prisma.user.create({ data: { ...userData, passwordHash } });
    const token = this.generateToken(user.id, user.role);
    return { user: { id: user.id, fullName: user.fullName }, token };
  }

  static async login(data: { employeeId?: string; email?: string; password: string }) {
    // Both identifiers are supported because teachers commonly know one but not the other.
    const user = data.employeeId
      ? await prisma.user.findUnique({ where: { employeeId: data.employeeId } })
      : await prisma.user.findUnique({ where: { email: data.email! } });
    if (!user || !(await bcrypt.compare(data.password, user.passwordHash))) {
      throw new AppError('Invalid credentials', 401);
    }
    const token = this.generateToken(user.id, user.role);
    return { user: { id: user.id, fullName: user.fullName }, token };
  }

  private static generateToken(id: string, role: string) {
    return jwt.sign({ id, role }, env.JWT_SECRET, { expiresIn: env.JWT_EXPIRES_IN as any });
  }
}
