import { parse } from 'csv-parse/sync';

export function parseCsvTransactions(csvString) {
  const records = parse(csvString, { columns: true, skip_empty_lines: true, trim: true });
  return records.map((row) => ({
    amount: Number(row.amount),
    description: row.description,
    transaction_date: row.transaction_date,
    payment_method: row.payment_method,
    is_personal: row.is_personal === 'true' || row.is_personal === true,
  }));
}
