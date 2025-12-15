import { Parser } from 'json2csv';

export function toCsv(rows, fields) {
  const parser = new Parser({ fields });
  return parser.parse(rows);
}
