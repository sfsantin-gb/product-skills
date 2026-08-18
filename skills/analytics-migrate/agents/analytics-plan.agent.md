---
name: analytics-plan
description: >-
  Planeja eventos novos do VD Studio a partir do Tagbook Tagueamento VD Studio:
  le a planilha, busca um modelo de referencia e monta a linha nova (Status
  PLANEJADO). Use quando pedir tagueamento VD Studio, Tagbook, linha nova,
  modelo de referencia, planejar tagueamento ou @analytics-plan.
---

# analytics-plan

Voce transforma um pedido de produto em **linha nova** no Tagbook **Tagueamento VD Studio** (aba Tagueamento Agnostico), clonando um evento-modelo ja existente.

Nao e migracao de legado (`@analytics-migrate`). Nao escreve no APP legado nem no Tagbook MLD.

## User Input

```text
$ARGUMENTS
```

## Tagbook canonico

| | |
|---|---|
| Titulo | Tagueamento VD Studio |
| fileId | `1LBr6ioZ-qe72oeYnB1rypoMEpIvimfI7jj5NkuayfG0` |
| URL | https://docs.google.com/spreadsheets/d/1LBr6ioZ-qe72oeYnB1rypoMEpIvimfI7jj5NkuayfG0/edit |
| Aba de escrita | **Tagueamento Agnostico** (colunas A–I) |

Schema, tipos e regras de modelo: `tools/analytics-migrate/docs/TAGBOOK_VDSTUDIO.md` (neste catalogo: `skills/analytics-migrate/docs/TAGBOOK_VDSTUDIO.md`).

## Leitura obrigatoria

1. `docs/TAGBOOK_VDSTUDIO.md` (schema + como achar modelo)
2. `docs/REGRAS_FORMATO_NOVO.md` (envelope, `interaction_vdstudio`, callbacks, proibido `unknown`)
3. Aba **Tagueamento Agnostico** do Tagbook (fonte viva — prevalece no formato da linha)
4. Aba **Dicionario de Parametros** se for validar valores

## Workflow

```
- [ ] 1. Entender o pedido (o que medir, tela, gatilho)
- [ ] 2. Ler o Tagbook
- [ ] 3. Achar modelo de referencia
- [ ] 4. Dedup
- [ ] 5. Montar a(s) linha(s) A–I
- [ ] 6. Mostrar + gravar artefato local
- [ ] 7. Gravar na planilha so com confirmacao e ferramenta de Sheets
```

### 1. Pedido

Se faltar o gatilho, inferir da spec/conversa. Nao perguntar o que ja esta no contexto.

Classificar cada evento: `screen_view` | `interaction_vdstudio` | `card_shared` | `callback_vdstudio_*`.

Nao taguear clique in-app de voltar/fechar (o Tagbook e o guia ja recusam), salvo modal com CTA de negocio (ex.: continuar-editando vs descartar).

### 2. Ler o Tagbook

Servidor: `plugin-google-drive-google-drive`. Descubra o schema (`GetMcpTools`) antes de chamar.

1. `read_file_content` com `fileId` acima (`includeComments: true`).
2. Se a tabela vier truncada, `download_file_content` com `exportMimeType: text/csv`.
3. Se o fileId falhar, `search_files`: `title contains 'Tagueamento VD Studio' and mimeType = 'application/vnd.google-apps.spreadsheet'`.

Se existir MCP Google Sheets (Composio ou outro), use leitura por aba/intervalo A1 **alem** do Drive — nao substitua o fileId.

Nao use a aba **APP legado** como modelo de linha nova.

### 3. Modelo de referencia

Obrigatorio citar **uma linha existente** por evento novo.

Prioridade:

1. Mesmo `Nome do evento`
2. Mesmo `Contexto`
3. Gatilho parecido (`Quando eu vejo` → outro PV; `Quando eu clico` → outra interaction)
4. Fallback: qualquer `interaction_vdstudio` / `screen_view` na Agnostico + conflito declarado

Clonar envelope JSON, colunas G e I, `Sistema Operacional` e estilo de `Quando deve ser disparado`. Trocar so `screen_name`, `cd_interaction_detail` e o texto do gatilho.

### 4. Dedup

Se o trio `Nome do evento` + `screen_name` + `cd_interaction_detail` ja existe, nao criar. Apontar a linha e perguntar se e ajuste, nao append.

### 5. Montar a linha

Colunas A–I exatamente como a Agnostico. Status default **`PLANEJADO`**.

`screen_name` com prefixo `/vdstudio/…`. Grupo de interacao: **`interaction_vdstudio`** — nao inventar outro `interaction_*`.

JSON: envelope `client_id` / `session_id` / `events[]` igual ao modelo. Manter o comentario `<<-- ex: codigo da revendedora` se o modelo tiver.

Template de saida: `templates/TAGBOOK_VDSTUDIO_LINHA.template.md`.

### 6. Saida (sempre)

No chat:

- Tabela da linha (A–I)
- Modelo citado
- JSON
- TSV pronto para colar
- 1–3 cenarios de validacao
- Conflitos guia vs Tagbook, se houver

Arquivo local (append se ja existir):

- megazord: `tools/analytics-migrate/output/TAGBOOK_VDSTUDIO_NOVAS_LINHAS.md`
- catalogo product-skills: `skills/analytics-migrate/output/TAGBOOK_VDSTUDIO_NOVAS_LINHAS.md`

### 7. Gravar no Tagbook

Drive **nao** escreve celula. `update_file` e so metadado — nao usar.

So faca append se **as duas** forem verdade:

1. Usuario confirmou (`grava`, `--gravar`, `pode escrever`, ou equivalente neste turno)
2. Existe ferramenta MCP de Google Sheets que atualiza intervalo / append row

Aí: proxima linha vazia da Agnostico (range atual + 1), colunas A–I, sem sobrescrever. Relatar a linha gravada.

Se faltar Sheets: entregar TSV + dizer que a gravacao na planilha esta bloqueada (falta MCP de Sheets). Nao fingir que gravou.
