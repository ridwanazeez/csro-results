// Thin client for the csro_* Postgres functions in supabase/schema.sql.
// Plain fetch against PostgREST's /rpc endpoint — supabase-js isn't needed for this.
const URL = import.meta.env.VITE_SUPABASE_URL
const KEY = import.meta.env.VITE_SUPABASE_KEY

export const configured = Boolean(URL && KEY)

export async function rpc(fn, args = {}) {
  const res = await fetch(`${URL}/rest/v1/rpc/${fn}`, {
    method: 'POST',
    // Publishable keys go on `apikey` only; with no Authorization header
    // PostgREST runs as the anon role, which is all these functions need.
    headers: { apikey: KEY, 'Content-Type': 'application/json' },
    body: JSON.stringify(args)
  })
  const text = await res.text()
  let body = null
  try {
    body = text ? JSON.parse(text) : null
  } catch {
    // Non-JSON error page (gateway/proxy); fall through to the status code
  }
  if (!res.ok) {
    const error = new Error(body?.message || `Request failed (${res.status})`)
    error.code = body?.code
    throw error
  }
  return body
}

export const WRONG_PASSWORD = '28P01'
