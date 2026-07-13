--
-- PostgreSQL database dump
--

\restrict PVBSKf5YLWLmNfA0pieX7AkGuKTX1G9MurJ7ZR9nZSnIqmvrxIW4klEy6RIXhDm

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.10 (Ubuntu 17.10-1.pgdg24.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: meu_papel(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.meu_papel() RETURNS text
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  select papel from perfis where id = auth.uid()
$$;


--
-- Name: minha_empresa_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.minha_empresa_id() RETURNS uuid
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  select empresa_id from perfis where id = auth.uid()
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: atividades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.atividades (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    empresa_id uuid NOT NULL,
    negocio_id uuid,
    titulo text NOT NULL,
    tipo text DEFAULT 'outro'::text,
    data date NOT NULL,
    concluida boolean DEFAULT false,
    observacoes text,
    criado_em timestamp with time zone DEFAULT now(),
    CONSTRAINT atividades_tipo_check CHECK ((tipo = ANY (ARRAY['follow-up'::text, 'proposta'::text, 'email'::text, 'reuniao'::text, 'ligacao'::text, 'outro'::text])))
);


--
-- Name: campos_custom; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.campos_custom (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    empresa_id uuid NOT NULL,
    nome text NOT NULL,
    tipo text DEFAULT 'texto'::text,
    opcoes text[],
    ordem integer DEFAULT 0 NOT NULL,
    criado_em timestamp with time zone DEFAULT now(),
    CONSTRAINT campos_custom_tipo_check CHECK ((tipo = ANY (ARRAY['texto'::text, 'selecao'::text, 'data'::text])))
);


--
-- Name: diagnostico_diario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.diagnostico_diario (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    empresa_id uuid NOT NULL,
    data date NOT NULL,
    score_saude integer,
    kpis jsonb,
    alertas jsonb,
    oportunidades jsonb,
    diagnostico jsonb,
    criado_em timestamp with time zone DEFAULT now()
);


--
-- Name: empresas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.empresas (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nome text NOT NULL,
    vendedor_ve_todos boolean DEFAULT true,
    criado_em timestamp with time zone DEFAULT now()
);


--
-- Name: etapas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.etapas (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    empresa_id uuid NOT NULL,
    nome text NOT NULL,
    ordem integer NOT NULL,
    cor text DEFAULT '#7B2FFF'::text,
    alerta_dias integer,
    criado_em timestamp with time zone DEFAULT now()
);


--
-- Name: negocios; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.negocios (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    empresa_id uuid NOT NULL,
    titulo text NOT NULL,
    etapa_id uuid,
    owner_id uuid,
    contato_nome text,
    contato_telefone text,
    contato_email text,
    contato_cargo text,
    contato_empresa text,
    valor numeric DEFAULT 0,
    valor_fechado numeric,
    origem text,
    proximo_passo text,
    motivo_perda text,
    data_entrada date DEFAULT CURRENT_DATE,
    data_fechamento date,
    ultima_atualizacao timestamp with time zone DEFAULT now(),
    campos_valores jsonb DEFAULT '{}'::jsonb,
    criado_em timestamp with time zone DEFAULT now(),
    data_perda date,
    prioridade text DEFAULT 'media'::text,
    CONSTRAINT negocios_prioridade_check CHECK ((prioridade = ANY (ARRAY['baixa'::text, 'media'::text, 'alta'::text])))
);


--
-- Name: notas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notas (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    negocio_id uuid NOT NULL,
    empresa_id uuid NOT NULL,
    texto text NOT NULL,
    criado_em timestamp with time zone DEFAULT now()
);


--
-- Name: perfis; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.perfis (
    id uuid NOT NULL,
    empresa_id uuid,
    nome text NOT NULL,
    papel text DEFAULT 'vendedor'::text,
    criado_em timestamp with time zone DEFAULT now(),
    CONSTRAINT perfis_papel_check CHECK ((papel = ANY (ARRAY['super_admin'::text, 'admin'::text, 'vendedor'::text])))
);


--
-- Name: atividades atividades_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.atividades
    ADD CONSTRAINT atividades_pkey PRIMARY KEY (id);


--
-- Name: campos_custom campos_custom_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campos_custom
    ADD CONSTRAINT campos_custom_pkey PRIMARY KEY (id);


--
-- Name: diagnostico_diario diagnostico_diario_empresa_id_data_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diagnostico_diario
    ADD CONSTRAINT diagnostico_diario_empresa_id_data_key UNIQUE (empresa_id, data);


--
-- Name: diagnostico_diario diagnostico_diario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diagnostico_diario
    ADD CONSTRAINT diagnostico_diario_pkey PRIMARY KEY (id);


--
-- Name: empresas empresas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.empresas
    ADD CONSTRAINT empresas_pkey PRIMARY KEY (id);


--
-- Name: etapas etapas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.etapas
    ADD CONSTRAINT etapas_pkey PRIMARY KEY (id);


--
-- Name: negocios negocios_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.negocios
    ADD CONSTRAINT negocios_pkey PRIMARY KEY (id);


--
-- Name: notas notas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notas
    ADD CONSTRAINT notas_pkey PRIMARY KEY (id);


--
-- Name: perfis perfis_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.perfis
    ADD CONSTRAINT perfis_pkey PRIMARY KEY (id);


--
-- Name: atividades atividades_empresa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.atividades
    ADD CONSTRAINT atividades_empresa_id_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresas(id) ON DELETE CASCADE;


--
-- Name: atividades atividades_negocio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.atividades
    ADD CONSTRAINT atividades_negocio_id_fkey FOREIGN KEY (negocio_id) REFERENCES public.negocios(id) ON DELETE CASCADE;


--
-- Name: campos_custom campos_custom_empresa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campos_custom
    ADD CONSTRAINT campos_custom_empresa_id_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresas(id) ON DELETE CASCADE;


--
-- Name: diagnostico_diario diagnostico_diario_empresa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diagnostico_diario
    ADD CONSTRAINT diagnostico_diario_empresa_id_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresas(id) ON DELETE CASCADE;


--
-- Name: etapas etapas_empresa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.etapas
    ADD CONSTRAINT etapas_empresa_id_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresas(id) ON DELETE CASCADE;


--
-- Name: negocios negocios_empresa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.negocios
    ADD CONSTRAINT negocios_empresa_id_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresas(id) ON DELETE CASCADE;


--
-- Name: negocios negocios_etapa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.negocios
    ADD CONSTRAINT negocios_etapa_id_fkey FOREIGN KEY (etapa_id) REFERENCES public.etapas(id) ON DELETE SET NULL;


--
-- Name: negocios negocios_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.negocios
    ADD CONSTRAINT negocios_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.perfis(id) ON DELETE SET NULL;


--
-- Name: notas notas_empresa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notas
    ADD CONSTRAINT notas_empresa_id_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresas(id) ON DELETE CASCADE;


--
-- Name: notas notas_negocio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notas
    ADD CONSTRAINT notas_negocio_id_fkey FOREIGN KEY (negocio_id) REFERENCES public.negocios(id) ON DELETE CASCADE;


--
-- Name: perfis perfis_empresa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.perfis
    ADD CONSTRAINT perfis_empresa_id_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresas(id) ON DELETE CASCADE;


--
-- Name: perfis perfis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.perfis
    ADD CONSTRAINT perfis_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: atividades; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.atividades ENABLE ROW LEVEL SECURITY;

--
-- Name: atividades atividades_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY atividades_policy ON public.atividades USING (((public.meu_papel() = 'super_admin'::text) OR ((empresa_id = public.minha_empresa_id()) AND ((negocio_id IS NULL) OR (EXISTS ( SELECT 1
   FROM public.negocios n
  WHERE ((n.id = atividades.negocio_id) AND ((public.meu_papel() = 'admin'::text) OR ( SELECT empresas.vendedor_ve_todos
           FROM public.empresas
          WHERE (empresas.id = public.minha_empresa_id())) OR (n.owner_id = auth.uid()))))))))) WITH CHECK (((public.meu_papel() = 'super_admin'::text) OR ((empresa_id = public.minha_empresa_id()) AND ((negocio_id IS NULL) OR (EXISTS ( SELECT 1
   FROM public.negocios n
  WHERE ((n.id = atividades.negocio_id) AND ((public.meu_papel() = 'admin'::text) OR ( SELECT empresas.vendedor_ve_todos
           FROM public.empresas
          WHERE (empresas.id = public.minha_empresa_id())) OR (n.owner_id = auth.uid())))))))));


--
-- Name: campos_custom; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.campos_custom ENABLE ROW LEVEL SECURITY;

--
-- Name: campos_custom campos_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY campos_select ON public.campos_custom FOR SELECT USING (((public.meu_papel() = 'super_admin'::text) OR (empresa_id = public.minha_empresa_id())));


--
-- Name: campos_custom campos_write; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY campos_write ON public.campos_custom USING (((public.meu_papel() = 'super_admin'::text) OR ((public.meu_papel() = 'admin'::text) AND (empresa_id = public.minha_empresa_id())))) WITH CHECK (((public.meu_papel() = 'super_admin'::text) OR ((public.meu_papel() = 'admin'::text) AND (empresa_id = public.minha_empresa_id()))));


--
-- Name: diagnostico_diario; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.diagnostico_diario ENABLE ROW LEVEL SECURITY;

--
-- Name: diagnostico_diario diagnostico_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY diagnostico_insert ON public.diagnostico_diario FOR INSERT WITH CHECK (((empresa_id IN ( SELECT perfis.empresa_id
   FROM public.perfis
  WHERE (perfis.id = auth.uid()))) OR (EXISTS ( SELECT 1
   FROM public.perfis
  WHERE ((perfis.id = auth.uid()) AND (perfis.papel = 'super_admin'::text))))));


--
-- Name: diagnostico_diario diagnostico_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY diagnostico_select ON public.diagnostico_diario FOR SELECT USING (((empresa_id IN ( SELECT perfis.empresa_id
   FROM public.perfis
  WHERE (perfis.id = auth.uid()))) OR (EXISTS ( SELECT 1
   FROM public.perfis
  WHERE ((perfis.id = auth.uid()) AND (perfis.papel = 'super_admin'::text))))));


--
-- Name: diagnostico_diario diagnostico_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY diagnostico_update ON public.diagnostico_diario FOR UPDATE USING (((empresa_id IN ( SELECT perfis.empresa_id
   FROM public.perfis
  WHERE (perfis.id = auth.uid()))) OR (EXISTS ( SELECT 1
   FROM public.perfis
  WHERE ((perfis.id = auth.uid()) AND (perfis.papel = 'super_admin'::text))))));


--
-- Name: empresas; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.empresas ENABLE ROW LEVEL SECURITY;

--
-- Name: empresas empresas_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY empresas_delete ON public.empresas FOR DELETE USING ((public.meu_papel() = 'super_admin'::text));


--
-- Name: empresas empresas_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY empresas_insert ON public.empresas FOR INSERT WITH CHECK ((public.meu_papel() = 'super_admin'::text));


--
-- Name: empresas empresas_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY empresas_select ON public.empresas FOR SELECT USING (((public.meu_papel() = 'super_admin'::text) OR (id = public.minha_empresa_id())));


--
-- Name: empresas empresas_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY empresas_update ON public.empresas FOR UPDATE USING (((public.meu_papel() = 'super_admin'::text) OR ((public.meu_papel() = 'admin'::text) AND (id = public.minha_empresa_id())))) WITH CHECK (((public.meu_papel() = 'super_admin'::text) OR ((public.meu_papel() = 'admin'::text) AND (id = public.minha_empresa_id()))));


--
-- Name: etapas; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.etapas ENABLE ROW LEVEL SECURITY;

--
-- Name: etapas etapas_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY etapas_select ON public.etapas FOR SELECT USING (((public.meu_papel() = 'super_admin'::text) OR (empresa_id = public.minha_empresa_id())));


--
-- Name: etapas etapas_write; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY etapas_write ON public.etapas USING (((public.meu_papel() = 'super_admin'::text) OR ((public.meu_papel() = 'admin'::text) AND (empresa_id = public.minha_empresa_id())))) WITH CHECK (((public.meu_papel() = 'super_admin'::text) OR ((public.meu_papel() = 'admin'::text) AND (empresa_id = public.minha_empresa_id()))));


--
-- Name: negocios; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.negocios ENABLE ROW LEVEL SECURITY;

--
-- Name: negocios negocios_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY negocios_policy ON public.negocios USING (((public.meu_papel() = 'super_admin'::text) OR ((empresa_id = public.minha_empresa_id()) AND (( SELECT empresas.vendedor_ve_todos
   FROM public.empresas
  WHERE (empresas.id = public.minha_empresa_id())) OR (public.meu_papel() = 'admin'::text) OR (owner_id = auth.uid())))));


--
-- Name: notas; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.notas ENABLE ROW LEVEL SECURITY;

--
-- Name: notas notas_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY notas_policy ON public.notas USING (((public.meu_papel() = 'super_admin'::text) OR ((empresa_id = public.minha_empresa_id()) AND (EXISTS ( SELECT 1
   FROM public.negocios n
  WHERE ((n.id = notas.negocio_id) AND ((public.meu_papel() = 'admin'::text) OR ( SELECT empresas.vendedor_ve_todos
           FROM public.empresas
          WHERE (empresas.id = public.minha_empresa_id())) OR (n.owner_id = auth.uid())))))))) WITH CHECK (((public.meu_papel() = 'super_admin'::text) OR ((empresa_id = public.minha_empresa_id()) AND (EXISTS ( SELECT 1
   FROM public.negocios n
  WHERE ((n.id = notas.negocio_id) AND ((public.meu_papel() = 'admin'::text) OR ( SELECT empresas.vendedor_ve_todos
           FROM public.empresas
          WHERE (empresas.id = public.minha_empresa_id())) OR (n.owner_id = auth.uid()))))))));


--
-- Name: perfis; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.perfis ENABLE ROW LEVEL SECURITY;

--
-- Name: perfis perfis_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY perfis_delete ON public.perfis FOR DELETE USING (((public.meu_papel() = 'super_admin'::text) OR ((public.meu_papel() = 'admin'::text) AND (empresa_id = public.minha_empresa_id()))));


--
-- Name: perfis perfis_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY perfis_insert ON public.perfis FOR INSERT WITH CHECK (((public.meu_papel() = 'super_admin'::text) OR ((public.meu_papel() = 'admin'::text) AND (empresa_id = public.minha_empresa_id()))));


--
-- Name: perfis perfis_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY perfis_select ON public.perfis FOR SELECT USING (((public.meu_papel() = 'super_admin'::text) OR (empresa_id = public.minha_empresa_id())));


--
-- Name: perfis perfis_update_admin; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY perfis_update_admin ON public.perfis FOR UPDATE USING (((public.meu_papel() = 'super_admin'::text) OR ((public.meu_papel() = 'admin'::text) AND (empresa_id = public.minha_empresa_id())))) WITH CHECK (((public.meu_papel() = 'super_admin'::text) OR ((public.meu_papel() = 'admin'::text) AND (empresa_id = public.minha_empresa_id()))));


--
-- Name: perfis perfis_update_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY perfis_update_self ON public.perfis FOR UPDATE USING ((id = auth.uid())) WITH CHECK (((id = auth.uid()) AND (papel = public.meu_papel()) AND (empresa_id = public.minha_empresa_id())));


--
-- PostgreSQL database dump complete
--

\unrestrict PVBSKf5YLWLmNfA0pieX7AkGuKTX1G9MurJ7ZR9nZSnIqmvrxIW4klEy6RIXhDm

