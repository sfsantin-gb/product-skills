# Impacto da migracao

> Gerado em **2026-08-18** pelo pipeline `@analytics-business-impact`.
> Base: `config/perguntas-negocio-explorar-produtos.md` + `TAGUEAMENTO_MIGRADO_EXPLORAR-PRODUTOS.csv`.
> Inventario no escopo: **78** eventos (16 fora de dominio: share, barcode, marca, recomendacao/Top Ten; 22 jarvis).

**Como preencher `Decisao PM (se discordar)`:** vazio = concorda. Consolidar em `@analytics-migrate --aprovar`.

---

## Resumo executivo

| Status | Perguntas | Implicacao |
|--------|-----------|------------|
| **Respondivel** | 15 | Funil ECOM (lista, PDP, busca, banner, LP, ofertas) + wishlist |
| **Parcialmente respondivel** | 3 | Perde scroll / +/- quantidade / clique redirect |
| **Lacuna (eng)** | 3 | PV interpolado: ofertas, avise-me, favoritos, LP |

De-para: **33 migrar** · **22 manter** · **17 remover** · **6 PV novos** · **29 ECOM**.

### O que voce esta abrindo mao

| # | Pergunta | O que sai | Substituto | Decisao PM |
|---|----------|-----------|------------|------------|
| 1 | Qual % do carrossel a RE viu? | scroll | Nenhum (anti-padrao) | |
| 2 | Incrementou quantidade no card? | +/- | `add_to_cart` pai | |
| 3 | Clicou "ver mais" da vitrine? | redirect card | PV + `view_item_list` no destino | |

---

## Por dominio

### PDP

| Pergunta | Status | Eventos pos-migracao | Decisao PM |
|----------|--------|----------------------|------------|
| Abre a PDP? | respondivel | `view_item` (manter) | |
| Interage com detalhes do produto? | respondivel | `interaction_explorar` na PDP (dropdown, semelhantes, avise-me) | |
| Add to cart na PDP? | respondivel | `add_to_cart` (migrar) | |
| Avise-me / semelhantes? | lacuna / parcial | INT + PV modal interpolado | |

### Lista de produtos (PLP)

| Pergunta | Status | Eventos pos-migracao | Decisao PM |
|----------|--------|----------------------|------------|
| Ve a lista? | respondivel | `view_item_list` | |
| Seleciona SKU? | parcial | `select_item` (forte na busca) | |
| Add to cart no card? | respondivel | `add_to_cart` | |

### Busca

| Pergunta | Status | Eventos pos-migracao | Decisao PM |
|----------|--------|----------------------|------------|
| Busca com termo? | respondivel | `search` + `search_term` | |
| Lupa ok? | respondivel | `callback_busca_search_success` / `_error` | |
| Converte para PDP/carrinho? | respondivel | `search` → `view_item` / `add_to_cart` | |
| Filtros? | respondivel | INT filtro + PV categoria | |

### Vitrines home e banners

| Pergunta | Status | Eventos pos-migracao | Decisao PM |
|----------|--------|----------------------|------------|
| Clique em banner? | respondivel | `view_promotion` / `select_promotion` | |

### Landing pages (Prismic)

| Pergunta | Status | Eventos pos-migracao | Decisao PM |
|----------|--------|----------------------|------------|
| Abre a LP? | lacuna | PV da pagina Prismic (TODO eng se interpolado) | |
| LP gera add to cart? | respondivel | `view_item_list` / `add_to_cart` (`showcase_component`) | |
| Origem da chegada? | parcial | banner/oferta + PV destino | |

### Promocoes e ofertas

| Pergunta | Status | Eventos pos-migracao | Decisao PM |
|----------|--------|----------------------|------------|
| Entra em ofertas? | lacuna | PV proposto da categoria | |
| Promocao → cart? | respondivel | `view_promotion` / `view_item_list` → `add_to_cart` | |
| Lucro extra? | respondivel | `view_promotion` + `add_to_cart` | |

### Favoritos

| Pergunta | Status | Eventos pos-migracao | Decisao PM |
|----------|--------|----------------------|------------|
| Salva wishlist? | respondivel | `add_to_wishlist` | |
| Volta a lista? | lacuna | PV `/app-rev/busca/favoritos` | |

---

## Fora desta jornada

Share produto, barcode, jornada de marca, recomendacao/Top Ten, `jarvis`, LPs de dicas C&T, checkout/`purchase`.

## Proximo passo

1. Revisar coluna Decisao PM
2. `@analytics-migrate --aprovar` (output `output-explorar-produtos`)
3. Entregar `ENTREGA_ENG.csv` (56 linhas de trabalho eng)
