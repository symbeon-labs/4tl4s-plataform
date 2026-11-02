
-- 4TL4S P0 integrity and authority hardening.
-- Additive migration: preserves existing rows and the initial schema.

BEGIN;

-- 1) Tenant-scoped candidate keys for composite foreign keys.
ALTER TABLE public.initiatives
  ADD CONSTRAINT initiatives_org_id_id_key UNIQUE (organization_id, id);
ALTER TABLE public.work_packages
  ADD CONSTRAINT work_packages_org_id_id_key UNIQUE (organization_id, id);
ALTER TABLE public.artifacts
  ADD CONSTRAINT artifacts_org_id_id_key UNIQUE (organization_id, id);
ALTER TABLE public.decision_records
  ADD CONSTRAINT decision_records_org_id_id_key UNIQUE (organization_id, id);

-- 2) Enforce same-tenant parent/child references.
ALTER TABLE public.work_packages
  ADD CONSTRAINT work_packages_org_initiative_fkey
  FOREIGN KEY (organization_id, initiative_id)
  REFERENCES public.initiatives (organization_id, id)
  ON DELETE CASCADE;

ALTER TABLE public.artifacts
  ADD CONSTRAINT artifacts_org_initiative_fkey
  FOREIGN KEY (organization_id, initiative_id)
  REFERENCES public.initiatives (organization_id, id)
  ON DELETE SET NULL (initiative_id),
  ADD CONSTRAINT artifacts_org_work_package_fkey
  FOREIGN KEY (organization_id, work_package_id)
  REFERENCES public.work_packages (organization_id, id)
  ON DELETE SET NULL (work_package_id);

ALTER TABLE public.evidence_records
  ADD CONSTRAINT evidence_org_initiative_fkey
  FOREIGN KEY (organization_id, initiative_id)
  REFERENCES public.initiatives (organization_id, id)
  ON DELETE SET NULL (initiative_id),
  ADD CONSTRAINT evidence_org_artifact_fkey
  FOREIGN KEY (organization_id, artifact_id)
  REFERENCES public.artifacts (organization_id, id)
  ON DELETE SET NULL (artifact_id);

ALTER TABLE public.decision_records
  ADD CONSTRAINT decisions_org_initiative_fkey
  FOREIGN KEY (organization_id, initiative_id)
  REFERENCES public.initiatives (organization_id, id)
  ON DELETE SET NULL (initiative_id),
  ADD CONSTRAINT decisions_org_supersedes_fkey
  FOREIGN KEY (organization_id, supersedes_id)
  REFERENCES public.decision_records (organization_id, id)
  ON DELETE SET NULL (supersedes_id);

ALTER TABLE public.ip_assets
  ADD CONSTRAINT ip_assets_org_initiative_fkey
  FOREIGN KEY (organization_id, initiative_id)
  REFERENCES public.initiatives (organization_id, id)
  ON DELETE SET NULL (initiative_id);

-- Supporting indexes for the new composite foreign keys.
CREATE INDEX work_packages_org_initiative_idx
  ON public.work_packages (organization_id, initiative_id);
CREATE INDEX artifacts_org_initiative_idx
  ON public.artifacts (organization_id, initiative_id);
CREATE INDEX artifacts_org_work_package_idx
  ON public.artifacts (organization_id, work_package_id);
CREATE INDEX evidence_org_initiative_idx
  ON public.evidence_records (organization_id, initiative_id);
CREATE INDEX evidence_org_artifact_idx
  ON public.evidence_records (organization_id, artifact_id);
CREATE INDEX decisions_org_initiative_idx
  ON public.decision_records (organization_id, initiative_id);
CREATE INDEX decisions_org_supersedes_idx
  ON public.decision_records (organization_id, supersedes_id);
CREATE INDEX ip_assets_org_initiative_idx
  ON public.ip_assets (organization_id, initiative_id);

-- 3) Validate typed relationship endpoints and lock referenced rows against
-- concurrent deletion while a relationship is being recorded.
CREATE OR REPLACE FUNCTION private.assert_relationship_endpoint(
  entity_type text,
  entity_id uuid,
  tenant_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
BEGIN
  CASE entity_type
    WHEN 'initiative' THEN
      PERFORM 1 FROM public.initiatives
       WHERE id = entity_id AND organization_id = tenant_id
       FOR KEY SHARE;
    WHEN 'work_package' THEN
      PERFORM 1 FROM public.work_packages
       WHERE id = entity_id AND organization_id = tenant_id
       FOR KEY SHARE;
    WHEN 'artifact' THEN
      PERFORM 1 FROM public.artifacts
       WHERE id = entity_id AND organization_id = tenant_id
       FOR KEY SHARE;
    WHEN 'evidence_record' THEN
      PERFORM 1 FROM public.evidence_records
       WHERE id = entity_id AND organization_id = tenant_id
       FOR KEY SHARE;
    WHEN 'decision_record' THEN
      PERFORM 1 FROM public.decision_records
       WHERE id = entity_id AND organization_id = tenant_id
       FOR KEY SHARE;
    WHEN 'ip_asset' THEN
      PERFORM 1 FROM public.ip_assets
       WHERE id = entity_id AND organization_id = tenant_id
       FOR KEY SHARE;
    WHEN 'integration_connection' THEN
      PERFORM 1 FROM public.integration_connections
       WHERE id = entity_id AND organization_id = tenant_id
       FOR KEY SHARE;
    ELSE
      RAISE EXCEPTION 'Unsupported relationship entity type: %', entity_type
        USING ERRCODE = '22023';
  END CASE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Relationship endpoint does not exist in this organization'
      USING ERRCODE = '23503';
  END IF;
END;
$function$;

CREATE OR REPLACE FUNCTION private.validate_relationship_endpoints()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
BEGIN
  PERFORM private.assert_relationship_endpoint(
    NEW.source_type, NEW.source_id, NEW.organization_id
  );
  PERFORM private.assert_relationship_endpoint(
    NEW.target_type, NEW.target_id, NEW.organization_id
  );
  RETURN NEW;
END;
$function$;

REVOKE ALL ON FUNCTION private.assert_relationship_endpoint(text, uuid, uuid) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION private.validate_relationship_endpoints() FROM PUBLIC, anon, authenticated;

DROP TRIGGER IF EXISTS relationships_validate_endpoints ON public.relationships;
CREATE TRIGGER relationships_validate_endpoints
BEFORE INSERT OR UPDATE OF organization_id, source_type, source_id, target_type, target_id
ON public.relationships
FOR EACH ROW
EXECUTE FUNCTION private.validate_relationship_endpoints();

-- 4) Membership authority boundaries.
DROP POLICY IF EXISTS memberships_manage_admins ON public.memberships;

-- Existing members may inspect the membership roster; only owners/admins
-- may mutate ordinary memberships, and only owners may mutate privileged roles.
CREATE POLICY memberships_owner_insert
ON public.memberships FOR INSERT TO authenticated
WITH CHECK (private.has_org_role(organization_id, ARRAY['owner']));

CREATE POLICY memberships_owner_update
ON public.memberships FOR UPDATE TO authenticated
USING (private.has_org_role(organization_id, ARRAY['owner']))
WITH CHECK (private.has_org_role(organization_id, ARRAY['owner']));

CREATE POLICY memberships_owner_delete
ON public.memberships FOR DELETE TO authenticated
USING (private.has_org_role(organization_id, ARRAY['owner']));

CREATE POLICY memberships_admin_insert_nonprivileged
ON public.memberships FOR INSERT TO authenticated
WITH CHECK (
  private.has_org_role(organization_id, ARRAY['admin'])
  AND role NOT IN ('owner', 'admin')
);

CREATE POLICY memberships_admin_update_nonprivileged
ON public.memberships FOR UPDATE TO authenticated
USING (
  private.has_org_role(organization_id, ARRAY['admin'])
  AND role NOT IN ('owner', 'admin')
)
WITH CHECK (
  private.has_org_role(organization_id, ARRAY['admin'])
  AND role NOT IN ('owner', 'admin')
);

CREATE POLICY memberships_admin_delete_nonprivileged
ON public.memberships FOR DELETE TO authenticated
USING (
  private.has_org_role(organization_id, ARRAY['admin'])
  AND role NOT IN ('owner', 'admin')
);

-- Prevent moving membership identities between users/tenants and protect
-- the final active owner. Organization-row locking serializes concurrent
-- attempts to demote/delete multiple owners in the same tenant.
CREATE OR REPLACE FUNCTION private.guard_membership_invariants()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  locked_org uuid;
  active_owner_count bigint;
  removes_active_owner boolean;
BEGIN
  IF TG_OP = 'UPDATE' THEN
    IF NEW.organization_id IS DISTINCT FROM OLD.organization_id
       OR NEW.user_id IS DISTINCT FROM OLD.user_id THEN
      RAISE EXCEPTION 'Membership organization_id and user_id are immutable'
        USING ERRCODE = '23514';
    END IF;
    removes_active_owner :=
      OLD.role = 'owner' AND OLD.status = 'active'
      AND NOT (NEW.role = 'owner' AND NEW.status = 'active');
  ELSE
    removes_active_owner := OLD.role = 'owner' AND OLD.status = 'active';
  END IF;

  IF removes_active_owner THEN
    SELECT id INTO locked_org
      FROM public.organizations
     WHERE id = OLD.organization_id
     FOR UPDATE;

    SELECT count(*) INTO active_owner_count
      FROM public.memberships
     WHERE organization_id = OLD.organization_id
       AND role = 'owner'
       AND status = 'active';

    IF active_owner_count <= 1 THEN
      RAISE EXCEPTION 'Cannot remove or deactivate the last active organization owner'
        USING ERRCODE = '23514';
    END IF;
  END IF;

  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$function$;

REVOKE ALL ON FUNCTION private.guard_membership_invariants() FROM PUBLIC, anon, authenticated;

DROP TRIGGER IF EXISTS memberships_guard_invariants ON public.memberships;
CREATE TRIGGER memberships_guard_invariants
BEFORE UPDATE OR DELETE ON public.memberships
FOR EACH ROW
EXECUTE FUNCTION private.guard_membership_invariants();

-- Organization identity/creator provenance must not be rewritten after creation.
CREATE OR REPLACE FUNCTION private.guard_organization_identity()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
BEGIN
  IF NEW.id IS DISTINCT FROM OLD.id
     OR NEW.created_by IS DISTINCT FROM OLD.created_by THEN
    RAISE EXCEPTION 'Organization id and created_by are immutable'
      USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END;
$function$;

REVOKE ALL ON FUNCTION private.guard_organization_identity() FROM PUBLIC, anon, authenticated;

DROP TRIGGER IF EXISTS organizations_guard_identity ON public.organizations;
CREATE TRIGGER organizations_guard_identity
BEFORE UPDATE ON public.organizations
FOR EACH ROW
EXECUTE FUNCTION private.guard_organization_identity();

COMMIT;
