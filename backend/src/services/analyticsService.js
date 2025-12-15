import { supabase } from '../config/supabaseClient.js';
import { buildCrossCutSuggestions } from './crossCutService.js';
import { predictRecurring } from './recurringPredictor.js';
import { toCsv } from './reportService.js';

export async function getCrossCut(userId) {
  const { data, error } = await supabase
    .from('transactions')
    .select('id, amount, category_id, merchant_clean, transaction_date')
    .eq('user_id', userId)
    .order('transaction_date', { ascending: false })
    .limit(50);
  if (error) throw error;
  const trigger = data.find((t) => Number(t.amount) > 10000);
  return buildCrossCutSuggestions({ triggerTransaction: trigger, budgets: [] });
}

export async function getPredictions(userId) {
  const { data, error } = await supabase
    .from('transactions')
    .select('amount, description_raw, merchant_clean, transaction_date')
    .eq('user_id', userId)
    .order('transaction_date', { ascending: false })
    .limit(200);
  if (error) throw error;
  return { next_7_days: predictRecurring(data).slice(0, 3), next_30_days: [], special_occasions: [] };
}

export async function getSpendingReport(userId, { start_date, end_date, group_by }) {
  let query = supabase.from('transactions').select('*').eq('user_id', userId);
  if (start_date) query = query.gte('transaction_date', start_date);
  if (end_date) query = query.lte('transaction_date', end_date);
  const { data, error } = await query;
  if (error) throw error;
  // TODO: aggregate per group_by.
  return { group_by: group_by ?? 'category', rows: data };
}

export async function exportSpendingCsv(userId, params) {
  const report = await getSpendingReport(userId, params);
  const csv = toCsv(report.rows, ['id', 'amount', 'description_raw', 'transaction_date', 'category_id']);
  return csv;
}
