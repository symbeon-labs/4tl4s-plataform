-- 4TL4S P0: prevent authenticated clients from fabricating audit events.
DROP POLICY IF EXISTS audit_events_insert_members ON public.audit_events;
REVOKE INSERT ON TABLE public.audit_events FROM anon, authenticated;

-- Cover foreign-key columns flagged by Supabase Performance Advisor.
CREATE INDEX IF NOT EXISTS artifacts_created_by_idx ON public.artifacts (created_by);
CREATE INDEX IF NOT EXISTS audit_events_actor_user_id_idx ON public.audit_events (actor_user_id);
CREATE INDEX IF NOT EXISTS decision_records_decided_by_idx ON public.decision_records (decided_by);
CREATE INDEX IF NOT EXISTS evidence_records_recorded_by_idx ON public.evidence_records (recorded_by);
CREATE INDEX IF NOT EXISTS initiatives_created_by_idx ON public.initiatives (created_by);
CREATE INDEX IF NOT EXISTS initiatives_owner_user_id_idx ON public.initiatives (owner_user_id);
CREATE INDEX IF NOT EXISTS integration_connections_created_by_idx ON public.integration_connections (created_by);
CREATE INDEX IF NOT EXISTS ip_assets_recorded_by_idx ON public.ip_assets (recorded_by);
CREATE INDEX IF NOT EXISTS organizations_created_by_idx ON public.organizations (created_by);
CREATE INDEX IF NOT EXISTS relationships_created_by_idx ON public.relationships (created_by);
CREATE INDEX IF NOT EXISTS work_packages_assignee_user_id_idx ON public.work_packages (assignee_user_id);
CREATE INDEX IF NOT EXISTS work_packages_created_by_idx ON public.work_packages (created_by);
