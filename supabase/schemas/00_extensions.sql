-- Extensions required by this project.
--
-- NOTE: These declarations are part of the *declarative* schema, used by
-- `supabase db diff` to detect drift against your Cloud database. The actual
-- enablement on fresh Supabase Cloud projects is performed by the bootstrap
-- migration `supabase/migrations/20260520170000_bootstrap_self_host.sql`,
-- which is idempotent and safe on legacy projects that already ship these
-- extensions pre-installed.

create extension if not exists pg_cron      with schema pg_catalog;

create extension if not exists moddatetime  with schema public;

-- These used to be present in older Supabase projects by default but are NOT
-- automatically enabled in new ones (2025+). They are required by trigger
-- functions, cron jobs and `net.http_post` calls throughout the schema.

create extension if not exists pg_net         with schema extensions;
create extension if not exists supabase_vault with schema vault;
create extension if not exists pgcrypto       with schema extensions;

-- Optional: kept here so `supabase db diff` does not flag drift on projects
-- where they are present. Comment out if your Cloud project does not have them.

-- create extension if not exists pg_graphql        with schema graphql;
-- create extension if not exists pg_stat_statements with schema extensions;
-- create extension if not exists "uuid-ossp"       with schema extensions;
