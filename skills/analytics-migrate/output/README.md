# Artefatos gerados pelo pipeline analytics-migrate

Arquivos `.md`, `.csv` e `.json` produzidos por `discover.ps1` e `@analytics-migrate` ficam nesta pasta.

## Fluxo PM

| Etapa | Artefato | Uso |
|-------|----------|-----|
| Input | `../config/perguntas-negocio-{squad}.md` | Perguntas P0/P1 do PM |
| Pipeline | `PERGUNTAS_NEGOCIO.md` | Trade-offs — preencher **Decisao PM** |
| Revisao | `RESUMO_DE_PARA.md` | Numeros gerais do de-para |
| Handoff eng | **`ENTREGA_ENG.csv`** | Tag + JSON legado + JSON novo + classificacao |

## Todos os artefatos

| Artefato | Fase | Para quem |
|----------|------|-----------|
| `RESUMO_DE_PARA.md` | pos-transform | PM — numeros |
| `PERGUNTAS_NEGOCIO.md` | business-impact | PM — trade-offs |
| `ENTREGA_ENG.csv` | export-entrega-eng | **Eng** — implementacao |
| `TAGUEAMENTO_MIGRADO_CT.csv` | transform | PM/eng — inventario completo |
| `MIGRACAO_DECISOES.md` | `--aprovar` | PM — log de aprovacao |
| `SIMPLIFICACAO_JORNADAS.md` | simplify | PM — P0/P1/P2 |

Nao commitar `_tag_extract_*.json` se for muito grande para o repo — opcional.
