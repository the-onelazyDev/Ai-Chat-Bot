#!/bin/bash

# Spur AI Chat - Development Runner
# Runs both backend and frontend servers concurrently

set -e

echo "🚀 Starting Spur AI Chat in development mode..."
echo ""

# Check if .env files exist
if [ ! -f backend/.env ]; then
    echo "⚠️  backend/.env not found!"
    echo "Run: cp backend/.env.example backend/.env"
    echo "Then add your OpenAI API key and database credentials."
    exit 1
fi

if [ ! -f frontend/.env ]; then
    echo "⚠️  frontend/.env not found!"
    echo "Run: cp frontend/.env.example frontend/.env"
    exit 1
fi

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "🛑 Shutting down servers..."
    kill $(jobs -p) 2>/dev/null
    exit
}

trap cleanup SIGINT SIGTERM

# Start backend
echo "🔧 Starting backend server..."
cd backend
npm run dev > ../backend.log 2>&1 &
BACKEND_PID=$!
cd ..

# Wait for backend to start
echo "⏳ Waiting for backend to be ready..."
sleep 3

# Check if backend is running
if ! kill -0 $BACKEND_PID 2>/dev/null; then
    echo "❌ Backend failed to start. Check backend.log for details."
    exit 1
fi

# Start frontend
echo "🎨 Starting frontend server..."
cd frontend
npm run dev > ../frontend.log 2>&1 &
FRONTEND_PID=$!
cd ..

# Wait for frontend to start
sleep 3

# Check if frontend is running
if ! kill -0 $FRONTEND_PID 2>/dev/null; then
    echo "❌ Frontend failed to start. Check frontend.log for details."
    kill $BACKEND_PID
    exit 1
fi

echo ""
echo "✅ Both servers are running!"
echo ""
echo "📝 Logs:"
echo "   Backend:  tail -f backend.log"
echo "   Frontend: tail -f frontend.log"
echo ""
echo "🌐 URLs:"
echo "   Frontend: http://localhost:5173"
echo "   Backend:  http://localhost:3000"
echo "   API Docs: http://localhost:3000/api/chat/health"
echo ""
echo "Press Ctrl+C to stop both servers"
echo ""

# Wait for both processes
wait
