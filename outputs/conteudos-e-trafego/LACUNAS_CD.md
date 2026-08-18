# Lacunas `cd_*` — inventario migrado

> Atualizado em **2026-08-04** apos [Preserve cd_* in json_novo](eeb4a83d-a2d3-4cf5-aad9-3b9a9d2996a1) e [Add pageview title to json_novo](8466a355-8577-47d3-99a1-688fff8b2077).
> **Regra PM:** toda `cd_*` ja disparada em producao **deve** constar em `json_novo` no de-para — senao eng perde na implementacao.

## Estado atual do CSV

| CD no `json_novo` | Linhas |
|-------------------|--------|
| `cd_interaction_detail` | interacoes `interaction_*` migrar |
| `cd_error_message` | callbacks erro |
| `cd_page_title` (+ `screen_name`) | pageviews `manter` / `adicionar_pageview` (**21 linhas**) |
| **Demais `cd_*` (enriquecimento)** | **23** linhas (22 `migrar` + 1 pageview `manter` com `cd_section`) |

Modulo: `tools/analytics-migrate/scripts/legacy-cd-params.ps1` — integrado em `export_tagueamento_migrado_ct.ps1` e `apply-migracao-decisoes.ps1` (`Merge-RowJsonNovoCdParams`).

Envelope GA4 (`client_id`, `session_id`, `events[]`) em **204** linhas com `json_novo`. Regras: `REGRAS_FORMATO_NOVO.md` §1 (envelope), §2.3 (`cd_*`), §2.4 (pageviews).

---

## Ja coberto no `json_novo` (23 linhas com cd_* extra)

| CD(s) | Tag / label | Exemplo |
|-------|-------------|---------|
| `cd_brand` | `catalog_page_tag`, `catalog_module_tag`, `opt_out_tag` | `share:catalog-$brand` |
| `cd_catalog_type` + `cd_brand` | `catalog_module_tag` / `divulgar-$type-$brand` | MLD divulgar catalogo |
| `cd_image_name`, `cd_index`, `cd_section` | `materials_page_tag` / imagem galeria | click em card de imagem |
| `cd_section` | `materials_page_tag` M3 / `$button:$sectionNameFormatted` | botao generico por secao |
| `cd_quantity`, `cd_sku` | `create_stock_tag`, `edit_stock_tag`, `stock_page_tag` | callbacks estoque |
| `cd_edicao_produtos`, `cd_qtd_*` (4) | `sellin_sellout_tag` / pronta-entrega | botao adicionar produtos |
| `cd_id_venda` | `sales_*_tag` com `$saleId` | acoes por venda |
| `cd_charge_type`, `cd_origin` | `charge_link_tag` / gerar-link | tipo cobranca + origem |
| `cd_profile_re` | `promote_products_tag` (clique produto/divulgar) | perfil RE |

Placeholders `$...` / `${...}` = variavel Dart no tag impl (preservar para eng).

### Pageviews — `cd_page_title`

Todas as linhas `manter` (18) e `adicionar_pageview` (3) possuem `cd_page_title` em `json_novo.params`.

| Tipo | Exemplo `cd_page_title` | `screen_name` |
|------|-------------------------|---------------|
| Estatico | `Fluxo de gestao de clientes` | `/app-rev/gerenciar-clientes/meus-clientes` |
| Dinamico (secao) | `${sectionName}` | `$imagesGalleryPage/$sectionName` |
| Dinamico (conteudo) | `${screenTitle}` | `/app-rev/conteudo/novidade/${FormatterHelper...}` |
| Lacuna eng | `Pageview ao trocar para aba financeira` | `/app-rev/gestao/relatorio-de-vendas/financeiro` |

**Excecao:** linha `remover` (V1 modal MLD obsoleto) — sem `json_novo` por design.

---

## Parcial — codigo existe, inventario incompleto

Estes fluxos tem logica em `legacy-cd-params.ps1`, mas **nao geram linha enriquecida** hoje porque falta evento no extract, linha esta `remover`, ou evento e Firebase/e-commerce fora do contrato `interaction_*`:

| CD | Tag | Motivo da lacuna |
|----|-----|------------------|
| `cd_filtros` | `customers_filter_tag` | Codigo em `aplicar-filtros` / `adicionar-novo-cliente`; inventario legado so tem pageview |
| `cd_id_venda`, `cd_id_parcela` | `installment_detail_tag`, `manage_receipts_tag` | `enviar-lembrete` marcado `remover` — sem `json_novo` |
| `cd_sku`, `cd_its_from_wishlist` | `promote_products_tag` | `onShareButton` / `onAddToCart` sem linha equivalente no extract |
| `cd_profile_re` | `activations_tag` | Params em eventos e-commerce (`logViewItem`, wishlist) — fora do de-para `interaction_*` |
| `cd_sku` | modais estoque (`create_stock_tag`) | Labels com `$sku` em linhas `remover` / `fundir_pai` |

**Proximo passo:** completar inventario legado (extract) ou criar linhas `adicionar` no CSV para esses eventos; re-rodar `apply-migracao-decisoes.ps1`.

---

## Fora escopo C&T (F1) — referencia apenas

VD Studio (`personalize_product_tag`): `cd_index_produto`, `cd_dimensoes_imagem`, `cd_card_details`, textos do editor, evento `card_shared`. Decisao PM F1 — snapshot separado se owner retomar migracao.

---

## Exemplo `json_novo` — pronta-entrega (coberto)

```json
{
  "client_id": "[[identificador-unico-usuario]]",
  "session_id": "[[identificador-unico-sessao]]",
  "events": [{
    "name": "interaction_gestao",
    "params": {
      "cd_interaction_detail": "click:button-adicionar-produtos-pronta-entrega",
      "cd_edicao_produtos": "${changedQuantity}",
      "cd_qtd_produtos_pedido": "${totalPossibleQuantity}",
      "cd_qtd_produtos_pronta_entrega": "${totalSelectedQuantity}",
      "cd_qtd_selecao_total": "${howManyTotalProductsWereAdded}",
      "cd_qtd_selecao_parcial": "${howManyPartialProductsWereAdded}"
    }
  }]
}
```

**Fonte codigo:** `sellin_sellout_tag_impl.dart`, `customers_filter_tag_impl.dart`, `personalize_product_tag_impl.dart`, `promote_products_tag_impl.dart`
