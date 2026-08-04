# Regras do novo formato de tagueamento C&T

Fonte de verdade para a migracao do inventario legado (`TAGUEAMENTO_LEGADO_CT.*`) para o contrato GA4 unificado da squad **Conteudos e Trafego**.

**Referencias:**

- Inventario legado: [`TAGUEAMENTO_LEGADO_CT.md`](TAGUEAMENTO_LEGADO_CT.md) | [`TAGUEAMENTO_LEGADO_CT.csv`](TAGUEAMENTO_LEGADO_CT.csv)
- Guia de escopo: [`GUIA_CONTEXTOS_TAGUEAMENTO_CT.md`](GUIA_CONTEXTOS_TAGUEAMENTO_CT.md)
- Padrao tecnico Megazord: repo `megazord_mobile` — `packages/flutter_monitor/docs/GUIA_TAGUEAMENTO_GA4.md`
- Dominios: [`../config/dominios-ct.md`](../config/dominios-ct.md)

---

## 1. Envelope da sessao

Cada valor de `json_novo` no de-para (`TAGUEAMENTO_MIGRADO_CT.csv`) deve usar o **envelope completo** abaixo. `client_id` e `session_id` sao responsabilidade do **provider** (`AnalyticsProvider` / bootstrap do app), nao de cada classe `*Tag`; no CSV usam placeholders fixos para eng implementar no provider.

```json
{
  "client_id": "[[identificador-unico-usuario]]",
  "session_id": "[[identificador-unico-sessao]]",
  "events": [{
    "name": "interaction_divulgar",
    "params": {
      "cd_interaction_detail": "share:catalog-boticario"
    }
  }]
}
```

| Campo | Regra |
|-------|--------|
| `client_id` | Placeholder `[[identificador-unico-usuario]]` no CSV; em runtime = codigo estavel da revendedora |
| `session_id` | Placeholder `[[identificador-unico-sessao]]` no CSV; em runtime = identificador da sessao atual |
| `events` | Um ou mais hits por chamada ao provider |

---

## 2. Interacoes (`interaction_*`)

### 2.1 Nome do evento (`events[].name`)

Agrupamento por **dominio/squad**, nao por tela ou microapp:

| Agrupamento | `name` |
|-------------|--------|
| Navbar Inicio | `interaction_inicio` |
| Navbar Divulgar (catalogos, MLD, materiais, noticias, treinamentos) | `interaction_divulgar` |
| VD Studio | `interaction_vdstudio` |
| Navbar Gestao (clientes, vendas, estoque, relatorios, hub) | `interaction_gestao` |
| Navbar Menu / atalhos jarvis C&T | `interaction_menu` |

Novos agrupamentos exigem aprovacao do PM — evitar explosao de `interaction_*`.

### 2.2 Parametro principal: `cd_interaction_detail`

| Regra | Valor |
|-------|--------|
| Formato | **`{acao}:{componente}-{contexto}`** em **ingles**, kebab-case |
| Tamanho max. | **100 caracteres** |
| `{acao}` | Verbo da interacao: `click`, `open`, `share`, `view`, `swipe`, `download`, … |
| `{componente}` | Elemento de UI ou entidade: `share-button`, `catalog-card`, `product-item`, … |
| `{contexto}` | **Texto do botao/label** (prioridade) ou tela/modulo (fallback) | `ver-mais`, `compartilhar-catalogo`, `agora-nao`, `catalog-list` |
| Prioridade `{contexto}` | 1) `eventLabel` legado → 2) `acao_legado` ("Toca no botao: …") → 3) slug da tela/tag | |
| Exemplos | `click:button-ver-mais`, `open:catalog-boticario`, `download:button-baixa-a-imagem` |
| Proibido | `unknown`, `unkown` ou placeholders genericos — usar `revisar_pm` se faltar contexto |
| `eventAction: dinamico` no inventario | Placeholder do extrator: label vem de `FormatterHelper.toAnalyticsFormat(...)` em runtime. **Nao** traduzir para `dynamic-content-*`. Preservar variavel no `{contexto}` (ex.: `click:card-${formatterhelper.toanalyticsformat(label)}`). Linhas agregadas duplicadas → `inventario_agregado` / remover |
| Label generico + categoria especifica | Se `eventLabel` e generico (`selecionar`, `confirmar`, `fechar`, …) e o **ultimo segmento** de `eventCategory` estende o label (ex.: `selecionar-produto`), usar o tail como `{contexto}` → `click:button-selecionar-produto` |

### 2.3 Dimensoes adicionais (`cd_*`)

- Padrao de nome: `cd_<nome_da_dimensao>` (snake_case).
- **Limite do projeto:** maximo **100 CDs** no property GA4 — usar o minimo possivel.
- Preferir condensar contexto em `cd_interaction_detail` antes de **criar CD nova**.
- **Obrigatorio no de-para:** se o codigo legado **ja dispara** uma `cd_*` em producao, ela **deve** aparecer em `json_novo` (`events[].params`) na linha correspondente do `TAGUEAMENTO_MIGRADO_CT.csv`. Nao omitir — eng implementa a partir do CSV.
- Quando contexto couber em `cd_interaction_detail` (< 100 chars) **e** nao existia CD separada no legado, nao criar CD extra.
- Inventario de CDs faltantes: [`output/LACUNAS_CD.md`](../output/LACUNAS_CD.md).
- **Variaveis de negocio no legado** (`$brand`, `$sku`, `$quantity`, `$saleId`, …) devem virar `cd_*` em `json_novo` quando o codigo ou o label legado carrega contexto separado (ex.: `cd_brand`, `cd_sku`, `cd_quantity`, `cd_id_venda`). Preservar placeholder runtime: `"cd_brand": "$brand"`.

Exemplo (catalogo + marca):

```json
{
  "client_id": "[[identificador-unico-usuario]]",
  "session_id": "[[identificador-unico-sessao]]",
  "events": [{
    "name": "interaction_divulgar",
    "params": {
      "cd_interaction_detail": "share:catalog-{brand}",
      "cd_brand": "$brand"
    }
  }]
}
```

Exemplo (callback estoque):

```json
{
  "client_id": "[[identificador-unico-usuario]]",
  "session_id": "[[identificador-unico-sessao]]",
  "events": [{
    "name": "callback_estoque_add_product_error",
    "params": {
      "cd_error_message": "add-product-failed",
      "cd_quantity": "$quantity",
      "cd_sku": "$sku"
    }
  }]
}
```

### 2.4 Pageviews (`screen_view`)

Eventos de visualizacao de tela **mantem** o nome GA4/Firebase `screen_view`. Parametros obrigatorios em `events[].params`:

| Parametro | Regra |
|-----------|--------|
| `screen_name` | Path da rota (ex.: `/app-rev/divulgar/catalogos`) — mesmo valor enviado por `setCurrentScreen` / `meta.tag`; preservar placeholders runtime (`$screen`, `${screenTitle}`, …) |
| `cd_page_title` | Titulo legivel da tela para analise; variavel runtime quando o path e dinamico (ex.: `${screenTitle}`, `${sectionName}`) ou texto derivado de `contexto_legado` / `acao_legado` quando estatico |
| `cd_section` | Opcional — galeria de materiais quando `screen_name` inclui `$sectionName` |

**Obrigatorio no CSV:** linhas `manter` e `adicionar_pageview` devem ter `json_novo` com envelope completo, `screen_name` **e** `cd_page_title` em `events[].params`. Coluna **`nome_pageview`** = copia legivel de `screen_name` (rota/path) para filtro rapido no CSV.

Exemplo (pageview estatico):

```json
{
  "client_id": "[[identificador-unico-usuario]]",
  "session_id": "[[identificador-unico-sessao]]",
  "events": [{
    "name": "screen_view",
    "params": {
      "screen_name": "/app-rev/divulgar/catalogos-erro",
      "cd_page_title": "Catalogos digitais - lista de catalogos do ciclo para abrir PDF ou compartilhar link"
    }
  }]
}
```

Exemplo (pageview dinamico):

```json
{
  "client_id": "[[identificador-unico-usuario]]",
  "session_id": "[[identificador-unico-sessao]]",
  "events": [{
    "name": "screen_view",
    "params": {
      "screen_name": "/app-rev/conteudo/novidade/${FormatterHelper.toLowerHyphenated(screenTitle)}",
      "cd_page_title": "${screenTitle}"
    }
  }]
}
```

### 2.5 Migracao a partir do legado UA

| Legado | Novo |
|--------|------|
| `event` + `eventCategory` + `eventAction` + `eventLabel` | `interaction_<grupo>` + `cd_interaction_detail` |
| `screen_view` / `setCurrentScreen` | **`manter`** — envelope GA4 + `screen_view` + `screen_name` + `cd_page_title`; status `manter`, criterio `pageview_ok` (nao `migrar`) |
| Novo `screen_view` (lacuna) | status `adicionar_pageview` |
| Eventos de comercio (`logPurchase`, `logViewItemList`, …) | Eventos recomendados Firebase — fora deste contrato |

---

## 3. Callbacks (`callback_*`)

Callbacks de resultado (API, persistencia, operacao assincrona) **nao** usam `interaction_*`.

### 3.1 Sucesso

- `name`: `callback_<dominio>_<keyword>_success`
- `keyword`: snake_case ingles, verbo de negocio (`add_product`, `edit_sale`, `financial_report`)
- `dominio`: slug do dominio C&T no nome do evento (`estoque`, `vendas`, `gestao`) — derivado de `dominio_ct` / tag

Exemplo estoque:

```json
{
  "client_id": "[[identificador-unico-usuario]]",
  "session_id": "[[identificador-unico-sessao]]",
  "events": [{
    "name": "callback_estoque_add_product_success",
    "params": {}
  }]
}
```

Legado `callback:adicionar-produto` + tag `create_stock_tag` → `callback_estoque_add_product_success|error`.

### 3.2 Erro

```json
{
  "client_id": "[[identificador-unico-usuario]]",
  "session_id": "[[identificador-unico-sessao]]",
  "events": [{
    "name": "callback_estoque_add_product_error",
    "params": {
      "cd_error_message": "add-product-failed"
    }
  }]
}
```

- `name`: `callback_<dominio>_<keyword>_error`
- `cd_error_message`: codigo kebab-case curto em ingles

### 3.3 Migracao a partir do legado

| Legado | Novo |
|--------|------|
| `eventAction: callback:adicionar-produto`, label sucesso | `callback_estoque_add_product_success` |
| `eventAction: callback:adicionar-produto`, label erro | `callback_estoque_add_product_error` + `cd_error_message` |
| `eventAction: callback:auto_save_sale`, label sucesso | `callback_vendas_auto_save_sale_success` |
| `eventAction: callback:relatorio-financeiro`, label erro | `callback_gestao_financial_report_error` + `cd_error_message` |

---

## 4. Remocao de eventos de navegacao interna

### 4.1 Principio

Cliques que **apenas** levam a outra tela in-app sao candidatos a **remocao**. Origem via `last_page` do pageview.

### 4.2 Excecoes obrigatorias (manter tagueamento)

| Comportamento | Exemplos | Motivo |
|---------------|----------|--------|
| Link externo | `openUrl`, `launchUrl`, browser | Nao gera screen in-app |
| Compartilhamento | `shareText`, `Share`, sheet de share | Acao de negocio |
| Acao in-place | confirmar, excluir, modal sem troca de rota | Nao substituido por pageview |

**Nao classificar so pelo `eventLabel`.** Validar handler no codigo.

### 4.3 Navegacao in-app (regra corrigida)

Ver criterio completo: [`CRITERIO_RELEVANCIA.md`](./CRITERIO_RELEVANCIA.md)

| Sinal | Acao |
|-------|------|
| `ir-para-*`, `voltar-para-*`, `ver-mais*`, `ver-tudo*` + push in-app | **Sempre remover** o clique |
| Destino **sem** pageview | **Remover** o clique **e** `adicionar_pageview` no destino — **nao** manter o clique |
| Destino **com** pageview | Apenas remover o clique |
| `abrir-*` + `openUrl` | **Manter** → migrar (nao e nav in-app) |
| `compartilhar-*` | **Manter** → migrar |
| Evento nao dispara | Ver secao 1 de `CRITERIO_RELEVANCIA.md` (obsoleto vs bug) |

### 4.4 Pageview automatico

Rotas com `meta: {'tag': '...'}` em `router.dart` recebem `setCurrentScreen` via `TaggerNavigatorObserver` em `megazord_mobile/apps/megazord/lib/core/routes/observers/tagger_navigator_observer.dart`.

---

## 5. Simplificacao de jornadas

| Prioridade | Criterio | Acao tipica |
|------------|----------|-------------|
| **P0** | KPI/OKR, dashboard diario | Manter e migrar |
| **P1** | Acompanhamento mensal | Manter ou fundir |
| **P2** | Scroll, tooltip, navegacao duplicada | Remover ou fundir |

---

## 6. Artefatos da migracao

**Convencao:** `.md` e o artefato principal (leitura humana). `.csv` e export opcional (`--export-csv`) para scripts e integracoes.

| Artefato principal | Export opcional | Fase |
|--------------------|-----------------|------|
| `NAVEGACAO_AUDITORIA.md` | `.csv` | prune-navigation |
| `COBERTURA_AUDITORIA.md` | `.csv` | coverage |
| `CALLBACKS_MIGRACAO.md` | `.csv` | callbacks |
| `SIMPLIFICACAO_JORNADAS.md` | — | simplify |
| `TAGUEAMENTO_MIGRADO_CT.md` | `.csv` | transform |
| `MIGRACAO_DECISOES.md` | — | todas |

Templates markdown: `templates/*.template.md`

---

## 7. Escopo de codigo

Ver `GUIA_CONTEXTOS_TAGUEAMENTO_CT.md` — 217 arquivos `*_tag*.dart` nos microapps C&T do `megazord_mobile`.
