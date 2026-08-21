-- TN AR Navigation -- Phase 14 schema.
--
-- Run this once in the Supabase dashboard: Project -> SQL Editor -> New
-- query -> paste this whole file -> Run. Safe to re-run (every statement
-- uses IF NOT EXISTS / DROP POLICY IF EXISTS first).
--
-- Row Level Security (RLS) is the real access-control boundary here, not
-- the app's own code -- the anon key shipped in the client can only ever
-- see/change rows these policies allow for the signed-in user.

create extension if not exists pgcrypto;

create table if not exists public.saved_places (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name text not null,
  address text not null default '',
  latitude double precision not null,
  longitude double precision not null,
  created_at timestamptz not null default now()
);

alter table public.saved_places enable row level security;

drop policy if exists "Users can view their own saved places" on public.saved_places;
create policy "Users can view their own saved places"
  on public.saved_places for select
  using (auth.uid() = user_id);

drop policy if exists "Users can insert their own saved places" on public.saved_places;
create policy "Users can insert their own saved places"
  on public.saved_places for insert
  with check (auth.uid() = user_id);

drop policy if exists "Users can delete their own saved places" on public.saved_places;
create policy "Users can delete their own saved places"
  on public.saved_places for delete
  using (auth.uid() = user_id);
