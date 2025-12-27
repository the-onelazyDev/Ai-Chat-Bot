<script lang="ts">
	import { onMount, afterUpdate } from 'svelte';
	import { sendMessage, type Message } from '$lib/api';

	interface DisplayMessage {
		id: string;
		sender: 'user' | 'ai';
		text: string;
		timestamp: Date;
	}

	let messages: DisplayMessage[] = [];
	let inputMessage = '';
	let sessionId: string | null = null;
	let isLoading = false;
	let isTyping = false;
	let error: string | null = null;
	let messagesContainer: HTMLDivElement;

	onMount(() => {
		// Load session ID from localStorage
		sessionId = localStorage.getItem('chatSessionId');
	});

	afterUpdate(() => {
		// Auto-scroll to bottom when new messages arrive
		if (messagesContainer) {
			messagesContainer.scrollTop = messagesContainer.scrollHeight;
		}
	});

	async function handleSendMessage() {
		if (!inputMessage.trim() || isLoading) return;

		const userMessageText = inputMessage.trim();
		inputMessage = '';
		error = null;

		// Add user message to UI immediately
		const userMessage: DisplayMessage = {
			id: `temp-${Date.now()}`,
			sender: 'user',
			text: userMessageText,
			timestamp: new Date()
		};
		messages = [...messages, userMessage];

		isLoading = true;
		isTyping = true;

		try {
			// Send message to backend
			const response = await sendMessage(userMessageText, sessionId || undefined);

			// Update session ID
			if (!sessionId) {
				sessionId = response.sessionId;
				localStorage.setItem('chatSessionId', sessionId);
			}

			// Add AI response to UI
			const aiMessage: DisplayMessage = {
				id: response.messageId,
				sender: 'ai',
				text: response.reply,
				timestamp: new Date()
			};
			messages = [...messages, aiMessage];
		} catch (err: any) {
			error = err.message || 'Failed to send message. Please try again.';
			console.error('Error sending message:', err);
		} finally {
			isLoading = false;
			isTyping = false;
		}
	}

	function handleKeyPress(event: KeyboardEvent) {
		if (event.key === 'Enter' && !event.shiftKey) {
			event.preventDefault();
			handleSendMessage();
		}
	}

	function formatTime(date: Date): string {
		return date.toLocaleTimeString('en-US', {
			hour: 'numeric',
			minute: '2-digit',
			hour12: true
		});
	}

	function startNewConversation() {
		messages = [];
		sessionId = null;
		localStorage.removeItem('chatSessionId');
		error = null;
	}
</script>

<svelte:head>
	<title>ShopEase AI Support Chat</title>
</svelte:head>

<div class="chat-container">
	<div class="chat-header">
		<div class="header-content">
			<div class="brand">
				<div class="brand-icon">💬</div>
				<div>
					<h1>ShopEase Support</h1>
					<p class="status">
						<span class="status-dot"></span>
						Online - We're here to help!
					</p>
				</div>
			</div>
			<button class="new-chat-btn" on:click={startNewConversation} title="Start new conversation">
				↻
			</button>
		</div>
	</div>

	<div class="messages-container" bind:this={messagesContainer}>
		{#if messages.length === 0}
			<div class="welcome-message">
				<h2>👋 Welcome to ShopEase!</h2>
				<p>I'm your AI support assistant. I can help you with:</p>
				<ul>
					<li>🚚 Shipping information</li>
					<li>↩️ Returns and refunds</li>
					<li>📞 Support hours</li>
					<li>💳 Payment methods</li>
				</ul>
				<p>Ask me anything!</p>
			</div>
		{/if}

		{#each messages as message (message.id)}
			<div class="message message-{message.sender}">
				<div class="message-content">
					<div class="message-text">{message.text}</div>
					<div class="message-time">{formatTime(message.timestamp)}</div>
				</div>
			</div>
		{/each}

		{#if isTyping}
			<div class="message message-ai">
				<div class="message-content">
					<div class="typing-indicator">
						<span></span>
						<span></span>
						<span></span>
					</div>
				</div>
			</div>
		{/if}

		{#if error}
			<div class="error-message">
				<strong>⚠️ Error:</strong>
				{error}
			</div>
		{/if}
	</div>

	<div class="input-container">
		<textarea
			bind:value={inputMessage}
			on:keypress={handleKeyPress}
			placeholder="Type your message here..."
			rows="1"
			disabled={isLoading}
		></textarea>
		<button
			on:click={handleSendMessage}
			disabled={isLoading || !inputMessage.trim()}
			class="send-button"
		>
			{#if isLoading}
				<span class="loader"></span>
			{:else}
				<span class="send-icon">➤</span>
			{/if}
		</button>
	</div>
</div>

<style>
	.chat-container {
		max-width: 800px;
		margin: 0 auto;
		height: 100vh;
		display: flex;
		flex-direction: column;
		background: var(--background);
		box-shadow: var(--shadow);
	}

	.chat-header {
		background: var(--primary-color);
		color: white;
		padding: 1rem 1.5rem;
		box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
	}

	.header-content {
		display: flex;
		justify-content: space-between;
		align-items: center;
	}

	.brand {
		display: flex;
		gap: 1rem;
		align-items: center;
	}

	.brand-icon {
		font-size: 2rem;
	}

	.brand h1 {
		font-size: 1.25rem;
		font-weight: 600;
		margin-bottom: 0.25rem;
	}

	.status {
		font-size: 0.875rem;
		opacity: 0.9;
		display: flex;
		align-items: center;
		gap: 0.5rem;
	}

	.status-dot {
		width: 8px;
		height: 8px;
		background: #10b981;
		border-radius: 50%;
		display: inline-block;
		animation: pulse 2s infinite;
	}

	@keyframes pulse {
		0%,
		100% {
			opacity: 1;
		}
		50% {
			opacity: 0.5;
		}
	}

	.new-chat-btn {
		background: rgba(255, 255, 255, 0.2);
		border: none;
		color: white;
		width: 36px;
		height: 36px;
		border-radius: 50%;
		cursor: pointer;
		font-size: 1.25rem;
		display: flex;
		align-items: center;
		justify-content: center;
		transition: background 0.2s;
	}

	.new-chat-btn:hover {
		background: rgba(255, 255, 255, 0.3);
	}

	.messages-container {
		flex: 1;
		overflow-y: auto;
		padding: 1.5rem;
		background: #f9fafb;
	}

	.welcome-message {
		text-align: center;
		padding: 3rem 1rem;
		color: var(--text-secondary);
	}

	.welcome-message h2 {
		color: var(--text-primary);
		margin-bottom: 1rem;
		font-size: 1.5rem;
	}

	.welcome-message p {
		margin: 1rem 0;
	}

	.welcome-message ul {
		list-style: none;
		margin: 1.5rem 0;
		text-align: left;
		max-width: 300px;
		margin-left: auto;
		margin-right: auto;
	}

	.welcome-message li {
		padding: 0.5rem;
		margin: 0.5rem 0;
	}

	.message {
		display: flex;
		margin-bottom: 1rem;
		animation: fadeIn 0.3s ease-in;
	}

	@keyframes fadeIn {
		from {
			opacity: 0;
			transform: translateY(10px);
		}
		to {
			opacity: 1;
			transform: translateY(0);
		}
	}

	.message-user {
		justify-content: flex-end;
	}

	.message-ai {
		justify-content: flex-start;
	}

	.message-content {
		max-width: 70%;
		padding: 0.75rem 1rem;
		border-radius: 1rem;
		position: relative;
	}

	.message-user .message-content {
		background: var(--user-message-bg);
		color: var(--user-message-text);
		border-bottom-right-radius: 0.25rem;
	}

	.message-ai .message-content {
		background: var(--ai-message-bg);
		color: var(--ai-message-text);
		border-bottom-left-radius: 0.25rem;
		box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
	}

	.message-text {
		word-wrap: break-word;
		white-space: pre-wrap;
		line-height: 1.5;
	}

	.message-time {
		font-size: 0.75rem;
		opacity: 0.7;
		margin-top: 0.25rem;
		text-align: right;
	}

	.typing-indicator {
		display: flex;
		gap: 0.25rem;
		padding: 0.5rem 0;
	}

	.typing-indicator span {
		width: 8px;
		height: 8px;
		background: var(--text-secondary);
		border-radius: 50%;
		animation: typing 1.4s infinite;
	}

	.typing-indicator span:nth-child(2) {
		animation-delay: 0.2s;
	}

	.typing-indicator span:nth-child(3) {
		animation-delay: 0.4s;
	}

	@keyframes typing {
		0%,
		60%,
		100% {
			transform: translateY(0);
		}
		30% {
			transform: translateY(-10px);
		}
	}

	.error-message {
		background: #fee;
		color: var(--error-color);
		padding: 1rem;
		border-radius: 0.5rem;
		margin: 1rem 0;
		border-left: 4px solid var(--error-color);
	}

	.input-container {
		padding: 1rem 1.5rem;
		background: var(--background);
		border-top: 1px solid var(--border);
		display: flex;
		gap: 0.75rem;
		align-items: flex-end;
	}

	textarea {
		flex: 1;
		padding: 0.75rem;
		border: 1px solid var(--border);
		border-radius: 0.5rem;
		resize: none;
		font-family: inherit;
		font-size: 1rem;
		max-height: 120px;
		min-height: 44px;
		transition: border-color 0.2s;
	}

	textarea:focus {
		outline: none;
		border-color: var(--primary-color);
	}

	textarea:disabled {
		background: #f9fafb;
		cursor: not-allowed;
	}

	.send-button {
		width: 44px;
		height: 44px;
		border: none;
		background: var(--primary-color);
		color: white;
		border-radius: 0.5rem;
		cursor: pointer;
		display: flex;
		align-items: center;
		justify-content: center;
		transition: background 0.2s;
		flex-shrink: 0;
	}

	.send-button:hover:not(:disabled) {
		background: var(--primary-hover);
	}

	.send-button:disabled {
		background: #d1d5db;
		cursor: not-allowed;
	}

	.send-icon {
		font-size: 1.25rem;
	}

	.loader {
		width: 20px;
		height: 20px;
		border: 2px solid rgba(255, 255, 255, 0.3);
		border-top-color: white;
		border-radius: 50%;
		animation: spin 0.8s linear infinite;
	}

	@keyframes spin {
		to {
			transform: rotate(360deg);
		}
	}

	@media (max-width: 768px) {
		.chat-container {
			max-width: 100%;
		}

		.message-content {
			max-width: 85%;
		}
	}
</style>
