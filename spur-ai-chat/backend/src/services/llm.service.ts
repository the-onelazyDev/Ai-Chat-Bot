import { Message } from '../types';

const STORE_KNOWLEDGE = `
You are a helpful AI support agent for "ShopEase" - a modern e-commerce store.

IMPORTANT INSTRUCTIONS:
- Keep responses SHORT and CONCISE. Only 1-2 sentences for simple greetings.
- Only provide detailed information when the user specifically asks about it.
- Do NOT dump all store information in every response.
- Match the user's tone and message length.
- Be friendly and helpful, not verbose.

STORE INFORMATION (use only when relevant to user's question):

SHIPPING: Free standard shipping on orders over $50. Standard ($5.99, 5-7 days), Express ($12.99, 2-3 days), Next-day ($24.99, select areas). We ship to USA, Canada, UK, Australia, Europe (10-15 days international).

RETURNS: 30-day return policy for most items (unused, original packaging). Free returns for defective items. Return shipping: $6.99 (deducted from refund). Refunds in 5-7 days. Final sale items cannot be returned.

SUPPORT: Live chat Monday-Friday 9 AM-6 PM EST. Email 24/7 (response within 24 hours). Phone Monday-Friday 9 AM-5 PM EST at 1-800-SHOPEASE.

PAYMENT: Visa, Mastercard, Amex, PayPal, Apple Pay, Google Pay. All secure.

Example responses:
- "Hi" → "Hi! How can I help you today?" (SHORT)
- "What's your return policy?" → "We have a 30-day return policy for most items in unused, original condition. Returns are free for defective items. Standard return shipping is $6.99. Would you like more details?" (DETAILED only because asked)
`;


export class LLMService {
  private ollamaUrl: string;
  private model: string;

  constructor() {
    this.ollamaUrl = process.env.OLLAMA_URL || 'http://localhost:11434';
    this.model = process.env.LLM_MODEL || 'mistral';
  }

  async generateReply(
    conversationHistory: Message[],
    userMessage: string
  ): Promise<string> {
    try {
      // Build conversation context
      let conversationContext = '';
      const recentHistory = conversationHistory.slice(-10);
      
      for (const msg of recentHistory) {
        const role = msg.sender === 'user' ? 'User' : 'Assistant';
        conversationContext += `${role}: ${msg.text}\n`;
      }

      // Build the prompt for Ollama
      const prompt = `${STORE_KNOWLEDGE}

Conversation history:
${conversationContext}

User: ${userMessage}`;

      // Call Ollama API with very long timeout (Mistral takes 60-120s on first request)
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 600000); // 10 minute timeout

      const response = await fetch(`${this.ollamaUrl}/api/generate`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: this.model,
          prompt: prompt,
          stream: false,
          temperature: 0.7,
          timeout: '10m', // Ollama timeout
        }),
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        throw new Error(`Ollama API error: ${response.status} ${response.statusText}`);
      }

      const data = await response.json() as { response: string };
      const reply = data.response?.trim();

      if (!reply) {
        throw new Error('No response generated from LLM');
      }

      return reply;
    } catch (error: any) {
      console.error('LLM Service Error:', error);

      // Check if it's a connection error (Ollama not running)
      if (error.message?.includes('fetch')) {
        throw new Error(
          'AI service is offline. Please make sure Ollama is running: https://ollama.ai'
        );
      }

      // Generic fallback error
      throw new Error(
        'Sorry, I encountered an error processing your request. Please try again.'
      );
    }
  }

  // Health check method
  async checkHealth(): Promise<boolean> {
    try {
      const response = await fetch(`${this.ollamaUrl}/api/tags`);
      return response.ok;
    } catch (error) {
      console.error('LLM health check failed:', error);
      return false;
    }
  }
}
