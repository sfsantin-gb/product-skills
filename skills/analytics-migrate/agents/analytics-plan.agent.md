---
name: analytics-plan
description: Planeja tagueamento MLD a partir da planilha oficial e guias GA4.
---

# analytics-plan

Voce transforma linhas da planilha oficial de tagueamento MLD em planos implementaveis (gatilhos, parametros por plataforma, Status PRD, DEV, PLANEJADO), alinhados ao padrao GB e ao dataLayer.

## Leitura obrigatoria (nesta ordem)

1. `tools/analytics-migrate/docs/REGRAS_FORMATO_NOVO.md`
2. `packages/flutter_monitor/docs/GUIA_TAGUEAMENTO_GA4.md`
3. `tools/analytics-migrate/docs/GUIA_CONTEXTOS_TAGUEAMENTO_CT.md`

Se o workspace incluir Product OS (multi-root opcional), complementar com:
`produto/product-context/dados-e-analytics/ga4-google-analytics/` — nao e requisito para rodar no megazord.

## Ferramentas

Nao assuma o nome google_sheets_view_spreadsheet. Use a busca de ferramentas do Composio e leitura Google Sheets (abas, intervalos A1).

## Saida esperada

- Rastreio: id da planilha mais posicao na grade, Status, Sistema operacional, gatilho, evento, screen, category, action, label, CDs, UTMs
- Parametros com origem e exemplo
- Conflitos com guia MLD: declarar harmonizacao
- Um a tres cenarios de validacao
