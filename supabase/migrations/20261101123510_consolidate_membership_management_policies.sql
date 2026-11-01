BEGIN;

DROP POLICY IF EXISTS memberships_owner_insert ON public.memberships;
DROP POLICY IF EXISTS memberships_admin_insert_nonprivileged ON public.memberships;
DROP POLICY IF EXISTS memberships_owner_update ON public.memberships;
DROP POLICY IF EXISTS memberships_admin_update_nonprivileged ON public.memberships;
DROP POLICY IF EXISTS memberships_owner_delete ON public.memberships;
DROP POLICY IF EXISTS memberships_admin_delete_nonprivileged ON public.memberships;

CREATE POLICY memberships_managers_insert
ON public.memberships FOR INSERT TO authenticated
WITH CHECK (
  private.has_org_role(organization_id, ARRAY['owner'])
  OR (
    private.has_org_role(organization_id, ARRAY['admin'])
    AND role NOT IN ('owner', 'admin')
  )
);

CREATE POLICY memberships_managers_update
ON public.memberships FOR UPDATE TO authenticated
USING (
  private.has_org_role(organization_id, ARRAY['owner'])
  OR (
    private.has_org_role(organization_id, ARRAY['admin'])
    AND role NOT IN ('owner', 'admin')
  )
)
WITH CHECK (
  private.has_org_role(organization_id, ARRAY['owner'])
  OR (
    private.has_org_role(organization_id, ARRAY['admin'])
    AND role NOT IN ('owner', 'admin')
  )
);

CREATE POLICY memberships_managers_delete
ON public.memberships FOR DELETE TO authenticated
USING (
  private.has_org_role(organization_id, ARRAY['owner'])
  OR (
    private.has_org_role(organization_id, ARRAY['admin'])
    AND role NOT IN ('owner', 'admin')
  )
);

COMMIT;