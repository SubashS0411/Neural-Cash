import { supabase } from '../config/supabaseClient.js';

const RECEIPTS_BUCKET = process.env.RECEIPTS_BUCKET || 'receipts';

export async function uploadReceipt(userId, file) {
  if (!file) throw new Error('No file provided');
  const path = `${userId}/${Date.now()}-${file.originalname}`;
  const { data, error } = await supabase.storage.from(RECEIPTS_BUCKET).upload(path, file.buffer, {
    contentType: file.mimetype,
    upsert: false,
  });
  if (error) throw error;
  const { data: publicUrl } = supabase.storage.from(RECEIPTS_BUCKET).getPublicUrl(data.path);
  return { path: data.path, publicUrl: publicUrl.publicUrl };
}
