import Database from 'better-sqlite3';
import dotenv from 'dotenv';
import path from 'path';

dotenv.config();

// Initialize SQLite database from DATABASE_URL or default path
const dbUrl = process.env.DATABASE_URL || 'sqlite:./spur_chat.db';
const dbPath = dbUrl.replace('sqlite:', '');

const db = new Database(dbPath);

// Enable foreign keys
db.pragma('foreign_keys = ON');

// Type for database query result
interface QueryResult {
  rows: any[];
  rowCount: number;
}

export const query = async (text: string, params?: any[]): Promise<QueryResult> => {
  const start = Date.now();
  try {
    // Convert SQL from PostgreSQL dialect to SQLite dialect
    let sqliteSQL = text;
    
    // Replace PostgreSQL specific syntax
    sqliteSQL = sqliteSQL.replace(/CURRENT_TIMESTAMP/g, "datetime('now')");
    sqliteSQL = sqliteSQL.replace(/gen_random_uuid\(\)/g, "(lower(hex(randomblob(16))))");
    sqliteSQL = sqliteSQL.replace(/UUID PRIMARY KEY DEFAULT gen_random_uuid\(\)/g, "TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16))))");
    sqliteSQL = sqliteSQL.replace(/TIMESTAMP WITH TIME ZONE/g, "TEXT");
    sqliteSQL = sqliteSQL.replace(/JSONB/g, "TEXT");
    sqliteSQL = sqliteSQL.replace(/CHECK \([^)]+\)/g, ''); // SQLite doesn't support CHECK in same way
    
    // Handle parameterized queries (? for SQLite instead of $1, $2, etc)
    let paramIndex = 1;
    while (sqliteSQL.includes(`$${paramIndex}`)) {
      sqliteSQL = sqliteSQL.replace(`$${paramIndex}`, '?');
      paramIndex++;
    }

    // Check if it's a RETURNING query (we need to handle this specially)
    const hasReturning = sqliteSQL.includes('RETURNING');
    let selectSQL = sqliteSQL;
    
    if (hasReturning) {
      selectSQL = sqliteSQL.substring(0, sqliteSQL.indexOf('RETURNING')).trim();
    }

    // Check if it's a SELECT query
    if (sqliteSQL.trim().toUpperCase().startsWith('SELECT')) {
      const stmt = db.prepare(sqliteSQL);
      const rows = stmt.all(...(params || []));
      const duration = Date.now() - start;
      console.log('Executed query', { sql: text.substring(0, 50), duration, rows: rows.length });
      return { rows, rowCount: rows.length };
    } else {
      // INSERT, UPDATE, DELETE
      const stmt = db.prepare(selectSQL);
      const info = stmt.run(...(params || []));
      const duration = Date.now() - start;
      console.log('Executed query', { sql: text.substring(0, 50), duration, changes: info.changes });
      
      // For RETURNING queries, fetch the inserted/updated row
      if (hasReturning) {
        // Extract table name from the original SQL
        let tableName = 'conversations'; // default
        if (selectSQL.includes('INSERT INTO')) {
          const match = selectSQL.match(/INSERT INTO (\w+)/i);
          if (match) tableName = match[1];
        } else if (selectSQL.includes('UPDATE')) {
          const match = selectSQL.match(/UPDATE (\w+)/i);
          if (match) tableName = match[1];
        }
        
        // Get the last inserted/updated row
        const rows = db.prepare(`SELECT * FROM ${tableName} WHERE rowid = last_insert_rowid()`).all();
        return { rows, rowCount: info.changes };
      }
      
      return { rows: [], rowCount: info.changes };
    }
  } catch (error) {
    console.error('Database query error:', error);
    throw error;
  }
};

export const getClient = async () => {
  // SQLite doesn't have clients, return a simple object
  return {
    query,
    release: () => {},
  };
};

export default db;
