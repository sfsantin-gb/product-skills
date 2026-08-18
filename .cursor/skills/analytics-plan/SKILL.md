---
name: analytics-plan
description: >-
  Planeja eventos novos do VD Studio a partir do Tagbook Tagueamento VD Studio:
  le a planilha, busca um modelo de referencia e monta a linha nova (Status
  PLANEJADO). Use quando pedir tagueamento VD Studio, Tagbook, linha nova,
  modelo de referencia, planejar tagueamento ou @analytics-plan.
---

# analytics-plan

Agente fonte (mesmo workflow, copiado ao megazord): `skills/analytics-migrate/agents/analytics-plan.agent.md`.

Schema: `skills/analytics-migrate/docs/TAGBOOK_VDSTUDIO.md`.  
Template: `skills/analytics-migrate/templates/TAGBOOK_VDSTUDIO_LINHA.template.md`.

## Tagbook canonico

- Titulo: **Tagueamento VD Studio**
- fileId: `1LBr6ioZ-qe72oeYnB1rypoMEpIvimfI7jj5NkuayfG0`
- Aba de escrita: **Tagueamento Agnostico** (A–I)
- URL: https://docs.google.com/spreadsheets/d/1LBr6ioZ-qe72oeYnB1rypoMEpIvimfI7jj5NkuayfG0/edit

## Workflow

```
- [ ] 1. Classificar o pedido (screen_view / interaction_vdstudio / card_shared / callback_*)
- [ ] 2. Ler o Tagbook via Drive (read_file_content; CSV se truncar)
- [ ] 3. Citar um modelo na aba Agnostico (mesmo Nome do evento, depois Contexto/gatilho)
- [ ] 4. Dedup do trio evento + screen_name + cd_interaction_detail
- [ ] 5. Montar linha A–I com Status PLANEJADO, screen_name /vdstudio/…
- [ ] 6. Chat + arquivo output/TAGBOOK_VDSTUDIO_NOVAS_LINHAS.md + TSV
- [ ] 7. Append na planilha so com confirmacao do usuario E MCP Google Sheets
```

Drive nao grava celula. Sem Sheets, entregar TSV e declarar bloqueio — nao fingir que gravou.

Nao usar a aba APP legado como modelo. Nao criar outro `interaction_*` alem de `interaction_vdstudio`.
