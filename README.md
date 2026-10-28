# Repositório da Lulu

Aulas, anotações e calendário escolar de uma professora da rede pública do DF, em um app para celular.

- Site estático (GitHub Pages) + banco de dados Supabase.
- Sem o `config.js` preenchido, abre em **modo demonstração** (dados só no aparelho).
- Instalável no celular; no Android aparece no botão **Compartilhar** do WhatsApp e do Instagram.

## O que tem

- **Aulas**: tema, turma, data, bimestre (automático pela data), disciplina, objetivos, desenvolvimento, recursos, avaliação, habilidades da BNCC, etiquetas, links e arquivos (até 25 MB cada).
- **Busca** por texto e filtros por turma, ano letivo, bimestre e situação (planejada/dada).
- **"Como foi a aula"**: reflexão depois de dar a aula; e **Usar em outra turma** para reaproveitar o planejamento.
- **Agenda** com o calendário escolar 2026 da SEEDF e feriados já carregados, mais os eventos dela.
- **Avisos da escola**: cola ou compartilha uma mensagem, o app encontra datas e horários e manda para a agenda. Também lê texto de prints (no próprio aparelho).
- **Anotações** coloridas, que podem ser fixadas no início e ligadas a uma turma.
- **Turmas** por ano letivo, com cor própria.
- **Questões**: banco de questões de múltipla escolha (4 alternativas), com série, bimestre, dificuldade, BNCC e etiquetas. Dá para colar várias de uma vez, de uma prova antiga.
- **Quiz** para projetar na sala: a pergunta aparece sem a resposta, com cronômetro opcional para a turma pensar (20 s a 2 min, com pausa, +15 s e aviso sonoro). A professora avança para mostrar a resposta certa e a explicação, e avança de novo para a próxima. Se quiser, marca a resposta da turma e vê o placar no final. No computador, Enter avança.
- **Provas**: monta a prova a partir do banco, reordena, embaralha alternativas, imprime ou salva em PDF, imprime o gabarito separado e baixa para Word.
- **Cópia de segurança** em arquivo.

## Publicar (uma vez só, uns 15 minutos)

### 1. Supabase (banco de dados)
1. Crie uma conta em supabase.com e um projeto novo (região São Paulo).
2. Vá em **SQL Editor > New query**, cole todo o conteúdo de `setup.sql` e clique em **Run**.
3. Em **Authentication > URL Configuration**, coloque em *Site URL* o endereço do GitHub Pages (passo 2), por exemplo `https://guilherme-lucas7.github.io/repositorio-da-lulu/`.
4. Em **Project Settings > API**, copie a *Project URL* e a chave *anon/publishable* para o `config.js`.

### 2. GitHub Pages (o site)
1. Crie um repositório chamado `repositorio-da-lulu` e envie todos os arquivos desta pasta.
2. Em **Settings > Pages**, escolha *Deploy from a branch*, branch `main`, pasta `/ (root)`.
3. Em um ou dois minutos o app fica em `https://guilherme-lucas7.github.io/repositorio-da-lulu/`.

### 3. Primeiro acesso
Abra o endereço no celular dela, toque em **Criar conta**, confirme o e-mail e entre.
Depois instale: no Chrome (Android), menu de três pontos > **Instalar app**; no iPhone (Safari), Compartilhar > **Adicionar à Tela de Início**.

## Arquivos

| Arquivo | Para quê |
|---|---|
| `index.html` | O app inteiro |
| `config.js` | Endereço e chave pública do Supabase |
| `setup.sql` | Cria as tabelas, as regras de acesso e o espaço dos anexos |
| `manifest.json`, `sw.js`, ícones | Instalação no celular e botão Compartilhar |

## Calendário de outros anos
As datas oficiais ficam em `CAL_OFICIAL`, no começo do script do `index.html`. Quando a SEEDF publicar o calendário de 2027, acrescente um bloco igual ao de 2026. As datas dos bimestres também podem ser ajustadas pelo próprio app em **Mais > Calendário letivo e perfil**.

## Se virar produto
O banco já separa os dados por usuária (cada conta só vê o que é seu), então várias professoras podem usar o mesmo projeto. Como o app guarda dados de turmas, revise os termos de uso e a política de privacidade (LGPD) antes de abrir para outras pessoas, e evite registrar dados pessoais de estudantes.
