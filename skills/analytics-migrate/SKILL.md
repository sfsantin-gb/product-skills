---
name: analytics-migrate
description: >-
  Migra tagueamento legado (megazord_mobile) para interaction_* e callback_*
  com auditoria de navegacao, cobertura de pageview e simplificacao. Use quando
  mencionar migracao de tagueamento, TAGUEAMENTO_LEGADO, analytics-migrate,
  --setup, primeira vez, nova squad, remover eventos de navegacao ou novo formato GA4.
  PMs: comece com @analytics-migrate --setup ou PM_QUICKSTART.md.
---

# Analytics Migrate

Skill do pipeline `@analytics-migrate`. **Roda no megazord_mobile** — Product OS nao e necessario.

Instalacao: [product-skills](https://github.com/sfsantin-gb/product-skills) `install.ps1` **ou** `tools/analytics-migrate/install-agents.ps1`. Abra **somente** o megazord no Cursor.

## PM — caminho recomendado (guiado)

```text
@analytics-migrate --setup
```

O agente **entrevista** o PM (squad, time GitHub, dominios, perguntas P0/P1), gera os arquivos de contexto, roda o discover e pergunta se quer seguir com o pipeline.

Leia tambem **`tools/analytics-migrate/PM_QUICKSTART.md`**.

### Etapa 1 — Input do PM (manual OU via --setup)

| # | Acao | Arquivo |
|---|------|---------|
| 1 | Mapear dominios e contextos da squad | `config/dominios-{squad}.md` (template: `templates/dominios-squad.template.md`) |
| 2 | Indicar **perguntas de negocio principais** (P0/P1) por dominio | `config/perguntas-negocio-{squad}.md` (template: `templates/perguntas-negocio-squad.template.md`) |
| 3 | Apontar paths no config | `analytics-migrate.config.yml` → `workspace.dominios` + `workspace.perguntas_negocio` |

Scaffold via script (usado pelo `--setup`):

```powershell
powershell -ExecutionPolicy Bypass -File tools\analytics-migrate\scripts\setup-squad.ps1 -ListTeams
powershell -ExecutionPolicy Bypass -File tools\analytics-migrate\scripts\setup-squad.ps1 `
  -SquadId minha-squad -SquadName "Minha Squad" -GithubTeam vd-sellout-exemplo
```

### Etapa 2 — Skill (automatico)

```text
discover.ps1  →  @analytics-migrate --fase all --export-csv  →  apply-migracao-decisoes.ps1 (se decisoes PM)
```

Artefatos gerados em `tools/analytics-migrate/output/`:

| Artefato | Para o PM |
|----------|-----------|
| `RESUMO_DE_PARA.md` | **Numeros gerais** (migrar / remover / manter / novo) |
| `PERGUNTAS_NEGOCIO.md` | Perguntas respondiveis vs nao — trade-offs da migracao |
| `TAGUEAMENTO_MIGRADO_CT.csv` | Inventario completo com criterios |

### Etapa 3 — Revisao PM + entrega ENG

| # | Acao | Saida |
|---|------|-------|
| 1 | Ler `RESUMO_DE_PARA.md` (contagens) | — |
| 2 | Revisar `PERGUNTAS_NEGOCIO.md` — preencher coluna **Decisao PM (se discordar)** | Respostas / discordancias |
| 3 | `@analytics-migrate --aprovar` | `MIGRACAO_DECISOES.md` |
| 4 | Regenerar entrega (ou rodar apply script) | **`ENTREGA_ENG.csv`** |

**Entrega final para engenharia:** `output/ENTREGA_ENG.csv`

| Coluna | Conteudo |
|--------|----------|
| `navbar` | Area / microapp |
| `dominio_ct` | Dominio C&T |
| `status` | Status do de-para (`migrar`, `remover`, `adicionar_pageview`, …) |
| `classificacao` | Acao eng: `novo` · `migrar` · `remover` |
| `contexto_legado` | Contexto legivel do evento legado |
| `evento_legado_json` | JSON legado para ctrl+F (vazio em `novo`; reconstruido se vazio nas demais) |
| `json_novo` | Envelope GA4 alvo (completo) |

Pageviews ok (`manter`) ficam de fora por padrao; `export-entrega-eng.ps1 -IncludeManter` inclui referencia.

Script manual: `powershell -ExecutionPolicy Bypass -File tools/analytics-migrate/scripts/export-entrega-eng.ps1`

PM **nao** edita Dart; foco em dominios, perguntas P0/P1, trade-offs e aprovacao de remocoes.

## Leitura obrigatoria (agente)

1. `tools/analytics-migrate/PM_QUICKSTART.md`
2. `tools/analytics-migrate/docs/REGRAS_FORMATO_NOVO.md`
3. `tools/analytics-migrate/docs/CRITERIO_RELEVANCIA.md`
4. `tools/analytics-migrate/docs/EVENTOS_ESSENCIAIS_CT.md` (ou rascunho gerado pelo discover)
5. `tools/analytics-migrate/output/_tag_extract_{squad}.json` ou `TAGUEAMENTO_LEGADO_*.md`
6. `tools/analytics-migrate/docs/GUIA_CONTEXTOS_TAGUEAMENTO_CT.md`
7. `tools/analytics-migrate/config/dominios-{squad}.md`
8. `packages/flutter_monitor/docs/GUIA_TAGUEAMENTO_GA4.md`
9. `apps/megazord/lib/core/routes/observers/tagger_navigator_observer.dart`

## Pipeline

```
discover (script)               -> output/DISCOVER_REPORT.md + _tag_extract_{squad}.json
  tools/analytics-migrate/scripts/discover.ps1

analytics-migrate (orquestrador)
  -> analytics-prune-navigation   -> output/NAVEGACAO_AUDITORIA.md
  -> analytics-coverage           -> output/COBERTURA_AUDITORIA.md
  -> analytics-callbacks          -> output/CALLBACKS_MIGRACAO.md
  -> analytics-simplify           -> output/SIMPLIFICACAO_JORNADAS.md
  -> analytics-transform          -> output/TAGUEAMENTO_MIGRADO_CT.md + CSV
  -> analytics-business-impact     -> output/PERGUNTAS_NEGOCIO.md
  -> export-entrega-eng.ps1         -> output/ENTREGA_ENG.csv (handoff eng)
  -> generate-resumo-de-para.ps1    -> output/RESUMO_DE_PARA.md
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
| Impacto negocio | `.github/agents/analytics-business-impact.agent.md` | `output/PERGUNTAS_NEGOCIO.md` |
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
4. Depois: `@analytics-migrate --fase all --export-csv` (se nao rodou no fim do setup)

Documentacao: `WORKFLOW.md`, `PIPELINE_COMPLETO.md`, `CASE.md`, `INSTALACAO_SKILLS_CORPORATIVAS.md`.
