import Joi from 'joi';
import { supabase } from '../config/supabaseClient.js';
import { categorize, recordFeedback } from './aiService.js';
import { parseCsvTransactions } from './csvImportService.js';

const baseSchema = Joi.object({
  amount: Joi.number().positive().required(),
  description: Joi.string().required(),
  transaction_date: Joi.date().iso().required(),
  payment_method: Joi.string().valid('cash', 'online', 'credit_card', 'upi').required(),
  is_personal: Joi.boolean().default(false),
});

export async function addTransaction(userId, payload) {
  const { value, error } = baseSchema.validate(payload, { abortEarly: false });
  if (error) throw new Error(error.message);

  const { category, confidence } = await categorize({ description: value.description, keywordsByCategory: {} });
  const { data, error: dbError } = await supabase
    .from('transactions')
    .insert({
      user_id: userId,
      amount: value.amount,
      description_raw: value.description,
      transaction_date: value.transaction_date,
      payment_method: value.payment_method,
      is_personal: value.is_personal,
      is_ai_categorized: true,
      confidence_score: confidence,
      merchant_clean: value.description,
      status: 'approved',
      // TODO: map category name to category_id once categories are fetched
    })
    .select()
    .single();
  if (dbError) throw dbError;
  return data;
}

export async function bulkImport(userId, csvString) {
  const parsed = parseCsvTransactions(csvString);
  // TODO: batch insert with AI categorization.
  return parsed.map((row) => ({ ...row, user_id: userId }));
}

export async function listTransactions(userId, { start_date, end_date, limit = 50, offset = 0 } = {}) {
  let query = supabase.from('transactions').select('*').eq('user_id', userId).order('transaction_date', { ascending: false });
  if (start_date) query = query.gte('transaction_date', start_date);
  if (end_date) query = query.lte('transaction_date', end_date);
  if (limit) query = query.limit(limit);
  if (offset) query = query.range(offset, offset + limit - 1);
  const { data, error } = await query;
  if (error) throw error;
  return data;
}

export async function approveTransaction(id, action) {
  const { data, error } = await supabase.from('transactions').update({ status: action }).eq('id', id).select().single();
  if (error) throw error;
  return data;
}

export async function recategorize(id, { userId, category_id, description, predictedCategory, confidence }) {
  const { error } = await supabase.from('transactions').update({ category_id }).eq('id', id);
  if (error) throw error;
  await recordFeedback({ userId, description, predictedCategory, correctedCategory: category_id, confidence });
  return { id, category_id };
}

export async function softDelete(id) {
  const { error } = await supabase.from('transactions').delete().eq('id', id);
  if (error) throw error;
  return { id };
}
