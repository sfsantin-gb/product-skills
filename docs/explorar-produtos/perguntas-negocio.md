# Perguntas de negocio — Explorar Produtos

> **Gate 2.** Jornada sell-in de descoberta e compra de produtos no app.
> Fonte para [EVENTOS_ESSENCIAIS.md](EVENTOS_ESSENCIAIS.md) e [IMPACTO_MIGRACAO.md](IMPACTO_MIGRACAO.md).

**Documentos relacionados:**

- [dominios.md](dominios.md)
- Contrato ECOM: [../../skills/analytics-migrate/docs/REGRAS_FORMATO_NOVO.md](../../skills/analytics-migrate/docs/REGRAS_FORMATO_NOVO.md) §3

---

## PDP (detalhe do produto)


| Prioridade | Pergunta de negocio                                 | Indicador / como medir                |
| ---------- | --------------------------------------------------- | ------------------------------------- |
| P0         | A RE abre a PDP antes de comprar?                   | `view_item` + `item_list_name`        |
| P0         | RE interage com detalhes do produto?                | `interaction_explorar` na PDP (dropdown, semelhantes, avise-me) |
| P0         | A RE adiciona o SKU ao carrinho de compra pela PDP? | `add_to_cart` (origem PDP)            |
| P1         | Ruptura na PDP gera avise-me ou semelhantes?        | INT avise-me / semelhantes + PV modal |


---

## Lista de produtos (PLP)


| Prioridade | Pergunta de negocio                                | Indicador / como medir           |
| ---------- | -------------------------------------------------- | -------------------------------- |
| P0         | A RE visualiza lista/categoria no funil de compra? | `view_item_list`                 |
| P0         | A RE seleciona um SKU na lista?                    | `select_item`                    |
| P0         | A RE adiciona ao carrinho direto do card?          | `add_to_cart` (origem lista)     |


---

## Busca


| Prioridade | Pergunta de negocio                                 | Indicador / como medir                |
| ---------- | --------------------------------------------------- | ------------------------------------- |
| P0         | A RE busca produto (termo) no funil de compra?      | `search` + `search_term`              |
| P0         | A busca retorna resultado com sucesso?              | `callback_busca_*_success` / `_error` |
| P0         | Busca converte para PDP ou carrinho?                | `search` → `view_item` / `add_to_cart` |
| P1         | Filtros e categorias da busca sao usados?           | INT filtro/categoria                  |


---

## Vitrines home e banners


| Prioridade | Pergunta de negocio                           | Indicador / como medir                 |
| ---------- | --------------------------------------------- | -------------------------------------- |
| P0         | Clique em banner/criativo no funil de compra? | `view_promotion` / `select_promotion`  |


---

## Landing pages (Prismic)


| Prioridade | Pergunta de negocio                 | Indicador / como medir                                      |
| ---------- | ----------------------------------- | ----------------------------------------------------------- |
| P0         | A RE abre a LP de campanha/produto? | PV da LP (`screen_name` da pagina Prismic)                  |
| P0         | A LP gera descoberta e add to cart? | `view_item_list` / `add_to_cart` com `item_list_name` da LP |
| P1         | De onde a RE chega na LP?           | origem (busca rapida, banner, oferta) + PV destino          |


---

## Promocoes e ofertas


| Prioridade | Pergunta de negocio                           | Indicador / como medir             |
| ---------- | --------------------------------------------- | ---------------------------------- |
| P0         | A RE entra em ofertas exclusivas / promocoes? | PV ofertas + `view_promotion`      |
| P0         | Promocao selecionada gera add to cart?        | `view_promotion` / `view_item_list` → `add_to_cart` |
| P1         | Lucro extra no card influencia a compra?      | INT lucro extra + `add_to_cart`    |


---

## Favoritos


| Prioridade | Pergunta de negocio                     | Indicador / como medir |
| ---------- | --------------------------------------- | ---------------------- |
| P1         | A RE salva produto para comprar depois? | `add_to_wishlist`      |
| P1         | A RE volta a lista de favoritos?        | PV favoritos           |


---

## Disponibilidade e utilitarios


| Prioridade | Pergunta de negocio          | Indicador / como medir |
| ---------- | ---------------------------- | ---------------------- |
| P1         | Avise-me e usado em ruptura? | INT/CB remind-me       |


---

## Checklist PM

- [x] Cada dominio de `dominios-explorar-produtos.md` com perguntas P0/P1
- [x] Perguntas sao decisoes de negocio (funil de compra), nao nomes de evento soltos
- [x] Config aponta para este arquivo em `workspace.perguntas_negocio`
- [ ] Dizer **pronto** para o agente gerar eventos essenciais (gate 3)