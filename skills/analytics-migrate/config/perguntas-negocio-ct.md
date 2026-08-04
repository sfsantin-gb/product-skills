# Perguntas de negocio — Conteudos e Trafego

> Fonte PM para `@analytics-business-impact`. Prioriza o cruzamento em `PERGUNTAS_NEGOCIO.md`.
> Complementa (nao substitui) [`docs/EVENTOS_ESSENCIAIS_CT.md`](../docs/EVENTOS_ESSENCIAIS_CT.md).

---

## Divulgacao MLD

| Prioridade | Pergunta de negocio | Indicador / como medir |
|------------|---------------------|------------------------|
| P0 | RE compartilha MLD ou catalogo? | PV hub Divulgar + `interaction_divulgar` share_* |
| P0 | RE abre catalogo digital? | `open:catalog-{brand}` |
| P1 | Funil Home → catalogo → share? | PV Home + PV catalogos + share |

## Materiais de divulgacao

| Prioridade | Pergunta de negocio | Indicador / como medir |
|------------|---------------------|------------------------|
| P0 | RE baixa/compartilha imagem de material? | `download:imagem`, `share:imagem` |
| P1 | RE navega galeria por secao? | PV `$imagesGalleryPage/$sectionName` |

## Vendas sellout

| Prioridade | Pergunta de negocio | Indicador / como medir |
|------------|---------------------|------------------------|
| P0 | RE registra venda? | `callback_vendas_create_sale_success` |
| P0 | RE cobra cliente? | interaction cobranca + PV vendas |
| P0 | Auto-save de rascunho funciona? | `callback_vendas_auto_save_sale_*` |

## Estoque RE

| Prioridade | Pergunta de negocio | Indicador / como medir |
|------------|---------------------|------------------------|
| P0 | RE adiciona produto ao estoque? | `callback_estoque_add_product_*` |
| P0 | RE divulga pronta-entrega? | interaction pronta-entrega + share MLD |

## Gestao do negocio

| Prioridade | Pergunta de negocio | Indicador / como medir |
|------------|---------------------|------------------------|
| P0 | RE acessa relatorio financeiro? | PV relatorio + `callback_gestao_financial_report_error` |
| P1 | RE navega aba financeira vs vendas? | PV aba financeira (lacuna eng se ausente) |

## Checklist PM

- [ ] Perguntas P0 cobrem OKRs / review semanal do time
- [ ] `analytics-migrate.config.yml` → `workspace.perguntas_negocio` aponta para este arquivo
- [ ] Apos pipeline: revisar `PERGUNTAS_NEGOCIO.md` e preencher **Decisao PM**
