// Placeholder OCR service. Wire Tesseract.js when enabling receipt uploads.
import Tesseract from 'tesseract.js';

export async function extractTextFromBuffer(buffer) {
  const { data } = await Tesseract.recognize(buffer, 'eng');
  return data.text;
}

export async function parseReceipt(buffer) {
  const text = await extractTextFromBuffer(buffer);
  // TODO: parse amount/date/merchant with regex + heuristics.
  return { text, amount: null, date: null, merchant: null, items: [] };
}
