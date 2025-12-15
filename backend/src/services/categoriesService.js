import { supabase } from '../config/supabaseClient.js';

export async function listCategories(userId) {
  const { data, error } = await supabase.from('categories').select('*').eq('user_id', userId);
  if (error) throw error;
  return data;
}

export async function createCategory(userId, payload) {
  const { data, error } = await supabase
    .from('categories')
    .insert({ ...payload, user_id: userId })
    .select()
    .single();
  if (error) throw error;
  return data;
}

export async function updateCategory(id, payload) {
  const { data, error } = await supabase.from('categories').update(payload).eq('id', id).select().single();
  if (error) throw error;
  return data;
}
