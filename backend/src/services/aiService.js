import natural from 'natural';

// Basic TF-IDF stub with keyword override support. Replace with persisted models per user.
const tokenizer = new natural.WordTokenizer();

export function cleanText(input = '') {
  return tokenizer
    .tokenize(input.replace(/[^a-zA-Z\s]/g, ' '))
    .map((t) => t.toLowerCase())
    .filter(Boolean)
    .join(' ');
}

export async function categorize({ description, keywordsByCategory = {} }) {
  const cleaned = cleanText(description);
  const hits = Object.entries(keywordsByCategory).find(([, kws]) =>
    kws.some((k) => cleaned.includes(k.toLowerCase()))
  );
  if (hits) {
    return { category: hits[0], confidence: 0.82, method: 'rule' };
  }
  // Placeholder TF-IDF: return generic bucket until model is trained.
  return { category: 'uncategorized', confidence: 0.5, method: 'tfidf_stub' };
}

export async function recordFeedback({ userId, description, predictedCategory, correctedCategory, confidence }) {
  // TODO: persist in ai_feedback table for retraining.
  return { userId, description, predictedCategory, correctedCategory, confidence };
}
