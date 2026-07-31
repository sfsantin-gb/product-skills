---
name: analytics-coverage
description: Audita lacunas de pageview antes de remover eventos de navegacao; detecta telas desconfiguradas e eventos obsoletos no megazord_mobile.
handoffs:
  - label: Padronizar callbacks
    agent: analytics-callbacks
    prompt: Continue migracao com CALLBACKS_MIGRACAO.md apos cobertura aprovada.
---

## User Input

```text
$ARGUMENTS
```

## Outline

**Artefato principal (leitura humana):**
`tools/analytics-migrate/output/COBERTURA_AUDITORIA.md`

**Export opcional (agentes/scripts):**
`tools/analytics-migrate/output/COBERTURA_AUDITORIA.csv`
— gerar somente se o usuario pedir `--export-csv` ou o orquestrador incluir export.

### 1. Leitura obrigatoria

1. `NAVEGACAO_AUDITORIA.md` (preferir) ou `.csv` (fallback)
2. `REGRAS_FORMATO_NOVO.md` - secao 4.4
3. `tagger_navigator_observer.dart` no megazord_mobile
4. `router.dart` dos microapps C&T listados no `GUIA_CONTEXTOS_TAGUEAMENTO_CT.md`
5. Template: `templates/ARTEFATO_AUDITORIA.template.md`


### 2. Politica de navegacao (corrigida)

- Cliques ir-para-* / voltar-* / ver-mais* saem do inventario migrado
- Se destino e tela essencial sem PV: veredito substituir + linha adicionar_pageview em transform
- Nunca recomendar manter clique de navegacao como fallback
- Cruzar destinos com EVENTOS_ESSENCIAIS_CT.md
### 2. Fontes de pageview (qualquer uma valida)

| `fonte_pageview` | Onde buscar |
|------------------|-------------|
| `meta.tag` | `AutoRoute(..., meta: {'tag': '...'})` no router do microapp |
| `setCurrentScreen_manual` | `*_tag_impl.dart` chamado no init/build do widget |
| `tab_sem_screen` | Aba dentro da mesma rota - **lacuna tipica** |
| `modal_sem_screen` | Bottom sheet/modal sem setCurrentScreen |
| `cross_microapp` | `PublisherAction` - cadeia origem/destino incerta |
| `nenhum` | Sem cobertura detectada |

### 3. Para cada evento com veredito `remover` em navegacao

1. Identifique rota/tela destino (SITEMAP + codigo)
2. Verifique se destino tem pageview
3. Emita veredito final:

| `veredito` | Significado |
|------------|-------------|
| `ok_remover` | Destino tem pageview confiavel |
| `lacuna_aberta` | Clique sai do migrado; registrar adicionar_pageview no destino (nunca manter clique como fallback) |
| `substituir` | Remover clique mas adicionar pageview/interaction no destino |
| `revisar_pm` | Tab, cross-microapp, fluxo ambiguo |
| `manter` | Nao e navegacao entre telas |

### 4. Auditoria de eventos faltantes / desconfigurados

Alem dos candidatos a remocao, reportar em secao propria do markdown:

- Rotas C&T no SITEMAP **sem** `meta['tag']` nem `setCurrentScreen`
- Screen paths suspeitos (ex.: `gerenciar-clientes2`, paths fora do padrao `/app-rev/...`)
- Event names legados fora do padrao (`add_customer`, `eventAction` vazio no extrator mas preenchido no codigo)
- Metodos em `*_tag_impl.dart` **sem referencia** em `lib/` (candidato obsoleto) - amostrar por microapp se escopo grande

### 5. Formato do markdown (obrigatorio)

Estruture para leitura rapida:

1. **Resumo executivo** — contagem por veredito final
2. **Bloqueados** — secao prioritária com lacuna e acao recomendada
3. **Revisar PM** — decisoes de produto ou eventos mortos
4. **Manter** — comportamentos in-page
5. **Ok para remover** — tabelas por navbar (Divulgar, Gestao)
6. **Achados extras** — rotas sem tag, codigo obsoleto
7. **Legenda** de vereditos

Colunas nas tabelas: event label, tag, destino, fonte pageview, lacuna (se houver), recomendacao.

### 6. Export CSV (opcional)

Se `--export-csv`, colunas:

`navbar`, `evento_legado_json`, `arquivo_tag`, `acao_proposta`, `destino_rota_esperada`, `tem_pageview`, `fonte_pageview`, `lacuna`, `recomendacao`, `veredito`

### 7. Casos criticos conhecidos (sempre validar)

- Relatorio financeiro como **aba** em `SalesReportPage` - tab switch nao gera novo screen_view
- `ir-para-pronta-entrega` via `PublisherAction` + delay
- Catalogo `abrir-catalogo` usa `openUrl` - **nao** e lacuna de navegacao; manter interacao
