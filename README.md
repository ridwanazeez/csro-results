# Assetto Corsa Server JSON formatter app for CSRO Admins

## 🛠 Built With

⚡ [VueJS v3](https://vuejs.org/) \
⚡ [TailwindCSS](https://tailwindcss.com/) \
⚡ [Supabase](https://supabase.com/)

## 🗄 Supabase Setup

Results, settings and point adjustments are stored in Supabase behind one shared password.

1. Create a Supabase project.
2. In the dashboard, open **SQL Editor → New query**, paste [`supabase/schema.sql`](supabase/schema.sql) and run it. It's safe to re-run.
3. From **Project Settings → API Keys** (the URL is under **Data API**), copy the **Project URL** and the **publishable key** (`sb_publishable_…`; the legacy `anon` key also works). Never use the secret/`service_role` key — this value ships in the browser bundle.
4. Create `.env.local` in the repo root (gitignored):

   ```
   VITE_SUPABASE_URL=https://<project-ref>.supabase.co
   VITE_SUPABASE_KEY=sb_publishable_...
   ```

5. `npm run dev`. On first run, the lock screen asks you to set the shared password (8+ characters). Any results already in the browser's localStorage are moved to the database on first unlock.

### Deploying (GitHub Pages)

Add `VITE_SUPABASE_URL` and `VITE_SUPABASE_KEY` as repository **variables** (**Settings → Secrets and variables → Actions → Variables**). The deploy workflow passes them to `npm run build`.

---

Made with ♥ from Georgetown, Guyana ✈
