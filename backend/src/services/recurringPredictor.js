// Placeholder recurring expense predictor using simple grouping. Replace with real model.
export function predictRecurring(transactions = []) {
  return transactions.slice(0, 3).map((t) => ({
    merchant: t.merchant_clean ?? t.description_raw,
    predicted_amount: t.amount,
    predicted_date: t.transaction_date,
    confidence: 0.5,
  }));
}
