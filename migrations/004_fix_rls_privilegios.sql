-- ═══════════════════════════════════════════════════════════════
-- Migração: corrige 4 policies de RLS que permitiam escalação de
-- privilégio / vazamento de dado entre vendedores da mesma empresa.
--
-- Encontrado numa auditoria de segurança: as policies antigas de
-- perfis/empresas/etapas/campos_custom só checavam empresa_id, sem
-- checar papel do usuário nem dono do registro — qualquer vendedor
-- conseguia, via chamada direta à API (fora da UI), se auto-promover
-- a admin, editar a própria empresa, ou mexer em etapas/campos que
-- deveriam ser só de admin.
--
-- Testado e confirmado em produção (Empresa Teste) antes de aplicar
-- em definitivo. Já refletida no retrato de schema atual
-- (000_baseline_schema.sql) — mantida aqui separada como registro
-- histórico do "porquê" de cada policy ser como é hoje.
-- ═══════════════════════════════════════════════════════════════

-- ── perfis — impedir auto-promoção a admin/super_admin ──
drop policy if exists perfis_policy on perfis;

create policy perfis_select on perfis
for select
using (meu_papel() = 'super_admin' OR empresa_id = minha_empresa_id());

create policy perfis_update_self on perfis
for update
using (id = auth.uid())
with check (id = auth.uid() and papel = meu_papel() and empresa_id = minha_empresa_id());

create policy perfis_update_admin on perfis
for update
using (meu_papel() = 'super_admin' OR (meu_papel() = 'admin' AND empresa_id = minha_empresa_id()))
with check (meu_papel() = 'super_admin' OR (meu_papel() = 'admin' AND empresa_id = minha_empresa_id()));

create policy perfis_insert on perfis
for insert
with check (meu_papel() = 'super_admin' OR (meu_papel() = 'admin' AND empresa_id = minha_empresa_id()));

create policy perfis_delete on perfis
for delete
using (meu_papel() = 'super_admin' OR (meu_papel() = 'admin' AND empresa_id = minha_empresa_id()));


-- ── empresas — só admin/super_admin escrevem ──
drop policy if exists empresas_policy on empresas;

create policy empresas_select on empresas
for select
using (meu_papel() = 'super_admin' OR id = minha_empresa_id());

create policy empresas_insert on empresas
for insert
with check (meu_papel() = 'super_admin');

create policy empresas_update on empresas
for update
using (meu_papel() = 'super_admin' OR (meu_papel() = 'admin' AND id = minha_empresa_id()))
with check (meu_papel() = 'super_admin' OR (meu_papel() = 'admin' AND id = minha_empresa_id()));

create policy empresas_delete on empresas
for delete
using (meu_papel() = 'super_admin');


-- ── etapas e campos_custom — só admin/super_admin escrevem ──
drop policy if exists etapas_policy on etapas;

create policy etapas_select on etapas
for select
using (meu_papel() = 'super_admin' OR empresa_id = minha_empresa_id());

create policy etapas_write on etapas
for all
using (meu_papel() = 'super_admin' OR (meu_papel() = 'admin' AND empresa_id = minha_empresa_id()))
with check (meu_papel() = 'super_admin' OR (meu_papel() = 'admin' AND empresa_id = minha_empresa_id()));

drop policy if exists campos_policy on campos_custom;

create policy campos_select on campos_custom
for select
using (meu_papel() = 'super_admin' OR empresa_id = minha_empresa_id());

create policy campos_write on campos_custom
for all
using (meu_papel() = 'super_admin' OR (meu_papel() = 'admin' AND empresa_id = minha_empresa_id()))
with check (meu_papel() = 'super_admin' OR (meu_papel() = 'admin' AND empresa_id = minha_empresa_id()));


-- ── notas e atividades — respeitar o dono do negócio, igual "negocios_policy" ──
drop policy if exists notas_policy on notas;

create policy notas_policy on notas
for all
using (
  meu_papel() = 'super_admin' OR (
    empresa_id = minha_empresa_id() AND exists (
      select 1 from negocios n where n.id = notas.negocio_id and (
        meu_papel() = 'admin'
        or (select vendedor_ve_todos from empresas where id = minha_empresa_id())
        or n.owner_id = auth.uid()
      )
    )
  )
)
with check (
  meu_papel() = 'super_admin' OR (
    empresa_id = minha_empresa_id() AND exists (
      select 1 from negocios n where n.id = notas.negocio_id and (
        meu_papel() = 'admin'
        or (select vendedor_ve_todos from empresas where id = minha_empresa_id())
        or n.owner_id = auth.uid()
      )
    )
  )
);

drop policy if exists atividades_policy on atividades;

create policy atividades_policy on atividades
for all
using (
  meu_papel() = 'super_admin' OR (
    empresa_id = minha_empresa_id() AND (
      negocio_id is null OR exists (
        select 1 from negocios n where n.id = atividades.negocio_id and (
          meu_papel() = 'admin'
          or (select vendedor_ve_todos from empresas where id = minha_empresa_id())
          or n.owner_id = auth.uid()
        )
      )
    )
  )
)
with check (
  meu_papel() = 'super_admin' OR (
    empresa_id = minha_empresa_id() AND (
      negocio_id is null OR exists (
        select 1 from negocios n where n.id = atividades.negocio_id and (
          meu_papel() = 'admin'
          or (select vendedor_ve_todos from empresas where id = minha_empresa_id())
          or n.owner_id = auth.uid()
        )
      )
    )
  )
);
