# Criterio de relevancia — migracao tagueamento C&T

> Fonte de verdade para decidir **manter**, **remover**, **fundir** ou **adicionar pageview**.
> Usado por `@analytics-simplify`, `@analytics-coverage`, `@analytics-transform` e export CSV.

Referencias: [`REGRAS_FORMATO_NOVO.md`](./REGRAS_FORMATO_NOVO.md) | [`MIGRACAO_DECISOES.md`](./MIGRACAO_DECISOES.md)

---

## 1. Evento nao dispara — obsoleto ou bug?

Antes de falar em relevancia, classificar **por que** o evento nao aparece nos dados:

| Situacao | Diagnostico | Evidencia no codigo | Acao |
|----------|-------------|---------------------|------|
| Metodo na tag **sem chamada** em `lib/` (so testes) | **Obsoleto** | grep widget → metodo ausente | `remover` tag + linha do inventario |
| UI chama callback **vazio** (`() {}`) | **Obsoleto** | widget com handler vazio | `remover` |
| Fluxo **removido do produto** (feature off) | **Obsoleto** | SITEMAP / PM confirma | `remover` |
| Fluxo **ativo no produto**, metodo existe, widget **deveria** chamar mas nao chama | **Bug de implementacao** | SITEMAP ativo + gap no widget | **Nao remover** — abrir task engenharia |
| Extrator inventario **errado** (falso positivo) | **Inventario** | codigo dinamico / template | `revisar` + corrigir extrator |

**Regra:** obsoleto → remove do migrado. Bug → corrige wiring **antes** de decidir relevancia (senao perde-se sinal de funil quebrado).

---

## 2. Navegacao in-app — regra corrigida

Labels tipicas: `ir-para-*`, `voltar-para-*`, `ver-mais*`, `ver-tudo*`.

### O clique de navegacao **sempre sai** do inventario migrado

Nao mantemos evento de clique para substituir navegacao entre telas. Pageview (automatico ou manual) e a fonte de verdade de "usuario chegou na tela".

| Pergunta | Resposta |
|----------|----------|
| Destino ja tem pageview? | **Remover** o clique. Nada mais a fazer. |
| Destino **nao** tem pageview? | **Remover** o clique **e** mapear `adicionar_pageview` no destino. **Nao** manter o clique como fallback. |

### Fluxo de decisao

```
Clique ir-para-* / voltar-* / ver-mais* / ver-tudo*
        |
        v
  E openUrl / share externo? ----sim----> MANTER (interaction_*, nao e nav in-app)
        |
       nao
        v
  status = REMOVER (clique)
        |
        v
  Destino tem pageview confiavel?
        |
   sim--+---> fim (so remover clique)
        |
       nao
        v
  status = ADICIONAR_PAGEVIEW no destino
  (screen_view ou interaction ao exibir tela/aba)
        |
        v
  Depois que pageview existir: clique ja esta removido
```

### Excecoes (nao sao navegacao in-app)

| Label / comportamento | Tratamento |
|-----------------------|------------|
| `abrir-catalogo` + `openUrl` | **Manter** → `interaction_divulgar` / `open_catalog:*` |
| `compartilhar-*` | **Manter** |
| `navegacao` swipe **na mesma** galeria | Nao e troca de rota → P2 fundir/remover por relevancia, nao regra de pageview |

### Lacunas conhecidas (remover clique + adicionar pageview)

| Clique legado | Tag | Pageview a implementar |
|---------------|-----|------------------------|
| `ir-para-relatorio` | `payment_detail_model_tag`, `payment_methods_tag` | Aba financeira em `SalesReportPage` |
| (proposta) deep link `startAtFinancialTab` | `sales_report_tag` | `screen_view` da aba financeira no load |

---

## 3. Score de relevancia (eventos que permanecem)

Aplicar **somente** a eventos que nao foram removidos pelas regras 1 e 2.

| Dimensao | +1 se… |
|----------|--------|
| **Decisao** | Alimenta OKR/KPI ou decisao operacional da RE |
| **Frequencia** | Acao recorrente no funil (nao edge unico) |
| **Irreversivel** | Commit, handoff, callback de operacao |
| **Diagnostico** | Explica falha (callbacks erro, estados de erro) |
| **Nao substituivel** | Nenhum pageview/interaction pai captura o mesmo |

| Score | Veredito |
|-------|----------|
| 0–1 | `remover` ou fundir no pai |
| 2 | `fundir` ou `revisar_pm` |
| 3–5 | `migrar` (P0 se callback/share/funil core) |

### Anti-padroes (score 0, remover direto)

- `clique:tooltip`
- `interacao:scroll` em carrossel
- `show:modal` isolado (fundir no pai)
- Modais com granularidade excessiva (`*:modal:*:botao`) → fundir

---

## 4. Prioridade de implementacao

| Prioridade | Quando |
|------------|--------|
| **P0** | Callbacks, compartilhar/abrir, funil vendas/clientes core |
| **P1** | Score 2–3, diagnostico periodico |
| **P2** | Score 0–1, anti-padroes |

Ordem sugerida no rollout: **adicionar_pageview** (lacunas) → **P0 migrar** → remover cliques nav → P1 → P2.

---

## 5. Colunas no CSV de-para

### Decisao

| Coluna | Valores |
|--------|---------|
| `status` | `migrar` \| `remover` \| `adicionar_pageview` \| `revisar` |
| `criterio` | `essencial_p0` \| `essencial_p1` \| `nao_essencial` \| `fundir_pai` \| `nav_duplicada` \| `lacuna_pageview` \| `anti_padrao` \| `obsoleto` \| `revisar_pm` |
| `prioridade` | `P0` \| `P1` \| `P2` \| `revisar` \| `lacuna` |
| `regra_decisiva` | Regra que encerrou o pipeline (ex.: `callback_p0`, `nav_duplicada`, `fora_mapa_essencial`) |
| `notas` | Texto livre com destino / acao engenharia |

### Classificacoes intermediarias (diagnostico)

| Coluna | Valores | Significado |
|--------|---------|-------------|
| `dominio_ct` | Nome da area em EVENTOS_ESSENCIAIS_CT.md | Dominio C&T para saude/performance |
| `tipo_legado` | `screen_view` \| `callback` \| `interaction` \| `custom` | Tipo do evento legado |
| `nav_in_app` | `sim` \| `nao` \| `na` | Clique de navegacao in-app |
| `obsoleto` | `sim` \| `nao` | Codigo morto confirmado |
| `anti_padrao` | `sim` \| `nao` | tooltip, scroll, modal isolado, etc. |
| `anti_padrao_tipo` | `tooltip` \| `scroll` \| `show_modal` \| ... | Subtipo quando `anti_padrao=sim` |
| `fundir_pai` | `sim` \| `nao` | Granularidade modal/parcela/SKU |
| `essencial_match` | `p0` \| `p1` \| `nao` \| `na` | Match no mapa EVENTOS_ESSENCIAIS_CT |
| `revisar_pm` | `sim` \| `nao` | Pendencia de produto |
| `lacuna_pageview` | `sim` \| `nao` | Destino essencial sem PV |
| `diagnostico` | cadeia `>` | Pipeline completo: dominio > checks > decisao |

**Ordem do pipeline no `diagnostico`:** dominio > tipo > callback > revisar_pm > obsoleto > nav_in_app > anti_padrao > fundir_pai > essencial > nao_essencial > decisao

Export: `megazord_mobile/tools/export_tagueamento_migrado_ct.ps1`
---

## 6. Responsabilidades

| Pergunta | Quem |
|----------|------|
| Dispara no codigo? Obsoleto vs bug? | Engenharia (`prune-navigation`) |
| Destino tem pageview? | Agente `coverage` + codigo |
| Score / P0–P2 | PM + `simplify` |
| Inventario final | `transform` + CSV |
---

## 7. Eventos essenciais por area (EVENTOS_ESSENCIAIS_CT.md)

Antes de classificar score generico, cruzar com o mapa de saude/performance:

| Criterio CSV | Significado |
|--------------|-------------|
| `essencial_p0` | Responde pergunta norte da secao (callback, share/open, PV, funil core) |
| `essencial_p1` | Diagnostico periodico ou acao de funil secundaria no dominio |
| `nao_essencial` | Fora do mapa; hub/atalho duplica pageview; gestao sem KPI |
| `fundir_pai` | Modal/parcela/SKU - granularidade a consolidar no interaction pai |
| `revisar_pm` | Ambiguidade (assistant, tarefas, Encontre, cross-tab) |

**Regra:** se o evento nao ajuda a responder nenhuma pergunta de EVENTOS_ESSENCIAIS_CT.md e nao e callback/share/PV, preferir `remover` com `nao_essencial`.

Export: `megazord_mobile/tools/export_tagueamento_migrado_ct.ps1`
