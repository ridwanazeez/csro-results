-- CSRO Results Generator: Supabase schema.
-- Run once in the Supabase dashboard (SQL Editor → New query → paste → Run).
-- Safe to re-run.
--
-- Access model: one shared workspace protected by one password. The tables
-- have RLS on and no policies, so the public (anon/publishable) key can't read
-- or write them directly. Every read/write goes through the csro_* functions
-- below, which check the password (bcrypt via pgcrypto) before doing anything.

create extension if not exists pgcrypto with schema extensions;

create table if not exists public.workspace (
  id int primary key default 1 check (id = 1), -- single row
  password_hash text not null,
  settings jsonb not null default '{}',
  point_adjustments jsonb not null default '{}'
);

create table if not exists public.results (
  id text primary key,
  name text not null unique,
  data jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.workspace enable row level security;
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

-- Everything the app needs on unlock.
create or replace function public.csro_load(p_password text) returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  perform csro_check(p_password);
  return (
    select jsonb_build_object(
      'settings', w.settings,
      'pointAdjustments', w.point_adjustments,
      'results', coalesce((
        select jsonb_agg(jsonb_build_object(
          'id', r.id,
          'name', r.name,
          'data', r.data,
          'timestamp', (extract(epoch from r.updated_at) * 1000)::bigint
        ) order by r.created_at)
        from results r
      ), '[]')
    )
    from workspace w
  );
end $$;

create or replace function public.csro_save_result(
  p_password text, p_id text, p_name text, p_data jsonb
) returns void
language plpgsql security definer set search_path = public as $$
begin
  perform csro_check(p_password);
  insert into results (id, name, data) values (p_id, p_name, p_data)
  on conflict (id) do update
    set name = excluded.name, data = excluded.data, updated_at = now();
end $$;

create or replace function public.csro_delete_result(p_password text, p_id text) returns void
language plpgsql security definer set search_path = public as $$
begin
  perform csro_check(p_password);
  delete from results where id = p_id;
end $$;

create or replace function public.csro_save_settings(p_password text, p_settings jsonb) returns void
language plpgsql security definer set search_path = public as $$
begin
  perform csro_check(p_password);
  update workspace set settings = p_settings where id = 1;
end $$;

create or replace function public.csro_save_adjustments(p_password text, p_adjustments jsonb)
returns void
language plpgsql security definer set search_path = public as $$
begin
  perform csro_check(p_password);
  update workspace set point_adjustments = p_adjustments where id = 1;
end $$;

-- Deletes all results, settings and adjustments. The password stays.
create or replace function public.csro_reset(p_password text) returns void
language plpgsql security definer set search_path = public as $$
begin
  perform csro_check(p_password);
  delete from results where true;
  update workspace set settings = '{}', point_adjustments = '{}' where id = 1;
end $$;

revoke all on function public.csro_check(text) from public, anon, authenticated;
