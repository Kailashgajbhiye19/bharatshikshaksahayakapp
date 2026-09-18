import { PrismaClient, Role, AttendanceStatus } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seeding...');

  const passwordHash = await bcrypt.hash('password123', 10);

  // 1. Create User
  const teacher = await prisma.user.upsert({
    where: { employeeId: 'BSS-2018-4902' },
    update: {},
    create: {
      employeeId: 'BSS-2018-4902',
      email: 'asha.sharma@gov.in',
      passwordHash,
      fullName: 'Asha Sharma',
      role: Role.TEACHER,
      schoolName: 'Govt. Primary School, Sector 14',
    },
  });

  // 2. Create Classes
  const class5A = await prisma.class.upsert({
    where: { grade_subject_teacherId: { grade: '5A', subject: 'Mathematics', teacherId: teacher.id } },
    update: {},
    create: { grade: '5A', subject: 'Mathematics', teacherId: teacher.id },
  });

  const class6B = await prisma.class.upsert({
    where: { grade_subject_teacherId: { grade: '6B', subject: 'General Science', teacherId: teacher.id } },
    update: {},
    create: { grade: '6B', subject: 'General Science', teacherId: teacher.id },
  });

  // 3. Create Students
  const studentsData = [
    { name: 'Aarav Sharma', rollNo: 1 },
    { name: 'Diya Patel', rollNo: 2 },
    { name: 'Ishaan Kumar', rollNo: 3 },
    { name: 'Neha Gupta', rollNo: 4 },
    { name: 'Rohan Singh', rollNo: 5 },
  ];

  for (const student of studentsData) {
    await prisma.student.upsert({
      where: { classId_rollNo: { classId: class5A.id, rollNo: student.rollNo } },
      update: {},
      create: { name: student.name, rollNo: student.rollNo, classId: class5A.id },
    });
  }

  // 4. Create the sample resource only once, so reseeding stays safe and repeatable.
  const existingResource = await prisma.resource.findFirst({
    where: { title: 'Grade 5 Mathematics Textbook', classId: class5A.id },
  });
  if (!existingResource) {
    await prisma.resource.create({
      data: {
        title: 'Grade 5 Mathematics Textbook',
        fileUrl: 'https://example.com/math5.pdf',
        fileType: 'PDF',
        classId: class5A.id,
      },
    });
  }

  console.log('✅ Seeding completed successfully!');
}

main()
  .catch((e) => { console.error(e); process.exit(1); })
  .finally(async () => { await prisma.$disconnect(); });
