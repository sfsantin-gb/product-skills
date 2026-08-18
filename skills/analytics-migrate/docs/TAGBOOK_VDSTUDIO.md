# Tagbook VD Studio

Fonte canonica de eventos **novos** do VD Studio. Nao e o Tagbook GA4 MLD nem o APP legado.

**Planilha:** [Tagueamento VD Studio](https://docs.google.com/spreadsheets/d/1LBr6ioZ-qe72oeYnB1rypoMEpIvimfI7jj5NkuayfG0/edit)  
**fileId:** `1LBr6ioZ-qe72oeYnB1rypoMEpIvimfI7jj5NkuayfG0`

## Abas

| Aba | Uso |
|-----|-----|
| **Tagueamento Agnostico** | Canonica para linha nova (app + VDI). Colunas A–I. |
| Dicionario de Parametros | Valores esperados de `screen_name`, `cd_interaction_detail`, formatos |
| GA Whatsapp / Logs Whatsapp | So se o pedido for fluxo WhatsApp |
| APP legado | UA (`event` + category/action/label). **Nao** usar como modelo de linha nova |

## Colunas (Tagueamento Agnostico)

| Col | Nome | Regra |
|-----|------|--------|
| A | Status | Nova linha: `PLANEJADO`. `DEV` / `PRD` so se o usuario pedir |
| B | Sistema Operacional | Default `iOS, Android, VDI`. Recortar se o gatilho for so uma plataforma (ver `card_shared`) |
| C | Contexto | Agrupamento da jornada: `Inicio`, `Sair`, `Divulgacao`, … — reutilizar o do modelo |
| D | Tela | Preencher so se o modelo daquele contexto ja usa. Muitas linhas deixam vazio |
| E | Quando deve ser disparado | Primeira pessoa: `Quando eu …` |
| F | Nome do evento | Ver tipos abaixo |
| G | Parametros | Lista humana, um por linha: `screen_name: …` / `cd_interaction_detail: …` |
| H | JSON Payload | Envelope GA4 completo (abaixo) |
| I | Exemplo de Disparo Parametros | Mesmos params com **um** valor concreto (sem `[ a \| b ]`) |

Proxima linha vazia: ler o range da aba (hoje amostra `A1:I36`) e gravar em `I{n+1}` — nao sobrescrever.

## Tipos de evento (modelo)

| Tipo | `Nome do evento` | Quando | Modelo de referencia |
|------|------------------|--------|----------------------|
| Pageview | `screen_view` | Usuario **ve** uma tela/modal | Outro `screen_view` com `screen_name` no mesmo prefixo `/vdstudio/…` |
| Interacao | `interaction_vdstudio` | Clique, toggle, navbar, tentativa bloqueada | `interaction_vdstudio` com o mesmo padrao de gatilho (click / toggle / navbar) |
| Share/export | `card_shared` | Salvar ou divulgar o card | Linhas `card_shared` (Android vs iOS/VDI sao **duas** linhas) |
| Callback | `callback_vdstudio_<keyword>_success` / `_error` | Resultado de API/render | Se nao houver no Tagbook, usar `REGRAS_FORMATO_NOVO.md` § callbacks + envelope do modelo `interaction_vdstudio` |

Nao criar `interaction_*` novo (ex.: `interaction_legal`). Grupo ja existe: `interaction_vdstudio`.

Nao usar ECOM (`view_item`, `purchase`, …) no editor de card.

## Contrato

`screen_name` novo: `/vdstudio/…` (nao `/app-rev/pdp/vdstudio`).

`cd_interaction_detail`: ingles, kebab-case. No Tagbook vigente: `click:continuar-editando`, `click:toggle-textos-[exibir | ocultar]`, `click:navbar-salvar`. Preferir `{acao}:{contexto}` alinhado as linhas **Agnostico**, nao o `clique:` do dicionario legado.

Alternativas na coluna G: `click:[ continuar-editando | descartar-e-sair ]`. Coluna I: um valor so.

Envelope JSON (igual as linhas PRD/DEV):

```json
{
  "client_id": "[[identificador-unico-usuario]]",
  "session_id": "[[identificador-unico-sessao]]",
  "events": [{
    "name": "interaction_vdstudio",
    "params": {
      "screen_name": "/vdstudio",
      "cd_interaction_detail": "click:navbar-salvar"
    }
  }]
}
```

`screen_view` leva so `screen_name` no Tagbook atual (nao inventar `cd_page_title` aqui, mesmo que o guia C&T peca — declarar o conflito).

Nao criar CD nova se o contexto couber em `cd_interaction_detail` (< 100 chars). Limite do projeto: 100 CDs.

## Como achar o modelo

1. Ler a aba **Tagueamento Agnostico** inteira.
2. Filtrar pelo mesmo `Nome do evento`.
3. Desempate: mesmo `Contexto`, depois gatilho parecido (`Quando eu vejo` vs `Quando eu clico`).
4. Citar a linha modelo: Status + Contexto + evento + `screen_name` (+ `cd_interaction_detail` se houver).
5. Clonar envelope e coluna G/I; trocar so o que muda.

Dedup: se ja existe o mesmo trio `Nome do evento` + `screen_name` + `cd_interaction_detail`, **nao** criar linha — apontar a existente.
