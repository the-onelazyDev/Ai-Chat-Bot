#!/bin/bash

# Spur AI Chat - Setup Script
# This script automates the setup process

set -e  # Exit on error

echo "🚀 Setting up Spur AI Chat Application..."
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check prerequisites
echo "📋 Checking prerequisites..."

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed. Please install Node.js 18+ first.${NC}"
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo -e "${RED}❌ Node.js version 18+ required. You have $(node -v)${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Node.js $(node -v) found${NC}"

# Check PostgreSQL
if ! command -v psql &> /dev/null; then
    echo -e "${RED}⚠️  PostgreSQL not found in PATH. Make sure it's installed and running.${NC}"
    echo "Continue anyway? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo -e "${GREEN}✓ PostgreSQL found${NC}"
fi

echo ""
echo "📦 Installing dependencies..."

# Backend dependencies
echo -e "${BLUE}Installing backend dependencies...${NC}"
cd backend
npm install
echo -e "${GREEN}✓ Backend dependencies installed${NC}"

# Frontend dependencies
echo -e "${BLUE}Installing frontend dependencies...${NC}"
cd ../frontend
npm install
echo -e "${GREEN}✓ Frontend dependencies installed${NC}"

cd ..

echo ""
echo "⚙️  Setting up environment files..."

# Backend .env
if [ ! -f backend/.env ]; then
    cp backend/.env.example backend/.env
    echo -e "${GREEN}✓ Created backend/.env${NC}"
    echo -e "${BLUE}ℹ️  Please edit backend/.env and add your:${NC}"
    echo "   - Database credentials"
    echo "   - OpenAI API key"
else
    echo -e "${BLUE}ℹ️  backend/.env already exists${NC}"
fi

# Frontend .env
if [ ! -f frontend/.env ]; then
    cp frontend/.env.example frontend/.env
    echo -e "${GREEN}✓ Created frontend/.env${NC}"
else
    echo -e "${BLUE}ℹ️  frontend/.env already exists${NC}"
fi

echo ""
echo "🗄️  Database setup..."
echo "Would you like to create the database now? (y/n)"
read -r response

if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "Enter database name (default: spur_chat):"
    read -r dbname
    dbname=${dbname:-spur_chat}
    
    echo "Creating database: $dbname"
    createdb "$dbname" 2>/dev/null && echo -e "${GREEN}✓ Database created${NC}" || echo -e "${BLUE}ℹ️  Database might already exist${NC}"
    
    echo "Running migrations..."
    cd backend
    npm run db:migrate
    cd ..
    echo -e "${GREEN}✓ Database migrated${NC}"
else
    echo -e "${BLUE}ℹ️  Skipping database setup. Run 'npm run db:migrate' in backend/ later.${NC}"
fi

echo ""
echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo "📝 Next steps:"
echo ""
echo "1. Edit backend/.env with your credentials:"
echo "   - Add OpenAI API key"
echo "   - Verify database connection"
echo ""
echo "2. Start the backend server:"
echo "   cd backend && npm run dev"
echo ""
echo "3. In a new terminal, start the frontend:"
echo "   cd frontend && npm run dev"
echo ""
echo "4. Open http://localhost:5173 in your browser"
echo ""
echo "📚 For more details, see README.md or QUICKSTART.md"
echo ""
