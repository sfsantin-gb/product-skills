---
name: analytics-migrate
description: Migra tagueamento legado para interaction_* e callback_* com setup guiado para PMs, auditoria de navegacao, cobertura de pageview e simplificacao de jornadas.
handoffs:
  - label: Auditar navegacao
    agent: analytics-prune-navigation
    prompt: Gere NAVEGACAO_AUDITORIA.md a partir do inventario legado validando handlers no megazord_mobile.
  - label: Auditar cobertura
    agent: analytics-coverage
    prompt: Cruze candidatos a remocao com pageview (router meta tag, TagNavigatorObserver, setCurrentScreen manual).
  - label: Padronizar callbacks
    agent: analytics-callbacks
    prompt: Gere CALLBACKS_MIGRACAO.md conforme REGRAS_FORMATO_NOVO.md.
  - label: Simplificar jornadas
    agent: analytics-simplify
    prompt: Classifique eventos P0/P1/P2 por dominio usando EVENTOS_ESSENCIAIS gerado/atualizado.
  - label: Gerar inventario migrado
    agent: analytics-transform
    prompt: Produza TAGUEAMENTO_MIGRADO_*.md e export CSV com criterio essencial vs nao_essencial.
  - label: Impacto da migracao
    agent: analytics-business-impact
    prompt: Gere IMPACTO_MIGRACAO.md cruzando perguntas-negocio-{squad}.md com eventos essenciais (gate 4). Nao gere CSV neste passo.
  - label: Exportar entrega eng
    agent: analytics-migrate
    prompt: Rode export-entrega-eng.ps1 e generate-resumo-de-para.ps1 apos aprovacao PM.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

Interpret `$ARGUMENTS` for:

- `--setup` / "quero pesquisar {jornada}" - comecar no **gate 1** (dominios). Nao rode o resto.
- `--continuar` / "pronto" / "proximo" / "acabei" - avancar **um** gate (ler `STATUS_REVISAO.md`)
- `--fase <nome>` - fase tecnica: `navigation`, `coverage`, `callbacks`, `simplify`, `transform`, `business-impact`, `all`
- `--navbar <Inicio|Divulgar|Gestao|Menu>` - limitar escopo
- `--dry-run` - planejar sem gravar artefatos
- `--export-csv` - planilha completa `TAGUEAMENTO_MIGRADO_*.csv` (so apos gate 4)
- `--export-entrega-eng` - `ENTREGA_ENG.csv` + `RESUMO_DE_PARA.md` (so apos gate 4)
- `--aprovar` - consolidar decisoes em `MIGRACAO_DECISOES.md`

Se o PM disser "primeira vez", "do zero", "minha squad", "quero pesquisar", "nao sei por onde comecar" **sem** `--fase`, trate como `--setup` (**so gate 1**).

`--fase all` **antes** dos 4 gates aprovados: recusar e dizer qual gate falta. Depois dos 4: pipeline tecnico + CSV completo + `ENTREGA_ENG.csv`.

---

## Outline

### 0. Gates PM (obrigatorio)

Siga `SKILL.md` secao **Fluxo obrigatorio — 4 gates**. **HARD STOP** apos cada gate. Nao rode `--fase all` neste modo.

Use a UI nativa de perguntas (`AskQuestion`) quando disponivel; senao, pergunte no chat.

Leia `output/STATUS_REVISAO.md` se existir e retome o gate pendente.

#### Gate 1 — Dominios (unica coisa no `--setup` / "quero pesquisar")

1. Rode `setup-squad.ps1 -ListTeams` se a squad for nova. Confirme nome, time GitHub, slug.
2. Scaffold se preciso (`setup-squad.ps1` sem `-Force` a menos que o PM peca).
3. Escreva `config/dominios-<id>.md` (dominios reais, subdominios, contexto em 1 frase). Sem placeholder.
4. Atualize `STATUS_REVISAO.md`: gate `dominios`, status `aguardando_pm`.
5. **PARE.** Nao escreva perguntas, essenciais, impacto nem CSV.

Quando o PM disser **pronto**: marque gate 1 `aprovado`. Opcional: `discover.ps1` (inventario interno). Va ao gate 2.

#### Gate 2 — Perguntas de negocio

Escreva `config/perguntas-negocio-<id>.md` (P0/P1 + indicador por dominio). **PARE.**

#### Gate 3 — Eventos essenciais

Escreva `EVENTOS_ESSENCIAIS_{SQUAD}.md` cruzando dominios + perguntas + extract. **PARE.**

#### Gate 4 — Impacto da migracao

Escreva `IMPACTO_MIGRACAO.md` (trade-offs). **PARE.** Nao gere CSV neste passo.

#### Depois do gate 4 aprovado

Aí sim: pipeline tecnico (secoes 2–4) + `TAGUEAMENTO_MIGRADO_*.csv` (motivo em `notas`) + `ENTREGA_ENG.csv`.

Nunca invente inventario sem discover. Discover so **depois** do gate 1 aprovado.

---

### 1. Pre-requisitos (modo pipeline)

1. Leia `.github/skills/analytics-migrate/SKILL.md` (ou `.cursor/skills/analytics-migrate/SKILL.md`)
2. Leia `tools/analytics-migrate/docs/REGRAS_FORMATO_NOVO.md`
3. Leia `tools/analytics-migrate/docs/CRITERIO_RELEVANCIA.md`
4. Leia `tools/analytics-migrate/docs/EVENTOS_ESSENCIAIS_*.md` **ou** o rascunho gerado pelo discover da squad
5. Leia `tools/analytics-migrate/output/_tag_extract_{squad}.json` ou `TAGUEAMENTO_LEGADO_*.md`
6. Contexto PM: `config/dominios-{squad}.md`, `config/perguntas-negocio-{squad}.md`
7. Codigo: `packages/flutter_monitor/docs/GUIA_TAGUEAMENTO_GA4.md`, `tagger_navigator_observer.dart`
8. Se dominios/perguntas/essenciais/impacto do gate atual estiverem so com placeholder → **pare no gate** e nao avance

### 2. Pipeline tecnico (ordem fixa — so apos gate 4)

| Fase | Artefato principal | Export opcional |
|------|-------------------|-----------------|
| prune-navigation | `tools/analytics-migrate/output/NAVEGACAO_AUDITORIA.md` | `.csv` |
| coverage | `tools/analytics-migrate/output/COBERTURA_AUDITORIA.md` | `.csv` |
| callbacks | `tools/analytics-migrate/output/CALLBACKS_MIGRACAO.md` | `.csv` |
| simplify | `tools/analytics-migrate/output/SIMPLIFICACAO_JORNADAS.md` | - |
| transform | `tools/analytics-migrate/output/TAGUEAMENTO_MIGRADO_*.md` | `.csv` completo (motivo em `notas`) |
| entrega-eng | `tools/analytics-migrate/output/ENTREGA_ENG.csv` | `RESUMO_DE_PARA.md` |

`IMPACTO_MIGRACAO.md` e o **gate 4**, nao a ultima fase tecnica.

Nao pule coverage apos prune-navigation.

**Convencao:** markdown em `tools/analytics-migrate/output/` (ou `workspace.output_dir` do config); CSV quando `--export-csv`.

### 3. Regras criticas

- **Navegacao:** cliques `ir-para-*` / `voltar-*` / `ver-mais*` / `ver-tudo*` **sempre remover**; se destino sem pageview, `adicionar_pageview` - **nunca** manter clique como fallback
- **Essencial:** manter eventos que respondem perguntas de `EVENTOS_ESSENCIAIS` + `perguntas-negocio-{squad}.md`
- **Remocao:** P2, modais granulares (`fundir_pai`), hub sem KPI (`nao_essencial`)
- **Callbacks:** `callback_<keyword>_success` | `callback_<keyword>_error` + `cd_error_message`
- **Interacoes:** `interaction_<grupo>` + `cd_interaction_detail` (`{acao}:{componente}-{contexto}`; prioriza texto do botao; proibido `unknown`)
- **Pageview:** `screen_view` existente -> `status: manter`; lacuna -> `adicionar_pageview`

### 4. Saida do orquestrador

Ao final do pipeline **depois do gate 4**:

- Resumo: total legado, removidos, mantidos, migrados, lacunas
- **`TAGUEAMENTO_MIGRADO_*.csv`** (planilha completa — `notas` = motivo) e **`ENTREGA_ENG.csv`** (eng)
- **`RESUMO_DE_PARA.md`**, **`IMPACTO_MIGRACAO.md`** (ja revisado no gate 4)
- Itens `revisar_pm` → orientar o PM a marcar na planilha ou `@analytics-migrate --aprovar`

## Handoffs

- `@analytics-prune-navigation`, `@analytics-coverage`, `@analytics-callbacks`, `@analytics-simplify`, `@analytics-transform`, `@analytics-business-impact`
- `@analytics-plan` - eventos novos no Tagbook **Tagueamento VD Studio** (le modelo, monta linha; grava so com Sheets + confirmacao)
- `@speckit.specify` - spec de implementacao no megazord_mobile
