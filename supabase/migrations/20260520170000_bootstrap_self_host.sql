-- =============================================================================
-- Bootstrap for self-host deployments on fresh Supabase Cloud projects (2025+)
-- -----------------------------------------------------------------------------
-- New Supabase projects no longer ship with `pg_net`, `supabase_vault`, or the
-- legacy `supabase_functions` schema enabled by default. This project depends
-- on all three (vault secrets are read by trigger functions and cron jobs,
-- `net.http_post` is used to invoke Edge Functions from the database, and the
-- legacy `supabase_functions.hooks` table is written to by the existing
-- `public.edge_function()` and `public.dispatcher_edge_function()` triggers).
--
-- Without this migration, the following silent failures occur on a fresh
-- Supabase Cloud project deployed via the Supabase GitHub Integration:
--   * `whatsapp-webhook` Edge Function logs: `schema "net" does not exist`.
--   * `whatsapp-webhook` Edge Function logs: `relation "supabase_functions.hooks"
--     does not exist`.
--   * Inbound WhatsApp messages reach the Edge Function but are NOT persisted
--     to `public.messages` because the row trigger reverts the INSERT.
--
-- This migration is fully idempotent (safe to re-run, safe on legacy projects
-- that already have these objects pre-installed by the Supabase platform).
-- =============================================================================

-- 1) Extensions required by triggers and cron jobs ---------------------------

create extension if not exists pg_net         with schema extensions;
create extension if not exists supabase_vault with schema vault;
create extension if not exists pgcrypto       with schema extensions;

-- 2) Legacy `supabase_functions` schema --------------------------------------
-- Used by `public.edge_function()` and `public.dispatcher_edge_function()` to
-- audit every HTTP request fired via `net.http_post` (so it shows up under
-- Supabase Dashboard > Database > Webhooks > History).

create schema if not exists supabase_functions;

create table if not exists supabase_functions.hooks (
  id            bigserial primary key,
  hook_table_id oid         not null,
  hook_name     text        not null,
  created_at    timestamptz not null default now(),
  request_id    bigint
);

create index if not exists supabase_functions_hooks_request_id_idx
  on supabase_functions.hooks (request_id);

create index if not exists supabase_functions_hooks_h_table_id_h_name_idx
  on supabase_functions.hooks (hook_table_id, hook_name);

-- 3) Grants ------------------------------------------------------------------
-- Mirrors what the legacy `supabase_functions` extension used to grant, so
-- trigger functions running as `postgres` / `service_role` can write to it.

grant usage on schema supabase_functions
  to postgres, anon, authenticated, service_role;

grant all on supabase_functions.hooks
  to postgres, anon, authenticated, service_role;

grant all on sequence supabase_functions.hooks_id_seq
  to postgres, anon, authenticated, service_role;
