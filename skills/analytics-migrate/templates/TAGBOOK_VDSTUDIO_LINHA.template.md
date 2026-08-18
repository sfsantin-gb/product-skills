# Linhas novas — Tagbook VD Studio

> Gerado por `@analytics-plan`. Tagbook: [Tagueamento VD Studio](https://docs.google.com/spreadsheets/d/1LBr6ioZ-qe72oeYnB1rypoMEpIvimfI7jj5NkuayfG0/edit) · aba **Tagueamento Agnostico**.
> Status de gravacao: `{nao-gravado | gravado-linha-{n} | bloqueado-sem-sheets}`

## Pedido

{o que o PM quer medir}

## Modelo de referencia

| Campo | Valor |
|-------|--------|
| Linha / ancora | {Status + Contexto + Nome do evento} |
| `screen_name` | |
| Por que este modelo | {mesmo tipo + gatilho parecido} |

## Linhas propostas

### {#} {Nome do evento} — {Contexto}

| Col | Campo | Valor |
|-----|--------|--------|
| A | Status | PLANEJADO |
| B | Sistema Operacional | iOS, Android, VDI |
| C | Contexto | |
| D | Tela | |
| E | Quando deve ser disparado | Quando eu … |
| F | Nome do evento | screen_view / interaction_vdstudio / card_shared / callback_vdstudio_… |
| G | Parametros | |
| H | JSON Payload | ver bloco abaixo |
| I | Exemplo de Disparo Parametros | |

```json
{
  "client_id": "[[identificador-unico-usuario]]",
  "session_id": "[[identificador-unico-sessao]]",
  "events": [{
    "name": "",
    "params": {}
  }]
}
```

**TSV para colar em A{n}:I{n}:**

```
PLANEJADO	iOS, Android, VDI	Contexto		Quando eu …	nome_evento	parametros	{json}	exemplo
```

## Conflitos / harmonizacao

- {guia vs Tagbook, se houver}

## Validacao

1. {cenario 1}
2. {cenario 2}
3. {cenario 3}

## Dedup

{nenhum conflito | ja existe na linha X}
