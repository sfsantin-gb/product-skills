# Guia de Tagueamento — Explorar Produtos (sell-in)

Inventario de arquivos de analytics (`*_tag*.dart`) da jornada **Explorar Produtos**.

**Squad GitHub:** `vd-sellin-explorar-produtos`  
**Microapp no escopo desta jornada:** `oraculo`

**Fora desta jornada:** share produto, barcode, jornada de marca, showcase/recomendacao/Top Ten (exceto vitrine em LP), `jarvis`, `contents` (Divulgar / LPs de dicas C&T).

**Referencias:**

- Novo formato: [`REGRAS_FORMATO_NOVO.md`](REGRAS_FORMATO_NOVO.md) §3 ECOM
- Dominios: [`dominios-explorar-produtos.md`](../config/dominios-explorar-produtos.md)
- Skill: `@analytics-migrate` com `analytics-migrate.config.explorar-produtos.yml`

---

## Objetivo

Migrar o tagueamento legado da descoberta/compra (PDP, PLP, vitrine home, banner, LP Prismic, ofertas, favoritos) para eventos GA4 **ECOM** quando houver intencao de compra, e `interaction_explorar` no restante.

## Mapa contexto → arquivos

| Contexto | Tags principais |
|----------|-----------------|
| PDP | `product_details_tag`, `remind_me_tag`, `stock_status_tag` |
| PLP | `products_list_component_tag`, `order_tag` |
| Busca | `search_tag`, `filter_search_tag`, `search_category_tag`, `medium_card_search_tag` |
| Vitrine home / banner | `section_tag`, `section_view_tag`, `banners_tag` |
| Landing pages (Prismic) | `showcase_component_tag` (LP), `products_list_component_tag` |
| Ofertas | `exclusive_offers_tag`, `extra_profit_cross_tag` |
| Favoritos | `favorites_tag` |
| Disponibilidade | `stock_status_tag`, `remind_me_tag` |

## Inventario (contrato + impl)

### PDP

| Status | Arquivo | Contexto |
|--------|---------|----------|
| [ ] | `microapps/oraculo/lib/product_details/presentation/tag/product_details_tag.dart` | PDP |
| [ ] | `microapps/oraculo/lib/product_details/presentation/tag/product_details_tag_impl.dart` | PDP |
| [ ] | `microapps/oraculo/lib/presentation/remind_me/tag/remind_me_tag.dart` | Avise-me |
| [ ] | `microapps/oraculo/lib/presentation/remind_me/tag/remind_me_tag_impl.dart` | Avise-me |
| [ ] | `microapps/oraculo/lib/presentation/stock_status/tag/stock_status_tag.dart` | Disponibilidade |
| [ ] | `microapps/oraculo/lib/presentation/stock_status/tag/stock_status_tag_impl.dart` | Disponibilidade |

### PLP

| Status | Arquivo | Contexto |
|--------|---------|----------|
| [ ] | `microapps/oraculo/lib/products_list_component/presentation/tag/products_list_component_tag.dart` | Lista de produtos |
| [ ] | `microapps/oraculo/lib/products_list_component/presentation/tag/products_list_component_tag_impl.dart` | Lista de produtos |
| [ ] | `microapps/oraculo/lib/order_by/tags/order_tag.dart` | Ordenacao |
| [ ] | `microapps/oraculo/lib/order_by/tags/order_tag_impl.dart` | Ordenacao |

### Busca

| Status | Arquivo | Contexto |
|--------|---------|----------|
| [ ] | `microapps/oraculo/lib/presentation/search/tag/search_tag.dart` | Busca |
| [ ] | `microapps/oraculo/lib/presentation/search/tag/search_tag_impl.dart` | Busca |
| [ ] | `microapps/oraculo/lib/presentation/search/tag/filter_search_tag.dart` | Filtros |
| [ ] | `microapps/oraculo/lib/presentation/search/tag/filter_search_tag_impl.dart` | Filtros |
| [ ] | `microapps/oraculo/lib/presentation/search/tag/medium_card_search_tag.dart` | Card busca |
| [ ] | `microapps/oraculo/lib/presentation/search/pages/category/tag/search_category_tag.dart` | Categoria busca |
| [ ] | `microapps/oraculo/lib/presentation/search/pages/category/tag/search_category_tag_impl.dart` | Categoria busca |

### Vitrines home e banners

| Status | Arquivo | Contexto |
|--------|---------|----------|
| [ ] | `microapps/oraculo/lib/presentation/sections/tag/section_tag.dart` | Vitrine home |
| [ ] | `microapps/oraculo/lib/presentation/sections/tag/section_tag_impl.dart` | Vitrine home |
| [ ] | `microapps/oraculo/lib/presentation/sections/tag/section_view_tag.dart` | View secao |
| [ ] | `microapps/oraculo/lib/presentation/sections/tag/section_view_tag_impl.dart` | View secao |
| [ ] | `microapps/oraculo/lib/presentation/sections/tag/section_scroll_tag.dart` | Scroll (anti-padrao) |
| [ ] | `microapps/oraculo/lib/presentation/sections/tag/section_scroll_tag_impl.dart` | Scroll (anti-padrao) |
| [ ] | `microapps/oraculo/lib/presentation/sections/tag/banners_tag.dart` | Banner |
| [ ] | `microapps/oraculo/lib/presentation/sections/tag/banners_tag_impl.dart` | Banner |

### Landing pages (Prismic)

| Status | Arquivo | Contexto |
|--------|---------|----------|
| [ ] | `microapps/oraculo/lib/showcase_component/presentation/tag/showcase_component_tag.dart` | Vitrine na LP |
| [ ] | `microapps/oraculo/lib/showcase_component/presentation/tag/showcase_component_tag_impl.dart` | Vitrine na LP |

### Ofertas e favoritos

| Status | Arquivo | Contexto |
|--------|---------|----------|
| [ ] | `microapps/oraculo/lib/exclusive_offers/presentation/tag/exclusive_offers_tag.dart` | Ofertas exclusivas |
| [ ] | `microapps/oraculo/lib/exclusive_offers/presentation/tag/exclusive_offers_tag_impl.dart` | Ofertas exclusivas |
| [ ] | `microapps/oraculo/lib/extra_profit_cross/presentation/tag/extra_profit_cross_tag.dart` | Lucro extra |
| [ ] | `microapps/oraculo/lib/extra_profit_cross/presentation/tag/extra_profit_cross_tag_impl.dart` | Lucro extra |
| [ ] | `microapps/oraculo/lib/presentation/search/pages/favorites_list/tags/favorites_tag.dart` | Favoritos |
| [ ] | `microapps/oraculo/lib/presentation/search/pages/favorites_list/tags/favorites_tag_impl.dart` | Favoritos |
