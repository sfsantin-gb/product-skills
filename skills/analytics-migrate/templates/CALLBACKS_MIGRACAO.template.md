# Callbacks — migracao C&T

> Gerado em {data} pelo pipeline `@analytics-callbacks`.
> Export estruturado (opcional): [`CALLBACKS_MIGRACAO.csv`](./CALLBACKS_MIGRACAO.csv)

## Resumo

| Tipo | Qtd |
|------|-----|
| success | |
| error | |
| revisar | |

---

## Por keyword

### `{keyword}`

| Resultado | Evento legado | Tag | Novo evento | Params | cd_error_message | Observacoes |
|-----------|---------------|-----|-------------|--------|------------------|-------------|
| sucesso | `callback:{acao}` / `{label}` | `{tag}` | `callback_{keyword}_success` | — | — | |
| erro | `callback:{acao}` / `{label}` | `{tag}` | `callback_{keyword}_error` | — | `{codigo-kebab}` | |

---

## Legenda

- `keyword`: snake_case ingles derivado do verbo legado
- `cd_error_message`: codigo curto kebab-case, nao mensagem literal longa
