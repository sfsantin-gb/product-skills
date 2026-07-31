---
name: analytics-callbacks
description: Mapeia eventos callback legados para callback_keyword_success e callback_keyword_error com cd_error_message.
handoffs:
  - label: Simplificar jornadas
    agent: analytics-simplify
    prompt: Classifique P0/P1/P2 apos callbacks mapeados.
---

## User Input

```text
$ARGUMENTS
```

## Outline

**Artefato principal (leitura humana):**
`tools/analytics-migrate/output/CALLBACKS_MIGRACAO.md`

**Export opcional (agentes/scripts):**
`tools/analytics-migrate/output/CALLBACKS_MIGRACAO.csv`
— gerar somente se o usuario pedir `--export-csv` ou o orquestrador incluir export.

### 1. Leitura obrigatoria

1. `REGRAS_FORMATO_NOVO.md` - secao 3
2. `TAGUEAMENTO_LEGADO_CT.csv` - filtrar `eventAction` contendo `callback:`
3. Template: `templates/CALLBACKS_MIGRACAO.template.md`

### 2. Regras de mapeamento

| Legado | Novo |
|--------|------|
| sucesso | `callback_<keyword>_success` |
| erro | `callback_<keyword>_error` + `cd_error_message: <codigo-kebab>` |

- `keyword`: snake_case ingles derivado do verbo (`add_product`, `edit_sale`, `auto_save_sale`, `financial_report`)
- Nao usar mensagem literal longa em `cd_error_message` - normalizar para codigo curto
- Params extras so se P0 para analise - evitar novas CDs

### 3. Validacao no codigo

Para cada callback, confirme em `*_tag_impl.dart`:

- Metodo que dispara `_sendCallbackEvent` ou `sendDefaultEvent` com `callback:*`
- Labels dinamicos (`sucesso`, `erro`, `$sku:erro`) - documentar no markdown

### 4. Formato do markdown (obrigatorio)

1. **Resumo** — contagem success / error / revisar
2. **Por keyword** — uma subsecao por `callback_<keyword>`
3. Tabela por par sucesso/erro: evento legado, tag, novo evento, `cd_error_message`, observacoes
4. Secao **Revisar** para labels dinamicos ambiguos ou keyword indefinida
5. **Legenda** de regras de mapeamento

Agrupe por dominio/navbar quando ajudar a leitura (Gestao concentra a maioria).

### 5. Export CSV (opcional)

Se `--export-csv`, use header em `templates/CALLBACKS_MIGRACAO.header.csv`:

`navbar`, `evento_legado_json`, `arquivo_tag`, `event_action_legado`, `event_label_legado`, `name_novo`, `params_novo`, `cd_error_message`, `observacoes`
