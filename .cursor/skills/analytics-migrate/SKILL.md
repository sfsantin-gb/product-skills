---
name: analytics-migrate
description: >-
  Migra tagueamento legado (megazord_mobile) para interaction_* e callback_*
  em 4 gates de revisao PM (dominios, perguntas, eventos essenciais, impacto)
  e so depois gera o CSV de-para e a entrega eng. Use quando mencionar
  migracao de tagueamento, pesquisa de tagueamento, TAGUEAMENTO_LEGADO,
  analytics-migrate, --setup, primeira vez, nova squad ou novo formato GA4.
---

# Analytics Migrate

Skill do pipeline `@analytics-migrate`. **Roda no megazord_mobile** — Product OS nao e necessario.

Instalacao: [product-skills](https://github.com/sfsantin-gb/product-skills) `install.ps1` **ou** `tools/analytics-migrate/install-agents.ps1`. Abra **somente** o megazord no Cursor.

Neste catalogo (`product-skills`), cada squad tem pasta propria:

| Squad | Docs (gates 1–4) | Outputs (CSV / eng) |
|-------|------------------|---------------------|
| Conteudos e Trafego | `docs/conteudos-e-trafego/` | `outputs/conteudos-e-trafego/` |
| Explorar Produtos | `docs/explorar-produtos/` | `outputs/explorar-produtos/` |

No megazord o pipeline grava em `tools/analytics-migrate/config/` e `output/` (ou `output-{squad}`). O `install.ps1` copia `docs/` e `outputs/` do catalogo para la.

## Fluxo obrigatorio — 4 gates + de-para

O PM fala a jornada/squad ("quero pesquisar Explorar Produtos"). O agente preenche **um** arquivo, **para** e espera o PM revisar. **Proibido** gerar o resto do pipeline no mesmo turno.

```
PM: quero pesquisar {jornada}
  1. Dominios              → PARE → PM revisa (entra/sai) → "pronto"
  2. Perguntas de negocio  → PARE → PM revisa → "pronto"
  3. Eventos essenciais    → PARE → PM revisa → "pronto"
  4. Impacto da migracao   → PARE → PM revisa → "pronto"
  5. De-para completo CSV + ENTREGA_ENG.csv
```

### HARD STOP (nao negociar)

Depois de gravar o artefato do gate atual:

1. Mostre o caminho do arquivo e um resumo curto (o que entrou / o que ficou de fora).
2. Diga: *Revise o arquivo. Pode editar direto ou me falar o que entra/sai. Quando terminar, diga **pronto**.*
3. **PARE.** Nao gere o proximo gate. Nao rode discover/pipeline/transform. Nao gere CSV. Nao pergunte "quer que eu ja rode o resto?".

So avance quando o PM disser explicitamente: **pronto** · **proximo** · **acabei** · **vamos continuar** · **pode seguir** · **revisado**.

- "Entra X / sai Y / muda Z" = editar o arquivo do **gate atual** e continuar parado.
- `--fase all`, "roda tudo", "pula revisao" = **confirme uma vez** ("isso pula as 4 revisoes; confirma?") e so execute se o PM confirmar.

Grave `docs/{squad}/STATUS_REVISAO.md` com o gate atual (`aguardando_pm` / `aprovado`). Se a conversa retomar, leia esse arquivo e continue do gate pendente — nao recomece do zero nem pule.

### Gate 1 — Dominios

Arquivo: `docs/{squad}/dominios.md` (catalogo) ou `config/dominios-{squad}.md` (megazord). Template: `templates/dominios-squad.template.md`.

1. Identifique squad / jornada / time GitHub (`setup-squad.ps1 -ListTeams` se for nova).
2. Scaffold do config se ainda nao existir (`setup-squad.ps1`).
3. Escreva os dominios (areas grandes + subdominios + contexto em 1 frase). Nao deixe placeholder.
4. **PARE.**

### Gate 2 — Perguntas de negocio

Arquivo: `docs/{squad}/perguntas-negocio.md` (catalogo) ou `config/perguntas-negocio-{squad}.md` (megazord).

1. Leia os dominios **ja revisados**.
2. Monte tabela P0/P1 por dominio (pergunta de negocio + indicador).
3. **PARE.**

Pode rodar `discover.ps1` **depois** do gate 1 aprovado (inventario para os gates 3–4). Nao apresente `EVENTOS_ESSENCIAIS_*.md` do discover como versao final — isso e o gate 3.

### Gate 3 — Eventos essenciais

Arquivo: `docs/{squad}/EVENTOS_ESSENCIAIS.md`.

1. Cruze dominios + perguntas + inventario do discover.
2. Liste o minimo de eventos por dominio para responder as perguntas (ECOM / PV / INT / CB).
3. **PARE.**

### Gate 4 — Impacto da migracao

Arquivo: `docs/{squad}/IMPACTO_MIGRACAO.md` (template: `templates/IMPACTO_MIGRACAO.template.md`).

1. Cruze perguntas + essenciais + regras (nav in-app, anti-padrao, ECOM) e o extract.
2. Deixe explicito o que continua mensuravel e o que o PM abre mao (scroll, clique duplicado, etc.).
3. **PARE.**

Nao gere o CSV de-para neste gate.

### Depois dos 4 gates — de-para (CSV)

So agora rode o pipeline tecnico (`navigation` → `coverage` → `callbacks` → `simplify` → `transform`) e entregue **dois CSVs**:

| Arquivo | Para quem | O que tem |
|---------|-----------|-----------|
| `TAGUEAMENTO_MIGRADO_{SQUAD}.csv` em `outputs/{squad}/` | **PM** — planilha completa | Cada evento: `status` (`migrar` / `remover` / `adicionar_pageview` / `manter`) + `criterio` + **`notas` = motivo em portugues**. |
| `ENTREGA_ENG.csv` em `outputs/{squad}/` | **Engenharia** | O que implementar. **Nao** traz o ensaio do porque. |

`notas` **nunca** vazia na planilha completa. Frase curta, ex.: *Remover: clique so navega; o pageview no destino ja mede a chegada.* · *Migrar: responde P0 add to cart na PDP.* · *Adicionar: tela de ofertas sem pageview.*

Tambem gere `RESUMO_DE_PARA.md` (contagens). Pageviews ok (`manter`) ficam de fora de `ENTREGA_ENG.csv` por padrao (`export-entrega-eng.ps1 -IncludeManter` inclui).

PM **nao** edita Dart.

### Invocacao

| Intencao | O que fazer |
|----------|-------------|
| "quero pesquisar {jornada}", `--setup`, primeira vez | Comecar no **gate 1** (ou retomar `STATUS_REVISAO.md`) |
| "pronto" / "proximo" / "acabei" | Avancar **um** gate |
| `--fase all` **depois** dos 4 gates | Pipeline tecnico + os dois CSVs |
| `--fase all` **antes** dos 4 gates | Recusar; lembrar o gate pendente |
| PM baixou o CSV e mudou status | Aplicar e regenerar `ENTREGA_ENG.csv` |

Leia tambem **`tools/analytics-migrate/PM_QUICKSTART.md`**.

## Leitura obrigatoria (agente)

1. `tools/analytics-migrate/PM_QUICKSTART.md`
2. `tools/analytics-migrate/docs/REGRAS_FORMATO_NOVO.md`
3. `tools/analytics-migrate/docs/CRITERIO_RELEVANCIA.md`
4. `EVENTOS_ESSENCIAIS` da squad (gate 3; C&T: `docs/EVENTOS_ESSENCIAIS_CT.md`)
5. `tools/analytics-migrate/output/_tag_extract_{squad}.json` ou `TAGUEAMENTO_LEGADO_*.md`
6. `tools/analytics-migrate/docs/GUIA_CONTEXTOS_TAGUEAMENTO_CT.md`
7. `tools/analytics-migrate/config/dominios-{squad}.md`
8. `packages/flutter_monitor/docs/GUIA_TAGUEAMENTO_GA4.md`
9. `apps/megazord/lib/core/routes/observers/tagger_navigator_observer.dart`

## Pipeline (so depois dos 4 gates)

```
Gates PM (um por vez, STOP):
  1 dominios -> 2 perguntas -> 3 essenciais -> 4 IMPACTO_MIGRACAO.md

discover (apos gate 1)          -> output/DISCOVER_REPORT.md + _tag_extract_{squad}.json

Pipeline tecnico (apos gate 4):
  -> analytics-prune-navigation   -> output/NAVEGACAO_AUDITORIA.md
  -> analytics-coverage           -> output/COBERTURA_AUDITORIA.md
  -> analytics-callbacks          -> output/CALLBACKS_MIGRACAO.md
  -> analytics-simplify           -> output/SIMPLIFICACAO_JORNADAS.md
  -> analytics-transform          -> output/TAGUEAMENTO_MIGRADO_*.md + CSV  (planilha completa / motivo)
  -> export-entrega-eng.ps1       -> output/ENTREGA_ENG.csv (handoff eng)
  -> generate-resumo-de-para.ps1  -> output/RESUMO_DE_PARA.md
```

CSV de-para: `tools/export_tagueamento_migrado_ct.ps1` (com `--export-csv`).

### Fase opcional — jornadas Maestro (e2e)

```powershell
powershell -ExecutionPolicy Bypass -File tools/generate-matriz-jornadas-maestro.ps1
```

Gera `matriz_jornadas_maestro.csv` na raiz do megazord.

## Regras criticas

### Navegacao

- Cliques in-app (`ir-para-*`, `voltar-*`, `ver-mais*`, `ver-tudo*`) **sempre remover**
- Destino sem pageview: `adicionar_pageview` no destino — **nunca** manter clique como fallback
- **Manter:** `openUrl`, `shareText`, compartilhar
- Validar handler no codigo — nao decidir so pelo label

### Eventos essenciais (remocao informada)

Antes de sugerir `remover`, cruzar com `docs/EVENTOS_ESSENCIAIS_CT.md`:

| Veredito CSV | Quando | PM deve |
|--------------|--------|---------|
| `essencial_p0` | Callbacks, share/open, funil vendas/clientes/estoque, PV | **Manter** |
| `pageview_ok` | `screen_view` / `setCurrentScreen` ja no padrao GA4 | **Manter** — nao migrar para `interaction_*` |
| `essencial_p1` | Diagnostico periodico, conteudo, acoes de funil secundarias | **Manter** salvo decisao explicita |
| `nao_essencial` | Gestao/hub fora do mapa essencial; clique duplica PV | Aprovar remocao |
| `fundir_pai` | Granularidade modal/parcela/SKU | Validar se KPI exige filho |
| `nav_duplicada` | Navegacao in-app com PV no destino | Aprovar remocao |
| `lacuna_pageview` | Remover clique + TODO pageview no destino | Priorizar engenharia |
| `anti_padrao` | tooltip, scroll, show:modal isolado | Aprovar remocao |
| `obsoleto` | Codigo morto confirmado | Aprovar remocao |
| `revisar_pm` | Ambiguidade de produto | **Decidir** antes de transform |

### Novo formato

- `interaction_<grupo>` + `cd_interaction_detail` — ver regras abaixo
- `callback_<dominio>_<keyword>_success` | `callback_<dominio>_<keyword>_error` + `cd_error_message` (ex.: `callback_estoque_add_product_success`)
- Max 100 CDs no projeto

### screen_view (pageview)

Eventos `screen_view` / `setCurrentScreen` **ja estao no padrao GA4 esperado** — nao passam por transformacao para `interaction_*`.

| Situacao | `status` | Acao |
|----------|----------|------|
| PV existente no codigo (router meta, observer ou tag) | `manter` | Preservar JSON legado (`screen_view` + `screen_name`); **nao** listar como `migrar` |
| Lacuna de cobertura (destino sem PV) | `adicionar_pageview` | Linha TODO separada com `screen_name` proposto |
| PV novo aprovado pelo PM | `adicionar_pageview` | Unica excecao em que um screen_view entra como trabalho de engenharia |

Nas fases **simplify** e **transform**: `tipo_legado=screen_view` → recomendacao/veredito **`manter`**, salvo lacuna ou inclusao nova.

### cd_interaction_detail

Formato obrigatorio: **`{acao}:{componente}-{contexto}`**

| Parte | Regra | Exemplos |
|-------|--------|----------|
| `{acao}` | Verbo da interacao, ingles, kebab-case | `click`, `open`, `share`, `view`, `swipe`, `download` |
| `{componente}` | Elemento de UI ou entidade clicada | `share-button`, `catalog-card`, `product-item`, `filter-chip` |
| `{contexto}` | Texto do botao/label (prioridade) ou tela/modulo (fallback) | `ver-mais`, `compartilhar-minha-loja`, `catalog-list` |
| Prioridade `{contexto}` | 1) `eventLabel` → 2) `acao_legado` ("Toca no botao: …") → 3) slug da tela/tag | |

- Tamanho maximo: **100 caracteres** no valor completo
- Exemplos validos: `click:button-ver-mais`, `open:catalog-boticario`, `download:button-baixa-a-imagem`
- **Proibido** usar `unknown`, `unkown` ou placeholders genericos

Quando faltar contexto:

1. **Priorizar texto do botao:** `eventLabel` legado, depois `acao_legado`
2. Ler `*_tag_impl.dart`, widget chamador e `meta['tag']` da rota
3. Fallback: slug da tela/tag; se ambiguo → `status: revisar_pm`
4. **Nunca** emitir `unknown` como valor final

## Exploracao do codigo

- `*_tag_impl.dart` + widget chamador
- `router.dart` com `meta['tag']`
- `PublisherAction` para cross-microapp

## Templates

Markdown: `tools/analytics-migrate/templates/*.template.md`  
CSV: `templates/*.header.csv` + `tools/export_tagueamento_migrado_ct.ps1`

## Agentes

| Agente | Arquivo | Saida principal |
|--------|---------|-----------------|
| Orquestrador | `.github/agents/analytics-migrate.agent.md` | - |
| Discover | `.github/agents/analytics-discover.agent.md` | `output/DISCOVER_REPORT.md` |
| Navegacao | `.github/agents/analytics-prune-navigation.agent.md` | `output/NAVEGACAO_AUDITORIA.md` |
| Cobertura | `.github/agents/analytics-coverage.agent.md` | `output/COBERTURA_AUDITORIA.md` |
| Callbacks | `.github/agents/analytics-callbacks.agent.md` | `output/CALLBACKS_MIGRACAO.md` |
| Simplificar | `.github/agents/analytics-simplify.agent.md` | `output/SIMPLIFICACAO_JORNADAS.md` |
| Transformar | `.github/agents/analytics-transform.agent.md` | `output/TAGUEAMENTO_MIGRADO_CT.md` |
| Impacto negocio | `.github/agents/analytics-business-impact.agent.md` | `output/IMPACTO_MIGRACAO.md` |
| Plan (eventos novos) | `.github/agents/analytics-plan.agent.md` | Tagbook VD Studio + `output/TAGBOOK_VDSTUDIO_NOVAS_LINHAS.md` |
| Entrega eng | `scripts/export-entrega-eng.ps1` | `output/ENTREGA_ENG.csv` |

## Instalacao (primeira vez)

Pre-requisito: **acesso de leitura ao repo megazord_mobile**.

**Catalogo (recomendado):** clone [product-skills](https://github.com/sfsantin-gb/product-skills) e rode `install.ps1 -Target C:\megazord_mobile`.

**Local (Spec Kit):**

```powershell
cd C:\megazord_mobile
powershell -ExecutionPolicy Bypass -File tools\analytics-migrate\install-agents.ps1
```

Isso copia agentes para `.github/agents/` e a skill para `.github/skills/` + `.cursor/skills/`.

**Cursor:** abra **somente** o megazord e invoque `@analytics-migrate`.

### Compartilhar com outra squad

1. Link [product-skills](https://github.com/sfsantin-gb/product-skills) + [`PM_QUICKSTART.md`](PM_QUICKSTART.md)
2. `install.ps1 -Target C:\megazord_mobile`
3. No Cursor (so megazord): `@analytics-migrate --setup`
4. Depois: gates 1–4 com **pronto** entre cada um; so entao o de-para CSV

Documentacao: `WORKFLOW.md`, `PIPELINE_COMPLETO.md`, `CASE.md`, `INSTALACAO_SKILLS_CORPORATIVAS.md`.
