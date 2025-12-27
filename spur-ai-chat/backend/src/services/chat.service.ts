import { ConversationModel, MessageModel } from '../models';
import { LLMService } from './llm.service';
import { ChatMessageRequest, ChatMessageResponse } from '../types';

export class ChatService {
  private llmService: LLMService;

  constructor() {
    this.llmService = new LLMService();
  }

  async processMessage(request: ChatMessageRequest): Promise<ChatMessageResponse> {
    try {
      // Get or create conversation
      let conversationId = request.sessionId;
      
      if (conversationId) {
        const existingConversation = await ConversationModel.findById(conversationId);
        if (!existingConversation) {
          // Invalid session ID, create new conversation
          const newConversation = await ConversationModel.create();
          conversationId = newConversation.id;
        }
      } else {
        // Create new conversation
        const newConversation = await ConversationModel.create();
        conversationId = newConversation.id;
      }

      // Save user message
      const userMessage = await MessageModel.create(
        conversationId,
        'user',
        request.message
      );

      // Get conversation history
      const history = await MessageModel.getRecentMessages(conversationId, 10);

      // Generate AI reply
      const aiReply = await this.llmService.generateReply(
        history,
        request.message
      );

      // Save AI message
      const aiMessage = await MessageModel.create(
        conversationId,
        'ai',
        aiReply
      );

      // Update conversation timestamp
      await ConversationModel.updateTimestamp(conversationId);

      return {
        reply: aiReply,
        sessionId: conversationId,
        messageId: aiMessage.id,
      };
    } catch (error: any) {
      console.error('Chat Service Error:', error);
      throw error;
    }
  }

  async getConversationHistory(sessionId: string) {
    const conversation = await ConversationModel.findById(sessionId);
    if (!conversation) {
      throw new Error('Conversation not found');
    }

    const messages = await MessageModel.findByConversationId(sessionId);
    return {
      conversation,
      messages,
    };
  }
}
