const API_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000';

export interface Message {
	id: string;
	conversation_id: string;
	sender: 'user' | 'ai';
	text: string;
	created_at: string;
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

export interface ErrorResponse {
	error: string;
	details?: any[];
}

export async function sendMessage(
	message: string,
	sessionId?: string
): Promise<ChatMessageResponse> {
	const response = await fetch(`${API_URL}/api/chat/message`, {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json'
		},
		body: JSON.stringify({ message, sessionId })
	});

	const data = await response.json();

	if (!response.ok) {
		throw new Error(data.error || 'Failed to send message');
	}

	return data;
}

export async function getConversationHistory(sessionId: string): Promise<Message[]> {
	const response = await fetch(`${API_URL}/api/chat/history/${sessionId}`);

	const data = await response.json();

	if (!response.ok) {
		throw new Error(data.error || 'Failed to fetch conversation history');
	}

	return data.messages;
}
