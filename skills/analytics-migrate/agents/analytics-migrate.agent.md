---
name: analytics-migrate
description: Migra tagueamento legado C&T para interaction_* e callback_* com auditoria de navegacao, cobertura de pageview e simplificacao de jornadas.
handoffs:
  - label: Auditar navegacao
    agent: analytics-prune-navigation
    prompt: Gere NAVEGACAO_AUDITORIA.md a partir do TAGUEAMENTO_LEGADO_CT validando handlers no megazord_mobile.
  - label: Auditar cobertura
    agent: analytics-coverage
    prompt: Cruze candidatos a remocao com pageview (router meta tag, TagNavigatorObserver, setCurrentScreen manual).
  - label: Padronizar callbacks
    agent: analytics-callbacks
    prompt: Gere CALLBACKS_MIGRACAO.md conforme REGRAS_FORMATO_NOVO.md.
  - label: Simplificar jornadas
    agent: analytics-simplify
    prompt: Classifique eventos P0/P1/P2 por dominio C&T usando EVENTOS_ESSENCIAIS_CT.md.
  - label: Gerar inventario migrado
    agent: analytics-transform
    prompt: Produza TAGUEAMENTO_MIGRADO_CT.md e export CSV com criterio essencial vs nao_essencial.
  - label: Impacto em perguntas de negocio
    agent: analytics-business-impact
    prompt: Gere PERGUNTAS_NEGOCIO.md cruzando perguntas-negocio-{squad}.md com inventario migrado.
  - label: Exportar entrega eng
    agent: analytics-migrate
    prompt: Rode export-entrega-eng.ps1 e generate-resumo-de-para.ps1 apos aprovacao PM.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

Interpret `$ARGUMENTS` for:

- `--fase <nome>` - executar uma fase: `navigation`, `coverage`, `callbacks`, `simplify`, `transform`, `business-impact`, `all`
- `--navbar <Inicio|Divulgar|Gestao|Menu>` - limitar escopo
- `--dry-run` - planejar sem gravar artefatos
- `--export-csv` - gerar export tabular alem do markdown principal
- `--export-entrega-eng` - gerar `ENTREGA_ENG.csv` + `RESUMO_DE_PARA.md` (handoff eng)
- `--aprovar` - consolidar decisoes em `MIGRACAO_DECISOES.md`

## Outline

Orquestre a migracao de tagueamento C&T do legado para o novo formato.

### 1. Pre-requisitos

1. Leia `.github/skills/analytics-migrate/SKILL.md`
2. Leia `tools/analytics-migrate/docs/REGRAS_FORMATO_NOVO.md`
3. Leia `tools/analytics-migrate/docs/CRITERIO_RELEVANCIA.md`
4. Leia `tools/analytics-migrate/docs/EVENTOS_ESSENCIAIS_CT.md`
5. Leia `tools/analytics-migrate/output/_tag_extract_{squad}.json` ou `TAGUEAMENTO_LEGADO_*.md`
6. Contexto PM: `config/dominios-{squad}.md`, `config/perguntas-negocio-{squad}.md`, `docs/GUIA_CONTEXTOS_TAGUEAMENTO_CT.md`
7. Codigo: `packages/flutter_monitor/docs/GUIA_TAGUEAMENTO_GA4.md`, `tagger_navigator_observer.dart`

### 2. Pipeline (ordem fixa)

| Fase | Artefato principal | Export opcional |
|------|-------------------|-----------------|
| prune-navigation | `tools/analytics-migrate/output/NAVEGACAO_AUDITORIA.md` | `.csv` |
| coverage | `tools/analytics-migrate/output/COBERTURA_AUDITORIA.md` | `.csv` |
| callbacks | `tools/analytics-migrate/output/CALLBACKS_MIGRACAO.md` | `.csv` |
| simplify | `tools/analytics-migrate/output/SIMPLIFICACAO_JORNADAS.md` | - |
| transform | `tools/analytics-migrate/output/TAGUEAMENTO_MIGRADO_CT.md` | `.csv` |
| business-impact | `tools/analytics-migrate/output/PERGUNTAS_NEGOCIO.md` | - |
| entrega-eng | `tools/analytics-migrate/output/ENTREGA_ENG.csv` | `RESUMO_DE_PARA.md` |

Nao pule coverage apos prune-navigation.
Executar `business-impact` apos `transform` (incluido em `--fase all`).

**Convencao:** markdown em `tools/analytics-migrate/output/`; CSV via `tools/export_tagueamento_migrado_ct.ps1` quando `--export-csv`.

### 3. Regras criticas

- **Navegacao:** cliques `ir-para-*` / `voltar-*` / `ver-mais*` / `ver-tudo*` **sempre remover**; se destino sem pageview, `adicionar_pageview` - **nunca** manter clique como fallback
- **Essencial:** manter apenas eventos que respondem perguntas de `EVENTOS_ESSENCIAIS_CT.md` (PV + share/open + callbacks + funil core)
- **Remocao:** P2, modais granulares (`fundir_pai`), hub sem KPI, gestao fora do mapa essencial (`nao_essencial`)
- **Callbacks:** `callback_<keyword>_success` | `callback_<keyword>_error` + `cd_error_message`
- **Interacoes:** `interaction_<grupo>` + `cd_interaction_detail` (`{acao}:{componente}-{contexto}`; `{contexto}` prioriza texto do botao; proibido `unknown`)
- **Pageview:** `screen_view` existente -> `status: manter` (`pageview_ok`); lacuna -> `adicionar_pageview`

### 4. Saida do orquestrador

Ao final de `--fase all` ou apos business-impact:

- Resumo: total legado, removidos, mantidos, migrados, lacunas abertas
- **`RESUMO_DE_PARA.md`:** contagens migrar / remover / manter / novo
- **`PERGUNTAS_NEGOCIO.md`:** contagem respondivel / parcial / nao respondivel / lacuna
- **`ENTREGA_ENG.csv`:** planilha eng (classificacao + tag + json legado + json novo)
- Lista de itens `revisar_pm` em `MIGRACAO_DECISOES.md`
- CSV com coluna `criterio`: `essencial_p0` | `essencial_p1` | `nao_essencial` | `fundir_pai` | `nav_duplicada` | `lacuna_pageview` | `anti_padrao` | `obsoleto` | `revisar_pm`
- Handoff para `@speckit.specify` / engenharia quando inventario migrado estiver aprovado

## Handoffs

- `@analytics-prune-navigation`, `@analytics-coverage`, `@analytics-callbacks`, `@analytics-simplify`, `@analytics-transform`, `@analytics-business-impact`
- `@analytics-plan` - novos eventos em features (pos-migracao)
- `@speckit.specify` - spec de implementacao no megazord_mobile
