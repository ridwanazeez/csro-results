-- CSRO Results Generator: Supabase schema.
-- Run once in the Supabase dashboard (SQL Editor → New query → paste → Run).
-- Safe to re-run.
--
-- Access model: one shared workspace protected by one password. Results are
-- grouped into events; each event has its own branding, points edits and
-- hidden standings rows. The tables
-- have RLS on and no policies, so the public (anon/publishable) key can't read
-- or write them directly. Every read/write goes through the csro_* functions
-- below, which check the password (bcrypt via pgcrypto) before doing anything.

create extension if not exists pgcrypto with schema extensions;

create table if not exists public.workspace (
  id int primary key default 1 check (id = 1), -- single row
  password_hash text not null
);

create table if not exists public.events (
  id text primary key,
  name text not null unique,
  settings jsonb not null default '{}',
  point_adjustments jsonb not null default '{}',
  hidden_standings jsonb not null default '[]',
  created_at timestamptz not null default now()
);

create table if not exists public.results (
  id text primary key,
  event_id text not null references public.events (id) on delete cascade,
  name text not null,
  data jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Upgrade from the single-workspace version: results move into a "Default"
-- event that takes over the workspace's settings and points edits.
alter table public.results
  add column if not exists event_id text references public.events (id) on delete cascade;
do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'workspace' and column_name = 'settings'
  ) then
    if exists (select 1 from public.results where event_id is null) then
      insert into public.events (id, name, settings, point_adjustments)
      select 'default', 'Default', settings, point_adjustments from public.workspace
      on conflict (id) do nothing;
      update public.results set event_id = 'default' where event_id is null;
    end if;
    alter table public.workspace drop column settings, drop column point_adjustments;
  end if;
end $$;
alter table public.results alter column event_id set not null;
alter table public.results drop constraint if exists results_name_key;
create unique index if not exists results_event_name on public.results (event_id, name);

drop function if exists public.csro_save_result(text, text, text, jsonb);
drop function if exists public.csro_save_settings(text, jsonb);
drop function if exists public.csro_save_adjustments(text, jsonb);

alter table public.workspace enable row level security;
alter table public.events enable row level security;
alter table public.results enable row level security;

-- Raises unless p_password matches. Not callable from the API.
create or replace function public.csro_check(p_password text) returns void
language plpgsql security definer set search_path = public, extensions as $$
begin
  if not exists (
    select 1 from workspace where password_hash = crypt(p_password, password_hash)
  ) then
    raise exception 'Wrong password' using errcode = '28P01';
  end if;
end $$;

-- True once a password has been set.
create or replace function public.csro_status() returns boolean
language sql security definer set search_path = public as $$
  select exists (select 1 from workspace);
$$;

-- First-run only: sets the workspace password.
create or replace function public.csro_setup(p_password text) returns void
language plpgsql security definer set search_path = public, extensions as $$
begin
  if length(coalesce(p_password, '')) < 8 then
    raise exception 'Password must be at least 8 characters';
  end if;
  insert into workspace (id, password_hash) values (1, crypt(p_password, gen_salt('bf', 10)))
  on conflict (id) do nothing;
  if not found then
    raise exception 'A password is already set';
  end if;
end $$;

-- The event list shown after unlock.
create or replace function public.csro_load(p_password text) returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  perform csro_check(p_password);
  return coalesce((
    select jsonb_agg(jsonb_build_object(
      'id', e.id,
      'name', e.name,
      'resultCount', (select count(*) from results r where r.event_id = e.id)
    ) order by e.created_at desc)
    from events e
  ), '[]');
end $$;

-- Everything one event needs.
create or replace function public.csro_load_event(p_password text, p_id text) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v jsonb;
begin
  perform csro_check(p_password);
  select jsonb_build_object(
    'id', e.id,
    'name', e.name,
    'settings', e.settings,
    'pointAdjustments', e.point_adjustments,
    'hiddenStandings', e.hidden_standings,
    'results', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', r.id,
        'name', r.name,
        'data', r.data,
        'timestamp', (extract(epoch from r.updated_at) * 1000)::bigint
      ) order by r.created_at)
      from results r where r.event_id = e.id
    ), '[]')
  ) into v
  from events e where e.id = p_id;
  if v is null then
    raise exception 'Event not found' using errcode = 'P0002';
  end if;
  return v;
end $$;

create or replace function public.csro_create_event(p_password text, p_id text, p_name text)
returns void
language plpgsql security definer set search_path = public as $$
begin
  perform csro_check(p_password);
  if length(trim(coalesce(p_name, ''))) = 0 then
    raise exception 'Give the event a name';
  end if;
  insert into events (id, name) values (p_id, trim(p_name));
exception when unique_violation then
  raise exception 'An event called "%" already exists', trim(p_name);
end $$;

-- Patches any of settings / pointAdjustments / hiddenStandings.
create or replace function public.csro_update_event(p_password text, p_id text, p_patch jsonb)
returns void
language plpgsql security definer set search_path = public as $$
begin
  perform csro_check(p_password);
  update events set
    settings = coalesce(p_patch -> 'settings', settings),
    point_adjustments = coalesce(p_patch -> 'pointAdjustments', point_adjustments),
    hidden_standings = coalesce(p_patch -> 'hiddenStandings', hidden_standings)
  where id = p_id;
  if not found then
    raise exception 'Event not found' using errcode = 'P0002';
  end if;
end $$;

-- Deletes the event and every result in it.
create or replace function public.csro_delete_event(p_password text, p_id text) returns void
language plpgsql security definer set search_path = public as $$
begin
  perform csro_check(p_password);
  delete from events where id = p_id;
end $$;

create or replace function public.csro_save_result(
  p_password text, p_event_id text, p_id text, p_name text, p_data jsonb
) returns void
language plpgsql security definer set search_path = public as $$
begin
  perform csro_check(p_password);
  insert into results (id, event_id, name, data) values (p_id, p_event_id, p_name, p_data)
  on conflict (id) do update
    set name = excluded.name, data = excluded.data, updated_at = now();
end $$;

create or replace function public.csro_delete_result(p_password text, p_id text) returns void
language plpgsql security definer set search_path = public as $$
begin
  perform csro_check(p_password);
  delete from results where id = p_id;
end $$;

-- Deletes every event and result. The password stays.
create or replace function public.csro_reset(p_password text) returns void
language plpgsql security definer set search_path = public as $$
begin
  perform csro_check(p_password);
  delete from events where true; -- cascades to results
end $$;

revoke all on function public.csro_check(text) from public, anon, authenticated;
