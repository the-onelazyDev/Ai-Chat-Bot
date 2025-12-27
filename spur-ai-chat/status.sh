#!/bin/bash

# Check project status and show what needs to be done

echo "🔍 Spur AI Chat - Project Status Check"
echo "========================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check backend dependencies
echo "Backend Dependencies:"
if [ -d "backend/node_modules" ] && [ -f "backend/node_modules/.package-lock.json" ]; then
    echo -e "  ${GREEN}✓ Installed${NC}"
else
    echo -e "  ${RED}✗ Not installed${NC}"
    echo -e "  ${YELLOW}→ Run: cd backend && npm install${NC}"
fi

# Check frontend dependencies
echo ""
echo "Frontend Dependencies:"
if [ -d "frontend/node_modules" ] && [ -f "frontend/node_modules/.package-lock.json" ]; then
    echo -e "  ${GREEN}✓ Installed${NC}"
else
    echo -e "  ${RED}✗ Not installed${NC}"
    echo -e "  ${YELLOW}→ Run: cd frontend && npm install${NC}"
fi

# Check environment files
echo ""
echo "Environment Configuration:"
if [ -f "backend/.env" ]; then
    echo -e "  ${GREEN}✓ backend/.env exists${NC}"
else
    echo -e "  ${RED}✗ backend/.env missing${NC}"
    echo -e "  ${YELLOW}→ Run: cp backend/.env.example backend/.env${NC}"
fi

if [ -f "frontend/.env" ]; then
    echo -e "  ${GREEN}✓ frontend/.env exists${NC}"
else
    echo -e "  ${RED}✗ frontend/.env missing${NC}"
    echo -e "  ${YELLOW}→ Run: cp frontend/.env.example frontend/.env${NC}"
fi

# Check database
echo ""
echo "Database:"
if command -v psql &> /dev/null; then
    if psql -lqt 2>/dev/null | cut -d \| -f 1 | grep -qw spur_chat; then
        echo -e "  ${GREEN}✓ Database 'spur_chat' exists${NC}"
    else
        echo -e "  ${RED}✗ Database 'spur_chat' not found${NC}"
        echo -e "  ${YELLOW}→ Run: createdb spur_chat${NC}"
        echo -e "  ${YELLOW}→ Then: cd backend && npm run db:migrate${NC}"
    fi
else
    echo -e "  ${YELLOW}⚠ PostgreSQL not found in PATH${NC}"
fi

echo ""
echo "========================================"
echo ""

# Provide next steps
if [ ! -d "backend/node_modules" ] || [ ! -d "frontend/node_modules" ]; then
    echo -e "${YELLOW}📋 NEXT STEPS:${NC}"
    echo ""
    echo "1. Install dependencies:"
    echo "   cd backend && npm install"
    echo "   cd ../frontend && npm install"
    echo ""
    echo "2. Set up environment:"
    echo "   cp backend/.env.example backend/.env"
    echo "   cp frontend/.env.example frontend/.env"
    echo "   # Edit backend/.env with your OpenAI API key"
    echo ""
    echo "3. Set up database:"
    echo "   createdb spur_chat"
    echo "   cd backend && npm run db:migrate"
    echo ""
    echo "4. Start the app:"
    echo "   ./dev.sh"
    echo ""
    echo "OR run the automated setup:"
    echo "   ./setup.sh"
else
    echo -e "${GREEN}✓ Project is set up and ready!${NC}"
    echo ""
    echo "To start the application:"
    echo "   ./dev.sh"
    echo ""
    echo "Or manually:"
    echo "   Terminal 1: cd backend && npm run dev"
    echo "   Terminal 2: cd frontend && npm run dev"
fi

echo ""
