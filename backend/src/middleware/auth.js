import { supabase } from '../config/supabaseClient.js';

// Verifies Supabase JWT from Authorization header and attaches user to req.
export async function requireAuth(req, res, next) {
  const auth = req.headers.authorization;
  const token = auth?.startsWith('Bearer ') ? auth.slice(7) : null;
  if (!token) return res.status(401).json({ status: 'error', message: 'Missing bearer token' });
  const { data, error } = await supabase.auth.getUser(token);
  if (error || !data?.user) return res.status(401).json({ status: 'error', message: 'Invalid token' });
  req.user = data.user;
  next();
}
