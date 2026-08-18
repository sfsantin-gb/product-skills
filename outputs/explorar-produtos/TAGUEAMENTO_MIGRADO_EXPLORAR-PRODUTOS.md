# Tagueamento migrado â€” Explorar Produtos

> Gerado em **2026-08-18**. Jornada sell-in no microapp `oraculo`.
> Agrupamento novo: `interaction_explorar` (aprovar com PM). Funil de compra usa eventos **ECOM** GA4.
> Fora do escopo: share produto, barcode, jornada de marca, recomendacao/Top Ten, `jarvis`, `contents` (C&T).

## Resumo executivo

| Metrica | Valor |
|---------|-------|
| Inventario oraculo | 78 |
| **Migrar** | 33 |
| **Manter** (ECOM/PV/callback ja no padrao) | 22 |
| **Remover** | 17 |
| **Novo PV** | 6 |
| Linhas ECOM | 29 |

### Criterio

| Criterio | Qtd |
|----------|-----|
| `anti_padrao` | 7 |
| `essencial_p0` | 31 |
| `essencial_p1` | 20 |
| `fundir_pai` | 7 |
| `lacuna_pageview` | 6 |
| `nav_duplicada` | 3 |
| `pageview_ok` | 4 |

### Por dominio

| Dominio | Qtd |
|---------|-----|
| Busca | 29 |
| Favoritos | 3 |
| Landing pages (Prismic) | 10 |
| Lista de produtos (PLP) | 6 |
| PDP (detalhe do produto) | 7 |
| Promocoes e ofertas | 10 |
| Vitrines home e banners | 13 |

## Funil ECOM alvo

```
search / view_promotion
  -> view_item_list -> select_item -> view_item
    -> add_to_cart  (+ add_to_wishlist)
```

Checkout / purchase ficam com **Checkout e Pedidos** â€” nao entram nesta jornada.

## P0 â€” manter ou migrar

| Dominio | Status | Criterio | Evento novo | Tag |
|---------|--------|----------|-------------|-----|
| Promocoes e ofertas | `adicionar_pageview` | `lacuna_pageview` | `screen_view` | `exclusive_offers_tag_impl.dart` |
| Promocoes e ofertas | `manter` | `essencial_p0` | `view_item_list` | `exclusive_offers_tag_impl.dart` |
| Promocoes e ofertas | `migrar` | `essencial_p0` | `add_to_cart` | `exclusive_offers_tag_impl.dart` |
| Promocoes e ofertas | `migrar` | `essencial_p0` | `view_promotion` | `extra_profit_cross_tag_impl.dart` |
| Promocoes e ofertas | `manter` | `essencial_p0` | `view_promotion` | `extra_profit_cross_tag_impl.dart` |
| Promocoes e ofertas | `manter` | `essencial_p0` | `view_item_list` | `extra_profit_cross_tag_impl.dart` |
| Lista de produtos (PLP) | `adicionar_pageview` | `lacuna_pageview` | `screen_view` | `order_tag_impl.dart` |
| PDP (detalhe do produto) | `adicionar_pageview` | `lacuna_pageview` | `screen_view` | `remind_me_tag_impl.dart` |
| Busca | `manter` | `pageview_ok` | `screen_view` | `search_category_tag_impl.dart` |
| Favoritos | `manter` | `essencial_p0` | `add_to_wishlist` | `favorites_tag_impl.dart` |
| Favoritos | `manter` | `essencial_p0` | `remove_from_wishlist` | `favorites_tag_impl.dart` |
| Favoritos | `adicionar_pageview` | `lacuna_pageview` | `screen_view` | `favorites_tag_impl.dart` |
| Busca | `migrar` | `essencial_p0` | `add_to_cart` | `section_in_search_tag_impl.dart` |
| Busca | `migrar` | `essencial_p0` | `add_to_cart` | `section_in_search_tag_impl.dart` |
| Busca | `migrar` | `essencial_p0` | `add_to_cart` | `medium_card_search_tag.dart` |
| Busca | `manter` | `essencial_p0` | `view_item_list` | `search_tag_impl.dart` |
| Busca | `manter` | `essencial_p0` | `select_item` | `search_tag_impl.dart` |
| Busca | `migrar` | `essencial_p0` | `search` | `search_tag_impl.dart` |
| Busca | `migrar` | `essencial_p0` | `callback_busca_search_error` | `search_tag_impl.dart` |
| Busca | `migrar` | `essencial_p0` | `add_to_cart` | `search_tag_impl.dart` |
| Busca | `migrar` | `essencial_p0` | `add_to_cart` | `search_tag_impl.dart` |
| Busca | `manter` | `pageview_ok` | `screen_view` | `search_tag_impl.dart` |
| Busca | `manter` | `pageview_ok` | `screen_view` | `search_tag_impl.dart` |
| Vitrines home e banners | `manter` | `essencial_p0` | `view_promotion` | `banners_tag_impl.dart` |
| Vitrines home e banners | `manter` | `essencial_p0` | `view_item_list` | `banners_tag_impl.dart` |
| Vitrines home e banners | `migrar` | `essencial_p0` | `select_promotion` | `banners_tag_impl.dart` |
| Vitrines home e banners | `adicionar_pageview` | `lacuna_pageview` | `screen_view` | `banners_tag_impl.dart` |
| Vitrines home e banners | `manter` | `essencial_p0` | `view_item_list` | `section_tag_impl.dart` |
| Landing pages (Prismic) | `migrar` | `essencial_p0` | `add_to_cart` | `section_tag_impl.dart` |
| Vitrines home e banners | `migrar` | `essencial_p0` | `add_to_cart` | `section_tag_impl.dart` |
| Vitrines home e banners | `migrar` | `essencial_p0` | `interaction_explorar` | `section_tag_impl.dart` |
| Vitrines home e banners | `adicionar_pageview` | `lacuna_pageview` | `screen_view` | `section_tag_impl.dart` |
| Vitrines home e banners | `manter` | `essencial_p0` | `view_item_list` | `section_view_tag_impl.dart` |
| Lista de produtos (PLP) | `manter` | `essencial_p0` | `view_item_list` | `products_list_component_tag_impl.dart` |
| Lista de produtos (PLP) | `migrar` | `essencial_p0` | `add_to_cart` | `products_list_component_tag_impl.dart` |
| PDP (detalhe do produto) | `manter` | `essencial_p0` | `view_item_list` | `product_details_tag_impl.dart` |
| PDP (detalhe do produto) | `manter` | `essencial_p0` | `view_item` | `product_details_tag_impl.dart` |
| PDP (detalhe do produto) | `migrar` | `essencial_p0` | `add_to_cart` | `product_details_tag_impl.dart` |
| PDP (detalhe do produto) | `manter` | `pageview_ok` | `screen_view` | `product_details_tag_impl.dart` |
| Landing pages (Prismic) | `manter` | `essencial_p0` | `view_item_list` | `showcase_component_tag_impl.dart` |
| Landing pages (Prismic) | `migrar` | `essencial_p0` | `add_to_cart` | `showcase_component_tag_impl.dart` |

## Removidos

| Criterio | Tag | Motivo |
|----------|-----|--------|
| `anti_padrao` | `exclusive_offers_tag_impl.dart` | Scroll de carrossel - anti-padrao |
| `nav_duplicada` | `exclusive_offers_tag_impl.dart` | Clique de navegacao in-app - PV no destino cobre chegada |
| `fundir_pai` | `exclusive_offers_tag_impl.dart` | Granularidade +/- quantidade - fundir no add_to_cart pai |
| `fundir_pai` | `exclusive_offers_tag_impl.dart` | Granularidade +/- quantidade - fundir no add_to_cart pai |
| `fundir_pai` | `section_in_search_tag_impl.dart` | Granularidade +/- quantidade - fundir no add_to_cart pai |
| `nav_duplicada` | `section_in_search_tag_impl.dart` | Clique de navegacao in-app - PV no destino cobre chegada |
| `anti_padrao` | `section_in_search_tag_impl.dart` | Scroll de carrossel - anti-padrao |
| `anti_padrao` | `filter_tutorial_tag_impl.dart` | Tutorial/coachmark - anti-padrao |
| `anti_padrao` | `filter_tutorial_tag_impl.dart` | Tutorial/coachmark - anti-padrao |
| `fundir_pai` | `search_tag_impl.dart` | Granularidade +/- quantidade - fundir no add_to_cart pai |
| `anti_padrao` | `banners_tag_impl.dart` | Scroll de carrossel - anti-padrao |
| `anti_padrao` | `section_scroll_tag_impl.dart` | Scroll de carrossel - anti-padrao |
| `fundir_pai` | `section_tag_impl.dart` | Granularidade +/- quantidade - fundir no add_to_cart pai |
| `nav_duplicada` | `section_tag_impl.dart` | Clique de navegacao in-app - PV no destino cobre chegada |
| `anti_padrao` | `section_tag_impl.dart` | Scroll de carrossel - anti-padrao |
| `fundir_pai` | `products_list_component_tag_impl.dart` | Granularidade +/- quantidade - fundir no add_to_cart pai |
| `fundir_pai` | `showcase_component_tag_impl.dart` | Granularidade +/- quantidade - fundir no add_to_cart pai |

## Lacunas de pageview

| screen_name proposto | Tag | Nota |
|---------------------|-----|------|
| `/app-rev/{origin}/categoria/ofertas-exclusivas` | `exclusive_offers_tag_impl.dart` | PV com interpolacao no extrator ('$_appRev/$origin/$_exclusiveOffersScreen') - propor /app-rev/{origin}/categoria/ofertas-exclusivas |
| `/app-rev/lista/ordenar` | `order_tag_impl.dart` | PV com interpolacao no extrator ('orderBottomSheetScreen(screen') - propor /app-rev/lista/ordenar |
| `/app-rev/avise-me/{flow}` | `remind_me_tag_impl.dart` | PV com interpolacao no extrator ('$remindMeScreen$name') - propor /app-rev/avise-me/{flow} |
| `/app-rev/busca/favoritos` | `favorites_tag_impl.dart` | PV com interpolacao no extrator ('screenName as String') - propor /app-rev/busca/favoritos |
| `/app-rev/inicio/banner` | `banners_tag_impl.dart` | PV com interpolacao no extrator ('$dynamic') - propor /app-rev/inicio/banner |
| `/app-rev/inicio/secao` | `section_tag_impl.dart` | PV com interpolacao no extrator ('$dynamic') - propor /app-rev/inicio/secao |

## Pendencias PM

1. Aprovar agrupamento **`interaction_explorar`** (nao existe no catalogo C&T).
2. Confirmar que +/- quantidade (`fundir_pai`) pode sair â€” `add_to_cart` cobre o gesto.
3. Confirmar remocao de scroll de vitrine (`anti_padrao`).
4. Landing pages Prismic: confirmar PV da LP + `item_list_name` da pagina.

CSV: [TAGUEAMENTO_MIGRADO_EXPLORAR-PRODUTOS.csv](./TAGUEAMENTO_MIGRADO_EXPLORAR-PRODUTOS.csv)
