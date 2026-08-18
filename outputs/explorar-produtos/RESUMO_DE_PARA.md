# Resumo de-para â€” migracao tagueamento

> Gerado em **2026-08-18** para revisao PM antes da entrega a engenharia.

## Numeros gerais

| Metrica | Valor |
|---------|-------|
| Inventario C&T (linhas) | 78 |
| **Migrar** (interaction/callback) | 33 |
| **Remover** | 17 |
| **Manter** (pageview ok â€” sem trabalho eng) | 22 |
| **Novo** (dicionar_pageview) | 6 |
| Revisar PM | 0 |
| Linhas com json_novo preenchido | 61 |

## Proximos passos PM

1. Abrir **[IMPACTO_MIGRACAO.md](./IMPACTO_MIGRACAO.md)** (gerado)
2. Preencher coluna **Decisao PM (se discordar)** onde discordar do veredito
3. Consolidar: `@analytics-migrate --aprovar`
4. Regenerar entrega eng: `powershell -ExecutionPolicy Bypass -File tools/analytics-migrate/scripts/export-entrega-eng.ps1`

## Entrega engenharia

| Artefato | Descricao |
|----------|-----------|
| **[ENTREGA_ENG.csv](./ENTREGA_ENG.csv)** | Planilha final: navbar + dominio + status + contexto + JSON legado/novo |
| [TAGUEAMENTO_MIGRADO_CT.csv](./TAGUEAMENTO_MIGRADO_CT.csv) | Inventario completo com criterios e diagnostico |

### Colunas ENTREGA_ENG.csv

| Coluna | Uso |
|--------|-----|
| 
avbar | Area / microapp |
| dominio_ct | Dominio C&T |
| status | Status do de-para (migrar, 
emover, dicionar_pageview, â€¦) |
| classificacao | Acao eng: 
ovo \| migrar \| 
emover |
| contexto_legado | Contexto legivel do evento legado |
| evento_legado_json | JSON legado para ctrl+F (vazio em 
ovo; reconstruido se vazio nas demais) |
| json_novo | Envelope GA4 completo alvo |

Pageviews ja corretos (manter) **nao** entram por padrao â€” use export-entrega-eng.ps1 -IncludeManter se precisar referencia.

