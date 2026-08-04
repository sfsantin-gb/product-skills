---
name: analytics-transform
description: Gera TAGUEAMENTO_MIGRADO_CT no novo formato interaction_* e callback_* a partir das auditorias aprovadas e EVENTOS_ESSENCIAIS_CT.md.
handoffs:
  - label: Impacto em perguntas de negocio
    agent: analytics-business-impact
    prompt: Gere PERGUNTAS_NEGOCIO.md cruzando EVENTOS_ESSENCIAIS com o inventario migrado.
---

## User Input

```text
$ARGUMENTS
```

## Outline

**Artefato principal (leitura humana):**
`tools/analytics-migrate/output/TAGUEAMENTO_MIGRADO_CT.md`

**Export de-para (obrigatorio quando usuario pedir CSV ou `--export-csv`):**
`tools/analytics-migrate/output/TAGUEAMENTO_MIGRADO_CT.csv`

Executar: `tools/export_tagueamento_migrado_ct.ps1`

### 1. Pre-requisitos

Artefatos das fases anteriores (preferir `.md`, fallback `.csv`):

- `NAVEGACAO_AUDITORIA.md`
- `COBERTURA_AUDITORIA.md`
- `CALLBACKS_MIGRACAO.md`
- `SIMPLIFICACAO_JORNADAS.md`
- `EVENTOS_ESSENCIAIS_CT.md` - norte para manter vs remover
- `CRITERIO_RELEVANCIA.md`
- Decisoes em `MIGRACAO_DECISOES.md`

Se ausentes, gere apenas eventos explicitamente aprovados pelo usuario.

### 2. Regras de transformacao

Consulte `tools/analytics-migrate/docs/REGRAS_FORMATO_NOVO.md` e `docs/EVENTOS_ESSENCIAIS_CT.md`:

- Interacoes essenciais -> `interaction_<grupo>` + `cd_interaction_detail` no formato **`{acao}:{componente}-{contexto}`**
- **`{contexto}` prioriza texto do botao** (`eventLabel`, depois `acao_legado`)
- **`screen_view` existente** -> `status: manter`, `criterio: pageview_ok`
- Novo PV (lacuna) -> `status: adicionar_pageview`
- Callbacks -> `callback_<keyword>_success|error`
- Navegacao in-app -> `remover` (+ `adicionar_pageview` se lacuna)
- Proibido `unknown` em `cd_interaction_detail` — usar `revisar_pm` se ambiguo

Executar CSV: `tools/export_tagueamento_migrado_ct.ps1` (paths default em `tools/analytics-migrate/output/`).

### 3. Formato do markdown (obrigatorio)

Template: `templates/TAGUEAMENTO_MIGRADO_CT.template.md`

1. **Resumo executivo** - total legado / migrado / removido / lacunas / revisar_pm
2. **Por navbar** - tabela: contexto, acao usuario, JSON novo, arquivo tag, status
3. **Removidos** - lista com motivo (`criterio`) e fonte da decisao
4. **Lacunas abertas (TODO)** - itens `adicionar_pageview`
5. **Pendencias revisar_pm**

`Status migracao`: `migrar` | `manter` | `remover` | `adicionar_pageview` | `revisar`

### 4. Export CSV de-para

Colunas:

`navbar`, `dominio_ct`, `prioridade`, `tipo_legado`, `nav_in_app`, `obsoleto`, `anti_padrao`, `anti_padrao_tipo`, `fundir_pai`, `essencial_match`, `revisar_pm`, `lacuna_pageview`, `regra_decisiva`, `criterio`, `status`, `diagnostico`, `contexto_legado`, `acao_legado`, `event_category_legado`, `event_action_legado`, `event_label_legado`, `evento_legado_json`, `arquivo_tag`, `interaction_group`, `cd_interaction_detail`, `json_novo`, `notas`

Valores `criterio` obrigatorios ao sugerir remocao - ver SKILL `analytics-migrate`.

Meta pos-simplificacao: ~200 eventos `migrar` + ~260 `remover` sobre 481 legados.

### 5. Resumo executivo no topo

- Total legado / migrado / removido / lacunas
- Lista de `revisar_pm` pendentes
- Referencia cruzada com secoes de `EVENTOS_ESSENCIAIS_CT.md`
