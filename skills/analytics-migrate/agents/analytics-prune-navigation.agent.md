---
name: analytics-prune-navigation
description: Identifica eventos de navegacao interna candidatos a remocao no inventario legado C&T, preservando links externos e compartilhamento.
handoffs:
  - label: Validar cobertura pageview
    agent: analytics-coverage
    prompt: Valide pageview dos destinos dos eventos marcados para remocao em NAVEGACAO_AUDITORIA.md.
---

## User Input

```text
$ARGUMENTS
```

## Outline

**Artefato principal (leitura humana):**
`tools/analytics-migrate/output/NAVEGACAO_AUDITORIA.md`

**Export opcional (agentes/scripts):**
`tools/analytics-migrate/output/NAVEGACAO_AUDITORIA.csv`
— gerar somente se o usuario pedir `--export-csv` ou o orquestrador incluir export.

### 1. Leitura obrigatoria

1. `REGRAS_FORMATO_NOVO.md` - secao 4
2. `TAGUEAMENTO_LEGADO_CT.csv`
3. `SITEMAP_CT.md`
4. Template: `templates/ARTEFATO_AUDITORIA.template.md`

### 2. Para cada evento do legado

1. Localize `arquivo_tag` e metodo no `megazord_mobile`
2. Rastreie o widget/page que invoca o metodo
3. Classifique comportamento:

| `comportamento_codigo` | Criterio |
|------------------------|----------|
| `navegacao_interna` | `router.push`, `navigate`, `PublisherAction` para outra tela |
| `link_externo` | `openUrl`, `launchUrl`, WebView externa |
| `compartilhamento` | `shareText`, `Share`, `clique:compartilhar` |
| `acao_in_place` | modal, API, confirmacao sem troca de rota |
| `pageview` | `setCurrentScreen` / screen_view - nao candidato a remocao por navegacao |
| `callback` | delegar a `@analytics-callbacks` |
| `indefinido` | marcar `revisar` |

4. **Nunca** marcar `remover` para `link_externo` ou `compartilhamento`, mesmo com label `abrir-*`

### 3. Veredito preliminar

| Veredito | Quando |
|----------|--------|
| `remover` | `navegacao_interna` - sujeito a confirmacao em coverage |
| `manter` | externo, share, in-place, callback, pageview |
| `revisar` | codigo nao encontrado ou fluxo ambiguo |

### 4. Formato do markdown (obrigatorio)

Estruture para leitura rapida:

1. **Resumo** no topo — tabela de contagem por veredito
2. **Secoes por navbar** (Divulgar, Gestao, Inicio, Menu)
3. Dentro de cada navbar, subsecoes por veredito: `Remover` → `Revisar` → `Manter`
4. Tabelas curtas: event label, tag, comportamento, evidencia (`arquivo` → `metodo`), motivo
5. **Legenda** de vereditos no final
6. Link para CSV export no topo (se gerado)

Evite JSON inline no markdown — use event label + tag + categoria legado resumida.

### 5. Export CSV (opcional)

Se `--export-csv`, use header em `templates/NAVEGACAO_AUDITORIA.header.csv`:

`navbar`, `evento_legado_json`, `arquivo_tag`, `event_label`, `comportamento_codigo`, `veredito`, `motivo`, `evidencia_arquivo`, `evidencia_metodo`

### 6. Heuristicas de label (somente pista - codigo manda)

- `ir-para-*`, `voltar-para-*` → provavel `navegacao_interna`
- `ver-mais`, `ver-tudo` → provavel `navegacao_interna`
- `compartilhar-*` → `compartilhamento`
- `abrir-*` → **indefinido** ate ver `openUrl` vs `push`
