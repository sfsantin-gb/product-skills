# PM Quickstart â€” Analytics Migrate

Guia de 1 pagina para PMs rodarem a migracao de tagueamento legado â†’ GA4 **somente com o megazord_mobile** â€” Product OS nao e necessario.

## O que voce recebe no final

| Artefato | Para que serve |
|----------|----------------|
| `tools/analytics-migrate/output/TAGUEAMENTO_MIGRADO_CT.md` / `.csv` | De-para legado â†’ GA4 (entrega para eng) |
| `tools/analytics-migrate/output/SIMPLIFICACAO_JORNADAS.md` | Eventos P0/P1/P2 e recomendacao manter/remover |
| `tools/analytics-migrate/output/NAVEGACAO_AUDITORIA.md` | Cliques de navegacao interna candidatos a remocao |
| `tools/analytics-migrate/output/MIGRACAO_DECISOES.md` | Registro das suas aprovacoes |
| `matriz_jornadas_maestro.csv` (opcional) | Passos e2e para Maestro â€” ver secao 6 |

## Pre-requisitos

| Item | Quem | Onde |
|------|------|------|
| Clone `megazord_mobile` | PM ou dev | sua maquina |
| `config/dominios-{squad}.md` | **PM** | `tools/analytics-migrate/config/` |
| `analytics-migrate.config.yml` | PM | `tools/analytics-migrate/` |
| Cursor com agente | PM | `@analytics-migrate` |

## Passo 1 â€” Instalar o pacote (uma vez)

**Opcao A â€” product-skills (recomendado para compartilhar):**

```powershell
git clone https://github.com/sfsantin-gb/product-skills.git
git clone https://github.com/grupoboticario/megazord_mobile.git C:\megazord_mobile

cd product-skills
powershell -ExecutionPolicy Bypass -File install.ps1 -Target C:\megazord_mobile
```

**Opcao B â€” Spec Kit (pacote ja no clone do megazord):**

```powershell
cd C:\megazord_mobile
powershell -ExecutionPolicy Bypass -File tools\analytics-migrate\install-agents.ps1
```

Isso copia agentes e skills para `.github/` e `.cursor/skills/` do megazord.

## Passo 2 â€” Configurar squad

Se ainda nao existir, copie o exemplo:

```powershell
copy tools\analytics-migrate\analytics-migrate.config.example.yml tools\analytics-migrate\analytics-migrate.config.yml
```

Edite:

| Campo | Exemplo C&T |
|-------|-------------|
| `squad.github_team` | `vd-sellout-conteudos-e-trafego-mld` |
| `workspace.dominios` | `tools/analytics-migrate/config/dominios-ct.md` |
| `workspace.output_dir` | `tools/analytics-migrate/output` |

Referencia C&T: [`config/dominios-ct.md`](config/dominios-ct.md).  
Nova squad: copie [`templates/dominios-squad.template.md`](templates/dominios-squad.template.md).

## Passo 3 â€” Discover (inventario legado)

**Opcao A â€” script (recomendado na 1a vez):**

```powershell
powershell -ExecutionPolicy Bypass -File tools\analytics-migrate\scripts\discover.ps1
```

**Opcao B â€” agente no Cursor** (somente megazord aberto):

```
@analytics-migrate --fase discover
```

Confira `tools/analytics-migrate/output/DISCOVER_REPORT.md`.

## Passo 4 â€” Pipeline completo (agente)

```
@analytics-migrate --fase all --export-csv
```

Fases na ordem:

1. **navigation** â€” o que e clique in-app duplicado
2. **coverage** â€” destinos tem pageview?
3. **callbacks** â€” sucesso/erro de API
4. **simplify** â€” P0/P1/P2 por dominio
5. **transform** â€” CSV/MD migrado final

Limite por aba:

```
@analytics-migrate --fase simplify --navbar Divulgar
```

## Passo 5 â€” O que o PM valida

Abra `tools/analytics-migrate/output/SIMPLIFICACAO_JORNADAS.md` e `TAGUEAMENTO_MIGRADO_CT.md`.

| Veredito | Acao do PM |
|----------|------------|
| `essencial_p0` | Manter â€” nao remover |
| `essencial_p1` | Manter salvo decisao explicita |
| `revisar_pm` | **Voce decide** â€” marcar manter/remover |
| `nav_duplicada` / `nao_essencial` | Aprovar remocao se concordar |
| `lacuna_pageview` | Abrir card eng â€” falta PV no destino |
| `obsoleto` | Aprovar remocao |

Consolide:

```
@analytics-migrate --aprovar
```

Atualiza `tools/analytics-migrate/output/MIGRACAO_DECISOES.md`.

## Passo 6 â€” Jornadas Maestro (opcional)

```powershell
powershell -ExecutionPolicy Bypass -File tools\generate-matriz-jornadas-maestro.ps1
```

Saida: `matriz_jornadas_maestro.csv` na raiz do megazord.

## Invocacao rapida

| Intencao | Comando |
|----------|---------|
| Primeira vez | `install-agents.ps1` + discover |
| Migracao completa | `@analytics-migrate --fase all --export-csv` |
| So priorizacao PM | `@analytics-migrate --fase simplify` |
| So navegacao | `@analytics-migrate --fase navigation` |
| Aprovar decisoes | `@analytics-migrate --aprovar` |
| Jornadas e2e | `generate-matriz-jornadas-maestro.ps1` |

## Documentacao de referencia

Tudo em `tools/analytics-migrate/`:

- [`docs/REGRAS_FORMATO_NOVO.md`](docs/REGRAS_FORMATO_NOVO.md)
- [`docs/EVENTOS_ESSENCIAIS_CT.md`](docs/EVENTOS_ESSENCIAIS_CT.md)
- [`docs/CRITERIO_RELEVANCIA.md`](docs/CRITERIO_RELEVANCIA.md)
- [`PIPELINE_COMPLETO.md`](PIPELINE_COMPLETO.md)
- [`README.md`](README.md)

## Compartilhar com outra squad

1. Envie link do megazord + este quickstart
2. Rode `install-agents.ps1` no clone local
3. PM preenche `config/dominios-{squad}.md` + ajusta `analytics-migrate.config.yml`
4. Discover â†’ pipeline â†’ aprovacao PM

Nao precisa de Product OS â€” basta o megazord e o time mapeado no CODEOWNERS.
