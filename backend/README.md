# NeuralCash Backend (Node/Express)

Early scaffold aligned to PRD endpoints. Provides Express API shells for transactions, analytics, categories, savings, trips, receipts (OCR stub), and CSV export. Supabase is the primary data store.

## Setup
1. Install Node 18+.
2. `cd backend`
3. `npm install`
4. Copy `.env.example` to `.env` and set `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `SUPABASE_JWT_SECRET` (for validation if needed), optional `RECEIPTS_BUCKET`, and `PORT`.
5. Ensure Supabase has bucket `receipts` (or set `RECEIPTS_BUCKET`) and RPC `increment_goal_amount` (in `supabase/schema.sql`).
6. Run dev server: `npm run dev` (defaults to `http://localhost:4000`).

## Routes (v1)
- `GET /api/v1/health`
- `GET /api/v1/transactions` (query: start_date, end_date, limit, offset)
- `POST /api/v1/transactions/add` (manual entry)
- `POST /api/v1/transactions/bulk-import` (multipart file csv)
- `POST /api/v1/transactions/receipt` (multipart file receipt → OCR stub)
- `PATCH /api/v1/transactions/:id/approve`
- `PATCH /api/v1/transactions/:id/recategorize`
- `DELETE /api/v1/transactions/:id`
- `GET /api/v1/categories`, `POST /api/v1/categories`, `PATCH /api/v1/categories/:id`
- `GET /api/v1/analytics/cross-cut`
- `GET /api/v1/analytics/predictions`
- `GET /api/v1/analytics/spending-report`
- `GET /api/v1/analytics/export` (CSV)
- `GET /api/v1/savings/goals`, `POST /api/v1/savings/goals`, `POST /api/v1/savings/goals/:id/contribute`
- `GET /api/v1/trips`, `POST /api/v1/trips`

## Auth
Routes are protected with Supabase JWT verification (`Authorization: Bearer <access_token>`). The user id is taken from the token for RLS-safe queries.

## Next steps
- Implement Supabase RLS-compliant RPCs (increment_goal_amount, seeded categories, family groups).
- Wire AI: persist `ai_feedback`, train TF-IDF per user, and map category names → IDs.
- Add OCR field extraction heuristics and storage uploads.
- Add family dashboards, installment plans, notifications, budget alerts, and reporting aggregates.
- Add unit tests and lint config.
