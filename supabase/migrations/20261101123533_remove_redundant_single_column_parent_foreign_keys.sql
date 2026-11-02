BEGIN;

-- The composite tenant-scoped foreign keys supersede these single-column
-- references. Removing the redundant constraints avoids duplicate referential
-- actions and leaves tenant consistency as the authoritative relationship.
ALTER TABLE public.work_packages
  DROP CONSTRAINT work_packages_initiative_id_fkey;

ALTER TABLE public.artifacts
  DROP CONSTRAINT artifacts_initiative_id_fkey,
  DROP CONSTRAINT artifacts_work_package_id_fkey;

ALTER TABLE public.evidence_records
  DROP CONSTRAINT evidence_records_initiative_id_fkey,
  DROP CONSTRAINT evidence_records_artifact_id_fkey;

ALTER TABLE public.decision_records
  DROP CONSTRAINT decision_records_initiative_id_fkey,
  DROP CONSTRAINT decision_records_supersedes_id_fkey;

ALTER TABLE public.ip_assets
  DROP CONSTRAINT ip_assets_initiative_id_fkey;

COMMIT;