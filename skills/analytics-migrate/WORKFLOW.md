# ADTM Workflow — Analytics-Driven Tag Migration

Metodologia em fases com artefatos `.md` e review gates — espelhando o ciclo SDD (`specify → plan → tasks → implement`).

```
                    ┌─────────────────────────────────────────┐
                    │      megazord_mobile (fonte canonica)    │
                    │  tools/analytics-migrate/               │
                    │  config/dominios-{squad}.md · docs/     │
                    └─────────────────┬───────────────────────┘
                                      │
    ┌─────────────────────────────────▼─────────────────────────────────┐
    │  Gates PM (STOP apos cada um; PM diz "pronto")                      │
    │  1 Dominios → 2 Perguntas → 3 Essenciais → 4 IMPACTO_MIGRACAO.md   │
    └─────────────────────────────────┬─────────────────────────────────┘
                                      │
    ┌─────────────────────────────────▼─────────────────────────────────┐
    │  Discover + AUDIT + PRIORIZE + TRANSFORM                            │
    │  → TAGUEAMENTO_MIGRADO_*.csv (completo, motivo) + ENTREGA_ENG.csv  │
    └─────────────────────────────────┬─────────────────────────────────┘
                                      │
                    ┌─────────────────▼───────────────────────┐
                    │  Codigo Flutter (microapps, packages)   │
                    │  *_tag.dart · rotas · widgets            │
                    └─────────────────────────────────────────┘
```

Instalacao local (Spec Kit): `install-agents.ps1` → `@analytics-migrate` no Cursor. Product OS **nao** e necessario.

---

## Fase 0 — Discover

**Analogia SDD:** `specify` — define o escopo a partir da intencao de produto.

| | |
|---|---|
| **Entrada** | `dominios-{squad}.md`, CODEOWNERS, `analytics-migrate.config.yml` |
| **Agente** | `@analytics-migrate --fase discover` ou `discover.ps1` |
| **Artefatos** | `DISCOVER_REPORT.md`, `_tag_extract_{squad}.json`, `TAGUEAMENTO_LEGADO_{SQUAD}.md`, `ESCOPO_{SQUAD}.md`, rascunho `EVENTOS_ESSENCIAIS_{SQUAD}.md` |
| **Gate** | PM confere se dominios cobrem areas de negocio reais |

**O que acontece:** extrator percorre `megazord_mobile` filtrando microapps do time, le labels/metodos em `*_tag.dart`, cruza com dominios PM.

---

## Fase 1 — Prune Navigation

**Analogia SDD:** `plan` (parte 1) — decide o que nao precisa existir.

| | |
|---|---|
| **Entrada** | Inventario legado, codigo megazord |
| **Agente** | `@analytics-migrate --fase navigation` |
| **Artefato** | `NAVEGACAO_AUDITORIA.md` [+ `.csv`] |
| **Gate** | PM revisa vereditos `remover` vs `manter` (share/link externo nunca remove) |

**Regras:**

- Cliques in-app (`ir-para-*`, `voltar-*`, `ver-mais*`) → candidatos a remocao
- Validar handler no codigo (`router.push` vs `openUrl` vs `shareText`)
- Nunca remover compartilhamento ou link externo

---

## Fase 2 — Coverage

**Analogia SDD:** `plan` (parte 2) — garante que destinos tem contrato.

| | |
|---|---|
| **Entrada** | Candidatos a remocao da Fase 1 |
| **Agente** | `@analytics-migrate --fase coverage` |
| **Artefato** | `COBERTURA_AUDITORIA.md` [+ `.csv`] |
| **Gate** | Lacunas `lacuna_pageview` viram TODO eng antes de remover clique |

**O que valida:** destino da navegacao tem `screen_view` via router meta, `TagNavigatorObserver` ou `setCurrentScreen`.

---

## Fase 3 — Callbacks

**Analogia SDD:** padronizacao de contratos de erro/sucesso.

| | |
|---|---|
| **Entrada** | Eventos `callback:*` no legado |
| **Agente** | `@analytics-migrate --fase callbacks` |
| **Artefato** | `CALLBACKS_MIGRACAO.md` [+ `.csv`] |
| **Gate** | Eng confirma keywords (`callback_add_product_success`, etc.) |

**Formato novo:** `callback_<keyword>_success|error` + `cd_error_message`.

---

## Fase 4 — Simplify

**Analogia SDD:** `tasks` — prioriza o que importa para o negocio.

| | |
|---|---|
| **Entrada** | `EVENTOS_ESSENCIAIS_CT.md`, `dominios.md`, auditorias 1–3 |
| **Agente** | `@analytics-migrate --fase simplify` |
| **Artefato** | `SIMPLIFICACAO_JORNADAS.md` |
| **Gate PM** | Decidir todos os `revisar_pm`; confirmar P0 intocaveis |

**Vereditos:**

| Veredito | Significado |
|----------|-------------|
| `essencial_p0` | Manter — funil critico |
| `essencial_p1` | Manter salvo decisao |
| `nao_essencial` / `nav_duplicada` | Remover se PM concordar |
| `fundir_pai` | Agrupar granularidade modal/SKU |
| `revisar_pm` | **PM decide** |

---

## Fase 5 — Transform

**Analogia SDD:** `implement` — entrega executavel.

| | |
|---|---|
| **Entrada** | Decisoes aprovadas em `MIGRACAO_DECISOES.md` |
| **Agente** | `@analytics-migrate --fase transform --export-csv` |
| **Artefatos** | `TAGUEAMENTO_MIGRADO_CT.md`, `TAGUEAMENTO_MIGRADO_CT.csv` |
| **Gate PM** | `@analytics-migrate --aprovar` → atualiza `MIGRACAO_DECISOES.md` |
| **Gate Eng** | Implementar tags no megazord + testes |

**Formato GA4:**

- `interaction_<grupo>` + `cd_interaction_detail`
- `screen_view` via observer (nao clique duplicado)
- Max ~100 custom dimensions no projeto

---

## Fase 6 — Journey Matrix (opcional)

**Analogia SDD:** pos-implementacao / QA — validacao ponta a ponta.

| | |
|---|---|
| **Entrada** | CSV de eventos + codigo megazord |
| **Script** | `megazord_mobile/tools/generate-matriz-jornadas-maestro.ps1` |
| **Artefato** | `matriz_jornadas_maestro.csv` |
| **Uso** | Maestro e2e: navbar → tela → seletor → assert evento |

Colunas: `id_jornada`, `ordem_passo`, `tela_rota`, `seletor_ui`, `tipo_acao`, taxonomia GA4 e legado.

---

## Gates consolidados

| Gate | Quem | Quando | Artefato | Como avancar |
|------|------|--------|----------|--------------|
| G1 — Dominios | PM | Inicio | `dominios-{squad}.md` | **pronto** |
| G2 — Perguntas | PM | Pos G1 | `perguntas-negocio-{squad}.md` | **pronto** |
| G3 — Essenciais | PM | Pos G2 | `EVENTOS_ESSENCIAIS_*.md` | **pronto** |
| G4 — Impacto | PM | Pos G3 | `IMPACTO_MIGRACAO.md` | **pronto** |
| G5 — De-para | PM | Pos G4 | CSV completo + `ENTREGA_ENG.csv` | baixar CSV; mudar status se quiser |
| G6 — Implementacao | Eng | Pos G5 | PRs no megazord | — |

**Nao** rode o pipeline tecnico nem gere CSV antes de G1–G4. Ver `SKILL.md`.

---

## Invocacao

```text
quero pesquisar {jornada}
pronto          (avanca um gate)
```

Instalacao: [`INSTALACAO_SKILLS_CORPORATIVAS.md`](INSTALACAO_SKILLS_CORPORATIVAS.md)

Referencia normativa: [`REGRAS_FORMATO_NOVO.md`](REGRAS_FORMATO_NOVO.md)
