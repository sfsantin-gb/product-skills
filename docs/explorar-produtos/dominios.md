# Dominios — Explorar Produtos

> Mapeamento dos dominios e subdominios da jornada **Explorar Produtos** (sell-in), squad `vd-sellin-explorar-produtos`.
> Microapp principal: `oraculo`. CODEOWNERS tambem lista `jarvis` e `contents` (compartilhados) — **fora desta jornada**.
> Este arquivo alimenta [EVENTOS_ESSENCIAIS.md](EVENTOS_ESSENCIAIS.md) no discover.

**Documentos relacionados:**

- [GUIA_CONTEXTOS.md](GUIA_CONTEXTOS.md)
- Contrato GA4: [../../skills/analytics-migrate/docs/REGRAS_FORMATO_NOVO.md](../../skills/analytics-migrate/docs/REGRAS_FORMATO_NOVO.md) §3 (e-commerce avancado)
- Outputs: [../../outputs/explorar-produtos/](../../outputs/explorar-produtos/)

**Formato preferido:** esta jornada e de **intencao / compra real**. Preferir eventos **ECOM** (`view_item_list`, `select_item`, `view_item`, `add_to_cart`, `search`, `view_promotion`, `select_promotion`, `add_to_wishlist`). Interacoes que nao sao funil de compra usam `interaction_explorar` (agrupamento novo — aprovar com PM).

---

## PDP (detalhe do produto)

### Visualizar produto
> **Contexto:** A RE abre a PDP com intencao de comprar. Evento canonico: `view_item` (`item_list_name` da origem).
> **Caminhos:**
> * Busca / vitrine / categoria / ofertas → card SKU → PDP

### Adicionar ao carrinho (PDP)
> **Contexto:** A RE adiciona, aumenta ou diminui quantidade do SKU no **carrinho de compra**. Evento canonico: `add_to_cart` / `remove_from_cart`. Nao e cadastro de estoque.

### Semelhantes e avise-me
> **Contexto:** Quando o SKU esta indisponivel, a RE pede aviso ou navega para semelhantes. Mede recuperacao de conversao na PDP.
> **Caminhos:**
> * PDP → Avise-me
> * PDP → Produtos semelhantes (modal / lista)

---

## Lista de produtos (PLP)

### Visualizar lista
> **Contexto:** A RE ve uma lista/categoria/vitrine de SKUs no funil de compra. Evento canonico: `view_item_list` + `item_list_id` / `item_list_name`.

### Selecionar SKU
> **Contexto:** Clique no card que leva a PDP ou dispara intencao de compra. Evento canonico: `select_item`.

### Adicionar ao carrinho (lista)
> **Contexto:** CTA +/- no card da lista, sem abrir PDP. Mesmo funil ECOM (`add_to_cart`).

### Ordenacao
> **Contexto:** A RE muda a ordem da PLP (preco, relevancia). P1 — diagnostico de descoberta, nao substitui `view_item_list`.

---

## Busca

### Busca com termo
> **Contexto:** >50% do GMV vem da busca. Evento canonico: `search` + `search_term` (obrigatorio). Callbacks de sucesso/erro da API medem saude do servico.
> **Caminhos:**
> * Header → busca
> * PDP → icone busca
> * Historico / buscas rapidas

### Filtros e categorias da busca
> **Contexto:** A RE refina resultado (categoria, filtro, tutorial de filtro). P1 — qualidade da descoberta.

### Historico e buscas rapidas
> **Contexto:** Atalhos que disparam nova busca sem digitar. Intent ainda e `search` / `select_item` no destino.

---

## Vitrines home e banners

### Vitrine home
> **Contexto:** Secoes de produto na home no funil de compra. Evento canonico: `view_item_list` + `item_list_name`. Scroll de carrossel e anti-padrao (remover).
> **Caminhos:**
> * Inicio → secao / vitrine

### Banner
> **Contexto:** Banners promocionais no funil de compra. Evento canonico: `view_promotion` / `select_promotion`. Conteudo gerenciado via Prismic.
> **Caminhos:**
> * Inicio → banner

---

## Landing pages (Prismic)

### LP de produto / campanha
> **Contexto:** Landing pages de campanha e produto **cadastradas no Prismic** (ciclo, promocao, marca). Nao sao as LPs de dicas/treinamentos da aba Divulgar (`contents` / `landing_page_tag`). A RE chega, ve vitrine de SKUs e segue o funil de compra.
> **Caminhos:**
> * Busca rapida → destino `landing_page`
> * Banner / oferta exclusiva / promocao → LP Prismic
> * Deep link / `PublisherAction.openLandingPage`
> **Eventos:** PV da LP + `view_item_list` / `select_item` / `view_item` / `add_to_cart` (e `view_promotion` quando o criativo for promocao).

---

## Promocoes e ofertas

### Ofertas exclusivas
> **Contexto:** LP/categoria de ofertas exclusivas. 56% do GMV em promocoes complexas. Canonico: `view_promotion` / `select_promotion` + `view_item_list` da secao. Unificacao com Promoções e diretriz de produto (2x2 Canais).

### Lucro extra
> **Contexto:** Cross-sell de lucro extra no card/PDP. Mede se o criativo de margem extra influencia `add_to_cart`.

---

## Favoritos

### Lista de favoritos
> **Contexto:** A RE salva SKU para comprar depois. Evento canonico: `add_to_wishlist` **somente** no funil de compra. PV da lista de favoritos.

---

## Disponibilidade e utilitarios

### Status de estoque / avise-me
> **Contexto:** Sinal de ruptura na jornada de compra (estoque do ciclo). Nao e gestao de estoque sellout. INT/CB se nao houver evento ECOM equivalente.
