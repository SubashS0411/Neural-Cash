import { supabase } from '../config/supabaseClient.js';

export async function listGoals(userId) {
  const { data, error } = await supabase.from('savings_goals').select('*').eq('user_id', userId);
  if (error) throw error;
  return data;
}

export async function createGoal(userId, payload) {
  const { data, error } = await supabase
    .from('savings_goals')
    .insert({ ...payload, user_id: userId })
    .select()
    .single();
  if (error) throw error;
  return data;
}

export async function contributeGoal(id, amount) {
  const { error } = await supabase.rpc('increment_goal_amount', { goal_id: id, amount });
  if (error) throw error;
  return { id, amount_added: amount };
}
