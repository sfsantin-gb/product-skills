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
| **Tipo** | `PV` pageview · `INT` interaction_* · `CB` callback_* |
| **Repo APP** | Microapp em `megazord_mobile` |
| **Repo relacionado** | Outros repos do time (backend/portal) para correlacao ops |

**Regra:** pageview cobre *chegada na tela*; interaction cobre *intencao/acao*; callback cobre *resultado de operacao*.

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
| Estoque RE | RE gerencia pronta-entrega? | PV estoque, CB add/edit product, share RE | `stock_management` |
| Vendas sellout | RE registra e cobra vendas? | PV vendas, CB create_sale, charge link | `sales_management` |
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

| Pergunta | Eventos essenciais |
|----------|-------------------|
| RE acessa estoque? | PV `/app-rev/gestao-de-estoque` |
| RE adiciona produto ao estoque? | INT modal + `callback_add_product_success` / `callback_add_product_error` |
| RE edita item RE? | `callback_edit_product_success` / `callback_edit_product_error` |
| RE compartilha pronta-entrega pos-sucesso? | `interaction_gestao` / `share_mld:after_sale` |
| Fluxo sell-in/sell-out? | PV `/gestao-de-estoque/sellin-sellout` + PV sucesso |

---

## 9. Vendas Sellout VD

**Dominio:** Experiencia Venda APP, Gestao de Vendas, Registro e comprovacao
**Repos:** `sales_management` · `vd-sellout-voldemort` (BFF)

### Funil essencial

```
PV minhas-vendas → INT adicionar venda → CB create_sale_success
                → INT cobranca → INT generate_charge_link
                → CB auto_save_sale_* (rascunho)
```

| Pergunta | Eventos essenciais |
|----------|-------------------|
| RE acessa vendas? | PV `/app-rev/gerenciar-vendas` |
| RE cria venda? | `callback_create_sale_success` / `callback_create_sale_error` |
| RE salva rascunho? | `callback_auto_save_sale_success` / `callback_auto_save_sale_error` |
| RE gera link cobranca? | `interaction_gestao` / `click_button:generate_charge_link:{type}` |
| RE organiza vendas (novato)? | PV `/gestao-de-vendas/organizar-vendas` |

**Nao mensurar:** `voltar-para-*`, `ir-para-menu-*` entre telas do funil (removidos).

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
| **Estoque RE** | PV estoque · add_product success rate |
| **Financeiro** | PV relatorio · financial_report_error rate · **PV aba financeira** (pos-lacuna) |
| **Trafego MLD** | shares na Home vs Divulgar |

---

## Proximos passos

1. PM validar perguntas norte por dominio (este doc)
2. Cruzar com `TAGUEAMENTO_MIGRADO_CT.csv` — marcar gaps (`status != migrar`)
3. Implementar lacunas P0: aba financeira, normalizar `add_customer`
4. `@analytics-plan` para eventos novos fora do inventario legado

**Referencias:** [`CRITERIO_RELEVANCIA.md`](./CRITERIO_RELEVANCIA.md) · [`GUIA_CONTEXTOS_TAGUEAMENTO_CT.md`](./GUIA_CONTEXTOS_TAGUEAMENTO_CT.md)
