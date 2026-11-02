-- Authenticated multi-tenant runtime tests for the 4TL4S P0 boundary.
-- Uses synthetic users and tenants only. Runs inside a transaction and rolls back.
-- These tests exercise RLS under authenticated role/JWT subject contexts; they
-- do not replace external API/session lifecycle tests or multi-session races.

BEGIN;

SELECT plan(10);

-- Synthetic identities: user A owns tenant A; user B owns tenant B;
-- user C is an admin in tenant A; user D is a target for escalation attempts.
INSERT INTO auth.users (id, raw_user_meta_data)
VALUES
  ('10000000-0000-4000-8000-000000000001', '{"name":"Tenant A Owner"}'::jsonb),
  ('20000000-0000-4000-8000-000000000002', '{"name":"Tenant B Owner"}'::jsonb),
  ('30000000-0000-4000-8000-000000000003', '{"name":"Tenant A Admin"}'::jsonb),
  ('40000000-0000-4000-8000-000000000004', '{"name":"Escalation Target"}'::jsonb)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.organizations (id, name, slug, created_by)
VALUES
  ('a0000000-0000-4000-8000-000000000001', 'Synthetic Tenant A', 'synthetic-tenant-a', '10000000-0000-4000-8000-000000000001'),
  ('b0000000-0000-4000-8000-000000000002', 'Synthetic Tenant B', 'synthetic-tenant-b', '20000000-0000-4000-8000-000000000002');

INSERT INTO public.memberships (organization_id, user_id, role, status)
VALUES
  ('a0000000-0000-4000-8000-000000000001', '30000000-0000-4000-8000-000000000003', 'admin', 'active');

INSERT INTO public.initiatives (id, organization_id, name, domain, status, created_by)
VALUES
  ('a1000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'Tenant A Initiative', 'product_development', 'active', '10000000-0000-4000-8000-000000000001'),
  ('b1000000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000002', 'Tenant B Initiative', 'product_development', 'active', '20000000-0000-4000-8000-000000000002');

SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub', '10000000-0000-4000-8000-000000000001', true);

SELECT is(
  (SELECT count(*)::integer FROM public.initiatives
   WHERE id IN (
     'a1000000-0000-4000-8000-000000000001',
     'b1000000-0000-4000-8000-000000000002'
   )),
  1,
  'Tenant A owner can read only the initiative in tenant A'
);

SELECT is(
  (SELECT count(*)::integer FROM public.initiatives
   WHERE id = 'b1000000-0000-4000-8000-000000000002'),
  0,
  'Tenant A owner cannot read tenant B initiative by direct identifier'
);

SELECT throws_ok(
  $$INSERT INTO public.initiatives
      (organization_id, name, domain, created_by)
    VALUES
      ('b0000000-0000-4000-8000-000000000002',
       'Cross-tenant injection',
       'product_development',
       '10000000-0000-4000-8000-000000000001')$$,
  '42501',
  NULL,
  'Tenant A owner cannot insert an initiative into tenant B'
);

SELECT is(
  (WITH changed AS (
     UPDATE public.initiatives
        SET name = 'Unauthorized tenant B mutation'
      WHERE id = 'b1000000-0000-4000-8000-000000000002'
      RETURNING 1
   )
   SELECT count(*)::integer FROM changed),
  0,
  'Tenant A owner cannot update tenant B initiative'
);

SELECT is(
  (WITH removed AS (
     DELETE FROM public.initiatives
      WHERE id = 'b1000000-0000-4000-8000-000000000002'
      RETURNING 1
   )
   SELECT count(*)::integer FROM removed),
  0,
  'Tenant A owner cannot delete tenant B initiative'
);

SELECT throws_ok(
  $$INSERT INTO public.work_packages
      (organization_id, initiative_id, title, created_by)
    VALUES
      ('a0000000-0000-4000-8000-000000000001',
       'b1000000-0000-4000-8000-000000000002',
       'Cross-tenant parent reference',
       '10000000-0000-4000-8000-000000000001')$$,
  '23503',
  NULL,
  'Composite tenant foreign key rejects a parent from another tenant'
);

SELECT is(
  (WITH inserted AS (
     INSERT INTO public.initiatives
       (organization_id, name, domain, status, created_by)
     VALUES
       ('a0000000-0000-4000-8000-000000000001',
        'Authorized tenant A write',
        'product_development',
        'active',
        '10000000-0000-4000-8000-000000000001')
     RETURNING 1
   )
   SELECT count(*)::integer FROM inserted),
  1,
  'Tenant A owner can write within tenant A'
);

SELECT throws_ok(
  $$INSERT INTO public.audit_events
      (organization_id, actor_user_id, event_type, entity_type, entity_id)
    VALUES
      ('a0000000-0000-4000-8000-000000000001',
       '10000000-0000-4000-8000-000000000001',
       'test.untrusted',
       'initiative',
       'a1000000-0000-4000-8000-000000000001')$$,
  '42501',
  NULL,
  'Authenticated client cannot directly fabricate audit events'
);

SELECT set_config('request.jwt.claim.sub', '20000000-0000-4000-8000-000000000002', true);

SELECT is(
  (SELECT count(*)::integer FROM public.initiatives
   WHERE id IN (
     'a1000000-0000-4000-8000-000000000001',
     'b1000000-0000-4000-8000-000000000002'
   )),
  1,
  'Switching JWT subject to tenant B exposes only tenant B initiative'
);

SELECT set_config('request.jwt.claim.sub', '30000000-0000-4000-8000-000000000003', true);

SELECT throws_ok(
  $$INSERT INTO public.memberships
      (organization_id, user_id, role, status)
    VALUES
      ('a0000000-0000-4000-8000-000000000001',
       '40000000-0000-4000-8000-000000000004',
       'owner',
       'active')$$,
  '42501',
  NULL,
  'Tenant admin cannot grant owner authority'
);

RESET ROLE;

SELECT * FROM finish();

ROLLBACK;
