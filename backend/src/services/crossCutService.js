// Placeholder cross-cut logic for high discretionary spend.
export function buildCrossCutSuggestions({ triggerTransaction, budgets = [] }) {
  if (!triggerTransaction) return { suggestions: [] };
  const suggestions = budgets.slice(0, 2).map((b) => ({
    category: b.category,
    current_spent: b.current_spent ?? 0,
    budget: b.budget ?? 0,
    suggested_reduction: (b.budget ?? 0) * 0.15,
    percentage: 15,
  }));
  return { trigger_transaction: triggerTransaction, suggestions, remaining_disposable: null };
}
