# Regras do novo formato de tagueamento C&T

Fonte de verdade para a migracao do inventario legado (`TAGUEAMENTO_LEGADO_CT.*`) para o contrato GA4 unificado da squad **Conteudos e Trafego**.

**Referencias:**

- Inventario legado: [`TAGUEAMENTO_LEGADO_CT.md`](TAGUEAMENTO_LEGADO_CT.md) | [`TAGUEAMENTO_LEGADO_CT.csv`](TAGUEAMENTO_LEGADO_CT.csv)
- Guia de escopo: [`GUIA_CONTEXTOS_TAGUEAMENTO_CT.md`](GUIA_CONTEXTOS_TAGUEAMENTO_CT.md)
- Padrao tecnico Megazord: repo `megazord_mobile` — `packages/flutter_monitor/docs/GUIA_TAGUEAMENTO_GA4.md`
- Dominios: [`../config/dominios-ct.md`](../config/dominios-ct.md)
- Eventos recomendados GA4 (oficial): [developers.google.com/analytics/.../events](https://developers.google.com/analytics/devguides/collection/ga4/reference/events?hl=pt-br&client_type=gtag)

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
| Eventos de comercio / busca (`logPurchase`, `logViewItemList`, `logSearch`, …) | Eventos recomendados GA4 — ver **secao 3** |

---

## 3. Eventos recomendados GA4 (e-commerce e search)

Eventos **padronizados** do Google Analytics 4 para funil de produto, carrinho, checkout, promocao e busca. Usam o **nome oficial** do evento (`view_item`, `purchase`, …) — **nao** viram `interaction_*` nem `callback_*`.

Fonte: [Eventos recomendados GA4](https://developers.google.com/analytics/devguides/collection/ga4/reference/events?hl=pt-br&client_type=gtag).

### 3.1 Quando usar (vs `interaction_*` / `callback_*`)

| Situacao | Contrato |
|----------|----------|
| RE **tem intencao de comprar ou esta realizando a compra** (lista/detalhe → carrinho → checkout → `purchase`), promocao/busca **nesse** funil, frete de compra no header | **Preferir** evento recomendado GA4 desta secao (excecoes C&T: promocao e frete **sem** `items`) |
| **Sellout → compra de estoque:** a partir de uma venda registrada, RE adiciona produtos ao **carrinho de compra** para repor estoque e entregar ao cliente | **ECOM** (`add_to_cart` → … → `purchase`) |
| RE **cadastra no app** produtos **ja comprados** (gestao de estoque / “adicionar ao estoque” / editar SKU) | `interaction_gestao` / `callback_estoque_*` — **nao** ECOM |
| RE **vende / registra / cobra sellout** ao cliente (inclui adicionar SKU **a venda**) | `interaction_gestao` / `callback_vendas_*` — **nao** ECOM |
| Clique de UI fora do funil ecommerce (share, openUrl, filtros de gestao, etc.) | `interaction_<grupo>` + `cd_interaction_detail` |
| Resultado de API / persistencia **fora** do funil ecommerce (ou erro auxiliar) | `callback_<dominio>_<keyword>_success\|error` |
| Visualizacao de tela | `screen_view` (secao 2.4) |

**Regra C&T (evitar confusao):** ECOM e reservado a **intencao ou ato de compra** — inclusive reposicao de estoque a partir de uma venda sellout. Informar no app produtos que a RE **ja adquiriu** (cadastro de estoque) e montar a **venda do cliente** **nao** sao ECOM. Mapa de saude: [`EVENTOS_ESSENCIAIS_CT.md`](./EVENTOS_ESSENCIAIS_CT.md).

**Nao** mapear gestos de compra real (`add_to_cart` / `purchase` / `search` no checkout, incl. CTA sellout → carrinho de compra) para `interaction_*` — perde relatorios nativos de ecommerce do GA4. Do mesmo modo, **nao** forcar ECOM em cadastro de estoque nem em `adicionar-produto-a-venda`.

No de-para (`TAGUEAMENTO_MIGRADO_CT.csv`): `events[].name` = nome GA4; params oficiais em `events[].params` (sem prefixo `cd_` nos campos padrao). CDs custom (`cd_*`) so quando o legado ja envia dimensao extra que nao cabe nos params oficiais.

### 3.2 Catalogo no escopo C&T

Ordem tipica do funil + promocao + busca:

| Evento | Quando disparar | Params de evento (alem de `items`, quando houver) |
|--------|-----------------|-----------------------------------------------------|
| `view_item_list` | Lista/categoria de itens exibida | `currency`*, `item_list_id`, `item_list_name` |
| `select_item` | Usuario seleciona item na lista | `item_list_id`, `item_list_name` |
| `view_item` | Detalhe / conteudo do item exibido | `currency`*, `value`*, `item_list_name` |
| `add_to_wishlist` | Item adicionado a lista de desejos | `currency`*, `value`*, `item_list_name` |
| `add_to_cart` | Item adicionado ao carrinho | `currency`*, `value`*, `item_list_name` |
| `remove_from_cart` | Item removido do carrinho | `currency`*, `value`*, `item_list_name` |
| `begin_checkout` | Inicio do checkout | `currency`*, `value`*, `coupon` |
| `add_shipping_info` | Selecao de frete no **header** (fora do funil de compra) | `currency`, `shipping_tier` — **sem** `items` / `value` / `coupon` |
| `add_payment_info` | Pagamento informado no checkout | `currency`*, `value`*, `coupon`, `payment_type` |
| `purchase` | Compra concluida | `currency`*, `value`*, `transaction_id` (**obrigatorio**), `coupon`, `shipping`, `tax`, `customer_type` |
| `view_promotion` | Promocao exibida | `creative_name`, `creative_slot`, `promotion_id`, `promotion_name` — **sem** `items` |
| `select_promotion` | Promocao selecionada | `creative_name`, `creative_slot`, `promotion_id`, `promotion_name` — **sem** `items` |
| `search` | Usuario realizou busca | `search_term` (**obrigatorio**) — **sem** matriz `items` |

\* `currency` e `value`: obrigatorios **quando** `value` e enviado; `currency` = ISO 4217 (ex.: `BRL`). `value` = soma de `(price * quantity)` dos itens em `items` — **nao** incluir `shipping` nem `tax` em `value`.

| Evento | `items` |
|--------|---------|
| Funil de produto (`view_item_list`, `select_item`, `view_item`, `add_to_wishlist`, `add_to_cart`, `remove_from_cart`, `begin_checkout`, `add_payment_info`, `purchase`) | **Obrigatorio** |
| `view_promotion` / `select_promotion` | **Nao se aplica** (promocao sem matriz de produtos) |
| `add_shipping_info` | **Nao se aplica** (frete global no header, nao vinculado a itens do carrinho) |
| `search` | Nao se aplica |

### 3.3 Parametros compartilhados da matriz `items`

Em todo evento com `items`, cada item exige **`item_id` ou `item_name`** (pelo menos um). Demais campos sao opcionais, mas recomendados para relatorios:

| Parametro | Tipo | Obrigatorio | Descricao |
|-----------|------|-------------|-----------|
| `item_id` | string | Sim* | SKU / ID do item |
| `item_name` | string | Sim* | Nome do item |
| `affiliation` | string | Nao | Loja / afiliacao (somente no item) |
| `coupon` | string | Nao | Cupom no nivel do item (independente do cupom do evento) |
| `discount` | number | Nao | Desconto unitario |
| `index` | number | Nao | Posicao na lista |
| `item_brand` | string | Nao | Marca |
| `item_category` … `item_category5` | string | Nao | Hierarquia de categorias |
| `item_list_id` / `item_list_name` | string | Nao | Lista de origem; se no item, sobrescreve o nivel do evento |
| `item_variant` | string | Nao | Variante (cor, tamanho, …) |
| `location_id` | string | Nao | Local fisico (somente no item) |
| `price` | number | Nao | Preco unitario na moeda do evento; se houver desconto, `price` = unitario com desconto |
| `quantity` | number | Nao | Default `1` se omitido |

Ate **27 parametros personalizados** por item alem dos prescritos. Em C&T, preferir params oficiais; so criar `cd_*` no nivel do evento quando o legado ja envia dimensao que nao mapeia para a tabela acima.

**Excecoes sem `items`:** `view_promotion`, `select_promotion`, `add_shipping_info` e `search` — nao usam a matriz de produtos.

### 3.4 Detalhe por evento

#### `search`

| Parametro | Obrigatorio | Notas |
|-----------|-------------|-------|
| `search_term` | Sim | Termo pesquisado |

Nao usa `items`, `currency` nem `value`.

#### `view_item_list` / `select_item`

| Parametro | Obrigatorio | Notas |
|-----------|-------------|-------|
| `items` | Sim | Lista exibida (`view_item_list`) ou item selecionado (`select_item`) |
| `item_list_id` / `item_list_name` | Nao | Ignorados se definidos no item |
| `currency` | Condicional | Em `view_item_list` quando houver `value` |

#### `view_item` / `add_to_wishlist` / `add_to_cart` / `remove_from_cart`

| Parametro | Obrigatorio | Notas |
|-----------|-------------|-------|
| `items` | Sim | |
| `currency` / `value` | Condicional | Enviar juntos; `value` = soma `(price * quantity)` |
| `item_list_name` | Sim (contrato C&T) | Nome da lista de origem no **nivel do evento** |

#### `begin_checkout`

| Parametro | Obrigatorio | Notas |
|-----------|-------------|-------|
| `items` | Sim | |
| `currency` / `value` | Condicional | |
| `coupon` | Nao | |

#### `add_shipping_info`

No app C&T, frete **nao** faz parte do funil de compra de produtos: fica acessivel a qualquer momento no **header**. Contrato reduzido — **somente**:

| Parametro | Obrigatorio | Notas |
|-----------|-------------|-------|
| `currency` | Sim | ISO 4217 (ex.: `BRL`) |
| `shipping_tier` | Sim | Ex.: `terrestre`, `expresso` |

**Nao enviar** `items`, `value`, `coupon` nem demais params de checkout neste evento.

#### `add_payment_info`

| Parametro | Obrigatorio | Notas |
|-----------|-------------|-------|
| `items` | Sim | |
| `currency` / `value` | Condicional | |
| `coupon` | Nao | |
| `payment_type` | Nao | Ex.: `credit-card`, `pix` |

#### `purchase`

| Parametro | Obrigatorio | Notas |
|-----------|-------------|-------|
| `transaction_id` | **Sim** | Evita compra duplicada no GA4 |
| `items` | Sim | |
| `currency` / `value` | Condicional / recomendado | `value` sem frete/imposto |
| `coupon` | Nao | |
| `shipping` | Nao | Frete da transacao |
| `tax` | Nao | Tributos da transacao |
| `customer_type` | Nao | `new` ou `returning` |

#### `view_promotion` / `select_promotion`

Promocoes **sem** matriz `items` — apenas metadados do criativo/promocao no nivel do evento:

| Parametro | Obrigatorio | Notas |
|-----------|-------------|-------|
| `creative_name` / `creative_slot` | Nao | Criativo e slot |
| `promotion_id` / `promotion_name` | Nao | Identidade da promocao |

**Nao enviar** `items` (nem `currency` / `value` de produto) nestes eventos.

### 3.5 Envelope C&T — exemplos

`search`:

```json
{
  "client_id": "[[identificador-unico-usuario]]",
  "session_id": "[[identificador-unico-sessao]]",
  "events": [{
    "name": "search",
    "params": {
      "search_term": "$searchTerm"
    }
  }]
}
```

`view_item`:

```json
{
  "client_id": "[[identificador-unico-usuario]]",
  "session_id": "[[identificador-unico-sessao]]",
  "events": [{
    "name": "view_item",
    "params": {
      "currency": "BRL",
      "value": "$value",
      "item_list_name": "$itemListName",
      "items": [{
        "item_id": "$sku",
        "item_name": "$itemName",
        "item_brand": "$brand",
        "price": "$price",
        "quantity": 1
      }]
    }
  }]
}
```

`add_to_cart`:

```json
{
  "client_id": "[[identificador-unico-usuario]]",
  "session_id": "[[identificador-unico-sessao]]",
  "events": [{
    "name": "add_to_cart",
    "params": {
      "currency": "BRL",
      "value": "$value",
      "item_list_name": "$itemListName",
      "items": [{
        "item_id": "$sku",
        "item_name": "$itemName",
        "item_brand": "$brand",
        "price": "$price",
        "quantity": "$quantity"
      }]
    }
  }]
}
```

`add_shipping_info` (header — fora do funil):

```json
{
  "client_id": "[[identificador-unico-usuario]]",
  "session_id": "[[identificador-unico-sessao]]",
  "events": [{
    "name": "add_shipping_info",
    "params": {
      "currency": "BRL",
      "shipping_tier": "$shippingTier"
    }
  }]
}
```

`view_promotion`:

```json
{
  "client_id": "[[identificador-unico-usuario]]",
  "session_id": "[[identificador-unico-sessao]]",
  "events": [{
    "name": "view_promotion",
    "params": {
      "creative_name": "$creativeName",
      "creative_slot": "$creativeSlot",
      "promotion_id": "$promotionId",
      "promotion_name": "$promotionName"
    }
  }]
}
```

`purchase`:

```json
{
  "client_id": "[[identificador-unico-usuario]]",
  "session_id": "[[identificador-unico-sessao]]",
  "events": [{
    "name": "purchase",
    "params": {
      "transaction_id": "$transactionId",
      "currency": "BRL",
      "value": "$value",
      "shipping": "$shipping",
      "tax": "$tax",
      "coupon": "$coupon",
      "items": [{
        "item_id": "$sku",
        "item_name": "$itemName",
        "item_brand": "$brand",
        "price": "$price",
        "quantity": "$quantity"
      }]
    }
  }]
}
```

Placeholders `$…` seguem a mesma convencao do restante do de-para (valores runtime).

### 3.6 Migracao a partir do legado

| Legado tipico | Novo |
|--------------|------|
| Lista/detalhe/SKU / carrinho / checkout / `purchase` em jornada de **compra real** (intencao de adquirir agora) | Eventos ECOM correspondentes (`view_item_list`, `add_to_cart`, `purchase`, …) |
| Frete no header ligado a compra/envio | `add_shipping_info` + `currency` + `shipping_tier` (sem `items`) |
| Banner / criativo **no funil de compra** | `view_promotion` / `select_promotion` (sem `items`) |
| Busca com termo **no funil de compra** | `search` + `search_term` |
| `logViewItemList` / `logAddToCart` / `logPurchase` (Firebase) **de compra** | Mesmos nomes GA4 |
| Cadastrar no estoque produtos **ja comprados** (`adicionar-ao-estoque`, `adicionar-produto:$sku` de gestao, card SKU, editar preco) | `interaction_gestao` / `callback_estoque_*` — **nao** ECOM |
| Adicionar produto **a venda sellout** / `callback:nova-venda` | `interaction_gestao` / `callback_vendas_*` — **nao** ECOM |
| Share / open catalogo | `interaction_divulgar` — **nao** ECOM |

Se o legado misturar UI e gesto de **compra real**, priorizar o evento GA4 recomendado. Se for so **cadastro de inventario**, priorizar `interaction_*` / `callback_*` — nunca ECOM por heuristica de “tem SKU”.

---

## 4. Callbacks (`callback_*`)

Callbacks de resultado (API, persistencia, operacao assincrona) **nao** usam `interaction_*`.

### 4.1 Sucesso

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

### 4.2 Erro

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

### 4.3 Migracao a partir do legado

| Legado | Novo |
|--------|------|
| `eventAction: callback:adicionar-produto`, label sucesso | `callback_estoque_add_product_success` |
| `eventAction: callback:adicionar-produto`, label erro | `callback_estoque_add_product_error` + `cd_error_message` |
| `eventAction: callback:auto_save_sale`, label sucesso | `callback_vendas_auto_save_sale_success` |
| `eventAction: callback:relatorio-financeiro`, label erro | `callback_gestao_financial_report_error` + `cd_error_message` |

---

## 5. Remocao de eventos de navegacao interna

### 5.1 Principio

Cliques que **apenas** levam a outra tela in-app sao candidatos a **remocao**. Origem via `last_page` do pageview.

### 5.2 Excecoes obrigatorias (manter tagueamento)

| Comportamento | Exemplos | Motivo |
|---------------|----------|--------|
| Link externo | `openUrl`, `launchUrl`, browser | Nao gera screen in-app |
| Compartilhamento | `shareText`, `Share`, sheet de share | Acao de negocio |
| Acao in-place | confirmar, excluir, modal sem troca de rota | Nao substituido por pageview |

**Nao classificar so pelo `eventLabel`.** Validar handler no codigo.

### 5.3 Navegacao in-app (regra corrigida)

Ver criterio completo: [`CRITERIO_RELEVANCIA.md`](./CRITERIO_RELEVANCIA.md)

| Sinal | Acao |
|-------|------|
| `ir-para-*`, `voltar-para-*`, `ver-mais*`, `ver-tudo*` + push in-app | **Sempre remover** o clique |
| Destino **sem** pageview | **Remover** o clique **e** `adicionar_pageview` no destino — **nao** manter o clique |
| Destino **com** pageview | Apenas remover o clique |
| `abrir-*` + `openUrl` | **Manter** → migrar (nao e nav in-app) |
| `compartilhar-*` | **Manter** → migrar |
| Evento nao dispara | Ver secao 1 de `CRITERIO_RELEVANCIA.md` (obsoleto vs bug) |

### 5.4 Pageview automatico

Rotas com `meta: {'tag': '...'}` em `router.dart` recebem `setCurrentScreen` via `TaggerNavigatorObserver` em `megazord_mobile/apps/megazord/lib/core/routes/observers/tagger_navigator_observer.dart`.

---

## 6. Simplificacao de jornadas

| Prioridade | Criterio | Acao tipica |
|------------|----------|-------------|
| **P0** | KPI/OKR, dashboard diario | Manter e migrar |
| **P1** | Acompanhamento mensal | Manter ou fundir |
| **P2** | Scroll, tooltip, navegacao duplicada | Remover ou fundir |

---

## 7. Artefatos da migracao

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

## 8. Escopo de codigo

Ver `GUIA_CONTEXTOS_TAGUEAMENTO_CT.md` — 217 arquivos `*_tag*.dart` nos microapps C&T do `megazord_mobile`.
