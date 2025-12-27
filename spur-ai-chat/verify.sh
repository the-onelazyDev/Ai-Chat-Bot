#!/bin/bash

# Simple test script to verify the installation

echo "🧪 Running basic verification tests..."
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0

# Check Node.js
echo -n "Checking Node.js... "
if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v)
    echo -e "${GREEN}✓ Found $NODE_VERSION${NC}"
else
    echo -e "${RED}✗ Not found${NC}"
    ((ERRORS++))
fi

# Check npm
echo -n "Checking npm... "
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm -v)
    echo -e "${GREEN}✓ Found v$NPM_VERSION${NC}"
else
    echo -e "${RED}✗ Not found${NC}"
    ((ERRORS++))
fi

# Check PostgreSQL
echo -n "Checking PostgreSQL... "
if command -v psql &> /dev/null; then
    PSQL_VERSION=$(psql --version | head -n1)
    echo -e "${GREEN}✓ Found $PSQL_VERSION${NC}"
else
    echo -e "${RED}✗ Not found${NC}"
    ((ERRORS++))
fi

# Check if database exists
echo -n "Checking database 'spur_chat'... "
if psql -lqt 2>/dev/null | cut -d \| -f 1 | grep -qw spur_chat; then
    echo -e "${GREEN}✓ Found${NC}"
else
    echo -e "${BLUE}! Not found (run: createdb spur_chat)${NC}"
fi

# Check backend dependencies
echo -n "Checking backend dependencies... "
if [ -d "backend/node_modules" ]; then
    echo -e "${GREEN}✓ Installed${NC}"
else
    echo -e "${BLUE}! Not installed (run: cd backend && npm install)${NC}"
fi

# Check frontend dependencies
echo -n "Checking frontend dependencies... "
if [ -d "frontend/node_modules" ]; then
    echo -e "${GREEN}✓ Installed${NC}"
else
    echo -e "${BLUE}! Not installed (run: cd frontend && npm install)${NC}"
fi

# Check backend .env
echo -n "Checking backend/.env... "
if [ -f "backend/.env" ]; then
    echo -e "${GREEN}✓ Found${NC}"
    
    # Check for OpenAI key
    echo -n "  Checking OPENAI_API_KEY... "
    if grep -q "OPENAI_API_KEY=sk-" backend/.env; then
        echo -e "${GREEN}✓ Configured${NC}"
    else
        echo -e "${BLUE}! Not configured${NC}"
    fi
    
    # Check for DATABASE_URL
    echo -n "  Checking DATABASE_URL... "
    if grep -q "DATABASE_URL=" backend/.env; then
        echo -e "${GREEN}✓ Configured${NC}"
    else
        echo -e "${BLUE}! Not configured${NC}"
    fi
else
    echo -e "${BLUE}! Not found (run: cp backend/.env.example backend/.env)${NC}"
fi

# Check frontend .env
echo -n "Checking frontend/.env... "
if [ -f "frontend/.env" ]; then
    echo -e "${GREEN}✓ Found${NC}"
else
    echo -e "${BLUE}! Not found (run: cp frontend/.env.example frontend/.env)${NC}"
fi

# Check if backend can compile
echo -n "Checking backend TypeScript compilation... "
if [ -d "backend/node_modules" ]; then
    cd backend
    if npm run build &> /dev/null; then
        echo -e "${GREEN}✓ Success${NC}"
    else
        echo -e "${RED}✗ Failed${NC}"
        ((ERRORS++))
    fi
    cd ..
else
    echo -e "${BLUE}! Skipped (dependencies not installed)${NC}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo "You're ready to start the application:"
    echo "  ./dev.sh"
    echo ""
    echo "Or manually:"
    echo "  Terminal 1: cd backend && npm run dev"
    echo "  Terminal 2: cd frontend && npm run dev"
else
    echo -e "${RED}✗ $ERRORS error(s) found${NC}"
    echo ""
    echo "Please fix the errors above and try again."
    echo "See QUICKSTART.md or README.md for help."
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
