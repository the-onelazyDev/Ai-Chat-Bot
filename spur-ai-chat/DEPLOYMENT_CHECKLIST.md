# 📋 Deployment Checklist

Use this checklist before deploying to production.

## ✅ Code Quality

- [ ] All TypeScript compiles without errors
- [ ] No `console.log()` statements left in production code
- [ ] No hard-coded API keys or secrets
- [ ] Environment variables documented in `.env.example`
- [ ] All error messages are user-friendly
- [ ] Input validation is present
- [ ] Code follows consistent style

## ✅ Security

- [ ] No secrets committed to Git
- [ ] `.gitignore` excludes `.env` files
- [ ] CORS configured to allow only frontend URL
- [ ] Password/auth not required (as per spec, but document if added)
- [ ] Rate limiting considered (optional)
- [ ] SQL injection protection (parameterized queries)

## ✅ Database

- [ ] Database migrations auto-run on startup
- [ ] Schema is correct (conversations, messages tables)
- [ ] Indexes present for performance
- [ ] SQLite file is in `.gitignore`
- [ ] Connection string in `.env` not hardcoded

## ✅ Frontend

- [ ] Builds without errors: `npm run build` in frontend/
- [ ] Environment variables point to correct API URL
- [ ] Chat UI is responsive
- [ ] Messages display correctly
- [ ] Input validation works
- [ ] Session persistence works (localStorage)
- [ ] Error messages show to user

## ✅ Backend

- [ ] Builds without errors: `npm run build` in backend/
- [ ] Starts without errors: `npm start`
- [ ] All endpoints respond: POST /api/chat/message, GET /api/chat/history/:sessionId
- [ ] Database creates on first run
- [ ] LLM integration works (Ollama or OpenAI)
- [ ] Error handling catches all failures
- [ ] Logging is minimal but helpful

## ✅ LLM Integration

- [ ] Ollama is running (if using local)
- [ ] Model is downloaded: `ollama pull mistral`
- [ ] LLM responds to test queries
- [ ] Timeout is reasonable (10 min for Ollama)
- [ ] System prompt includes store knowledge
- [ ] API errors are handled gracefully

## ✅ Testing

- [ ] Manual chat test works end-to-end
- [ ] Messages persist after page reload
- [ ] Long messages are handled
- [ ] Empty messages are rejected
- [ ] API errors show user-friendly messages
- [ ] Session switching works

## ✅ Deployment Files

- [ ] `Dockerfile` exists and builds
- [ ] `docker-compose.yml` is configured
- [ ] `.env.example` files exist
- [ ] `DEPLOYMENT_GUIDE.md` is complete
- [ ] `render.yaml` configured (if using Render)
- [ ] `vercel.json` configured (if using Vercel)
- [ ] `deploy.sh` script is executable

## ✅ Documentation

- [ ] `README.md` is comprehensive
- [ ] `PRD_COMPLIANCE.md` documents all requirements met
- [ ] Architecture is explained
- [ ] LLM choice is justified
- [ ] Trade-offs are documented
- [ ] Setup instructions are clear
- [ ] No unnecessary `.md` files

## ✅ Git Repository

- [ ] Initialized with `git init`
- [ ] Remote added: `git remote add origin ...`
- [ ] All code committed
- [ ] `.gitignore` is comprehensive
- [ ] No `.env` files committed
- [ ] README visible on GitHub
- [ ] Public repository

## ✅ Render Deployment (if using)

- [ ] GitHub account linked to Render
- [ ] Repository is public
- [ ] Environment variables added:
  - `PORT=10000`
  - `NODE_ENV=production`
  - `DATABASE_URL=sqlite:./spur_chat.db`
  - `OLLAMA_URL=<your-ollama-server>`
  - `LLM_MODEL=mistral`
  - `CORS_ORIGIN=<frontend-url>`
- [ ] Build command set correctly
- [ ] Start command set correctly
- [ ] Backend deploys successfully
- [ ] Logs show no errors

## ✅ Vercel Deployment (if using)

- [ ] GitHub account linked to Vercel
- [ ] Repository imported
- [ ] Framework preset: SvelteKit
- [ ] Root directory: `./frontend`
- [ ] Environment variable added:
  - `VITE_API_BASE_URL=<backend-url>`
- [ ] Build succeeds
- [ ] Frontend loads at URL

## ✅ Final Verification

- [ ] Backend URL accessible: `https://your-backend.onrender.com/health`
- [ ] Frontend URL accessible: `https://your-frontend.vercel.app`
- [ ] Chat works end-to-end in production
- [ ] Messages persist
- [ ] No CORS errors in browser console
- [ ] No errors in backend logs

## 🚀 Deployment Steps

```bash
# 1. Prepare code
npm run install:all
npm run build:backend
npm run build:frontend

# 2. Test locally
npm run dev:backend &
npm run dev:frontend &
# Open http://localhost:5173 and test

# 3. Git setup
git add .
git commit -m "Ready for deployment"
git push origin main

# 4. Deploy
./deploy.sh render  # or 'docker' or 'local'

# 5. Verify
# Open your Vercel URL and test end-to-end
```

## 📞 Support

If deployment fails:

1. **Check logs**: Render/Vercel dashboards show build logs
2. **Verify env vars**: All variables set correctly
3. **Test locally**: Run `npm run dev:backend` and `npm run dev:frontend`
4. **Check CORS**: Ensure frontend URL matches CORS_ORIGIN
5. **LLM access**: Verify Ollama is running and accessible

---

**Checklist Complete? Ready to Deploy! 🎉**
