# Case — Analytics-Driven Tag Migration (ADTM)

> **Metodologia:** migracao de tagueamento orientada por artefatos `.md`, com gates de revisao humana — no mesmo espirito do Spec-Driven Development (SDD), aplicado a analytics de produto.
>
> **Posicionamento:** Skill 1–2 de um pipeline de 4 skills **sem engenharia** ate homologacao Maestro. Ver [`PIPELINE_COMPLETO.md`](PIPELINE_COMPLETO.md).

## Elevator pitch (competicao)

Times mobile acumulam centenas de eventos legados. PM nao sabe o que manter; homologacao e manual; eng vira gargalo.

**ADTM (Skills 1–2)** deixa o **PM decidir e documentar** o tagueamento futuro e as **jornadas e2e** — agentes leem o codigo, PM aprova `.md`/`.csv`, **zero linha de Dart**. O case Maestro do tech lead (Skills 3–4) **prova** que os eventos disparam certo antes de qualquer PR.

**Frase de efeito:** *SDD para analytics — PM especifica o que medir; Maestro prova que mede; eng so aplica o diff aprovado.*

---

## Problema

| Dor | Impacto |
|-----|---------|
| ~480 eventos legados so na squad C&T | Taxonomia inconsistente, dashboards ruidosos |
| Cliques de navegacao tagueados | Duplicam `screen_view`; inflam metricas |
| PM sem visibilidade do codigo | Decisoes de remocao no escuro |
| Migracao GA4 manual | Alto risco de regressao e lacunas de pageview |
| Testes e2e desconectados de analytics | QA valida UI sem assert de evento |

## Solucao — pipeline de 4 skills (2 cases)

| Skill | Owner | O que faz | Sem eng? |
|-------|-------|-----------|----------|
| **1 — analytics-migrate** | PM (este case) | Inventario, auditoria, de-para GA4 | Sim |
| **2 — jornadas e2e** | PM (este case) | `matriz_jornadas_maestro.csv` | Sim |
| **3 — scripts Maestro** | Tech lead | YAML + execucao + logs | Sim |
| **4 — validacao** | PM/QA | migrado vs logs | Sim |
| Implementacao no app | Eng (depois) | Aplicar diff aprovado | Unica fase dev |

Diagrama e handoff: [`PIPELINE_COMPLETO.md`](PIPELINE_COMPLETO.md)

### Skill 1 — analogia SDD

| SDD (Spec Kit) | ADTM (Analytics Migrate) |
|----------------|--------------------------|
| `specify` | **Discover** — inventario legado a partir do codigo |
| `plan` | **Prune + Coverage** — auditoria navegacao e pageview |
| `tasks` | **Callbacks + Simplify** — padronizacao e priorizacao P0/P1 |
| `implement` | **Transform** — de-para legado → GA4 (spec, nao codigo) |
| Review gates | **PM aprova** vereditos em `.md` |
| Pos-build QA | **Skill 2** → Maestro (Skills 3–4) |

Fases internas Skill 1: [`WORKFLOW.md`](WORKFLOW.md)

## Resultados (C&T — piloto)

| Metrica | Antes | Depois (pipeline) |
|---------|-------|-------------------|
| Eventos inventariados | dispersos em 217 arquivos tag | `_tag_extract_ct.json` + `TAGUEAMENTO_LEGADO_CT.md` |
| Cliques navegacao candidatos a remocao | nao auditados | `NAVEGACAO_AUDITORIA.md` (piloto 27 eventos) |
| Mapa essencial P0/P1 | inexistente | `EVENTOS_ESSENCIAIS_CT.md` |
| De-para GA4 | manual | `TAGUEAMENTO_MIGRADO_CT.csv` |
| Jornadas e2e | inexistente | `matriz_jornadas_maestro.csv` (1.155 passos, 75 jornadas) |

## Diferenciais competitivos

1. **Product OS como memoria** — dominios, sitemap e decisoes versionados em Git, nao em planilha solta.
2. **Codigo como evidencia** — cada veredito aponta `arquivo_tag` + widget + rota no megazord.
3. **PM no loop** — vereditos `revisar_pm` e gate `--aprovar` antes de eng implementar.
4. **Skill reutilizavel** — qualquer squad com CODEOWNERS + `dominios.md` roda o mesmo pipeline.
5. **Ponta a ponta** — da migracao GA4 ate matriz Maestro para homologacao automatizada.

## Stack

- **Product OS** (`produto-conteudos-e-trafego`) — artefatos, dominios, decisoes PM
- **megazord_mobile** — codigo fonte (tags, rotas, widgets) — **acesso obrigatorio**
- **Cursor** — agente `@analytics-migrate` + skill `.cursor/skills/analytics-migrate/`
- **Scripts** — `discover.ps1`, `export_tagueamento_migrado_ct.ps1`, `generate-matriz-jornadas-maestro.ps1`

## Quem faz o que (sem eng nas fases 1–4)

| Papel | Responsabilidade |
|-------|------------------|
| **PM** | Skills 1–2: dominios, gates, aprovacao, matriz jornadas |
| **Tech lead** | Skills 3–4: Maestro scripts + validacao (case complementar) |
| **Agente IA** | Le megazord (read-only), gera `.md`/`.csv` |
| **Eng** | So apos validacao Maestro — aplicar diff no app (opcional/deferred) |

Megazord = **leitura pelo agente**, nao "PM programando".

## Como reproduzir (5 minutos)

```powershell
# 1. Instalar skill no Product OS
pwsh C:\megazord_mobile\tools\analytics-migrate\install-agents.ps1 -ProductOsRoot .

# 2. Configurar squad
copy tools\analytics-migrate\analytics-migrate.config.example.yml analytics-migrate.config.yml

# 3. Discover
pwsh tools/analytics-migrate/scripts/discover.ps1 -ProductOsRoot .

# 4. Pipeline completo (Cursor)
@analytics-migrate --fase all --export-csv
```

Guia PM: [`PM_QUICKSTART.md`](PM_QUICKSTART.md)

## Publicacao corporativa

Instrucoes para repo compartilhado de skills: [`INSTALACAO_SKILLS_CORPORATIVAS.md`](INSTALACAO_SKILLS_CORPORATIVAS.md)

## Artefatos do case (anexos sugeridos para competicao)

| Artefato | Descricao |
|----------|-----------|
| [`WORKFLOW.md`](WORKFLOW.md) | Metodologia por fases (estilo SDD) |
| [`PM_QUICKSTART.md`](PM_QUICKSTART.md) | Onboarding PM |
| [`TAGUEAMENTO_MIGRADO_CT.csv`](TAGUEAMENTO_MIGRADO_CT.csv) | De-para final |
| [`SIMPLIFICACAO_JORNADAS.md`](SIMPLIFICACAO_JORNADAS.md) | Priorizacao P0/P1/P2 |
| `megazord_mobile/matriz_jornadas_maestro.csv` | Jornadas e2e |
| `megazord_mobile/Eventos C&T - Com microapps.csv` | Inventario enriquecido |

## Narrativa para apresentacao (roteiro 3 min)

1. **Contexto (30s):** 480 eventos legados, PM no escuro, homologacao manual.
2. **Insight (30s):** SDD para codigo; ADTM para analytics — artefatos `.md`, PM no gate.
3. **Skill 1 (45s):** `@analytics-migrate` — o que remover, migrar, revisar — **sem tocar no app**.
4. **Skill 2 (45s):** matriz jornadas — do Home ao clique, seletor + evento GA4 — **ponte para Maestro**.
5. **Skills 3–4 (30s):** case tech lead — Maestro executa e valida; PM le relatorio.
6. **Fechamento (30s):** Eng so entra para aplicar o que PM + Maestro ja provaram.

## Dois cases na competicao

| Case | Apresentador | Skills |
|------|--------------|--------|
| ADTM — decisao e jornadas | PM (voce) | 1 + 2 |
| Homologacao automatizada | Tech lead | 3 + 4 |
