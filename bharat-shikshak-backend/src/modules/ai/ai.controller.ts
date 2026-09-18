import { Request, Response, NextFunction } from 'express';

export class AIController {
  static async askSahayak(req: Request, res: Response, next: NextFunction) {
    try {
      const { prompt, gradeLevel } = req.body;
      // TODO: Integrate OpenAI/Gemini SDK here
      const mockResponse = `[AI Mock] For Grade ${gradeLevel}, here is a lesson plan idea for: "${prompt}". Start with a 5-minute interactive activity...`;
      res.status(200).json({ success: true, response: mockResponse });
    } catch (error) { next(error); }
  }
}