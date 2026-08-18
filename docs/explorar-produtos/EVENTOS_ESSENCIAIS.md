# Eventos essenciais - Explorar Produtos

> Rascunho gerado por discover. **PM deve validar** perguntas norte e KPIs por dominio.
> Dominios fonte: [dominios.md](dominios.md)

## Como usar

Preencha a coluna **Eventos essenciais (rascunho)** com o minimo para medir saude da area.
O pipeline de migracao usa este arquivo para decidir `essencial_p0/p1` vs `nao_essencial`.

| Dominio | Contexto (PM) | Pergunta norte | Eventos essenciais (rascunho) |
|---------|---------------|----------------|------------------------------|
| PDP (detalhe do produto) | Quando o SKU esta indisponivel, a RE pede aviso ou navega para semelhantes. Mede recuperacao de conversao na PDP. | A RE abre a PDP antes de comprar? | `view_item` + `item_list_name` |
| PDP (detalhe do produto) | Quando o SKU esta indisponivel, a RE pede aviso ou navega para semelhantes. Mede recuperacao de conversao na PDP. | A RE adiciona o SKU ao carrinho de compra pela PDP? | `add_to_cart` (origem PDP) |
| PDP (detalhe do produto) | Quando o SKU esta indisponivel, a RE pede aviso ou navega para semelhantes. Mede recuperacao de conversao na PDP. | Ruptura na PDP gera avise-me ou semelhantes? | INT avise-me / semelhantes + PV modal |
| Lista de produtos (PLP) | A RE muda a ordem da PLP (preco, relevancia). P1 — diagnostico de descoberta, nao substitui `view_item_list`. | A RE visualiza lista/categoria no funil de compra? | `view_item_list` |
| Lista de produtos (PLP) | A RE muda a ordem da PLP (preco, relevancia). P1 — diagnostico de descoberta, nao substitui `view_item_list`. | A RE seleciona um SKU na lista? | `select_item` |
| Lista de produtos (PLP) | A RE muda a ordem da PLP (preco, relevancia). P1 — diagnostico de descoberta, nao substitui `view_item_list`. | A RE adiciona ao carrinho direto do card? | `add_to_cart` (origem lista) |
| Lista de produtos (PLP) | A RE muda a ordem da PLP (preco, relevancia). P1 — diagnostico de descoberta, nao substitui `view_item_list`. | Ordenacao da PLP muda o mix visto? | INT ordenacao + `item_list_name` |
| Busca | Atalhos que disparam nova busca sem digitar. Intent ainda e `search` / `select_item` no destino. | A RE busca produto (termo) no funil de compra? | `search` + `search_term` |
| Busca | Atalhos que disparam nova busca sem digitar. Intent ainda e `search` / `select_item` no destino. | A busca retorna resultado com sucesso? | `callback_busca_*_success` / `_error` |
| Busca | Atalhos que disparam nova busca sem digitar. Intent ainda e `search` / `select_item` no destino. | Busca converte para PDP ou carrinho? | `search` → `view_item` / `add_to_cart` |
| Busca | Atalhos que disparam nova busca sem digitar. Intent ainda e `search` / `select_item` no destino. | Filtros e categorias da busca sao usados? | INT filtro/categoria |
| Vitrines home e banners | Banners promocionais no funil de compra. Evento canonico: `view_promotion` / `select_promotion`. Conteudo gerenciado via Prismic. | Qual vitrine/secao gera descoberta? | `view_item_list` por `item_list_name` |
| Vitrines home e banners | Banners promocionais no funil de compra. Evento canonico: `view_promotion` / `select_promotion`. Conteudo gerenciado via Prismic. | Clique em banner/criativo no funil de compra? | `view_promotion` / `select_promotion` |
| Vitrines home e banners | Banners promocionais no funil de compra. Evento canonico: `view_promotion` / `select_promotion`. Conteudo gerenciado via Prismic. | Home → lista → PDP ainda converte? | PV secao + `select_item` + `view_item` |
| Landing pages (Prismic) | Landing pages de campanha e produto **cadastradas no Prismic** (ciclo, promocao, marca). Nao sao as LPs de dicas/treinamentos da aba Divulgar (`contents` / `landing_page_tag`). A RE chega, ve vitrine de SKUs e segue o funil de compra. | A RE abre a LP de campanha/produto? | PV da LP (`screen_name` da pagina Prismic) |
| Landing pages (Prismic) | Landing pages de campanha e produto **cadastradas no Prismic** (ciclo, promocao, marca). Nao sao as LPs de dicas/treinamentos da aba Divulgar (`contents` / `landing_page_tag`). A RE chega, ve vitrine de SKUs e segue o funil de compra. | A LP gera descoberta e add to cart? | `view_item_list` / `add_to_cart` com `item_list_name` da LP |
| Landing pages (Prismic) | Landing pages de campanha e produto **cadastradas no Prismic** (ciclo, promocao, marca). Nao sao as LPs de dicas/treinamentos da aba Divulgar (`contents` / `landing_page_tag`). A RE chega, ve vitrine de SKUs e segue o funil de compra. | De onde a RE chega na LP? | origem (busca rapida, banner, oferta) + PV destino |
| Promocoes e ofertas | Cross-sell de lucro extra no card/PDP. Mede se o criativo de margem extra influencia `add_to_cart`. | A RE entra em ofertas exclusivas / promocoes? | PV ofertas + `view_promotion` |
| Promocoes e ofertas | Cross-sell de lucro extra no card/PDP. Mede se o criativo de margem extra influencia `add_to_cart`. | Promocao selecionada gera add to cart? | `select_promotion` → `add_to_cart` |
| Promocoes e ofertas | Cross-sell de lucro extra no card/PDP. Mede se o criativo de margem extra influencia `add_to_cart`. | Lucro extra no card influencia a compra? | INT lucro extra + `add_to_cart` |
| Favoritos | A RE salva SKU para comprar depois. Evento canonico: `add_to_wishlist` **somente** no funil de compra. PV da lista de favoritos. | A RE salva produto para comprar depois? | `add_to_wishlist` |
| Favoritos | A RE salva SKU para comprar depois. Evento canonico: `add_to_wishlist` **somente** no funil de compra. PV da lista de favoritos. | A RE volta a lista de favoritos? | PV favoritos |
| Disponibilidade e utilitarios | Sinal de ruptura na jornada de compra (estoque do ciclo). Nao e gestao de estoque sellout. INT/CB se nao houver evento ECOM equivalente. | Avise-me e usado em ruptura? | INT/CB remind-me |
