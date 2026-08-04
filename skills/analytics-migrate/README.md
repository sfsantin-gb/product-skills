# Analytics Migrate — pacote discover + pipeline

Bootstrap do tagueamento para qualquer squad do megazord. **Roda inteiro dentro do megazord_mobile** — Product OS nao e necessario.

## Pre-requisitos

1. Clone **megazord_mobile**
2. Arquivo **`config/dominios-{squad}.md`** escrito pelo PM
3. Time mapeado no **CODEOWNERS** do megazord
4. **Cursor** para invocar `@analytics-migrate`

## Instalacao (primeira vez)

**Catalogo PM:** [product-skills](https://github.com/sfsantin-gb/product-skills)

```powershell
git clone https://github.com/sfsantin-gb/product-skills.git
git clone https://github.com/grupoboticario/megazord_mobile.git C:\megazord_mobile
cd product-skills
powershell -ExecutionPolicy Bypass -File install.ps1 -Target C:\megazord_mobile
```

**Local (clone megazord com pacote embarcado):**

```powershell
cd C:\megazord_mobile
powershell -ExecutionPolicy Bypass -File tools\analytics-migrate\install-agents.ps1
```

**PM:** leia [`PM_QUICKSTART.md`](PM_QUICKSTART.md).

## Configuracao

```powershell
copy tools\analytics-migrate\analytics-migrate.config.example.yml tools\analytics-migrate\analytics-migrate.config.yml
```

| Campo | Quem preenche | Exemplo |
|-------|---------------|---------|
| `squad.github_team` | Eng/PM | `vd-sellout-conteudos-e-trafego-mld` |
| `workspace.dominios` | PM | `tools/analytics-migrate/config/dominios-ct.md` |
| `workspace.output_dir` | PM | `tools/analytics-migrate/output` |

## Fase 0 — Discover (comecar aqui)

```powershell
powershell -ExecutionPolicy Bypass -File tools\analytics-migrate\scripts\discover.ps1
```

**Dry-run:**

```powershell
powershell -ExecutionPolicy Bypass -File tools\analytics-migrate\scripts\discover.ps1 -DryRun
```

### O que o discover gera

Artefatos em `tools/analytics-migrate/output/`:

| Artefato | Descricao |
|----------|-----------|
| `_tag_extract_{squad}.json` | Inventario legado extraido do codigo |
| `TAGUEAMENTO_LEGADO_{SQUAD}.md` | Tabela legivel |
| `ESCOPO_{SQUAD}.md` | Microapps/packages do CODEOWNERS |
| `EVENTOS_ESSENCIAIS_{SQUAD}.md` | Rascunho a partir de dominios.md |
| `DISCOVER_REPORT.md` | Resumo + proximos passos |

## Pipeline completo (apos discover)

```
@analytics-migrate --fase discover
@analytics-migrate --fase all --export-csv
```

| Fase | Agente | Saida |
|------|--------|-------|
| discover | analytics-discover | inventario + escopo |
| navigation | analytics-prune-navigation | NAVEGACAO_AUDITORIA.md |
| coverage | analytics-coverage | COBERTURA_AUDITORIA.md |
| callbacks | analytics-callbacks | CALLBACKS_MIGRACAO.md |
| simplify | analytics-simplify | SIMPLIFICACAO_JORNADAS.md |
| transform | analytics-transform | TAGUEAMENTO_MIGRADO_*.md + CSV |

## Estrutura do pacote

```
tools/analytics-migrate/
├── config/          # dominios-{squad}.md (PM)
├── docs/            # regras, criterios, guias
├── output/          # artefatos gerados (discover + pipeline)
├── templates/       # templates MD/CSV
├── agents/          # fonte dos agentes Cursor
├── scripts/         # discover.ps1 e helpers
└── analytics-migrate.config.yml
```

## C&T (referencia)

Squad `ct` / team `vd-sellout-conteudos-e-trafego-mld` ja tem config e dominios em `config/dominios-ct.md`.
