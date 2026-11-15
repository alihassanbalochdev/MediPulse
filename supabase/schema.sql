-- Run this once in the Supabase dashboard: SQL Editor -> New query -> Run.
-- One row per (person, kind of data). `data` holds the JSON snapshot.

create table if not exists public.user_data (
  user_id    uuid not null default auth.uid() references auth.users (id) on delete cascade,
  kind       text not null,
  data       jsonb not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, kind)
);

-- Row Level Security: nobody can read or write another person's rows.
alter table public.user_data enable row level security;

create policy "read own data"   on public.user_data for select using (auth.uid() = user_id);
create policy "insert own data" on public.user_data for insert with check (auth.uid() = user_id);
create policy "update own data" on public.user_data for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "delete own data" on public.user_data for delete using (auth.uid() = user_id);
