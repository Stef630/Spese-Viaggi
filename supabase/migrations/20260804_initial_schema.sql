create extension if not exists pgcrypto;

create table public.trips (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (length(trim(name)) > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, user_id)
);

create unique index trips_user_name_unique
  on public.trips (user_id, lower(trim(name)));

create table public.expenses (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  trip_id uuid not null,
  expense_date date not null,
  category text not null,
  description text not null check (length(trim(description)) > 0),
  amount numeric(14, 2) not null check (amount > 0),
  currency text not null,
  amount_eur numeric(14, 2) not null,
  payment text not null,
  notes text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint expenses_trip_owner_fk
    foreign key (trip_id, user_id)
    references public.trips (id, user_id)
    on delete cascade
);

create index expenses_user_trip_date_idx
  on public.expenses (user_id, trip_id, expense_date desc);

create index expenses_trip_owner_idx
  on public.expenses (trip_id, user_id);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger trips_set_updated_at
before update on public.trips
for each row execute function public.set_updated_at();

create trigger expenses_set_updated_at
before update on public.expenses
for each row execute function public.set_updated_at();

alter table public.trips enable row level security;
alter table public.expenses enable row level security;

revoke all on public.trips, public.expenses from anon;
grant usage on schema public to authenticated;
grant select, insert, update, delete on public.trips, public.expenses to authenticated;

create policy "Users manage their own trips"
on public.trips
for all
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "Users manage their own expenses"
on public.expenses
for all
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

alter publication supabase_realtime add table public.trips;
alter publication supabase_realtime add table public.expenses;
