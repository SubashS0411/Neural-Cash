# NeuralCash React PWA Plan

This outlines how to stand up the PRD-aligned React 18 + Vite + Tailwind PWA with AI/OCR/ingest flows. Frontend will talk to the new `/api/v1` Node backend.

## Scaffold
- Already bootstrapped under `pwa/` with Vite config, Tailwind config, React Query, and placeholder routes.
- Install deps: `cd pwa && npm install` then `npm run dev`.
- Tailwind/Vite/PWA plugin are preconfigured.

## Core pages/routes
- `/auth` (email/password, magic link) hitting Supabase Auth (client SDK) and storing session.
- `/onboarding` (profile, income, tax, savings goals, family join/create via invite code).
- `/dashboard` (cards: safe-to-spend, burn rate, month summary, upcoming predictions; charts: pie, line, bar, heatmap).
- `/transactions` (list with swipe/approve/delete, color coding, confidence badge, filters; bulk CSV upload; receipt upload → OCR parse preview → submit; voice entry using Web Speech API; manual add/edit form with AI category suggestions).
- `/analytics/time-machine` (next 3 months prediction table).
- `/savings` (short/long-term goals, contributions, exceeded notifications).
- `/trips` (planner with estimators and suggestions cards; link expenses to trips).
- `/family` (member breakdown, person-wise charts, privacy badge for personal transactions).
- `/settings` (notification prefs, export/download CSV/PDF, backup options, theme toggle).

## Data layer
- Create `apiClient` for Node endpoints (axios with auth interceptor reading Supabase JWT).
- Hooks: `useTransactions`, `useAnalytics`, `useCategories`, `useSavings`, `useTrips`, `useFamily`, `useNotifications` built on React Query.
- Global store: Zustand for UI state (filters, toasts, modals).

## AI/OCR UX
- AI category suggestions inline chip with confidence; orange badge if < 0.6.
- Receipt upload flow: dropzone → preview parsed fields → allow edits → submit to `/transactions/add`.
- Voice entry: button starts Web Speech, populates form, runs client-side parse → send to API.

## Export/backup
- Buttons to call `/analytics/export` (CSV) and `/reports/pdf` (future) then trigger download; show toasts.

## Theming
- Tailwind theme tokens matching Flutter premium palette; glass cards, gradients; responsive grid; motion on load.

## QA checklist
- PWA installable, offline shell works.
- Auth guard redirects unauthenticated users.
- Forms validated with Zod; error toasts.
- File uploads handle size/type; CSV mapping preview; OCR errors surfaced.
- Charts render with empty states.

## Next actions
- Run scaffold commands above (not executed yet in repo).
- Generate base layout + router, auth guard, and shell nav.
- Implement transactions page with manual entry, CSV, OCR, voice stubs wired to backend.
- Add dashboard charts consuming `/analytics` endpoints.
