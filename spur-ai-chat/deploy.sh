#!/bin/bash

# Spur AI Chat - Quick Deployment Script
# Usage: ./deploy.sh [render|docker|local]

set -e

DEPLOY_TYPE=${1:-render}
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Spur AI Chat Deployment"
echo "Deploy Type: $DEPLOY_TYPE"
echo "Project Directory: $PROJECT_DIR"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command -v node &> /dev/null; then
        log_error "Node.js not found. Please install Node.js 18+"
        exit 1
    fi
    
    if ! command -v npm &> /dev/null; then
        log_error "npm not found. Please install Node.js"
        exit 1
    fi
    
    if ! command -v git &> /dev/null; then
        log_error "git not found. Please install git"
        exit 1
    fi
    
    log_info "Node.js $(node -v)"
    log_info "npm $(npm -v)"
}

# Build backend
build_backend() {
    log_info "Building backend..."
    cd "$PROJECT_DIR/backend"
    npm install
    npm run build
    cd "$PROJECT_DIR"
    log_info "Backend built successfully"
}

# Build frontend
build_frontend() {
    log_info "Building frontend..."
    cd "$PROJECT_DIR/frontend"
    npm install
    npm run build
    cd "$PROJECT_DIR"
    log_info "Frontend built successfully"
}

# Deploy to Render
deploy_render() {
    log_info "Preparing for Render deployment..."
    
    # Check if git is initialized
    if [ ! -d .git ]; then
        log_error "Git repository not initialized"
        log_warn "Please run: git init && git add . && git commit -m 'Initial commit'"
        exit 1
    fi
    
    # Check if remote exists
    if ! git remote | grep -q origin; then
        log_error "Git remote 'origin' not set"
        log_warn "Please run: git remote add origin https://github.com/your-username/spur-ai-chat.git"
        exit 1
    fi
    
    # Push to GitHub
    log_info "Pushing to GitHub..."
    git push -u origin main || git push -u origin master || true
    
    log_info "✅ Ready for Render deployment!"
    echo ""
    echo "Next steps:"
    echo "1. Go to https://render.com"
    echo "2. Click 'New +' → 'Web Service'"
    echo "3. Connect your GitHub repository"
    echo "4. Set these environment variables:"
    echo "   PORT=10000"
    echo "   NODE_ENV=production"
    echo "   DATABASE_URL=sqlite:./spur_chat.db"
    echo "   OLLAMA_URL=http://your-ollama-server:11434"
    echo "   LLM_MODEL=mistral"
    echo "   CORS_ORIGIN=https://your-frontend.vercel.app"
    echo "5. Build command: npm install --prefix backend && npm run build:backend"
    echo "6. Start command: cd backend && npm start"
    echo ""
}

# Deploy with Docker
deploy_docker() {
    log_info "Preparing Docker deployment..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker not installed. Install from https://docker.com"
        exit 1
    fi
    
    log_info "Building Docker image..."
    docker build -t spur-ai-chat:latest .
    log_info "Docker image built: spur-ai-chat:latest"
    
    echo ""
    echo "To run locally:"
    echo "  docker compose up"
    echo ""
    echo "To run backend only:"
    echo "  docker run -p 3000:3000 -e OLLAMA_URL=http://host.docker.internal:11434 spur-ai-chat:latest"
    echo ""
}

# Deploy locally (development)
deploy_local() {
    log_info "Setting up local development environment..."
    
    build_backend
    build_frontend
    
    log_info "✅ Local setup complete!"
    echo ""
    echo "To start development:"
    echo "1. Terminal 1: ollama serve"
    echo "2. Terminal 2: npm run dev:backend"
    echo "3. Terminal 3: npm run dev:frontend"
    echo ""
    echo "Then open http://localhost:5173"
    echo ""
}

# Verify deployment
verify_deployment() {
    log_info "Verifying files..."
    
    files_to_check=(
        "backend/src/index.ts"
        "backend/src/services/llm.service.ts"
        "frontend/src/routes/+page.svelte"
        "DEPLOYMENT_GUIDE.md"
        "README.md"
        "Dockerfile"
        "docker-compose.yml"
    )
    
    for file in "${files_to_check[@]}"; do
        if [ -f "$PROJECT_DIR/$file" ]; then
            log_info "Found $file"
        else
            log_error "Missing $file"
            exit 1
        fi
    done
}

# Main execution
main() {
    echo ""
    check_prerequisites
    echo ""
    
    verify_deployment
    echo ""
    
    case $DEPLOY_TYPE in
        render)
            deploy_render
            ;;
        docker)
            deploy_docker
            ;;
        local)
            deploy_local
            ;;
        *)
            log_error "Unknown deploy type: $DEPLOY_TYPE"
            echo "Usage: $0 [render|docker|local]"
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}✨ Deployment preparation complete!${NC}"
}

main "$@"
