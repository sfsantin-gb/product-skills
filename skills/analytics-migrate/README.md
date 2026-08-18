# Analytics Migrate — pacote discover + pipeline

Bootstrap do tagueamento para qualquer squad do megazord. **Roda inteiro dentro do megazord_mobile** — Product OS nao e necessario.

## Pre-requisitos

1. Clone **megazord_mobile**
2. Arquivo **`config/dominios-{squad}.md`** escrito e **revisado** pelo PM (gate 1)
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

Abra o Cursor **somente** no megazord → `@analytics-migrate` → *quero pesquisar {jornada}*. Quatro revisoes com **pronto** entre cada uma; depois o CSV de-para.

## Configuracao

```powershell
copy tools\analytics-migrate\analytics-migrate.config.example.yml tools\analytics-migrate\analytics-migrate.config.yml
```

| Campo | Quem preenche | Exemplo |
|-------|---------------|---------|
| `squad.github_team` | Eng/PM | `vd-sellout-conteudos-e-trafego-mld` |
| `workspace.dominios` | PM | `tools/analytics-migrate/config/dominios-ct.md` |
| `workspace.output_dir` | PM | `tools/analytics-migrate/output` |

## Gates PM (comecar aqui)

1. Dominios → **pronto**
2. Perguntas → **pronto**
3. Eventos essenciais → **pronto**
4. Impacto (`IMPACTO_MIGRACAO.md`) → **pronto**
5. Planilha completa CSV + `ENTREGA_ENG.csv`

Discover (`discover.ps1`) roda **depois** do gate 1, nao no lugar das revisoes.

### O que o discover gera

Artefatos em `tools/analytics-migrate/output/`:

| Artefato | Descricao |
|----------|-----------|
| `_tag_extract_{squad}.json` | Inventario legado extraido do codigo |
| `TAGUEAMENTO_LEGADO_{SQUAD}.md` | Tabela legivel |
| `ESCOPO_{SQUAD}.md` | Microapps/packages do CODEOWNERS |
| `EVENTOS_ESSENCIAIS_{SQUAD}.md` | Rascunho — **gate 3** e a versao que o PM revisa |
| `DISCOVER_REPORT.md` | Resumo + proximos passos |

## Pipeline tecnico (apos os 4 gates)

```
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
