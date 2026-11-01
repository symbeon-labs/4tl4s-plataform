-- PROPOSED ONLY — Organizational Unit scoped access for 4TL4S.
-- Do not apply until ADR-0005 and the domain/security contracts are approved,
-- the migration is reviewed, and authenticated runtime tests pass.
--
-- Access policy selected for this proposal:
--   * unassigned (unit_id IS NULL) initiatives remain visible to active org members;
--   * unit-scoped initiatives require an explicit active unit_membership;
--   * organization owner/admin roles manage unit structure but do not inherit
--     content access to unit-scoped initiatives;
--   * descendants inherit their Initiative scope.
--
-- This file is stored under supabase/proposals, not supabase/migrations.

BEGIN;

CREATE TABLE public.organizational_units (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  parent_unit_id uuid,
  name text NOT NULL CHECK (length(trim(name)) BETWEEN 2 AND 160),
  slug text NOT NULL CHECK (slug ~ '^[a-z0-9][a-z0-9-]{1,62}$'),
  unit_type text NOT NULL,
  description text,
  lifecycle_state text NOT NULL DEFAULT 'proposed'
    CHECK (lifecycle_state IN ('proposed','active','suspended','archived')),
  source_state text NOT NULL DEFAULT 'declared'
    CHECK (source_state IN ('declared','observed','documented','verified','conflicted','unknown')),
  source_reference jsonb,
  created_by uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT organizational_units_org_id_id_key UNIQUE (organization_id, id),
  CONSTRAINT organizational_units_org_slug_key UNIQUE (organization_id, slug),
  CONSTRAINT organizational_units_parent_same_org_fkey
    FOREIGN KEY (organization_id, parent_unit_id)
    REFERENCES public.organizational_units (organization_id, id)
    ON DELETE RESTRICT,
  CONSTRAINT organizational_units_not_own_parent
    CHECK (parent_unit_id IS NULL OR parent_unit_id <> id)
);

CREATE TABLE public.unit_memberships (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL,
  organizational_unit_id uuid NOT NULL,
  user_id uuid NOT NULL,
  role text NOT NULL CHECK (role IN ('unit_admin','unit_manager','contributor','reviewer','viewer')),
  status text NOT NULL DEFAULT 'invited'
    CHECK (status IN ('invited','active','suspended','revoked')),
  granted_by uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT unit_memberships_org_unit_user_key
    UNIQUE (organization_id, organizational_unit_id, user_id),
  CONSTRAINT unit_memberships_unit_same_org_fkey
    FOREIGN KEY (organization_id, organizational_unit_id)
    REFERENCES public.organizational_units (organization_id, id)
    ON DELETE RESTRICT,
  CONSTRAINT unit_memberships_org_user_fkey
    FOREIGN KEY (organization_id, user_id)
    REFERENCES public.memberships (organization_id, user_id)
    ON DELETE CASCADE
);

ALTER TABLE public.initiatives
  ADD COLUMN organizational_unit_id uuid,
  ADD CONSTRAINT initiatives_org_unit_fkey
    FOREIGN KEY (organization_id, organizational_unit_id)
    REFERENCES public.organizational_units (organization_id, id)
    ON DELETE RESTRICT;

CREATE INDEX organizational_units_org_state_idx
  ON public.organizational_units (organization_id, lifecycle_state);
CREATE INDEX unit_memberships_user_scope_idx
  ON public.unit_memberships (organization_id, user_id, organizational_unit_id, status);
CREATE INDEX initiatives_org_unit_status_idx
  ON public.initiatives (organization_id, organizational_unit_id, status);

-- Prevent cycles and immutable tenant/identity provenance.
CREATE OR REPLACE FUNCTION private.guard_organizational_unit()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  cycle_found boolean;
BEGIN
  IF TG_OP = 'UPDATE' THEN
    IF NEW.id IS DISTINCT FROM OLD.id
       OR NEW.organization_id IS DISTINCT FROM OLD.organization_id
       OR NEW.created_by IS DISTINCT FROM OLD.created_by THEN
      RAISE EXCEPTION 'Organizational unit identity, tenant and creator are immutable'
        USING ERRCODE = '23514';
    END IF;
  END IF;

  IF NEW.parent_unit_id IS NOT NULL THEN
    WITH RECURSIVE ancestors(id, parent_unit_id) AS (
      SELECT u.id, u.parent_unit_id
      FROM public.organizational_units u
      WHERE u.organization_id = NEW.organization_id
        AND u.id = NEW.parent_unit_id
      UNION ALL
      SELECT p.id, p.parent_unit_id
      FROM public.organizational_units p
      JOIN ancestors a ON p.id = a.parent_unit_id
      WHERE p.organization_id = NEW.organization_id
    )
    SELECT EXISTS (
      SELECT 1 FROM ancestors
      WHERE id = NEW.id
    ) INTO cycle_found;

    IF cycle_found THEN
      RAISE EXCEPTION 'Organizational unit hierarchy cannot contain cycles'
        USING ERRCODE = '23514';
    END IF;
  END IF;

  RETURN NEW;
END;
$function$;

REVOKE ALL ON FUNCTION private.guard_organizational_unit() FROM PUBLIC, anon, authenticated;

CREATE TRIGGER organizational_units_guard
BEFORE INSERT OR UPDATE ON public.organizational_units
FOR EACH ROW EXECUTE FUNCTION private.guard_organizational_unit();

-- Authorization helpers are SECURITY DEFINER to avoid RLS recursion.
CREATE OR REPLACE FUNCTION private.has_active_unit_membership(
  target_org uuid,
  target_unit uuid
)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = ''
AS $function$
  SELECT EXISTS (
    SELECT 1
    FROM public.memberships om
    JOIN public.unit_memberships um
      ON um.organization_id = om.organization_id
     AND um.user_id = om.user_id
    WHERE om.organization_id = target_org
      AND um.organizational_unit_id = target_unit
      AND om.user_id = (SELECT auth.uid())
      AND om.status = 'active'
      AND um.status = 'active'
  );
$function$;

CREATE OR REPLACE FUNCTION private.has_unit_write_role(
  target_org uuid,
  target_unit uuid
)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = ''
AS $function$
  SELECT EXISTS (
    SELECT 1
    FROM public.memberships om
    JOIN public.unit_memberships um
      ON um.organization_id = om.organization_id
     AND um.user_id = om.user_id
    WHERE om.organization_id = target_org
      AND um.organizational_unit_id = target_unit
      AND om.user_id = (SELECT auth.uid())
      AND om.status = 'active'
      AND um.status = 'active'
      AND um.role IN ('unit_admin','unit_manager','contributor')
  );
$function$;

CREATE OR REPLACE FUNCTION private.can_access_initiative(
  target_org uuid,
  target_initiative uuid,
  write_access boolean DEFAULT false
)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = ''
AS $function$
  SELECT CASE
    WHEN NOT private.is_org_member(target_org) THEN false
    WHEN target_initiative IS NULL THEN true
    WHEN NOT EXISTS (
      SELECT 1 FROM public.initiatives i
      WHERE i.organization_id = target_org AND i.id = target_initiative
    ) THEN false
    WHEN (
      SELECT i.organizational_unit_id
      FROM public.initiatives i
      WHERE i.organization_id = target_org AND i.id = target_initiative
    ) IS NULL THEN true
    WHEN write_access THEN private.has_unit_write_role(
      target_org,
      (SELECT i.organizational_unit_id FROM public.initiatives i
       WHERE i.organization_id = target_org AND i.id = target_initiative)
    )
    ELSE private.has_active_unit_membership(
      target_org,
      (SELECT i.organizational_unit_id FROM public.initiatives i
       WHERE i.organization_id = target_org AND i.id = target_initiative)
    )
  END;
$function$;

CREATE OR REPLACE FUNCTION private.can_access_artifact(
  target_org uuid,
  target_artifact uuid,
  write_access boolean DEFAULT false
)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = ''
AS $function$
  SELECT CASE
    WHEN NOT private.is_org_member(target_org) THEN false
    WHEN NOT EXISTS (
      SELECT 1 FROM public.artifacts a
      WHERE a.organization_id = target_org AND a.id = target_artifact
    ) THEN false
    ELSE private.can_access_initiative(
      target_org,
      COALESCE(
        (SELECT a.initiative_id FROM public.artifacts a
         WHERE a.organization_id = target_org AND a.id = target_artifact),
        (SELECT wp.initiative_id
         FROM public.artifacts a
         JOIN public.work_packages wp
           ON wp.organization_id = a.organization_id
          AND wp.id = a.work_package_id
         WHERE a.organization_id = target_org AND a.id = target_artifact)
      ),
      write_access
    )
  END;
$function$;

REVOKE ALL ON FUNCTION private.has_active_unit_membership(uuid,uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION private.has_unit_write_role(uuid,uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION private.can_access_initiative(uuid,uuid,boolean) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION private.can_access_artifact(uuid,uuid,boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION private.has_active_unit_membership(uuid,uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION private.has_unit_write_role(uuid,uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION private.can_access_initiative(uuid,uuid,boolean) TO authenticated;
GRANT EXECUTE ON FUNCTION private.can_access_artifact(uuid,uuid,boolean) TO authenticated;

ALTER TABLE public.organizational_units ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.unit_memberships ENABLE ROW LEVEL SECURITY;

CREATE POLICY organizational_units_select
ON public.organizational_units FOR SELECT TO authenticated
USING (
  private.is_org_member(organization_id)
  AND (
    private.has_org_role(organization_id, ARRAY['owner','admin'])
    OR private.has_active_unit_membership(organization_id, id)
  )
);

CREATE POLICY organizational_units_insert
ON public.organizational_units FOR INSERT TO authenticated
WITH CHECK (private.has_org_role(organization_id, ARRAY['owner','admin']));

CREATE POLICY organizational_units_update
ON public.organizational_units FOR UPDATE TO authenticated
USING (private.has_org_role(organization_id, ARRAY['owner','admin']))
WITH CHECK (private.has_org_role(organization_id, ARRAY['owner','admin']));

CREATE POLICY organizational_units_delete
ON public.organizational_units FOR DELETE TO authenticated
USING (false);

CREATE POLICY unit_memberships_select
ON public.unit_memberships FOR SELECT TO authenticated
USING (
  private.has_active_unit_membership(organization_id, organizational_unit_id)
  OR private.has_org_role(organization_id, ARRAY['owner','admin'])
);

CREATE POLICY unit_memberships_insert
ON public.unit_memberships FOR INSERT TO authenticated
WITH CHECK (
  private.has_org_role(organization_id, ARRAY['owner','admin'])
  OR (
    private.has_unit_write_role(organization_id, organizational_unit_id)
    AND role <> 'unit_admin'
  )
);

CREATE POLICY unit_memberships_update
ON public.unit_memberships FOR UPDATE TO authenticated
USING (
  private.has_org_role(organization_id, ARRAY['owner','admin'])
  OR (
    private.has_unit_write_role(organization_id, organizational_unit_id)
    AND role <> 'unit_admin'
  )
)
WITH CHECK (
  private.has_org_role(organization_id, ARRAY['owner','admin'])
  OR (
    private.has_unit_write_role(organization_id, organizational_unit_id)
    AND role <> 'unit_admin'
  )
);

CREATE POLICY unit_memberships_delete
ON public.unit_memberships FOR DELETE TO authenticated
USING (
  private.has_org_role(organization_id, ARRAY['owner','admin'])
  OR (
    private.has_unit_write_role(organization_id, organizational_unit_id)
    AND role <> 'unit_admin'
  )
);

-- Replace broad tenant-only content policies with scope-aware policies.
DROP POLICY IF EXISTS initiatives_org_access ON public.initiatives;
CREATE POLICY initiatives_scoped_access
ON public.initiatives FOR ALL TO authenticated
USING (private.can_access_initiative(organization_id, id, false))
WITH CHECK (private.can_access_initiative(organization_id, id, true));

DROP POLICY IF EXISTS work_packages_org_access ON public.work_packages;
CREATE POLICY work_packages_scoped_access
ON public.work_packages FOR ALL TO authenticated
USING (private.can_access_initiative(organization_id, initiative_id, false))
WITH CHECK (private.can_access_initiative(organization_id, initiative_id, true));

DROP POLICY IF EXISTS artifacts_org_access ON public.artifacts;
CREATE POLICY artifacts_scoped_access
ON public.artifacts FOR ALL TO authenticated
USING (private.is_org_member(organization_id)
  AND (
    (initiative_id IS NOT NULL AND private.can_access_initiative(organization_id, initiative_id, false))
    OR (initiative_id IS NULL AND work_package_id IS NOT NULL
        AND EXISTS (
          SELECT 1 FROM public.work_packages wp
          WHERE wp.organization_id = artifacts.organization_id
            AND wp.id = artifacts.work_package_id
            AND private.can_access_initiative(wp.organization_id, wp.initiative_id, false)
        ))
    OR (initiative_id IS NULL AND work_package_id IS NULL)
  ))
WITH CHECK (private.is_org_member(organization_id)
  AND (
    (initiative_id IS NOT NULL AND private.can_access_initiative(organization_id, initiative_id, true))
    OR (initiative_id IS NULL AND work_package_id IS NOT NULL
        AND EXISTS (
          SELECT 1 FROM public.work_packages wp
          WHERE wp.organization_id = artifacts.organization_id
            AND wp.id = artifacts.work_package_id
            AND private.can_access_initiative(wp.organization_id, wp.initiative_id, true)
        ))
    OR (initiative_id IS NULL AND work_package_id IS NULL)
  ));

DROP POLICY IF EXISTS evidence_org_access ON public.evidence_records;
CREATE POLICY evidence_scoped_access
ON public.evidence_records FOR ALL TO authenticated
USING (private.is_org_member(organization_id)
  AND (
    (initiative_id IS NOT NULL AND private.can_access_initiative(organization_id, initiative_id, false))
    OR (initiative_id IS NULL AND artifact_id IS NOT NULL
        AND private.can_access_artifact(organization_id, artifact_id, false))
    OR (initiative_id IS NULL AND artifact_id IS NULL)
  ))
WITH CHECK (private.is_org_member(organization_id)
  AND (
    (initiative_id IS NOT NULL AND private.can_access_initiative(organization_id, initiative_id, true))
    OR (initiative_id IS NULL AND artifact_id IS NOT NULL
        AND private.can_access_artifact(organization_id, artifact_id, true))
    OR (initiative_id IS NULL AND artifact_id IS NULL)
  ));

DROP POLICY IF EXISTS decisions_org_access ON public.decision_records;
CREATE POLICY decisions_scoped_access
ON public.decision_records FOR ALL TO authenticated
USING (
  private.is_org_member(organization_id)
  AND private.can_access_initiative(organization_id, initiative_id, false)
)
WITH CHECK (
  private.is_org_member(organization_id)
  AND private.can_access_initiative(organization_id, initiative_id, true)
);

DROP POLICY IF EXISTS ip_assets_org_access ON public.ip_assets;
CREATE POLICY ip_assets_scoped_access
ON public.ip_assets FOR ALL TO authenticated
USING (
  private.is_org_member(organization_id)
  AND private.can_access_initiative(organization_id, initiative_id, false)
)
WITH CHECK (
  private.is_org_member(organization_id)
  AND private.can_access_initiative(organization_id, initiative_id, true)
);

-- Relationships are conservatively tenant-member visible in this proposal.
-- Before production, relationship endpoint authorization must be tightened
-- so edges cannot disclose unit-scoped entity identities or relationships.

GRANT SELECT, INSERT, UPDATE ON public.organizational_units TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.unit_memberships TO authenticated;

COMMIT;
