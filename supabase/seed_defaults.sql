-- Default categories and helpers
-- Run after schema to pre-populate system defaults for new users via RPC/trigger.

create or replace function public.seed_default_categories(target_user uuid)
returns void language plpgsql security definer as $$
begin
  insert into public.categories (id, user_id, name, type, is_system_default, keywords)
  values
    (gen_random_uuid(), target_user, 'Food', 'expense', true, array['food','dining','restaurant','cafe','coffee']),
    (gen_random_uuid(), target_user, 'Travel', 'expense', true, array['travel','flight','train','bus','taxi','uber','ola','rapido']),
    (gen_random_uuid(), target_user, 'Bills', 'expense', true, array['bill','utility','electricity','water','gas','internet','recharge']),
    (gen_random_uuid(), target_user, 'Fuel', 'expense', true, array['fuel','petrol','diesel','gas station']),
    (gen_random_uuid(), target_user, 'Entertainment', 'expense', true, array['entertainment','movie','music','games','netflix','prime','disney']),
    (gen_random_uuid(), target_user, 'Medical', 'expense', true, array['medical','hospital','pharmacy','doctor','clinic','lab']),
    (gen_random_uuid(), target_user, 'Salary', 'income', true, array['salary','payroll','stipend','income','payout']);
end;
$$;
