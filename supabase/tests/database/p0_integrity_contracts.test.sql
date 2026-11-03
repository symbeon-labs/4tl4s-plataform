-- pgTAP contract tests for the 4TL4S P0 database hardening.
-- These tests inspect installed schema contracts; they do not substitute for
-- authenticated multi-tenant runtime tests with distinct JWT identities.

BEGIN;

SELECT plan(14);

SELECT is(
  (SELECT count(*)::integer
   FROM pg_class c
   JOIN pg_namespace n ON n.oid = c.relnamespace
   WHERE n.nspname = 'public'
     AND c.relkind = 'r'
     AND c.relrowsecurity),
  12,
  'RLS is enabled on all 12 public tables'
);

SELECT ok(
  (SELECT count(*) = 8
   FROM pg_constraint
   WHERE connamespace = 'public'::regnamespace
     AND conname IN (
       'work_packages_org_initiative_fkey',
       'artifacts_org_initiative_fkey',
       'artifacts_org_work_package_fkey',
       'evidence_org_initiative_fkey',
       'evidence_org_artifact_fkey',
       'decisions_org_initiative_fkey',
       'decisions_org_supersedes_fkey',
       'ip_assets_org_initiative_fkey'
     )),
  'All eight tenant-scoped parent foreign keys are installed'
);

SELECT ok(
  (SELECT count(*) = 4
   FROM pg_constraint
   WHERE connamespace = 'public'::regnamespace
     AND contype = 'u'
     AND conname IN (
       'initiatives_org_id_id_key',
       'work_packages_org_id_id_key',
       'artifacts_org_id_id_key',
       'decision_records_org_id_id_key'
     )),
  'All four tenant-scoped unique keys are installed'
);

SELECT ok(
  EXISTS (
    SELECT 1
    FROM pg_trigger t
    JOIN pg_class c ON c.oid = t.tgrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public'
      AND c.relname = 'relationships'
      AND t.tgname = 'relationships_validate_endpoints'
      AND NOT t.tgisinternal
  ),
  'Relationship endpoint validation trigger is installed'
);

SELECT ok(
  EXISTS (
    SELECT 1 FROM pg_trigger t
    JOIN pg_class c ON c.oid = t.tgrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public'
      AND c.relname = 'memberships'
      AND t.tgname = 'memberships_guard_invariants'
      AND NOT t.tgisinternal
  ),
  'Membership invariant trigger is installed'
);

SELECT ok(
  EXISTS (
    SELECT 1 FROM pg_trigger t
    JOIN pg_class c ON c.oid = t.tgrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public'
      AND c.relname = 'organizations'
      AND t.tgname = 'organizations_guard_identity'
      AND NOT t.tgisinternal
  ),
  'Organization identity trigger is installed'
);

SELECT is(
  (SELECT count(*)::integer
   FROM pg_policies
   WHERE schemaname = 'public'
     AND tablename = 'memberships'),
  4,
  'Memberships has one SELECT policy and three consolidated mutation policies'
);

SELECT is(
  (SELECT count(*)::integer
   FROM (
     SELECT tablename, roles, cmd
     FROM pg_policies
     WHERE schemaname = 'public'
     GROUP BY tablename, roles, cmd
     HAVING count(*) > 1
   ) duplicate_permissive_policy_groups),
  0,
  'No duplicate permissive policy groups remain in public schema'
);

SELECT ok(
  (SELECT bool_and(
      prosecdef
      AND coalesce(array_to_string(proconfig, ','), '') LIKE '%search_path=%'
    )
   FROM pg_proc p
   JOIN pg_namespace n ON n.oid = p.pronamespace
   WHERE n.nspname = 'private'
     AND p.proname IN (
       'assert_relationship_endpoint',
       'validate_relationship_endpoints',
       'guard_membership_invariants',
       'guard_organization_identity'
     )),
  'New private trigger functions are SECURITY DEFINER with explicit search_path'
);

SELECT ok(
  NOT has_function_privilege(
    'authenticated',
    'private.assert_relationship_endpoint(text,uuid,uuid)',
    'EXECUTE'
  ),
  'Authenticated role cannot directly execute relationship endpoint helper'
);

SELECT ok(
  NOT has_function_privilege(
    'authenticated',
    'private.guard_membership_invariants()',
    'EXECUTE'
  ),
  'Authenticated role cannot directly execute membership trigger helper'
);

SELECT ok(
  NOT has_function_privilege(
    'authenticated',
    'private.guard_organization_identity()',
    'EXECUTE'
  ),
  'Authenticated role cannot directly execute organization trigger helper'
);

SELECT ok(
  NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'audit_events'
      AND cmd = 'INSERT'
      AND 'authenticated' = ANY(roles::text[])
  ),
  'Authenticated clients have no direct audit-event INSERT policy'
);

SELECT ok(
  NOT has_table_privilege('authenticated', 'public.audit_events', 'INSERT'),
  'Authenticated role has no direct audit-event INSERT grant'
);

SELECT * FROM finish();

ROLLBACK;
