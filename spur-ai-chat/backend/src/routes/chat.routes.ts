import { Router, Request, Response } from 'express';
import { body, validationResult } from 'express-validator';
import { ChatService } from '../services/chat.service';

const router = Router();
const chatService = new ChatService();

// Validation middleware
const validateChatMessage = [
  body('message')
    .trim()
    .notEmpty()
    .withMessage('Message cannot be empty')
    .isLength({ max: parseInt(process.env.MAX_MESSAGE_LENGTH || '2000') })
    .withMessage(`Message is too long (max ${process.env.MAX_MESSAGE_LENGTH || 2000} characters)`),
  body('sessionId')
    .optional()
    .isUUID()
    .withMessage('Invalid session ID format'),
];

// POST /api/chat/message
router.post(
  '/message',
  validateChatMessage,
  async (req: Request, res: Response) => {
    try {
      // Check for validation errors
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          error: errors.array()[0].msg,
          details: errors.array(),
        });
      }

      const { message, sessionId } = req.body;

      // Process the message
      const response = await chatService.processMessage({
        message,
        sessionId,
      });

      res.json(response);
    } catch (error: any) {
      console.error('Chat endpoint error:', error);
      
      // Return user-friendly error message
      res.status(500).json({
        error: error.message || 'An error occurred processing your message',
        sessionId: req.body.sessionId || null,
      });
    }
  }
);

// GET /api/chat/history/:sessionId
router.get('/history/:sessionId', async (req: Request, res: Response) => {
  try {
    const { sessionId } = req.params;

    // Validate UUID
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
    if (!uuidRegex.test(sessionId)) {
      return res.status(400).json({ error: 'Invalid session ID format' });
    }

    const history = await chatService.getConversationHistory(sessionId);
    res.json(history);
  } catch (error: any) {
    console.error('History endpoint error:', error);
    
    if (error.message === 'Conversation not found') {
      return res.status(404).json({ error: error.message });
    }
    
    res.status(500).json({
      error: 'An error occurred fetching conversation history',
    });
  }
});

// GET /api/chat/health
router.get('/health', (req: Request, res: Response) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

export default router;
