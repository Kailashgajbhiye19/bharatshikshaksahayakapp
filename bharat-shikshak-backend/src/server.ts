import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { env } from './config/env';
import { errorHandler } from './middlewares/error.middleware';
import authRoutes from './modules/auth/auth.routes';
import userRoutes from './modules/user/user.routes';
import classRoutes from './modules/class/class.routes';
import attendanceRoutes from './modules/attendance/attendance.routes';
import libraryRoutes from './modules/library/library.routes';
import aiRoutes from './modules/ai/ai.routes';

const app = express();

app.use(helmet());
// `origin: true` reflects the caller's origin, which allows credentialed browser requests.
app.use(cors({ origin: env.CORS_ORIGIN ?? true, credentials: true }));
app.use(express.json({ limit: '10mb' }));

app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/classes', classRoutes);
app.use('/api/v1/attendance', attendanceRoutes);
app.use('/api/v1/library', libraryRoutes);
app.use('/api/v1/ai', aiRoutes);

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'OK', message: 'Bharat Shikshak API is running' });
});

// Return JSON for unknown API paths instead of Express's HTML default response.
app.use('/api', (req, res) => res.status(404).json({ success: false, message: 'API route not found' }));
app.use(errorHandler);

export { app };

// Keeping app separate from startup lets integration tests import it without opening a port.
if (require.main === module) {
  app.listen(env.PORT, () => {
    console.log(`🚀 Server running in ${env.NODE_ENV} mode on port ${env.PORT}`);
  });
}
