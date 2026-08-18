# Tagueamento migrado - Conteudos e Trafego (C&T)

> Gerado em **2026-08-04** apos analytics-transform + MIGRACAO_DECISOES.md (V1/V3 fechados; V2/V4 descartados).
> Export estruturado: [TAGUEAMENTO_MIGRADO_CT.csv](./TAGUEAMENTO_MIGRADO_CT.csv)

## Resumo executivo

| Metrica | Valor |
|---------|-------|
| Eventos legado (base pipeline) | 484 |
| Inventario C&T (pos-decisoes PM) | 482 |
| Migrados | 182 |
| Removidos | 278 |
| Manter (PV) | 18 |
| Adicionar pageview | 3 |
| Revisar PM | 1 |
| Fora escopo C&T (excluidos) | 2 |

Decisoes aplicadas: R1-R7, M1-M3, F1/F2, V1 (modal MLD obsoleto), V3 (funil catalogo validado).

---

## Por status

| Status | Qtd |
|--------|-----|
| adicionar_pageview | 3 |
| manter | 18 |
| migrar | 182 |
| remover | 278 |
| revisar | 1 |

---

## Fora escopo C&T (excluidos do CSV)

| Tag / dominio | Evento | Motivo |
|---------------|--------|--------|
| `personalize_product_tag` / VD Studio | dinamico (toAnalyticsFormat) | F1/F2 - ownership outro squad |
| `top_ten_show_case_home_tag` / Trafego Home | vitrine-recomendacao-topten | F1/F2 - ownership outro squad |

---

## Overrides PM (desta regeneracao)

| Ref | Acao | Linhas afetadas |
|-----|------|-----------------|
| R1 | Assistente - remover | 4 |
| R2 | Encontre RE - remover | 2 |
| M1 | ir-para-pedidos - migrar | 1 |
| M3 | botao secao galeria - migrar | 1 |
| V1 | PV modal MLD legado - remover (codigo morto) | 1 |
| F1/F2 | VD Studio + Top Ten - excluidos | 2 |

---

## Lacunas abertas (TODO eng)

| Contexto | Acao proposta | Responsavel |
|----------|---------------|-------------|
| Aba financeira SalesReportPage | adicionar_pageview (3 linhas CSV) | engenharia |
| Remover ir-para-relatorio (vendas) | Apos PV aba financeira | engenharia |
| CDs sem linha no inventario | Ver [LACUNAS_CD.md](./LACUNAS_CD.md) - filtros, lembrete parcelas, promote share/addToCart | PM + eng |

---

## Pendencias revisar_pm

- `financial_report_tag` / `ir-para-inicio` - contexto erro relatorio

---

## Removidos - amostra por criterio

| Criterio | Qtd |
|----------|-----|
| nao_essencial | 144 |
| fundir_pai | 63 |
| nav_duplicada | 34 |
| anti_padrao | 19 |
| inventario_agregado | 7 |
| pm_decisao_r1 | 4 |
| pm_decisao_r2 | 2 |
| lacuna_pageview | 2 |
| obsoleto | 2 |
| obsoleto_v1 | 1 |

Detalhe completo: ver colunas criterio, notas e diagnostico no CSV.

