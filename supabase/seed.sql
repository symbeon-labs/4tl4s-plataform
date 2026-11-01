-- =====================================================================
-- 4TL4S PLATFORM — INITIAL CLIENT SEED FIXTURE
-- Clients: Hub Açaí & Mundo Sabor
-- ADR: ADR-0005 (Organizational Units Scoped Access)
-- =====================================================================

BEGIN;

-- 1. Create Initial Organizations (Tenants)
INSERT INTO public.organizations (id, name, slug, legal_name, country_code, lifecycle_state)
VALUES 
  ('a1111111-1111-4111-8111-111111111111', 'Hub Açaí', 'hub-acai', 'Hub Açaí Distribuição e Alimentos Ltda', 'BR', 'active'),
  ('b2222222-2222-4222-8222-222222222222', 'Mundo Sabor', 'mundo-sabor', 'Mundo do Sabor Comércio de Alimentos Ltda', 'BR', 'active')
ON CONFLICT (id) DO NOTHING;

-- 2. Create Organizational Units for Hub Açaí
INSERT INTO public.organizational_units (id, organization_id, name, slug, unit_type, description, lifecycle_state)
VALUES
  ('a1111111-1111-4111-8111-000000000001', 'a1111111-1111-4111-8111-111111111111', 'Financeiro', 'financeiro', 'department', 'Gestão financeira, custos e diagnóstico inicial de caixa', 'active'),
  ('a1111111-1111-4111-8111-000000000002', 'a1111111-1111-4111-8111-111111111111', 'Logística & Frota', 'logistica-frota', 'department', 'Roteirização de entrega e manutenção preventiva de veículos', 'active'),
  ('a1111111-1111-4111-8111-000000000003', 'a1111111-1111-4111-8111-111111111111', 'Vendas', 'vendas', 'department', 'Funil comercial, captação e pedidos de distribuição', 'active')
ON CONFLICT (id) DO NOTHING;

-- 3. Create Organizational Units for Mundo Sabor
INSERT INTO public.organizational_units (id, organization_id, name, slug, unit_type, description, lifecycle_state)
VALUES
  ('b2222222-2222-4222-8222-000000000001', 'b2222222-2222-4222-8222-222222222222', 'Compras & Suprimentos', 'compras', 'department', 'Gestão de fornecedores, pedidos e rupturas de estoque', 'active'),
  ('b2222222-2222-4222-8222-000000000002', 'b2222222-2222-4222-8222-222222222222', 'Financeiro & Contas a Receber', 'financeiro', 'department', 'Controle diário de caixa, reserva semanal, POP e canhotos', 'active')
ON CONFLICT (id) DO NOTHING;

COMMIT;