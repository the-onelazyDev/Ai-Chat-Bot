# 🚀 Deployment Guide - Spur AI Chat Agent

## 📋 Overview

This guide covers deploying the Spur AI Chat Agent to production using free/affordable platforms:
- **Backend**: Render, Railway, or Fly.io
- **Frontend**: Vercel or Netlify
- **Database**: SQLite (bundled) or managed PostgreSQL
- **LLM**: Ollama (self-hosted) or external API

---

## ⚡ Quick Deploy (Render - Easiest)

### Step 1: Prepare Repository

```bash
cd /home/amit-singh/Projects/spur-ai-chat

# Ensure .gitignore is correct
git status

# Commit and push to GitHub
git add .
git commit -m "Ready for deployment"
git push origin main
```

### Step 2: Deploy Backend to Render

1. Go to https://render.com
2. Sign up with GitHub
3. Click "New +" → "Web Service"
4. Connect your GitHub repo
5. Fill in details:
   - **Name**: `spur-ai-chat-backend`
   - **Environment**: `Node`
   - **Build Command**: `npm install --prefix backend && npm run build:backend`
   - **Start Command**: `cd backend && npm start`
   - **Node Version**: `18`

6. Add Environment Variables (in Render Dashboard):
```
PORT=10000
NODE_ENV=production
DATABASE_URL=sqlite:./spur_chat.db
OLLAMA_URL=http://localhost:11434
LLM_MODEL=mistral
CORS_ORIGIN=https://your-frontend-url.vercel.app
```

7. Click "Create Web Service"
8. Copy the URL (e.g., `https://spur-ai-chat-backend.onrender.com`)

---

### Step 3: Deploy Frontend to Vercel

1. Go to https://vercel.com
2. Sign up with GitHub
3. Click "Add New" → "Project"
4. Import your repository
5. Fill in:
   - **Framework Preset**: `SvelteKit`
   - **Root Directory**: `./frontend`

6. Add Environment Variable:
```
VITE_API_BASE_URL=https://spur-ai-chat-backend.onrender.com
```

7. Click "Deploy"
8. Copy your Vercel URL (e.g., `https://spur-ai-chat.vercel.app`)

---

### Step 4: Update Backend CORS

1. Go back to Render Dashboard
2. Find your backend service
3. Edit Environment Variables
4. Update `CORS_ORIGIN` with your Vercel URL
5. Redeploy

---

## 🎯 Deploy LLM (Ollama) - Critical Step

### Option A: Self-hosted Ollama (Recommended for Spur Setup)

Since Ollama needs local/dedicated CPU resources, you have options:

#### Option A1: Deploy on Render with Docker

Create `Dockerfile` in project root:

```dockerfile
FROM ollama/ollama:latest

EXPOSE 11434

CMD ["serve"]
```

Create `.dockerignore`:
```
node_modules
dist
.git
.env
.env.local
```

Push to GitHub and deploy on Render with Docker runtime.

#### Option A2: AWS EC2 Free Tier

1. Create EC2 instance (t2.micro, Ubuntu 22.04)
2. SSH into instance:
```bash
ssh -i key.pem ubuntu@your-instance-ip
```

3. Install Ollama:
```bash
curl -fsSL https://ollama.ai/install.sh | sh
ollama serve
```

4. In another SSH session:
```bash
ollama pull mistral
```

5. Update backend `OLLAMA_URL` to point to EC2 IP

#### Option A3: Home Server / VPS

If you have access to a spare machine:
- Install Ollama on it
- Make sure it's accessible from backend
- Update `OLLAMA_URL` in backend env

### Option B: External LLM API (Simplest Alternative)

If Ollama hosting is too complex, use OpenAI/Anthropic:

1. Get API key from https://platform.openai.com
2. Update backend `.env`:
```
OPENAI_API_KEY=sk-xxx...
USE_OPENAI=true
```

3. Modify `backend/src/services/llm.service.ts` to use OpenAI instead of Ollama

This costs ~$0.001-0.01 per message but is simplest to deploy.

---

## 📊 Full Deployment Options Comparison

| Platform | Backend | Frontend | Cost | Effort | Uptime |
|----------|---------|----------|------|--------|--------|
| Render + Vercel | ✅ | ✅ | Free (limited) | Low | 99.9% |
| Railway | ✅ | - | Free tier | Low | 99% |
| Fly.io | ✅ | - | Generous free | Medium | 99.9% |
| Netlify | - | ✅ | Free | Low | 99.9% |
| AWS (EC2 + S3) | ✅ | ✅ | Free tier | High | 99.99% |
| DigitalOcean | ✅ | ✅ | $5/mo | Medium | 99.99% |

---

## 🚀 Step-by-Step: Render + Vercel (Recommended)

### Prerequisites
- GitHub account
- Code pushed to GitHub
- Render & Vercel accounts

### Backend Deployment (Render)

**Step 1: Prepare for Production**

```bash
# Update backend for production
cd backend

# Add production start script to package.json
```

Your `backend/package.json` should have:
```json
{
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js"
  }
}
```

**Step 2: Create Render Web Service**

- Dashboard → New Web Service
- Connect GitHub repo
- Select your repository
- Configure:
  ```
  Build Command: npm install && npm install --prefix backend && npm run build:backend
  Start Command: cd backend && npm start
  ```

**Step 3: Set Environment Variables**

In Render dashboard → Environment:
```
PORT=10000
NODE_ENV=production
DATABASE_URL=sqlite:./spur_chat.db
OLLAMA_URL=https://your-ollama-server.com:11434
LLM_MODEL=mistral
CORS_ORIGIN=https://your-frontend.vercel.app
```

**Step 4: Enable Auto-Deploy**

- Render auto-deploys on `main` branch push
- Wait for green checkmark

### Frontend Deployment (Vercel)

**Step 1: Configure SvelteKit for Vercel**

Add to `frontend/svelte.config.js`:
```javascript
import adapter from '@sveltejs/adapter-vercel';

export default {
  kit: {
    adapter: adapter()
  }
};
```

**Step 2: Deploy to Vercel**

- Vercel.com → Add Project
- Import your GitHub repository
- Framework: SvelteKit
- Root Directory: `frontend`
- Environment Variables:
  ```
  VITE_API_BASE_URL=https://your-backend.onrender.com
  ```

**Step 3: Deploy**

- Click "Deploy"
- Vercel auto-deploys on commits

---

## 🔧 Handling Ollama in Production

### Option 1: Docker on Render

```dockerfile
FROM ollama/ollama:latest

RUN ollama pull mistral

EXPOSE 11434
CMD ["serve"]
```

Deploy this as separate Render service.

### Option 2: AWS EC2 Instance

```bash
# Launch EC2 t2.micro (free tier)
# Ubuntu 22.04

# SSH in
ssh -i key.pem ubuntu@ec2-xx-xxx-xxx-xxx.compute-1.amazonaws.com

# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Start service
sudo systemctl start ollama
sudo systemctl enable ollama

# Pull model (takes ~5 min)
ollama pull mistral

# Make accessible (firewall rules needed)
```

Then update backend `OLLAMA_URL` to EC2 private IP.

### Option 3: Use Managed LLM API

Simplest: Switch to OpenAI/Anthropic/Together.ai:

```bash
# Update backend
OPENAI_API_KEY=sk-xxx
USE_OPENAI=true
```

Modify `llm.service.ts` to use OpenAI client instead of Ollama.

---

## 🐛 Troubleshooting Deployment

### Backend Won't Start

```bash
# Check logs
curl https://your-backend.onrender.com/health

# Common issues:
# 1. Missing NODE_ENV=production
# 2. Missing CORS_ORIGIN
# 3. Database permission issues
```

### Frontend Can't Reach Backend

```javascript
// Check frontend .env
console.log(import.meta.env.VITE_API_BASE_URL);

// Should output your backend URL
// Without trailing slash!
```

### CORS Errors

Backend `CORS_ORIGIN` must match frontend URL exactly:
```
Frontend: https://spur-ai-chat.vercel.app
Backend:  CORS_ORIGIN=https://spur-ai-chat.vercel.app
```

### Database Issues

SQLite works fine for small deployments. For production:
- Use managed PostgreSQL (Render, Railway, Supabase)
- Migrate data using migration scripts

### Ollama Connection Refused

Ollama must be running and accessible:
```bash
# Test connection
curl http://OLLAMA_HOST:11434/api/tags

# If fails, check:
# 1. Ollama running: ollama serve
# 2. Network accessible from backend
# 3. Firewall allows port 11434
```

---

## 📈 Scaling Checklist

Before going to production:

- [ ] Backend compiles without errors
- [ ] Frontend builds successfully
- [ ] All env vars documented
- [ ] No secrets in code
- [ ] Database migrations auto-run
- [ ] Error handling is robust
- [ ] CORS properly configured
- [ ] LLM API working
- [ ] Frontend can reach backend
- [ ] Chat flow tested end-to-end

---

## 💾 Database Migration to PostgreSQL

If SQLite becomes limiting:

```bash
# 1. Create PostgreSQL instance (Render, Supabase, Heroku)
# 2. Get connection string: postgresql://user:pass@host:5432/db

# 3. Update backend .env
DATABASE_URL=postgresql://...

# 4. Update schema (minimal changes needed)
# 5. Run migrations
npm run db:migrate

# 6. Export SQLite data if needed
npm run db:export
```

---

## 🔒 Production Security Checklist

- [ ] All secrets in environment variables
- [ ] No `.env` committed to git
- [ ] HTTPS enforced
- [ ] CORS restricted to frontend domain
- [ ] Input validation enabled
- [ ] Rate limiting (optional, add Express middleware)
- [ ] Database backups configured
- [ ] Logs monitored for errors

---

## 📱 Free Deployment Summary

| Service | Link | Cost |
|---------|------|------|
| Render (Backend) | https://render.com | $0-7/mo |
| Vercel (Frontend) | https://vercel.com | Free |
| Railway (Alt Backend) | https://railway.app | Free tier |
| Fly.io (Alt Backend) | https://fly.io | Free tier |
| Supabase (PostgreSQL) | https://supabase.com | Free tier |
| AWS EC2 (Ollama) | https://aws.amazon.com | Free tier (1 yr) |

**Total Cost**: $0-7/month

---

## 🎉 After Deployment

1. Test live chat at your Vercel URL
2. Check backend logs for errors
3. Monitor API response times
4. Set up monitoring (Render, Vercel dashboards)
5. Configure email alerts for errors

---

## ❓ FAQ

**Q: Can I host everything on free tier?**
A: Yes! Render (free), Vercel (free), Railway (free tier), AWS EC2 (1 yr free).

**Q: Do I need a domain?**
A: No, but free subdomain like `spur-ai-chat.vercel.app` is included.

**Q: How do I update after deployment?**
A: Just push to GitHub. Auto-deploy triggers automatically.

**Q: What if Ollama is too heavy?**
A: Use OpenAI API instead (~$0.001/msg). Just swap the LLM service.

**Q: Can I use my own VPS?**
A: Yes! Deploy to any VPS with Node.js and Ollama support.

---

**Ready to deploy? Start with Render + Vercel above! 🚀**
