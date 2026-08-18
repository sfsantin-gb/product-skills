# Escopo da squad EXPLORAR-PRODUTOS

> Gerado em 2026-08-18 por `discover.ps1`.
> Fonte ownership: `CODEOWNERS` + time `vd-sellin-explorar-produtos`.

## Resumo

| Metrica | Valor |
|---------|-------|
| Pastas no escopo | 2 |
| Arquivos tag | 72 |
| Eventos legado | 116 |
| Dominios PM | 8 |
| Perguntas negocio PM | 23 |

## Pastas (CODEOWNERS)

| Pasta | Tipo | Compartilhado | Owners |
|-------|------|---------------|--------|
| `jarvis` | microapp | nao | @grupoboticario/vd-sellin-explorar-produtos @grupoboticario/vd-appre-admin |
| `oraculo` | microapp | nao | product_scope |

## Proximo passo

1. PM revisar `tools/analytics-migrate/config/perguntas-negocio-explorar-produtos.md` (perguntas P0/P1 prioritarias)
2. PM revisar `EVENTOS_ESSENCIAIS_EXPLORAR-PRODUTOS.md` (rascunho por dominio)
3. Rodar `@analytics-migrate --fase all --export-csv`
4. Revisar `RESUMO_DE_PARA.md` + `IMPACTO_MIGRACAO.md` → `@analytics-migrate --aprovar`
5. Entregar `ENTREGA_ENG.csv` para engenharia
