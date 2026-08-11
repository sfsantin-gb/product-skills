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
  - label: Impacto em perguntas de negocio
    agent: analytics-business-impact
    prompt: Gere PERGUNTAS_NEGOCIO.md cruzando perguntas-negocio-{squad}.md com inventario migrado.
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

- `--setup` - **onboarding guiado** (primeira vez / nova squad): entrevista o PM, gera config + templates, preenche contexto, roda discover
- `--fase <nome>` - executar uma fase: `navigation`, `coverage`, `callbacks`, `simplify`, `transform`, `business-impact`, `all`
- `--navbar <Inicio|Divulgar|Gestao|Menu>` - limitar escopo
- `--dry-run` - planejar sem gravar artefatos
- `--export-csv` - gerar export tabular alem do markdown principal
- `--export-entrega-eng` - gerar `ENTREGA_ENG.csv` + `RESUMO_DE_PARA.md` (handoff eng)
- `--aprovar` - consolidar decisoes em `MIGRACAO_DECISOES.md`

Se o PM disser "primeira vez", "do zero", "minha squad", "nao sei por onde comecar" **sem** `--fase`, trate como `--setup`.

---

## Outline

### 0. Modo `--setup` (obrigatorio quando pedido)

Onboarding conversacional. **Nao** rode `--fase all` ate o PM confirmar o discover.

Use a UI nativa de perguntas (`AskQuestion`) quando disponivel; senao, pergunte no chat (uma decisao por vez, 2–3 opcoes quando couber).

#### Passo A — Identidade da squad

1. Rode e mostre o resultado:
   ```powershell
   powershell -ExecutionPolicy Bypass -File tools/analytics-migrate/scripts/setup-squad.ps1 -ListTeams
   ```
2. Pergunte:
   - Nome da squad (ex.: "Estoque e Vendas")
   - Time GitHub no CODEOWNERS (da lista; se nao souber, oriente a pedir ao eng)
   - Confirme um `squad id` slug (ex.: `estoque-vendas`)
3. Scaffold (sem `-Force` a menos que o PM peca sobrescrever):
   ```powershell
   powershell -ExecutionPolicy Bypass -File tools/analytics-migrate/scripts/setup-squad.ps1 `
     -SquadId <id> -SquadName "<nome>" -GithubTeam <team>
   ```
4. Explique os arquivos criados:
   - `tools/analytics-migrate/analytics-migrate.config.yml`
   - `tools/analytics-migrate/config/dominios-<id>.md`
   - `tools/analytics-migrate/config/perguntas-negocio-<id>.md`

#### Passo B — Dominios (entrevista)

1. Peca **2 a 6 dominios** reais do produto (areas grandes, nao telas soltas).
2. Para cada dominio, peca **1 a 4 subdominios** (fluxos).
3. Para cada subdominio, peca um **Contexto** em 1 frase: o que a RE faz e por que importa para KPI.
4. **Escreva** o markdown final em `config/dominios-<id>.md` no formato:

```markdown
## {Dominio}

### {Subdominio}
> **Contexto:** {frase}
```

Nao deixe placeholders `{...}` no arquivo final.

#### Passo C — Perguntas de negocio (entrevista)

1. Para cada dominio, peca **perguntas P0** (decisao diaria) e opcionalmente **P1**.
2. Se o PM nao souber o nome do evento, aceite descricao de negocio na coluna Indicador.
3. **Escreva** `config/perguntas-negocio-<id>.md` como tabela por dominio.
4. Mostre um resumo curto e peca confirmacao ("posso gravar assim?").

#### Passo D — Discover

1. Com confirmacao do PM, rode:
   ```powershell
   powershell -ExecutionPolicy Bypass -File tools/analytics-migrate/scripts/discover.ps1
   ```
2. Resuma `DISCOVER_REPORT.md` / `ESCOPO_*.md` (pastas, #eventos, shared).
3. Se escopo vazio: o time GitHub provavelmente esta errado ou sem acesso — volte ao Passo A.

#### Passo E — Pipeline (opcional)

Pergunte se quer rodar agora:

- **Sim** → execute o fluxo `--fase all --export-csv` (secoes 1–4 abaixo)
- **Nao** → diga o proximo comando: `@analytics-migrate --fase all --export-csv`

Nunca invente inventarios sem discover.

---

### 1. Pre-requisitos (modo pipeline)

1. Leia `.github/skills/analytics-migrate/SKILL.md` (ou `.cursor/skills/analytics-migrate/SKILL.md`)
2. Leia `tools/analytics-migrate/docs/REGRAS_FORMATO_NOVO.md`
3. Leia `tools/analytics-migrate/docs/CRITERIO_RELEVANCIA.md`
4. Leia `tools/analytics-migrate/docs/EVENTOS_ESSENCIAIS_*.md` **ou** o rascunho gerado pelo discover da squad
5. Leia `tools/analytics-migrate/output/_tag_extract_{squad}.json` ou `TAGUEAMENTO_LEGADO_*.md`
6. Contexto PM: `config/dominios-{squad}.md`, `config/perguntas-negocio-{squad}.md`
7. Codigo: `packages/flutter_monitor/docs/GUIA_TAGUEAMENTO_GA4.md`, `tagger_navigator_observer.dart`
8. Se dominios/perguntas estiverem so com placeholders de template → **interrompa e entre em `--setup`**

### 2. Pipeline (ordem fixa)

| Fase | Artefato principal | Export opcional |
|------|-------------------|-----------------|
| prune-navigation | `tools/analytics-migrate/output/NAVEGACAO_AUDITORIA.md` | `.csv` |
| coverage | `tools/analytics-migrate/output/COBERTURA_AUDITORIA.md` | `.csv` |
| callbacks | `tools/analytics-migrate/output/CALLBACKS_MIGRACAO.md` | `.csv` |
| simplify | `tools/analytics-migrate/output/SIMPLIFICACAO_JORNADAS.md` | - |
| transform | `tools/analytics-migrate/output/TAGUEAMENTO_MIGRADO_*.md` | `.csv` |
| business-impact | `tools/analytics-migrate/output/PERGUNTAS_NEGOCIO.md` | - |
| entrega-eng | `tools/analytics-migrate/output/ENTREGA_ENG.csv` | `RESUMO_DE_PARA.md` |

Nao pule coverage apos prune-navigation.
Executar `business-impact` apos `transform` (incluido em `--fase all`).

**Convencao:** markdown em `tools/analytics-migrate/output/` (ou `workspace.output_dir` do config); CSV quando `--export-csv`.

### 3. Regras criticas

- **Navegacao:** cliques `ir-para-*` / `voltar-*` / `ver-mais*` / `ver-tudo*` **sempre remover**; se destino sem pageview, `adicionar_pageview` - **nunca** manter clique como fallback
- **Essencial:** manter eventos que respondem perguntas de `EVENTOS_ESSENCIAIS` + `perguntas-negocio-{squad}.md`
- **Remocao:** P2, modais granulares (`fundir_pai`), hub sem KPI (`nao_essencial`)
- **Callbacks:** `callback_<keyword>_success` | `callback_<keyword>_error` + `cd_error_message`
- **Interacoes:** `interaction_<grupo>` + `cd_interaction_detail` (`{acao}:{componente}-{contexto}`; prioriza texto do botao; proibido `unknown`)
- **Pageview:** `screen_view` existente -> `status: manter`; lacuna -> `adicionar_pageview`

### 4. Saida do orquestrador

Ao final de `--fase all` ou apos business-impact:

- Resumo: total legado, removidos, mantidos, migrados, lacunas abertas
- **`RESUMO_DE_PARA.md`**, **`PERGUNTAS_NEGOCIO.md`**, **`ENTREGA_ENG.csv`**
- Itens `revisar_pm` → orientar `@analytics-migrate --aprovar` apos o PM preencher discordancias

## Handoffs

- `@analytics-prune-navigation`, `@analytics-coverage`, `@analytics-callbacks`, `@analytics-simplify`, `@analytics-transform`, `@analytics-business-impact`
- `@analytics-plan` - novos eventos em features (pos-migracao)
- `@speckit.specify` - spec de implementacao no megazord_mobile
