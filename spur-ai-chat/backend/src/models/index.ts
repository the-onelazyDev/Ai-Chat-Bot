import { query } from '../db';
import { Conversation, Message } from '../types';
import { v4 as uuidv4 } from 'uuid';

export class ConversationModel {
  static async create(): Promise<Conversation> {
    const result = await query(
      `INSERT INTO conversations (id) VALUES ($1) RETURNING *`,
      [uuidv4()]
    );
    return result.rows[0];
  }

  static async findById(id: string): Promise<Conversation | null> {
    const result = await query(
      `SELECT * FROM conversations WHERE id = $1`,
      [id]
    );
    return result.rows[0] || null;
  }

  static async updateTimestamp(id: string): Promise<void> {
    await query(
      `UPDATE conversations SET updated_at = CURRENT_TIMESTAMP WHERE id = $1`,
      [id]
    );
  }
}

export class MessageModel {
  static async create(
    conversationId: string,
    sender: 'user' | 'ai',
    text: string
  ): Promise<Message> {
    const result = await query(
      `INSERT INTO messages (id, conversation_id, sender, text) 
       VALUES ($1, $2, $3, $4) RETURNING *`,
      [uuidv4(), conversationId, sender, text]
    );
    return result.rows[0];
  }

  static async findByConversationId(conversationId: string): Promise<Message[]> {
    const result = await query(
      `SELECT * FROM messages 
       WHERE conversation_id = $1 
       ORDER BY created_at ASC`,
      [conversationId]
    );
    return result.rows;
  }

  static async getRecentMessages(
    conversationId: string,
    limit: number = 10
  ): Promise<Message[]> {
    const result = await query(
      `SELECT * FROM messages 
       WHERE conversation_id = $1 
       ORDER BY created_at DESC 
       LIMIT $2`,
      [conversationId, limit]
    );
    return result.rows.reverse();
  }
}
