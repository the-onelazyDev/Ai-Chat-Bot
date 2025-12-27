export interface Conversation {
  id: string;
  created_at: Date;
  updated_at: Date;
  metadata?: any;
}

export interface Message {
  id: string;
  conversation_id: string;
  sender: 'user' | 'ai';
  text: string;
  created_at: Date;
  metadata?: any;
}

export interface ChatMessageRequest {
  message: string;
  sessionId?: string;
}

export interface ChatMessageResponse {
  reply: string;
  sessionId: string;
  messageId: string;
}
