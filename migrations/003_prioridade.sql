-- ═══════════════════════════════════════════════════════════════
-- Migração: adiciona campo nativo "prioridade" aos negócios
-- Contexto: substitui o antigo campo fixo "origem" (não configurável),
-- que foi removido da UI nesta mesma fase do projeto.
-- Já refletida no retrato de schema atual (000_baseline_schema.sql) —
-- mantida aqui separada só como registro histórico do "porquê".
-- ═══════════════════════════════════════════════════════════════

alter table negocios add column if not exists prioridade text default 'media'
  check (prioridade in ('baixa','media','alta'));

update negocios set prioridade = 'media' where prioridade is null;
