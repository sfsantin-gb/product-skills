---
name: analytics-discover
description: Fase 0 do pipeline analytics-migrate â€” bootstrap a partir de CODEOWNERS + dominios.md do PM.
handoffs:
  - label: Auditar navegacao
    agent: analytics-prune-navigation
    prompt: Inventario legado gerado. Continue com NAVEGACAO_AUDITORIA.md.
---

## User Input

```text
$ARGUMENTS
```

## Outline

Fase **discover**: input minimo para iniciar migracao de tagueamento sem inventario pre-montado.

### Input obrigatorio (humano)

| Input | Quem | Exemplo |
|-------|------|---------|
| megazord_mobile | Dev | clone local |
| `dominios-{squad}.md` | PM | areas de produto do time |
| `analytics-migrate.config.yml` | Dev/PM | squad + github_team + paths |

### Input automatico (codigo)

| Fonte | O que extrai |
|-------|--------------|
| `megazord/.github/CODEOWNERS` | microapps/packages do time |
| `*_tag*.dart` no escopo | inventario legado JSON |

### Execucao

```powershell
powershell -ExecutionPolicy Bypass -File tools/analytics-migrate/scripts/discover.ps1
```

Flags: `-DryRun`, `-Force`, `-GithubTeam`, `-SquadId`, `-MegazordRoot`

### Artefatos gerados

| Arquivo | Uso |
|---------|-----|
| `_tag_extract_{squad}.json` | Fonte para pipeline e export CSV |
| `TAGUEAMENTO_LEGADO_{SQUAD}.md` | Leitura humana |
| `ESCOPO_{SQUAD}.md` | Ownership + microapps |
| `EVENTOS_ESSENCIAIS_{SQUAD}.md` | **PM valida** perguntas norte |
| `DISCOVER_REPORT.md` | Resumo e proximos passos |

### Apos discover

1. PM revisa `EVENTOS_ESSENCIAIS_{SQUAD}.md`
2. Handoff: `@analytics-migrate --fase navigation` ou `--fase all`
3. Nao pular coverage apos navigation

### Microapps compartilhados

Se CODEOWNERS lista mais de um time (ex.: `contents`), marcar em ESCOPO e decidir com PM:
- `include_shared: false` no config, ou
- filtrar tags manualmente pos-discover

### Validacao

- Comparar contagem eventos vs amostra manual em 2-3 microapps
- Verificar ESCOPO bate com expectativa do PM
- Dominios.md deve ter pelo menos 1 secao `##`
