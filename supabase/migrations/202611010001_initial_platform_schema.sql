-- 4TL4S initial platform schema
-- Tenant isolation is enforced by membership-backed RLS. No client data is seeded.

create extension if not exists pgcrypto;
create schema if not exists private;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) between 2 and 160),
  slug text not null unique check (slug ~ '^[a-z0-9][a-z0-9-]{1,62}$'),
  created_by uuid not null references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.memberships (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null check (role in ('owner','admin','researcher','engineer','producer','commercial','reviewer','viewer')),
  status text not null default 'active' check (status in ('invited','active','suspended')),
  created_at timestamptz not null default now(),
  unique (organization_id, user_id)
);

create or replace function private.is_org_member(target_org uuid)
returns boolean
language sql stable security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.memberships m
    where m.organization_id = target_org
      and m.user_id = (select auth.uid())
      and m.status = 'active'
  );
$$;

create or replace function private.has_org_role(target_org uuid, allowed_roles text[])
returns boolean
language sql stable security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.memberships m
    where m.organization_id = target_org
      and m.user_id = (select auth.uid())
      and m.status = 'active'
      and m.role = any(allowed_roles)
  );
$$;

revoke all on function private.is_org_member(uuid) from public;
revoke all on function private.has_org_role(uuid, text[]) from public;
grant usage on schema private to authenticated;
grant execute on function private.is_org_member(uuid) to authenticated;
grant execute on function private.has_org_role(uuid, text[]) to authenticated;

create or replace function private.create_org_owner_membership()
returns trigger
language plpgsql security definer
set search_path = ''
as $$
begin
  insert into public.memberships (organization_id, user_id, role, status)
  values (new.id, new.created_by, 'owner', 'active');
  return new;
end;
$$;

create trigger organizations_add_creator_as_owner
after insert on public.organizations
for each row execute function private.create_org_owner_membership();

create table public.initiatives (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  name text not null check (length(trim(name)) between 2 and 200),
  summary text,
  domain text not null check (domain in ('applied_research','product_development','artifact_production','commercial_operations','shared_governance')),
  status text not null default 'proposed' check (status in ('proposed','active','paused','completed','cancelled','archived')),
  owner_user_id uuid references auth.users(id) on delete set null,
  created_by uuid not null default auth.uid() references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.work_packages (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  initiative_id uuid not null references public.initiatives(id) on delete cascade,
  title text not null check (length(trim(title)) between 2 and 200),
  description text,
  status text not null default 'backlog' check (status in ('backlog','ready','in_progress','blocked','in_review','done','cancelled')),
  priority text not null default 'normal' check (priority in ('low','normal','high','critical')),
  assignee_user_id uuid references auth.users(id) on delete set null,
  created_by uuid not null default auth.uid() references auth.users(id),
  due_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.artifacts (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  initiative_id uuid references public.initiatives(id) on delete set null,
  work_package_id uuid references public.work_packages(id) on delete set null,
  title text not null,
  artifact_type text not null,
  version text,
  storage_path text,
  external_uri text,
  lifecycle_state text not null default 'draft' check (lifecycle_state in ('draft','in_review','approved','rejected','superseded','published','archived')),
  created_by uuid not null default auth.uid() references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (storage_path is null or external_uri is null)
);

create table public.evidence_records (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  initiative_id uuid references public.initiatives(id) on delete set null,
  artifact_id uuid references public.artifacts(id) on delete set null,
  evidence_type text not null,
  statement text not null,
  source_uri text,
  content_hash text,
  provenance jsonb not null default '{}'::jsonb,
  evidence_state text not null default 'declared' check (evidence_state in ('declared','observed','interpreted','verified','approved','rejected','superseded')),
  recorded_by uuid not null default auth.uid() references auth.users(id),
  recorded_at timestamptz not null default now()
);

create table public.decision_records (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  initiative_id uuid references public.initiatives(id) on delete set null,
  title text not null,
  rationale text not null,
  outcome text not null check (outcome in ('accepted','rejected','deferred','superseded')),
  decided_by uuid not null default auth.uid() references auth.users(id),
  decided_at timestamptz not null default now(),
  supersedes_id uuid references public.decision_records(id) on delete set null
);

create table public.ip_assets (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  initiative_id uuid references public.initiatives(id) on delete set null,
  name text not null,
  classification text not null check (classification in ('background_ip','research_ip','product_ip','client_ip','third_party_ip','undetermined')),
  provenance_summary text not null,
  governing_agreement_uri text,
  license_identifier text,
  status text not null default 'under_review' check (status in ('under_review','classified','disputed','superseded')),
  recorded_by uuid not null default auth.uid() references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.relationships (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  source_type text not null,
  source_id uuid not null,
  target_type text not null,
  target_id uuid not null,
  relationship_type text not null,
  rationale text,
  created_by uuid not null default auth.uid() references auth.users(id),
  created_at timestamptz not null default now(),
  unique (organization_id, source_type, source_id, target_type, target_id, relationship_type),
  check (source_type <> target_type or source_id <> target_id)
);

create table public.integration_connections (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  provider text not null,
  display_name text not null,
  external_account_id text,
  granted_scopes text[] not null default '{}',
  connection_state text not null default 'pending' check (connection_state in ('pending','active','revoked','error')),
  secret_reference text,
  created_by uuid not null default auth.uid() references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.audit_events (
  id bigint generated always as identity primary key,
  organization_id uuid not null references public.organizations(id) on delete cascade,
  actor_user_id uuid references auth.users(id) on delete set null,
  event_type text not null,
  entity_type text not null,
  entity_id text,
  event_payload jsonb not null default '{}'::jsonb,
  occurred_at timestamptz not null default now()
);

create index memberships_user_org_idx on public.memberships(user_id, organization_id);
create index initiatives_org_status_idx on public.initiatives(organization_id, status);
create index work_packages_org_status_idx on public.work_packages(organization_id, status);
create index work_packages_initiative_idx on public.work_packages(initiative_id);
create index artifacts_org_created_idx on public.artifacts(organization_id, created_at desc);
create index evidence_org_state_idx on public.evidence_records(organization_id, evidence_state);
create index decisions_org_decided_idx on public.decision_records(organization_id, decided_at desc);
create index ip_assets_org_class_idx on public.ip_assets(organization_id, classification);
create index relationships_org_idx on public.relationships(organization_id);
create index integrations_org_provider_idx on public.integration_connections(organization_id, provider);
create index audit_org_time_idx on public.audit_events(organization_id, occurred_at desc);

alter table public.profiles enable row level security;
alter table public.organizations enable row level security;
alter table public.memberships enable row level security;
alter table public.initiatives enable row level security;
alter table public.work_packages enable row level security;
alter table public.artifacts enable row level security;
alter table public.evidence_records enable row level security;
alter table public.decision_records enable row level security;
alter table public.ip_assets enable row level security;
alter table public.relationships enable row level security;
alter table public.integration_connections enable row level security;
alter table public.audit_events enable row level security;

create policy "profiles_select_self_or_org_member" on public.profiles
for select to authenticated using (
  id = (select auth.uid()) or exists (
    select 1 from public.memberships mine
    join public.memberships theirs on theirs.organization_id = mine.organization_id
    where mine.user_id = (select auth.uid()) and mine.status = 'active'
      and theirs.user_id = profiles.id and theirs.status = 'active'
  )
);
create policy "profiles_update_self" on public.profiles
for update to authenticated using (id = (select auth.uid())) with check (id = (select auth.uid()));

create policy "organizations_select_members" on public.organizations
for select to authenticated using (private.is_org_member(id));
create policy "organizations_insert_creator" on public.organizations
for insert to authenticated with check (created_by = (select auth.uid()));
create policy "organizations_update_admins" on public.organizations
for update to authenticated using (private.has_org_role(id, array['owner','admin'])) with check (private.has_org_role(id, array['owner','admin']));

create policy "memberships_select_org" on public.memberships
for select to authenticated using (private.is_org_member(organization_id));
create policy "memberships_manage_admins" on public.memberships
for all to authenticated using (private.has_org_role(organization_id, array['owner','admin']))
with check (private.has_org_role(organization_id, array['owner','admin']));

create policy "initiatives_org_access" on public.initiatives
for all to authenticated using (private.is_org_member(organization_id))
with check (private.is_org_member(organization_id));
create policy "work_packages_org_access" on public.work_packages
for all to authenticated using (private.is_org_member(organization_id))
with check (private.is_org_member(organization_id));
create policy "artifacts_org_access" on public.artifacts
for all to authenticated using (private.is_org_member(organization_id))
with check (private.is_org_member(organization_id));
create policy "evidence_org_access" on public.evidence_records
for all to authenticated using (private.is_org_member(organization_id))
with check (private.is_org_member(organization_id));
create policy "decisions_org_access" on public.decision_records
for all to authenticated using (private.is_org_member(organization_id))
with check (private.is_org_member(organization_id));
create policy "ip_assets_org_access" on public.ip_assets
for all to authenticated using (private.is_org_member(organization_id))
with check (private.is_org_member(organization_id));
create policy "relationships_org_access" on public.relationships
for all to authenticated using (private.is_org_member(organization_id))
with check (private.is_org_member(organization_id));
create policy "integrations_org_admins" on public.integration_connections
for all to authenticated using (private.has_org_role(organization_id, array['owner','admin']))
with check (private.has_org_role(organization_id, array['owner','admin']));
create policy "audit_events_read_members" on public.audit_events
for select to authenticated using (private.is_org_member(organization_id));
create policy "audit_events_insert_members" on public.audit_events
for insert to authenticated with check (
  private.is_org_member(organization_id)
  and (actor_user_id is null or actor_user_id = (select auth.uid()))
);

grant select, insert, update on public.organizations to authenticated;
grant select, insert, update, delete on public.initiatives, public.work_packages, public.artifacts,
  public.evidence_records, public.decision_records, public.ip_assets, public.relationships to authenticated;
grant select, insert, update, delete on public.memberships to authenticated;
grant select, insert on public.audit_events to authenticated;
grant select, insert, update on public.integration_connections to authenticated;
grant select, update on public.profiles to authenticated;

create or replace function private.handle_new_auth_user()
returns trigger
language plpgsql security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'name'))
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function private.handle_new_auth_user();
