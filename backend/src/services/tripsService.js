import { supabase } from '../config/supabaseClient.js';

export async function createTrip(userId, payload) {
  const { data, error } = await supabase
    .from('trips')
    .insert({ ...payload, user_id: userId })
    .select()
    .single();
  if (error) throw error;
  return data;
}

export async function listTrips(userId) {
  const { data, error } = await supabase.from('trips').select('*').eq('user_id', userId);
  if (error) throw error;
  return data;
}
