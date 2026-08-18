# Pipeline completo — Migracao → Jornadas → Maestro (sem engenharia)

Visao unificada do fluxo **PM-led**: da decisao de tagueamento ate homologacao automatizada, **sem PM escrever codigo** e **sem eng obrigatoria** nas fases 1–4.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  PM + Agente IA                    │  Tech lead / Maestro (case separado)   │
├────────────────────────────────────┼────────────────────────────────────────┤
│  SKILL 1  analytics-migrate        │                                        │
│  (inventario · auditoria · de-para)│                                        │
│           │                        │                                        │
│           ▼ TAGUEAMENTO_MIGRADO    │                                        │
│  SKILL 2  jornadas e2e             │  ◄── PONTE (artefato compartilhado)    │
│  (matriz_jornadas_maestro.csv)     │                                        │
│           │                        │                                        │
└───────────┼────────────────────────┼────────────────────────────────────────┘
            │                        │
            ▼                        ▼
                              SKILL 3  scripts Maestro
                              (YAML por jornada · execucao · logs)
                                        │
                                        ▼
                              SKILL 4  validacao
                              (migrado vs logs · relatorio certo/errado)
```

---

## Principio: o que e "sem engenharia"

| Fase | Quem opera | Toca codigo Dart? |
|------|------------|-------------------|
| Skill 1 — Migrate | **PM** + `@analytics-migrate` | **Nao** — so leitura do megazord pelo agente |
| Skill 2 — Jornadas | **PM** + script/agente | **Nao** — rastreio reverso automatico |
| Skill 3 — Maestro | **Tech lead / QA** + skill Maestro | **Nao** — gera YAML e executa testes |
| Skill 4 — Validacao | **PM ou QA** + agente | **Nao** — compara artefatos |
| Implementacao tag no app | **Eng** (fase posterior, opcional) | Sim — unica fase que exige dev |

O megazord e **leitura** para o agente (como o SDD le o repo para gerar spec). PM nao abre IDE nem PR.

**Unico prerequisito tecnico:** alguem do time garante clone local do `megazord_mobile` no config (pode ser TPM/analista, nao precisa ser dev migrando tag).

---

## Skill 1 — Analytics migrate (`@analytics-migrate`)

**Owner:** PM (C&T)  
**Status:** skill fechada para case / competicao

**O que faz (sem alterar app):**

1. Analisa tagueamento legado no codigo (`*_tag.dart`)
2. Identifica tags desnecessarias (navegacao in-app duplicada, anti-padroes)
3. Propoe remocao / fusao / migracao para nova taxonomia GA4
4. Devolve `.md` + `.csv` do que remover, criar e **areas `revisar_pm`**

**Artefatos:**

| Saida | Uso |
|-------|-----|
| `dominios-{squad}.md` | Gate 1 |
| `perguntas-negocio-{squad}.md` | Gate 2 |
| `EVENTOS_ESSENCIAIS_*.md` | Gate 3 |
| `IMPACTO_MIGRACAO.md` | Gate 4 — o que continua mensuravel vs o que se perde |
| `TAGUEAMENTO_MIGRADO_*.csv` | De-para completo (status + motivo em `notas`) |
| `ENTREGA_ENG.csv` | Handoff eng (JSON), sem o ensaio do motivo |

**Invocacao PM:**

```text
quero pesquisar {jornada}
pronto
```

---

## Skill 2 — Analise de tagueamentos e criacao de jornadas

**Owner:** PM (C&T) — **ponte para Maestro**  
**Status:** piloto entregue (`matriz_jornadas_maestro.csv`)

**O que faz:**

1. Cruza inventario migrado (Skill 1) com codigo do megazord
2. Rastreia reverso: tag → widget → rota → navbar → Home
3. Documenta jornadas e2e estruturadas (passo a passo)
4. Preserva taxonomia legada + GA4 em cada passo final

**Artefato de handoff:**

`matriz_jornadas_maestro.csv`

| Coluna | Maestro usa para |
|--------|------------------|
| `id_jornada` | Agrupar flow YAML |
| `ordem_passo` | Sequencia no script |
| `tela_rota` | Contexto / assert de tela |
| `seletor_ui` | `tapOn` / `assertVisible` |
| `tipo_acao` | `click`, `assert_visible`, `input` |
| `ga4_event_name` + `cd_interaction_detail` | Assert de evento pos-step |

**Geracao (PM, um comando):**

```powershell
powershell -ExecutionPolicy Bypass -File C:\megazord_mobile\tools\generate-matriz-jornadas-maestro.ps1
```

**Evolucao acordada com tech lead:** export adicional JSON por `id_jornada` (Skill 3 consome direto). CSV atual ja e contrato suficiente para prototipo.

---

## Skill 3 — Criacao dos scripts Maestro

**Owner:** Tech lead (case Maestro — em construcao)  
**Entrada:** artefato da Skill 2

**O que faz:**

1. Le documento de jornadas (CSV/JSON)
2. Valida cada passo contra codigo (seletor existe?)
3. Cria script Maestro por jornada e2e
4. Executa e gera **logs de tagueamento** por jornada

**Saida para Skill 4:** logs + artefatos em `E2E/test-results/`

**Relacao com repo:** `E2E/features/`, skill `maestro-e2e-debug` (debug pos-falha)

PM **nao** escreve YAML — consome relatorio da Skill 4.

---

## Skill 4 — Validacao

**Owner:** PM ou QA + agente  
**Entrada:** Skill 1 (migrado) + Skill 3 (logs execucao)

**O que faz:**

1. Compara eventos **esperados** (`TAGUEAMENTO_MIGRADO` / matriz) vs **disparados** (logs Maestro)
2. Classifica: correto · nao disparou · disparou errado
3. Devolve relatorio para PM priorizar correcao

**Gate PM:** so apos verde na Skill 4 (ou excecoes documentadas) a eng implementa mudanca de tag no app (se ainda necessario).

---

## Timeline sugerida (dois cases na competicao)

| Case | Apresenta | Narrativa |
|------|-----------|-----------|
| **Case PM — ADTM** | Voce | Skills 1 + 2: decisao e jornadas sem eng |
| **Case Maestro** | Tech lead | Skills 3 + 4: homologacao automatizada |

**Story conjunta:** *"PM define o que medir e como testar; Maestro prova que funciona — eng so entra para aplicar o diff aprovado."*

---

## Checklist PM (zero engenharia)

- [ ] `dominios.md` preenchido
- [ ] `@analytics-migrate --fase all --export-csv`
- [ ] Revisar `SIMPLIFICACAO_JORNADAS.md` (vereditos `revisar_pm`)
- [ ] `@analytics-migrate --aprovar`
- [ ] Gerar `matriz_jornadas_maestro.csv`
- [ ] Entregar CSV + `TAGUEAMENTO_MIGRADO_CT.csv` ao tech lead (Skill 3)
- [ ] Revisar relatorio Skill 4 quando Maestro rodar

---

## Documentos relacionados

| Doc | Conteudo |
|-----|----------|
| [`CASE.md`](CASE.md) | Pitch competicao (Skill 1) |
| [`WORKFLOW.md`](WORKFLOW.md) | Fases internas Skill 1 (estilo SDD) |
| [`PM_QUICKSTART.md`](PM_QUICKSTART.md) | Comandos PM |
| [`INSTALACAO_SKILLS_CORPORATIVAS.md`](INSTALACAO_SKILLS_CORPORATIVAS.md) | Publicar no catalogo |
