import Database from 'better-sqlite3';
import dotenv from 'dotenv';
import path from 'path';
import fs from 'fs';

dotenv.config();

const createTables = () => {
  // Initialize SQLite database from DATABASE_URL or default path
  const dbUrl = process.env.DATABASE_URL || 'sqlite:/home/amit-singh/Projects/spur-ai-chat/backend/spur_chat.db';
  const dbPath = dbUrl.replace('sqlite:', '');

  const db = new Database(dbPath);
  db.pragma('foreign_keys = ON');

  try {
    console.log('Creating database tables...');

    // Create conversations table
    db.exec(`
      CREATE TABLE IF NOT EXISTS conversations (
        id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
        created_at TEXT DEFAULT (datetime('now')),
        updated_at TEXT DEFAULT (datetime('now')),
        metadata TEXT DEFAULT '{}'
      );
    `);

    console.log('✓ Created conversations table');

    // Create messages table
    db.exec(`
      CREATE TABLE IF NOT EXISTS messages (
        id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
        conversation_id TEXT NOT NULL,
        sender TEXT NOT NULL CHECK (sender IN ('user', 'ai')),
        text TEXT NOT NULL,
        created_at TEXT DEFAULT (datetime('now')),
        metadata TEXT DEFAULT '{}',
        FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE
      );
    `);

    console.log('✓ Created messages table');

    // Create indexes
    db.exec(`
      CREATE INDEX IF NOT EXISTS idx_messages_conversation_id 
      ON messages(conversation_id, created_at);
    `);

    console.log('✓ Created indexes');
    console.log('Database migration completed successfully!');

    db.close();
  } catch (error) {
    console.error('Error creating tables:', error);
    db.close();
    process.exit(1);
  }
};

createTables();
