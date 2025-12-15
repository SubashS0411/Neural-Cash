-- NeuralCash core schema
-- Run in Supabase SQL editor or via supabase db push.

-- Extensions
create extension if not exists "uuid-ossp";
create extension if not exists pgcrypto;

-- Helper
create or replace function public.current_user_id()
returns uuid language sql stable as $$
  select auth.uid();
$$;

-- Table: profiles (1:1 with auth.users)
create table if not exists public.profiles (
  id uuid primary key references auth.users on delete cascade,
  full_name text,
  currency_symbol text default '₹',
  monthly_income_target numeric,
  tax_percentage numeric default 30,
  savings_goal_short_term numeric,
  savings_goal_long_term numeric,
  family_id uuid references public.families(id),
  notification_preferences jsonb default '{"reduce_this": true, "cross_cut": true, "savings_alert": true}'::jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Table: families
create table if not exists public.families (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  invite_code text unique not null,
  created_by uuid references public.profiles(id),
  created_at timestamptz default now()
);

-- Table: categories
create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id),
  family_id uuid references public.families(id),
  name text not null,
  type text not null check (type in ('income','expense')),
  keywords text[],
  monthly_budget numeric default 0,
  is_flexible boolean default false,
  is_system_default boolean default false,
  icon text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  family_id uuid references public.families(id),
  amount numeric not null,
  description_raw text not null,
  merchant_clean text,
  category_id uuid references public.categories(id),
  transaction_date timestamptz not null,
  is_ai_categorized boolean default true,
  confidence_score float,
  status text default 'approved' check (status in ('pending_approval','approved','rejected')),
  payment_method text check (payment_method in ('cash','online','credit_card','upi')),

-- Function: increment_goal_amount
create or replace function public.increment_goal_amount(goal_id uuid, amount numeric)
returns void
language plpgsql
security definer
as $$
  is_personal boolean default false,
  update savings_goals
    set current_amount = coalesce(current_amount, 0) + coalesce(amount, 0)
  where id = goal_id;
end;
$$;

grant execute on function public.increment_goal_amount(uuid, numeric) to authenticated;
  is_loop_transfer boolean default false,
  is_recurring boolean default false,
  recurrence_pattern text,
  next_predicted_date timestamptz,
  is_special_occasion boolean default false,
  occasion_name text,
  is_installment boolean default false,
  installment_plan_id uuid references public.installment_plans(id),
  installment_number int,
  total_installments int,
  trip_id uuid references public.trips(id),
  receipt_url text,
  receipt_extracted_data jsonb,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
create index if not exists idx_transactions_user on public.transactions(user_id);
create index if not exists idx_transactions_date on public.transactions(transaction_date);
create index if not exists idx_transactions_category on public.transactions(category_id);

-- Table: budgets_and_goals
create table if not exists public.budgets_and_goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id),
  category_id uuid references public.categories(id),
  target_amount numeric,
  alert_threshold numeric,
  month date,
  is_exceeded boolean default false,
  created_at timestamptz default now()
);

-- Table: savings_goals
create table if not exists public.savings_goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  goal_name text not null,
  goal_type text check (goal_type in ('short_term','long_term')),
  target_amount numeric not null,
  current_amount numeric default 0,
  monthly_contribution numeric,
  target_date date,
  status text default 'in_progress' check (status in ('in_progress','completed','paused')),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Table: trips
create table if not exists public.trips (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  trip_name text not null,
  destination text,
  start_date date,
  end_date date,
  estimated_budget numeric,
  actual_spent numeric default 0,
  estimated_petrol_cost numeric,
  estimated_hotel_cost numeric,
  suggested_hotels jsonb,
  estimated_transport_cost numeric,
  transport_suggestions jsonb,
  status text default 'planning' check (status in ('planning','ongoing','completed')),
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Table: installment_plans
create table if not exists public.installment_plans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  plan_name text not null,
  total_amount numeric not null,
  remaining_amount numeric not null,
  monthly_amount numeric not null,
  start_date date,
  end_date date,
  plan_type text check (plan_type in ('loan_given','loan_taken','emi','investment')),
  is_extra_fund_available boolean default false,
  status text default 'active' check (status in ('active','completed','defaulted')),
  created_at timestamptz default now()
);

-- Table: notifications
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  notification_type text check (notification_type in ('reduce_this','cross_cut','savings_exceeded','budget_alert','recurring_prediction')),
  title text not null,
  message text not null,
  action_data jsonb,
  is_read boolean default false,
  created_at timestamptz default now()
);

-- Table: ai_feedback
create table if not exists public.ai_feedback (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  transaction_description text not null,
  ai_predicted_category text,
  user_corrected_category text,
  confidence_score float,
  created_at timestamptz default now()
);

-- RLS enable
alter table public.profiles enable row level security;
alter table public.families enable row level security;
alter table public.categories enable row level security;
alter table public.transactions enable row level security;
alter table public.budgets_and_goals enable row level security;
alter table public.savings_goals enable row level security;
alter table public.trips enable row level security;
alter table public.installment_plans enable row level security;
alter table public.notifications enable row level security;
alter table public.ai_feedback enable row level security;

-- Policies: profiles (self only)
create policy if not exists profiles_select_self on public.profiles for select using (id = auth.uid());
create policy if not exists profiles_insert_self on public.profiles for insert with check (id = auth.uid());
create policy if not exists profiles_update_self on public.profiles for update using (id = auth.uid());
create policy if not exists profiles_delete_self on public.profiles for delete using (id = auth.uid());

-- Policies: families (creator and members)
create policy if not exists families_select_members on public.families for select using (
  created_by = auth.uid() or id in (select family_id from public.profiles where id = auth.uid())
);
create policy if not exists families_insert_creator on public.families for insert with check (created_by = auth.uid());
create policy if not exists families_update_creator on public.families for update using (created_by = auth.uid());
create policy if not exists families_delete_creator on public.families for delete using (created_by = auth.uid());

-- Policies: categories (owner or family member)
create policy if not exists categories_select_owner on public.categories for select using (
  user_id = auth.uid() or family_id in (select family_id from public.profiles where id = auth.uid())
);
create policy if not exists categories_insert_owner on public.categories for insert with check (
  user_id = auth.uid() or family_id in (select family_id from public.profiles where id = auth.uid())
);
create policy if not exists categories_update_owner on public.categories for update using (
  user_id = auth.uid() or family_id in (select family_id from public.profiles where id = auth.uid())
);
create policy if not exists categories_delete_owner on public.categories for delete using (
  user_id = auth.uid() or family_id in (select family_id from public.profiles where id = auth.uid())
);

-- Policies: transactions (owner)
create policy if not exists transactions_select_owner on public.transactions for select using (user_id = auth.uid());
create policy if not exists transactions_insert_owner on public.transactions for insert with check (user_id = auth.uid());
create policy if not exists transactions_update_owner on public.transactions for update using (user_id = auth.uid());
create policy if not exists transactions_delete_owner on public.transactions for delete using (user_id = auth.uid());

-- Policies: budgets_and_goals (owner)
create policy if not exists budgets_select_owner on public.budgets_and_goals for select using (user_id = auth.uid());
create policy if not exists budgets_insert_owner on public.budgets_and_goals for insert with check (user_id = auth.uid());
create policy if not exists budgets_update_owner on public.budgets_and_goals for update using (user_id = auth.uid());
create policy if not exists budgets_delete_owner on public.budgets_and_goals for delete using (user_id = auth.uid());

-- Policies: savings_goals (owner)
create policy if not exists savings_select_owner on public.savings_goals for select using (user_id = auth.uid());
create policy if not exists savings_insert_owner on public.savings_goals for insert with check (user_id = auth.uid());
create policy if not exists savings_update_owner on public.savings_goals for update using (user_id = auth.uid());
create policy if not exists savings_delete_owner on public.savings_goals for delete using (user_id = auth.uid());

-- Policies: trips (owner)
create policy if not exists trips_select_owner on public.trips for select using (user_id = auth.uid());
create policy if not exists trips_insert_owner on public.trips for insert with check (user_id = auth.uid());
create policy if not exists trips_update_owner on public.trips for update using (user_id = auth.uid());
create policy if not exists trips_delete_owner on public.trips for delete using (user_id = auth.uid());

-- Policies: installment_plans (owner)
create policy if not exists installments_select_owner on public.installment_plans for select using (user_id = auth.uid());
create policy if not exists installments_insert_owner on public.installment_plans for insert with check (user_id = auth.uid());
create policy if not exists installments_update_owner on public.installment_plans for update using (user_id = auth.uid());
create policy if not exists installments_delete_owner on public.installment_plans for delete using (user_id = auth.uid());

-- Policies: notifications (owner)
create policy if not exists notifications_select_owner on public.notifications for select using (user_id = auth.uid());
create policy if not exists notifications_insert_owner on public.notifications for insert with check (user_id = auth.uid());
create policy if not exists notifications_update_owner on public.notifications for update using (user_id = auth.uid());
create policy if not exists notifications_delete_owner on public.notifications for delete using (user_id = auth.uid());

-- Policies: ai_feedback (owner)
create policy if not exists ai_feedback_select_owner on public.ai_feedback for select using (user_id = auth.uid());
create policy if not exists ai_feedback_insert_owner on public.ai_feedback for insert with check (user_id = auth.uid());
create policy if not exists ai_feedback_update_owner on public.ai_feedback for update using (user_id = auth.uid());
create policy if not exists ai_feedback_delete_owner on public.ai_feedback for delete using (user_id = auth.uid());
