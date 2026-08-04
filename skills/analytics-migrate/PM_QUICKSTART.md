# PM Quickstart — Analytics Migrate

Guia de 1 pagina para PMs rodarem a migracao de tagueamento legado → GA4 **somente com o megazord_mobile** — Product OS nao e necessario.

## Fluxo PM (3 etapas)

```
[1] INPUT          [2] SKILL                    [3] REVISAO + ENG
dominios.md   →    discover + pipeline    →     RESUMO_DE_PARA.md (numeros)
perguntas.md       PERGUNTAS_NEGOCIO.md         preencher respostas PM
                   TAGUEAMENTO_MIGRADO_CT.csv   --aprovar
                                                ENTREGA_ENG.csv → eng
```

---

## O que voce recebe no final

| Artefato | Para que serve |
|----------|----------------|
| `output/RESUMO_DE_PARA.md` | **Numeros gerais** — migrar / remover / manter / novo |
| `output/PERGUNTAS_NEGOCIO.md` | Trade-offs — o que continua mensuravel vs o que se perde |
| `output/ENTREGA_ENG.csv` | **Entrega eng** — tag + JSON legado + JSON novo + classificacao |
| `output/TAGUEAMENTO_MIGRADO_CT.csv` | Inventario completo (auditoria / referencia) |
| `output/MIGRACAO_DECISOES.md` | Registro das suas aprovacoes |

---

## Etapa 1 — Input do PM

### 1a. Dominios

```powershell
copy tools\analytics-migrate\templates\dominios-squad.template.md tools\analytics-migrate\config\dominios-{squad}.md
```

Referencia C&T: [`config/dominios-ct.md`](config/dominios-ct.md).

### 1b. Perguntas de negocio principais

```powershell
copy tools\analytics-migrate\templates\perguntas-negocio-squad.template.md tools\analytics-migrate\config\perguntas-negocio-{squad}.md
```

Liste **perguntas P0/P1** que a squad usa de fato — nao precisa ser exaustivo.

Referencia C&T: [`config/perguntas-negocio-ct.md`](config/perguntas-negocio-ct.md).

### 1c. Config

```powershell
copy tools\analytics-migrate\analytics-migrate.config.example.yml tools\analytics-migrate\analytics-migrate.config.yml
```

| Campo | Exemplo |
|-------|---------|
| `workspace.dominios` | `tools/analytics-migrate/config/dominios-ct.md` |
| `workspace.perguntas_negocio` | `tools/analytics-migrate/config/perguntas-negocio-ct.md` |
| `workspace.output_dir` | `tools/analytics-migrate/output` |

---

## Etapa 2 — Instalar + pipeline (skill)

### Instalar (uma vez)

```powershell
cd C:\megazord_mobile
powershell -ExecutionPolicy Bypass -File tools\analytics-migrate\install-agents.ps1
```

### Discover

```powershell
powershell -ExecutionPolicy Bypass -File tools\analytics-migrate\scripts\discover.ps1
```

### Pipeline completo (Cursor)

```
@analytics-migrate --fase all --export-csv
```

Fases: navigation → coverage → callbacks → simplify → transform → **business-impact**.

---

## Etapa 3 — Revisao PM + handoff eng

### 3a. Numeros gerais

Abra **`output/RESUMO_DE_PARA.md`**.

### 3b. Perguntas de negocio

Abra **`output/PERGUNTAS_NEGOCIO.md`**:

- Leia resumo executivo (% respondivel / parcial / perdido)
- Preencha **Decisao PM (se discordar)** onde discordar
- Foque em linhas `nao_respondivel` e `revisar_pm`

### 3c. Aprovar

```
@analytics-migrate --aprovar
```

Atualiza `MIGRACAO_DECISOES.md` e regenera CSV se necessario.

### 3d. Entrega eng

```powershell
powershell -ExecutionPolicy Bypass -File tools\analytics-migrate\scripts\export-entrega-eng.ps1
```

Ou rode `apply-migracao-decisoes.ps1` (ja chama export + resumo).

**Arquivo para eng:** `output/ENTREGA_ENG.csv`

| classificacao | Significado |
|---------------|-------------|
| `novo` | Criar pageview/evento (ex.: lacuna aba financeira) |
| `migrar` | Alterar tag para `json_novo` |
| `remover` | Remover disparo legado |

Colunas principais: `arquivo_tag`, `evento_legado_json`, `json_novo`.

---

## O que validar no inventario completo

| Veredito | Acao do PM |
|----------|------------|
| `essencial_p0` | Manter — nao remover |
| `revisar_pm` | **Voce decide** |
| `nav_duplicada` / `nao_essencial` | Aprovar remocao se concordar |
| `lacuna_pageview` | Card eng — falta PV no destino |

---

## Invocacao rapida

| Intencao | Comando |
|----------|---------|
| Primeira vez | `install-agents.ps1` + discover |
| Migracao completa | `@analytics-migrate --fase all --export-csv` |
| Trade-offs negocio | `@analytics-migrate --fase business-impact` |
| Aprovar decisoes | `@analytics-migrate --aprovar` |
| Gerar planilha eng | `export-entrega-eng.ps1` |

## Documentacao

- [`docs/REGRAS_FORMATO_NOVO.md`](docs/REGRAS_FORMATO_NOVO.md)
- [`WORKFLOW.md`](WORKFLOW.md)
- [`PIPELINE_COMPLETO.md`](PIPELINE_COMPLETO.md)
