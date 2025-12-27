# Multi-stage build for Spur AI Chat Backend

# Stage 1: Build
FROM node:22-alpine AS builder

WORKDIR /app

# Copy backend only
COPY backend/package*.json ./backend/
RUN cd backend && npm ci

# Copy source
COPY backend/src ./backend/src
COPY backend/tsconfig.json ./backend/

# Build TypeScript
RUN cd backend && npm run build

# Stage 2: Production
FROM node:22-alpine

WORKDIR /app

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Copy only production dependencies
COPY backend/package.json backend/package-lock.json ./backend/
RUN cd backend && npm ci --omit=dev

# Copy built code
COPY --from=builder /app/backend/dist ./backend/dist

# Copy database (if exists)
COPY backend/spur_chat.db ./backend/ 2>/dev/null || true

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:' + (process.env.PORT || 3000) + '/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Expose port
EXPOSE ${PORT:-3000}

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start backend
CMD ["node", "backend/dist/index.js"]
