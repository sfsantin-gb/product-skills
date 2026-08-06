# Eventos essenciais por area — saude e performance C&T

> Mapa de **o que mensurar** para acompanhar saude/performance de cada dominio da squad Conteudos e Trafego.
> Base: [`SITEMAP_CT.md`](../../contextos/SITEMAP_CT.md) | [`dominios-c&t.md`](../../contextos/domínios-c&t.md) | [`repositorios-do-time.md`](../../contextos/repositorios-do-time.md)
> Contrato analytics: [`REGRAS_FORMATO_NOVO.md`](./REGRAS_FORMATO_NOVO.md) | de-para: [`TAGUEAMENTO_MIGRADO_CT.csv`](./TAGUEAMENTO_MIGRADO_CT.csv)

**Escopo APP:** eventos implementaveis em `megazord_mobile` (microapps C&T). Superficies web/portal/BFF aparecem como **contexto** — metricas de produto la fora exigem outra fonte (GA web, APIs).

---

## Como ler este documento

| Coluna | Significado |
|--------|-------------|
| **Pergunta de saude** | O que o time precisa saber para agir |
| **Eventos essenciais** | Minimo para responder a pergunta (formato migrado) |
| **Tipo** | `PV` pageview · `INT` interaction_* · `CB` callback_* · `ECOM` evento recomendado GA4 (e-commerce / search) |
| **Repo APP** | Microapp em `megazord_mobile` |
| **Repo relacionado** | Outros repos do time (backend/portal) para correlacao ops |

**Regra geral:** pageview cobre *chegada na tela*; interaction cobre *intencao/acao de UI*; callback cobre *resultado de operacao*; **e-commerce avancado** cobre *somente* jornadas em que a RE **tem intencao de comprar ou esta comprando** produtos (checkout / pagamento / conclusao de compra).

### Preferencia: e-commerce avancado vs interaction/callback

| Situacao | Preferir |
|----------|----------|
| RE **tem intencao de comprar ou esta realizando a compra** de produtos (carrinho de compra, checkout, pagamento, `purchase`, promocao/busca **nesse** funil) | **`ECOM`** — eventos GA4 da [secao 3 de `REGRAS_FORMATO_NOVO.md`](./REGRAS_FORMATO_NOVO.md) |
| **Sellout → compra de estoque:** a partir de uma **venda ja registrada**, RE adiciona produtos ao **carrinho de compra** para adquirir o estoque necessario e entregar ao cliente final | **`ECOM`** (`add_to_cart` → … → `purchase`) — e funil de compra do usuario do app |
| RE **cadastra / edita no app** produtos **ja comprados** (gestao de estoque, “adicionar ao estoque”, card SKU, editar preco, excluir do estoque) | **`INT` / `CB`** — **nao** e ECOM |
| RE **vende / cobra / registra venda sellout** ao cliente (inclui adicionar SKU **a venda**) | `INT` / `CB` (`interaction_gestao`, `callback_vendas_*`) — **nao** ECOM |
| Share, openUrl, navegacao de gestao, hub, relatorios | `INT` / `PV` |
| Frete no **header** (selecao de frete com intencao de compra / envio) | `ECOM` `add_shipping_info` (so `currency` + `shipping_tier`) |

**Anti-padrao (nao confundir):**

- Informar no app produtos que a RE **ja comprou** (cadastro de estoque) → `INT`/`CB`, **nao** ECOM
- Adicionar produto **na venda do cliente** → `INT`/`CB`, **nao** ECOM
- Adicionar produto **no carrinho de compra** (para repor estoque e entregar a venda) → **ECOM**

Contrato completo dos 13 eventos: [`REGRAS_FORMATO_NOVO.md` §3](./REGRAS_FORMATO_NOVO.md).

---

## Catalogo P0 — e-commerce avancado (intencao / compra real)

Usar **apenas** quando a jornada for de **compra** (a RE pretende adquirir ou esta adquirindo produtos agora) — incluindo o atalho **Sellout → carrinho de compra de estoque**. **Nao** usar quando estiver so registrando no estoque o que ja comprou, nem quando estiver montando a venda do cliente. Nomes oficiais GA4 — **nao** renomear para `interaction_*`.

| Tipo | Evento GA4 | Pergunta de saude que responde | Params C&T (resumo) |
|------|------------|--------------------------------|---------------------|
| ECOM | `view_item_list` | RE visualiza lista/categoria **no funil de compra**? | `items`, `item_list_id` / `item_list_name`, `currency`* |
| ECOM | `select_item` | RE seleciona um SKU **para comprar**? | `items`, `item_list_id` / `item_list_name` |
| ECOM | `view_item` | RE abre detalhe do produto **antes de comprar**? | `items`, `currency`*, `value`*, **`item_list_name`** |
| ECOM | `add_to_wishlist` | RE salva produto em wishlist **no contexto de compra**? | `items`, `currency`*, `value`*, **`item_list_name`** |
| ECOM | `add_to_cart` | RE adiciona produto ao **carrinho de compra** (incl. a partir de uma venda sellout)? | `items`, `currency`*, `value`*, **`item_list_name`** |
| ECOM | `remove_from_cart` | RE remove produto desse **carrinho de compra**? | `items`, `currency`*, `value`*, **`item_list_name`** |
| ECOM | `begin_checkout` | RE inicia checkout da compra? | `items`, `currency`*, `value`*, `coupon` |
| ECOM | `add_shipping_info` | RE escolhe frete (header / checkout de compra)? | **somente** `currency` + `shipping_tier` (sem `items`) |
| ECOM | `add_payment_info` | RE informa pagamento no checkout de compra? | `items`, `currency`*, `value`*, `coupon`, `payment_type` |
| ECOM | `purchase` | RE **conclui a compra** (reposicao de estoque)? | `items`, `transaction_id` (**obrig.**), `currency`*, `value`*, `coupon`, `shipping`, `tax` |
| ECOM | `view_promotion` | RE visualiza promocao **no funil de compra**? | `creative_*`, `promotion_*` — **sem** `items` |
| ECOM | `select_promotion` | RE seleciona essa promocao? | `creative_*`, `promotion_*` — **sem** `items` |
| ECOM | `search` | RE busca produto (termo) **no funil de compra**? | `search_term` (**obrig.**) — sem `items` |

\* Condicional: enviar `currency` sempre que houver `value`. Moeda tipica: `BRL`.

**Funil minimo P0 (somente compra real):**

```
view_item_list → select_item → view_item
       → add_to_cart / remove_from_cart
       → begin_checkout → add_payment_info → purchase
(+ search quando houver campo de busca com termo)
(+ view_promotion / select_promotion quando houver criativo)
(+ add_shipping_info no header, se aplicavel a compra/envio)
```

**Origem Sellout (caso C&T):**

```
Venda sellout registrada (INT/CB)
  → CTA "adicionar produtos ao carrinho" (compra de estoque p/ entrega)
  → add_to_cart → … → purchase   ← ECOM daqui em diante
```

**Nao usar este catalogo para:**

- Cadastrar no estoque produtos **ja comprados** (`adicionar-ao-estoque`, gestao de SKU/preco, callbacks de inventario sem checkout)
- Montar/editar a **venda do cliente** (`adicionar-produto-a-venda`, `selecionar-produto` na venda, `callback_vendas_*`) → `INT`/`CB` (secao 9)
- Share de MLD/catalogo, cobranca, parcelas → `INT`/`CB`

---

## Visao consolidada por dominio

| Dominio C&T | Pergunta norte | Eventos P0 (resumo) | Microapp principal |
|-------------|----------------|---------------------|-------------------|
| Divulgacao MLD | RE divulga e gera trafego? | share_*, open_catalog, PV hub Divulgar | `contents`, `mld_profile` |
| Materiais / Conteudos | RE consome e repassa conteudo? | share_material, open_content, PV LP | `contents` |
| VD Studio | RE cria e compartilha cards? | interaction_vdstudio, share pos-edicao | `contents_advertising` |
| Perfil MLD | Loja configurada e compartilhavel? | PV /minha-loja, click mld_config | `mld_profile` |
| Carteira clientes | Carteira ativa e crescendo? | PV clientes, add/edit customer, CB | `customer_management` |
| Divulgar produtos | RE indica produto ao cliente? | showcase, share produto, PV vitrine | `customer_management`, `oraculo` |
| Carrinho abandonado | RE recupera sacola? | PV card Divulgar, share sacola | `contents`, `customer_management` |
| Estoque RE | RE gerencia estoque e/ou **compra** reposicao? | PV + INT/CB inventario; **ECOM** no funil de compra (incl. a partir de venda) | `stock_management` |
| Vendas sellout | RE registra/cobra vendas e pode **repor estoque** via carrinho? | PV + CB create_sale + charge; **ECOM** se CTA for carrinho de compra p/ entrega | `sales_management` |
| Gestao / Relatorio | RE entende saude do negocio? | PV hub/relatorio, CB financial_report_error | `business_management` |
| Tarefas | RE executa missoes diarias? | PV missions, conclusao tarefa | `customer_management` |
| Aquisicao CF | RE aparece nas buscas? | PV recomendacao, opt-in busca | `recommendation` |
| Tráfego Home | MLD visivel na entrada? | share_catalog Home, view_component Top Ten | `contents`, `megazord` |

---

## 1. Divulgacao MLD

**Dominio:** Divulgar APP, Trafego geral MLD, Catalogo digital (link no app)
**Repos:** `megazord_mobile` (`contents`, `mld_profile`, `megazord`) · site catalogo = fora do app

### Perguntas de saude / performance

| Pergunta | Indicador proxy |
|----------|-----------------|
| RE acessa a aba Divulgar? | PV `/dash/divulgar/divulgar` |
| RE compartilha MLD/catálogo? | Volume `interaction_divulgar` share_* |
| Qual canal de divulgacao mais usado? | Breakdown `cd_interaction_detail` por modulo |
| RE abre catalogo digital (link)? | `open_catalog:{brand}` |
| Funil Home → catalogo → share? | PV Home + PV `/ciclos/catalogos` + share |

### Eventos essenciais

| Tipo | Evento (novo formato) | Tela / path | Tag |
|------|----------------------|-------------|-----|
| PV | `screen_view` `/app-rev/divulgar` (hub) | Hub Divulgar | router meta |
| PV | `screen_view` `/app-rev/divulgar/catalogos` | Lista catalogos | `catalog_page_tag` |
| INT | `interaction_divulgar` / `share_catalog:{brand}` | Catalogo | `catalog_page_tag`, `catalog_module_tag` |
| INT | `interaction_divulgar` / `open_catalog:{brand}` | Abrir PDF/link | `catalog_page_tag` |
| INT | `interaction_divulgar` / `share_mld:by_brand` | Modulo MLD | `mld_module_tag` |
| INT | `interaction_divulgar` / `share_mld:multibrand` | MLD multimarcas | `mld_module_tag` |
| INT | `interaction_divulgar` / `share_mld:ready_to_ship` | Pronta-entrega na MLD | `mld_module_tag` |
| INT | `interaction_inicio` / `share_catalog:{brand}` | Home catalogos | `home_catalogs_section_tag` |
| INT | `interaction_inicio` / `view_component:topten_showcase` | Vitrine Top Ten | `top_ten_show_case_home_tag` |

**Nao mensurar:** cliques `ver-mais` / `ver-tudo` (removidos; PV no destino basta).

---

## 2. Materiais de divulgacao

**Dominio:** Materiais de Divulgacao
**Repo:** `contents`

| Pergunta | Eventos essenciais |
|----------|-------------------|
| RE abre galeria de materiais? | PV `/app-rev/conteudo/divulgar/imagens` |
| RE compartilha material? | `interaction_divulgar` / `share_material:download`, `share_material:fullscreen` |
| RE explora secao/campanha? | `click_image:{action}:{section}` |

---

## 3. Conteudos e treinamento

**Dominio:** Dicas e treinamentos, Noticias
**Repo:** `contents` · conteudo Prismic (CMS fora do app)

| Pergunta | Eventos essenciais |
|----------|-------------------|
| RE abre LP de treinamento? | PV `/app-rev/conteudo/novidade/{title}` (`landing_page_tag`) |
| RE abre noticias? | PV `/app-rev/conteudo/divulgar/noticias` |
| RE engaja com card? | `interaction_divulgar` / `open_content:{card}` |

---

## 4. VD Studio

**Dominio:** VD Studio
**Repos:** `megazord_mobile` (`contents_advertising`) · `vd-sel-vd-studio-service` · `gb-cards-frontend` (Boticards web)

| Pergunta | Eventos essenciais |
|----------|-------------------|
| RE entra no editor? | PV `/divulgar/compartilhar-produto` |
| RE conclui edicao e compartilha? | `interaction_vdstudio` / `{action}:{detail}` + share subsequente |
| Erro ao gerar card? | CB backend (fora do app hoje) — **lacuna** se nao houver callback no app |

---

## 5. Perfil e configuracao MLD

**Dominio:** Perfil & Configuracao MLD, Opt-in Catalogo fisico
**Repos:** `mld_profile`, `opt_out`

| Pergunta | Eventos essenciais |
|----------|-------------------|
| RE acessa configuracao da loja? | PV `/app-rev/minha-loja-digital` |
| RE completa perfil antes de share? | PV editar-perfil-antes-compartilhar |
| RE altera opt-in catalogo fisico? | `interaction_menu` / `click_button:physical_catalog:{brand}:{opt}` |
| RE salva slug/link? | `interaction_menu` / `click_button:edit_slug:{action}` |

---

## 6. Carteira de clientes

**Dominio:** Gestao da Carteira, Gestao de clientes
**Repos:** `customer_management` · `vd-sellout-gestao-carteira` (API)

| Pergunta | Eventos essenciais |
|----------|-------------------|
| RE usa hub de clientes? | PV `/app-rev/gerenciar-clientes` |
| RE cadastra/edita cliente? | `interaction_gestao` / `click_button:add_customer`, `edit_customer` |
| Operacao de cliente falhou? | `callback_*` (normalizar `add_customer` legado) |
| RE compartilha catalogo com cliente? | PV + INT share em `share_catalogs_tag` |

---

## 7. Recomendacao de produtos e carrinho abandonado

**Dominio:** Divulgar Produtos, Ativacoes, Carrinho abandonado
**Repos:** `customer_management`, `contents`, `oraculo` · `vd-sellout-ativacoes`

| Pergunta | Eventos essenciais |
|----------|-------------------|
| RE abre vitrine de indicacoes? | PV `/app-rev/indicacoes-de-clientes` |
| RE divulga produto para cliente? | `interaction_gestao` / `click_button:showcase_{origin}` (`promote_products_tag`) |
| RE ve card sacola abandonada? | PV modulo Divulgar + INT share PLP |
| RE compartilha produto da busca? | `oraculo` share flow (fora inventario C&T parcial — validar tag) |

---

## 8. Pronta-entrega / Estoque RE

**Dominio:** Experiencia Gestao de Ativos (Estoque RE)
**Repo:** `stock_management`

**Regra de formato (evitar confusao):**

| Gesto da RE | Formato |
|-------------|--------|
| **Intencao / compra real** (carrinho → checkout → `purchase`), inclusive a partir de uma venda sellout | **`ECOM`** — catalogo acima + [`REGRAS_FORMATO_NOVO.md` §3](./REGRAS_FORMATO_NOVO.md) |
| **Cadastro / gestao** no app de produtos **ja comprados** (adicionar ao estoque, card SKU, editar preco, excluir, callbacks de inventario) | **`INT` / `CB`** — **nunca** `add_to_cart` / `purchase` / `view_item*` |
| Share MLD / pronta-entrega | `interaction_gestao` share_* |

### Funil essencial — gestao de estoque (cadastro de ja comprados)

```
PV gestao-de-estoque
  → INT adicionar/editar/excluir produto no estoque
  → CB callback_estoque_add_product_* / edit_product_*
  → INT share pronta-entrega (opcional)
```

| Pergunta | Eventos essenciais |
|----------|-------------------|
| RE acessa estoque? | PV `/app-rev/gestao-de-estoque` |
| RE cadastra produto **ja comprado** no estoque? | `interaction_gestao` + `callback_estoque_add_product_success\|error` |
| RE edita / exclui item do estoque? | `interaction_gestao` + `callback_estoque_edit_product_*` (ou INT de confirmacao) |
| RE compartilha pronta-entrega pos-sucesso? | `interaction_gestao` / `share_mld:after_sale` |
| Fluxo sell-in/sell-out (tela de gestao de inventario)? | PV + INT/CB de inventario — **sem** ECOM se nao houver checkout |

### Funil essencial — compra real (reposicao de estoque)

Inclui o caso em que a RE, **a partir de uma venda sellout**, adiciona produtos ao **carrinho de compra** para adquirir o estoque e entregar ao cliente:

```
(venda sellout = INT/CB)
  → add_to_cart (produtos da venda → carrinho de compra)
  → remove_from_cart (se ajustar)
  → begin_checkout → add_payment_info → purchase
(+ view_item_list / select_item / view_item / search se houver UI de catalogo nesse fluxo)
```

| Pergunta | Eventos essenciais |
|----------|-------------------|
| RE adiciona ao **carrinho de compra** (p/ repor estoque / entregar venda)? | `add_to_cart` (+ `item_list_name`, `items`) |
| RE remove do carrinho de compra? | `remove_from_cart` |
| RE conclui a compra de estoque? | `begin_checkout` → `add_payment_info` → `purchase` (`transaction_id`) |

**Nao confundir:**

| Gesto | Formato |
|-------|--------|
| Adicionar SKU **na venda do cliente** | `INT`/`CB` (secao 9) |
| Adicionar SKU **no carrinho de compra** (reposicao p/ entrega) | **ECOM** |
| Cadastrar no estoque o que **ja comprou** | `INT`/`CB` |

---

## 9. Vendas Sellout VD

**Dominio:** Experiencia Venda APP, Gestao de Vendas, Registro e comprovacao
**Repos:** `sales_management` · `vd-sellout-voldemort` (BFF)

**Formato misto:**

| Trecho da jornada | Formato |
|-------------------|--------|
| Registrar / editar / cobrar **venda ao cliente** | `INT` / `CB` — **nao** ECOM |
| A partir da venda, **adicionar produtos ao carrinho de compra** para repor estoque e entregar | **`ECOM`** a partir desse CTA (secao 8 + catalogo) |

### Funil essencial — venda ao cliente

```
PV minhas-vendas → INT adicionar venda → CB create_sale_success
                → INT cobranca → INT generate_charge_link
                → CB auto_save_sale_* (rascunho)
```

| Pergunta | Eventos essenciais |
|----------|-------------------|
| RE acessa vendas? | PV `/app-rev/gerenciar-vendas` |
| RE cria venda? | `callback_vendas_create_sale_success` / `callback_vendas_create_sale_error` |
| RE salva rascunho? | `callback_vendas_auto_save_sale_success` / `callback_vendas_auto_save_sale_error` |
| RE gera link cobranca? | `interaction_gestao` / `click_button:generate_charge_link:{type}` |
| RE organiza vendas (novato)? | PV `/gestao-de-vendas/organizar-vendas` |
| RE, a partir da venda, compra estoque p/ entregar? | **ECOM** `add_to_cart` → … → `purchase` (nao `interaction_gestao`) |

**Nao mensurar:** `voltar-para-*`, `ir-para-menu-*` entre telas do funil de venda (removidos).

**Labels legados tipicos do ponte Sellout → ECOM:** `adicionar-produtos-ao-carrinho` / `adicionar-produtos-ao-carrinho:$saleId` (quando o destino e o **carrinho de compra** de estoque, nao o carrinho da venda).

---

## 10. Gestao do negocio e relatorio financeiro

**Dominio:** Experiencia APP Relatorio Financeiro, Hub gestao
**Repos:** `business_management` · `vd-financial-management-api`

| Pergunta | Eventos essenciais |
|----------|-------------------|
| RE acessa hub gestao? | PV `/app-rev/gestao/gestao-de-negocio` |
| RE abre relatorio de vendas? | PV `/app-rev/gestao/relatorio-de-vendas` |
| RE ve aba financeira? | PV **dedicado** aba financeira (`adicionar_pageview` — lacuna atual) |
| Relatorio financeiro falha? | `callback_financial_report_error` + `unexpected-error` |
| RE atualiza cache relatorio? | `interaction_gestao` / `click_button:atualizar-relatorio-financeiro` |

**Acao engenharia:** implementar pageview aba financeira antes de remover `ir-para-relatorio`.

---

## 11. Tarefas / missoes

**Dominio:** Tarefas
**Repos:** `customer_management` · `vd-sellout-missions-api`

| Pergunta | Eventos essenciais |
|----------|-------------------|
| RE abre tarefas? | PV `/clientes/missions_page` |
| RE conclui missao? | `interaction_gestao` / `click_button:task_complete` (fundir granularidade — `revisar_pm`) |

---

## 12. Aquisicao CF (app)

**Dominio:** Apareca nas buscas
**Repo:** `recommendation` · `vd-sellout-aq-recommendation-services`

| Pergunta | Eventos essenciais |
|----------|-------------------|
| RE entra no fluxo? | PV `/dash/recomendacao/*` |
| RE faz opt-in aparecer nas buscas? | `interaction_menu` / `click_button:search_opt_in` |

**Fora do app:** Encontre RE (site) — `vd-sellout-aq-encontre-revendedores` · metricas web separadas.

---

## 13. Menu e atalhos (cross-cutting)

**Repo:** `jarvis` (`menu_page_tag`)

| Pergunta | Eventos essenciais |
|----------|-------------------|
| Por onde RE entra nos fluxos C&T? | `interaction_menu` / `click_section:{label}` |
| Distribuicao Menu vs navbar? | Breakdown por `gestao-de-vendas`, `gestao-de-clientes`, `divulgar`, etc. |

---

## Matriz repo do time × cobertura analytics APP

| Repo | Dominio | Eventos essenciais no app | Lacuna conhecida |
|------|---------|---------------------------|------------------|
| `megazord_mobile` | Todos APP acima | Inventario migrado ~205 INT/CB/PV | Aba financeira sem PV |
| `vd-financial-management-api` | Relatorio financeiro | Dados server-side; correlacionar com CB erro | Dashboard ops separado |
| `vd-sellout-gestao-carteira` | Clientes | API; app tem tags de UI | — |
| `vd-sellout-ativacoes` | Ativacoes/vitrine | Parcial no app | Ativacao generica/personalizada |
| `vd-sel-vd-studio-service` | VD Studio | App tem interaction_vdstudio | Erros de geracao no backend |
| `vd-sellout-missions-api` | Tarefas | PV missions; conclusao a refinar | — |
| `gb-cards-frontend` | Boticards | Fora megazord app | GA web proprio |
| `vd-sellout-aq-encontre-revendedores` | Encontre | Atalho menu apenas | Site = outro property |

---

## Dashboard sugerido por area (minimo)

| Area | Metricas semanais |
|------|-------------------|
| **Divulgacao** | PV Divulgar · shares/dia · mix share_catalog vs share_mld |
| **Conteudo** | PV LPs · open_content por secao |
| **Clientes** | PV hub · novos clientes (CB/intencao) · taxa erro callback |
| **Vendas** | PV vendas · create_sale_success rate · auto_save errors |
| **Estoque RE** | PV estoque · INT/CB inventario · ECOM **apenas** se existir checkout de compra real |
| **Financeiro** | PV relatorio · financial_report_error rate · **PV aba financeira** (pos-lacuna) |
| **Trafego MLD** | shares na Home vs Divulgar |

---

## Proximos passos

1. PM validar perguntas norte por dominio (este doc)
2. Cruzar com `TAGUEAMENTO_MIGRADO_CT.csv` — marcar gaps (`status != migrar`)
3. Implementar lacunas P0: aba financeira; normalizar callbacks de estoque/cliente
4. `@analytics-plan` para eventos novos — usar `ECOM` **somente** se a jornada for intencao/compra real (nao cadastro de estoque)

**Referencias:** [`REGRAS_FORMATO_NOVO.md`](./REGRAS_FORMATO_NOVO.md) (§3 e-commerce) · [`CRITERIO_RELEVANCIA.md`](./CRITERIO_RELEVANCIA.md) · [`GUIA_CONTEXTOS_TAGUEAMENTO_CT.md`](./GUIA_CONTEXTOS_TAGUEAMENTO_CT.md)
