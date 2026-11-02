-- =====================================================================
-- 4TL4S PLATFORM - INITIAL CLIENT SEED FIXTURE
-- Clients: Hub Açaí & Mundo Sabor
-- ADR: ADR-0005 (Organizational Units Scoped Access)
-- =====================================================================

BEGIN;

-- 0. Ensure Bootstrap Seed User in auth.users
INSERT INTO auth.users (id, raw_user_meta_data)
VALUES ('00000000-0000-4000-8000-000000000001', '{"name": "System Seed Operator"}'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- 1. Create Initial Organizations (Tenants)
INSERT INTO public.organizations (id, name, slug, created_by)
VALUES 
  ('a1111111-1111-4111-8111-111111111111', 'Hub Açaí', 'hub-acai', '00000000-0000-4000-8000-000000000001'),
  ('b2222222-2222-4222-8222-222222222222', 'Mundo Sabor', 'mundo-sabor', '00000000-0000-4000-8000-000000000001')
ON CONFLICT (id) DO NOTHING;

-- 2. Create Organizational Units for Hub Açaí
INSERT INTO public.organizational_units (id, organization_id, name, slug, unit_type, description, lifecycle_state, created_by)
VALUES
  ('a1111111-1111-4111-8111-000000000001', 'a1111111-1111-4111-8111-111111111111', 'Financeiro', 'financeiro', 'department', 'Gestão financeira, custos e diagnóstico inicial de caixa', 'active', '00000000-0000-4000-8000-000000000001'),
  ('a1111111-1111-4111-8111-000000000002', 'a1111111-1111-4111-8111-111111111111', 'Logística & Frota', 'logistica-frota', 'department', 'Roteirização de entrega e manutenção preventiva de veículos', 'active', '00000000-0000-4000-8000-000000000001'),
  ('a1111111-1111-4111-8111-000000000003', 'a1111111-1111-4111-8111-111111111111', 'Vendas', 'vendas', 'department', 'Funil comercial, captação e pedidos de distribuição', 'active', '00000000-0000-4000-8000-000000000001')
ON CONFLICT (id) DO NOTHING;

-- 3. Create Organizational Units for Mundo Sabor
INSERT INTO public.organizational_units (id, organization_id, name, slug, unit_type, description, lifecycle_state, created_by)
VALUES
  ('b2222222-2222-4222-8222-000000000001', 'b2222222-2222-4222-8222-222222222222', 'Compras & Suprimentos', 'compras', 'department', 'Gestão de fornecedores, pedidos e rupturas de estoque', 'active', '00000000-0000-4000-8000-000000000001'),
  ('b2222222-2222-4222-8222-000000000002', 'b2222222-2222-4222-8222-222222222222', 'Financeiro & Contas a Receber', 'financeiro', 'department', 'Controle diário de caixa, reserva semanal, POP e canhotos', 'active', '00000000-0000-4000-8000-000000000001')
ON CONFLICT (id) DO NOTHING;

COMMIT;