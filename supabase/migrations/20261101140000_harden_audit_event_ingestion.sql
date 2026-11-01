BEGIN;

-- Authenticated clients must not be able to fabricate trusted audit events.
-- Until a trusted database/service event-ingestion path is implemented,
-- user-scoped direct INSERT is denied. Privileged service ingestion remains
-- an explicit server-side responsibility and must derive actor/time itself.
DROP POLICY IF EXISTS audit_events_insert_members ON public.audit_events;
REVOKE INSERT ON public.audit_events FROM authenticated;

COMMENT ON TABLE public.audit_events IS
  'Trusted operational audit events. Direct authenticated-client INSERT is disabled; event ingestion must use a trusted server/database path. Append-only grants remain enforced.';

COMMIT;
