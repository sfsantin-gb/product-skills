# Regras do novo formato de tagueamento C&T

Fonte de verdade para a migracao do inventario legado (`TAGUEAMENTO_LEGADO_CT.*`) para o contrato GA4 unificado da squad **Conteudos e Trafego**.

**Referencias:**

- Inventario legado: [`TAGUEAMENTO_LEGADO_CT.md`](TAGUEAMENTO_LEGADO_CT.md) | [`TAGUEAMENTO_LEGADO_CT.csv`](TAGUEAMENTO_LEGADO_CT.csv)
- Guia de escopo: [`GUIA_CONTEXTOS_TAGUEAMENTO_CT.md`](GUIA_CONTEXTOS_TAGUEAMENTO_CT.md)
- Padrao tecnico Megazord: repo `megazord_mobile` — `packages/flutter_monitor/docs/GUIA_TAGUEAMENTO_GA4.md`
- Dominios: [`../config/dominios-ct.md`](../config/dominios-ct.md)

---

## 1. Envelope da sessao

`client_id` e `session_id` sao responsabilidade do **provider** (`AnalyticsProvider` / bootstrap do app), nao de cada classe `*Tag`. As tags disparam apenas o array `events`.

```json
{
  "client_id": "[[identificador-unico-usuario]]",
  "session_id": "[[identificador-unico-sessao]]",
  "events": [{
    "name": "interaction_divulgar",
    "params": {
      "cd_interaction_detail": "share_catalog:boticario"
    }
  }]
}
```

| Campo | Regra |
|-------|--------|
| `client_id` | Identificador estavel do usuario (ex.: codigo da revendedora) |
| `session_id` | Identificador da sessao atual |
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

### 2.3 Dimensoes adicionais (`cd_*`)

- Padrao de nome: `cd_<nome_da_dimensao>` (snake_case).
- **Limite do projeto:** maximo **100 CDs** no property GA4 — usar o minimo possivel.
- Preferir condensar contexto em `cd_interaction_detail` antes de criar nova CD.

### 2.4 Migracao a partir do legado UA

| Legado | Novo |
|--------|------|
| `event` + `eventCategory` + `eventAction` + `eventLabel` | `interaction_<grupo>` + `cd_interaction_detail` |
| `screen_view` / `setCurrentScreen` | **`manter`** — ja no padrao GA4; status `manter`, criterio `pageview_ok` (nao `migrar`) |
| Novo `screen_view` (lacuna) | status `adicionar_pageview` |
| Eventos de comercio (`logPurchase`, `logViewItemList`, …) | Eventos recomendados Firebase — fora deste contrato |

---

## 3. Callbacks (`callback_*`)

Callbacks de resultado (API, persistencia, operacao assincrona) **nao** usam `interaction_*`.

### 3.1 Sucesso

```json
{
  "name": "callback_add_product_success",
  "params": {}
}
```

- `name`: `callback_<keyword>_success`
- `keyword`: snake_case ingles, verbo de negocio (`add_product`, `edit_sale`, `financial_report`)

### 3.2 Erro

```json
{
  "name": "callback_add_product_error",
  "params": {
    "cd_error_message": "add-product-failed"
  }
}
```

- `name`: `callback_<keyword>_error`
- `cd_error_message`: codigo kebab-case curto em ingles

### 3.3 Migracao a partir do legado

| Legado | Novo |
|--------|------|
| `eventAction: callback:adicionar-produto`, label sucesso | `callback_add_product_success` |
| `eventAction: callback:adicionar-produto`, label erro | `callback_add_product_error` + `cd_error_message` |
| `eventAction: callback:auto_save_sale`, label sucesso | `callback_auto_save_sale_success` |
| `eventAction: callback:relatorio-financeiro`, label erro | `callback_financial_report_error` + `cd_error_message` |

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
