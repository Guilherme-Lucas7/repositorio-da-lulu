-- Repositório da Lulu — banco de dados no Supabase
-- Como usar: Supabase > SQL Editor > New query > cole tudo > Run.
-- Pode rodar de novo sem problema: nada é apagado.
--
-- Cada professora só enxerga os próprios dados (regras "owner = auth.uid()").
-- Assim o mesmo banco já serve para várias usuárias, se o app virar produto.

-- ---------- Turmas ----------
create table if not exists public.turmas (
  id            uuid primary key default gen_random_uuid(),
  owner         uuid not null default auth.uid() references auth.users(id) on delete cascade,
  nome          text not null,                      -- ex.: 6º A
  ano_letivo    int  not null,                      -- ex.: 2026
  serie         text,                               -- ex.: 6º ano
  turno         text,                               -- Matutino, Vespertino, Noturno, Integral
  disciplina    text,
  cor           text not null default '#6D3BE0',
  arquivada     boolean not null default false,
  criado_em     timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

-- ---------- Aulas (o repositório) ----------
create table if not exists public.aulas (
  id            uuid primary key default gen_random_uuid(),
  owner         uuid not null default auth.uid() references auth.users(id) on delete cascade,
  turma_id      uuid references public.turmas(id) on delete set null,
  titulo        text not null,
  data          date,
  bimestre      smallint check (bimestre between 1 and 4),
  disciplina    text,
  objetivos     text,
  conteudo      text,                               -- desenvolvimento da aula
  recursos      text,
  avaliacao     text,
  bncc          text[] not null default '{}',       -- ex.: {EF06MA07}
  etiquetas     text[] not null default '{}',
  links         text[] not null default '{}',
  anexos        jsonb  not null default '[]',       -- [{path, nome, tipo, tam}]
  status        text not null default 'planejada' check (status in ('planejada','dada')),
  reflexao      text,                               -- "como foi a aula"
  criado_em     timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

-- ---------- Anotações ----------
create table if not exists public.anotacoes (
  id            uuid primary key default gen_random_uuid(),
  owner         uuid not null default auth.uid() references auth.users(id) on delete cascade,
  titulo        text,
  texto         text,
  cor           text not null default 'lilas',
  fixada        boolean not null default false,
  turma_id      uuid references public.turmas(id) on delete set null,
  criado_em     timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

-- ---------- Avisos da escola (compartilhados do WhatsApp/Instagram) ----------
create table if not exists public.avisos (
  id            uuid primary key default gen_random_uuid(),
  owner         uuid not null default auth.uid() references auth.users(id) on delete cascade,
  texto         text not null,
  origem        text not null default 'outro' check (origem in ('whatsapp','instagram','outro')),
  criado_em     timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

-- ---------- Eventos da agenda ----------
create table if not exists public.eventos (
  id            uuid primary key default gen_random_uuid(),
  owner         uuid not null default auth.uid() references auth.users(id) on delete cascade,
  titulo        text not null,
  data          date not null,
  data_fim      date,
  hora          text,
  tipo          text not null default 'escola',
  descricao     text,
  aviso_id      uuid references public.avisos(id) on delete set null,
  criado_em     timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

-- lembretes: tipo "lembrete" e aviso no celular (minutos antes)
alter table public.eventos add column if not exists alarme_min integer;
alter table public.eventos drop constraint if exists eventos_tipo_check;
alter table public.eventos add constraint eventos_tipo_check check (tipo in ('escola','reuniao','prova','pessoal','lembrete'));

-- ---------- Banco de questões (múltipla escolha, 4 alternativas) ----------
create table if not exists public.questoes (
  id            uuid primary key default gen_random_uuid(),
  owner         uuid not null default auth.uid() references auth.users(id) on delete cascade,
  enunciado     text not null,
  alternativas  text[] not null check (array_length(alternativas, 1) = 4),
  correta       smallint not null check (correta between 0 and 3),   -- 0 = A, 1 = B, 2 = C, 3 = D
  explicacao    text,
  disciplina    text,
  serie         text,
  bimestre      smallint check (bimestre between 1 and 4),
  dificuldade   text check (dificuldade in ('facil','media','dificil')),
  bncc          text[] not null default '{}',
  etiquetas     text[] not null default '{}',
  criado_em     timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

-- ---------- Provas montadas a partir do banco ----------
create table if not exists public.provas (
  id            uuid primary key default gen_random_uuid(),
  owner         uuid not null default auth.uid() references auth.users(id) on delete cascade,
  titulo        text not null,
  turma_id      uuid references public.turmas(id) on delete set null,
  data          date,
  valor         text,
  instrucoes    text,
  questao_ids   uuid[] not null default '{}',                         -- na ordem da prova
  embaralhar    boolean not null default false,
  semente       integer not null default 1,                           -- sorteio das alternativas
  criado_em     timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

-- ---------- Perfil (nome, escola, datas dos bimestres) ----------
create table if not exists public.perfil (
  owner         uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  nome          text,
  escola        text,
  bimestres     jsonb not null default '{}',        -- {"2026": [["2026-02-12","2026-04-24"], ...]}
  atualizado_em timestamptz not null default now()
);

create index if not exists aulas_owner_idx     on public.aulas(owner);
create index if not exists aulas_turma_idx     on public.aulas(turma_id);
create index if not exists turmas_owner_idx    on public.turmas(owner);
create index if not exists anotacoes_owner_idx on public.anotacoes(owner);
create index if not exists eventos_owner_idx   on public.eventos(owner, data);
create index if not exists avisos_owner_idx    on public.avisos(owner);
create index if not exists questoes_owner_idx  on public.questoes(owner);
create index if not exists provas_owner_idx    on public.provas(owner);

-- ---------- Regras de acesso: cada uma vê só o que é seu ----------
do $$
declare t text;
begin
  foreach t in array array['turmas','aulas','anotacoes','avisos','eventos','perfil','questoes','provas'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('drop policy if exists "dona dos dados" on public.%I', t);
    execute format('create policy "dona dos dados" on public.%I for all to authenticated
                    using (owner = auth.uid()) with check (owner = auth.uid())', t);
  end loop;
end $$;

-- garante que o app (usuária logada) consegue usar as tabelas
grant usage on schema public to authenticated;
grant select, insert, update, delete on public.turmas, public.aulas, public.anotacoes, public.avisos,
  public.eventos, public.perfil, public.questoes, public.provas to authenticated;

-- ---------- Arquivos anexados às aulas (PDF, slides, fotos) ----------
insert into storage.buckets (id, name, public, file_size_limit)
values ('anexos', 'anexos', false, 26214400)   -- até 25 MB por arquivo
on conflict (id) do nothing;

drop policy if exists "anexos: ler os meus"    on storage.objects;
drop policy if exists "anexos: enviar os meus" on storage.objects;
drop policy if exists "anexos: trocar os meus" on storage.objects;
drop policy if exists "anexos: apagar os meus" on storage.objects;
create policy "anexos: ler os meus" on storage.objects for select to authenticated
  using (bucket_id = 'anexos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "anexos: enviar os meus" on storage.objects for insert to authenticated
  with check (bucket_id = 'anexos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "anexos: trocar os meus" on storage.objects for update to authenticated
  using (bucket_id = 'anexos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "anexos: apagar os meus" on storage.objects for delete to authenticated
  using (bucket_id = 'anexos' and (storage.foldername(name))[1] = auth.uid()::text);
