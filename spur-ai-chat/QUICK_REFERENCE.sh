#!/bin/bash

# Spur AI Chat - Quick Reference Card
# Keep this handy while deploying!

cat << 'EOF'

╔═══════════════════════════════════════════════════════════════════════╗
║           🚀 SPUR AI CHAT - DEPLOYMENT QUICK REFERENCE               ║
║                    Deadline: 31st December 2025                       ║
╚═══════════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────────┐
│ 📋 WHAT YOU HAVE                                                    │
└─────────────────────────────────────────────────────────────────────┘

✅ Full-stack AI chat application
✅ Backend: Node.js + TypeScript + Express
✅ Frontend: SvelteKit + Svelte
✅ Database: SQLite (zero setup)
✅ LLM: Ollama (Mistral 7B, free & local)
✅ Persistent chat history
✅ Responsive chat UI
✅ Error handling
✅ Production-ready code


┌─────────────────────────────────────────────────────────────────────┐
│ 🎯 QUICKEST DEPLOYMENT (5-10 minutes)                               │
└─────────────────────────────────────────────────────────────────────┘

Step 1: Deploy Backend (Render)
  → Go to https://render.com
  → Connect GitHub repo
  → Create Web Service
  → Set environment variables (see DEPLOYMENT_GUIDE.md)
  → Deploy
  ⏱️  Takes ~3 minutes

Step 2: Deploy Frontend (Vercel)
  → Go to https://vercel.com
  → Import your GitHub repo
  → Select SvelteKit framework
  → Root directory: frontend/
  → Add VITE_API_BASE_URL env var
  → Deploy
  ⏱️  Takes ~2 minutes

Step 3: Update Backend CORS
  → Go back to Render
  → Edit env: CORS_ORIGIN = your Vercel URL
  → Redeploy
  ⏱️  Takes ~1 minute

TOTAL: ~6 minutes from start to live! 🎉


┌─────────────────────────────────────────────────────────────────────┐
│ 🔑 ENVIRONMENT VARIABLES                                            │
└─────────────────────────────────────────────────────────────────────┘

BACKEND (Render):
  PORT=10000
  NODE_ENV=production
  DATABASE_URL=sqlite:./spur_chat.db
  OLLAMA_URL=http://your-ollama-server:11434
  LLM_MODEL=mistral
  CORS_ORIGIN=https://your-frontend.vercel.app

FRONTEND (Vercel):
  VITE_API_BASE_URL=https://your-backend.onrender.com


┌─────────────────────────────────────────────────────────────────────┐
│ 📁 KEY FILES                                                        │
└─────────────────────────────────────────────────────────────────────┘

README.md              - Start here, how to run locally
DEPLOYMENT_GUIDE.md   - Detailed deployment instructions
DEPLOYMENT_CHECKLIST  - Pre-deployment verification
DEPLOYMENT_READY.md   - Summary and next steps
PRD_COMPLIANCE.md     - Requirements met
Dockerfile            - Docker build
docker-compose.yml    - Local dev with Ollama
deploy.sh             - Automated deployment script


┌─────────────────────────────────────────────────────────────────────┐
│ ⚙️  LOCAL DEVELOPMENT                                               │
└─────────────────────────────────────────────────────────────────────┘

Terminal 1 (Ollama):
  $ ollama serve

Terminal 2 (Backend):
  $ cd backend && npm run dev

Terminal 3 (Frontend):
  $ cd frontend && npm run dev

Open: http://localhost:5173


┌─────────────────────────────────────────────────────────────────────┐
│ 🐛 TROUBLESHOOTING                                                  │
└─────────────────────────────────────────────────────────────────────┘

Issue: Backend won't start
  ✓ Check: PORT set correctly
  ✓ Check: NODE_ENV=production
  ✓ Check: DATABASE_URL valid

Issue: CORS errors in browser console
  ✓ Check: CORS_ORIGIN matches frontend URL exactly
  ✓ Check: No trailing slash in URL

Issue: LLM not responding
  ✓ Check: Ollama running: ollama serve
  ✓ Check: Model downloaded: ollama pull mistral
  ✓ Check: Connection working: curl http://localhost:11434/api/tags

Issue: Frontend can't reach backend
  ✓ Check: VITE_API_BASE_URL set in Vercel env
  ✓ Check: No trailing slash in URL
  ✓ Check: Backend URL is correct and running


┌─────────────────────────────────────────────────────────────────────┐
│ 💰 COST                                                             │
└─────────────────────────────────────────────────────────────────────┘

Render (Backend):    $0 (free tier) to $7/month
Vercel (Frontend):   FREE
Ollama (LLM):        FREE (self-hosted)

TOTAL MONTHLY:       $0-7 🎉


┌─────────────────────────────────────────────────────────────────────┐
│ 📊 DEPLOYMENT CHECKLIST                                             │
└─────────────────────────────────────────────────────────────────────┘

Before deploying:

☐ npm run build:backend  → No errors?
☐ npm run build:frontend → No errors?
☐ npm run dev:backend & npm run dev:frontend → Chat works?
☐ Messages persist on page reload?
☐ No secrets in code?
☐ .env not committed to git?
☐ All code pushed to GitHub?
☐ Environment files documented?

Then:

☐ Create Render service
☐ Set env variables
☐ Backend deploys successfully?
☐ Create Vercel project
☐ Set env variables
☐ Frontend deploys successfully?
☐ Update CORS in backend
☐ Test live app
☐ Chat works end-to-end?


┌─────────────────────────────────────────────────────────────────────┐
│ 🎁 DEPLOYMENT OPTIONS                                               │
└─────────────────────────────────────────────────────────────────────┘

RECOMMENDED (Easiest):
  Backend:  Render  (render.com)
  Frontend: Vercel  (vercel.com)
  LLM:      Ollama  (self-hosted or Docker)

ALTERNATIVES:
  Backend:  Railway, Fly.io, AWS EC2, DigitalOcean, Heroku
  Frontend: Netlify, GitHub Pages, AWS Amplify
  LLM:      OpenAI API, Anthropic Claude, HuggingFace


┌─────────────────────────────────────────────────────────────────────┐
│ 📞 IMPORTANT LINKS                                                  │
└─────────────────────────────────────────────────────────────────────┘

Render:        https://render.com
Vercel:        https://vercel.com
Ollama:        https://ollama.ai
OpenAI:        https://platform.openai.com
GitHub:        https://github.com


┌─────────────────────────────────────────────────────────────────────┐
│ ✨ WHEN DEPLOYED                                                    │
└─────────────────────────────────────────────────────────────────────┘

✓ Test your live chat at frontend URL
✓ Check backend logs for errors
✓ Send test message: "Hi"
✓ Send test message: "What are your shipping options?"
✓ Reload page - messages should persist
✓ Share URLs with graders
✓ Submit to Spur


┌─────────────────────────────────────────────────────────────────────┐
│ 🎯 STATUS: DEPLOYMENT READY ✅                                      │
└─────────────────────────────────────────────────────────────────────┘

Your application is production-ready!

Next step: Choose deployment option and follow DEPLOYMENT_GUIDE.md

Questions? Check:
  • DEPLOYMENT_GUIDE.md    (How to deploy)
  • DEPLOYMENT_CHECKLIST.md (What to verify)
  • DEPLOYMENT_READY.md    (Summary & FAQ)
  • README.md              (Local setup)


═══════════════════════════════════════════════════════════════════════

                    🚀 READY TO GO LIVE! 🚀

═══════════════════════════════════════════════════════════════════════

EOF
