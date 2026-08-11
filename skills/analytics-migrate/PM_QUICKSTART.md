# PM Quickstart — Analytics Migrate

Guia de 1 pagina para PMs rodarem a migracao de tagueamento legado → GA4 **somente com o megazord_mobile** — Product OS nao e necessario.

## Caminho mais facil (recomendado)

Depois de instalar a skill e abrir o Cursor **so no megazord**:

```text
@analytics-migrate --setup
```

O agente vai **perguntando**:

1. Nome da squad + time GitHub (lista do CODEOWNERS)
2. Dominios e subdominios do seu produto
3. Perguntas de negocio P0/P1
4. Roda o **discover**
5. Pergunta se quer seguir com o pipeline completo

Voce **nao** precisa editar YAML na mao na primeira vez.

---

## Fluxo PM (3 etapas)

```
[1] SETUP / INPUT     [2] SKILL                         [3] REVISAO + ENG
--setup  (ou arquivos) → discover + --fase all       → RESUMO_DE_PARA.md
dominios + perguntas     PERGUNTAS_NEGOCIO.md            --aprovar
                         TAGUEAMENTO_MIGRADO_*.csv       ENTREGA_ENG.csv → eng
```

---

## O que voce recebe no final

| Artefato | Para que serve |
|----------|----------------|
| `output/RESUMO_DE_PARA.md` | **Numeros gerais** — migrar / remover / manter / novo |
| `output/PERGUNTAS_NEGOCIO.md` | Trade-offs — o que continua mensuravel vs o que se perde |
| `output/ENTREGA_ENG.csv` | **Entrega eng** — navbar, dominio, status, contexto + JSON legado/novo |
| `output/TAGUEAMENTO_MIGRADO_*.csv` | Inventario completo (auditoria / referencia) |
| `output/MIGRACAO_DECISOES.md` | Registro das suas aprovacoes |

---

## Pre-requisito: acesso ao megazord

Peca ao eng do time para te colocar no **time GitHub da squad** na org `grupoboticario`. Sem isso o clone/leitura do `megazord_mobile` falha e o discover nao acha escopo.

---

## Instalacao da skill

Catalogo temporario: https://github.com/sfsantin-gb/product-skills

```powershell
git clone https://github.com/sfsantin-gb/product-skills.git
git clone https://github.com/grupoboticario/megazord_mobile.git C:\megazord_mobile

cd product-skills
powershell -ExecutionPolicy Bypass -File install.ps1 -Target C:\megazord_mobile
```

Abra o Cursor **somente** em `C:\megazord_mobile`.

---

## Etapa 1 — Input manual (alternativa ao --setup)

### 1a. Dominios

```powershell
copy tools\analytics-migrate\templates\dominios-squad.template.md tools\analytics-migrate\config\dominios-{squad}.md
```

Referencia C&T: [`config/dominios-ct.md`](config/dominios-ct.md).

### 1b. Perguntas de negocio

```powershell
copy tools\analytics-migrate\templates\perguntas-negocio-squad.template.md tools\analytics-migrate\config\perguntas-negocio-{squad}.md
```

### 1c. Config / scaffold

```powershell
powershell -ExecutionPolicy Bypass -File tools\analytics-migrate\scripts\setup-squad.ps1 -ListTeams
powershell -ExecutionPolicy Bypass -File tools\analytics-migrate\scripts\setup-squad.ps1 `
  -SquadId minha-squad -SquadName "Minha Squad" -GithubTeam vd-sellout-exemplo
```

---

## Etapa 2 — Pipeline

### Discover (se nao rodou no --setup)

```powershell
powershell -ExecutionPolicy Bypass -File tools\analytics-migrate\scripts\discover.ps1
```

### Pipeline completo (Cursor)

```text
@analytics-migrate --fase all --export-csv
```

---

## Etapa 3 — Revisao PM + handoff eng

1. Ler `output/RESUMO_DE_PARA.md`
2. Revisar `output/PERGUNTAS_NEGOCIO.md` — coluna **Decisao PM (se discordar)**
3. `@analytics-migrate --aprovar`
4. Entregar `output/ENTREGA_ENG.csv` para eng

---

## Invocacao rapida

| Intencao | Comando |
|----------|---------|
| **Primeira vez / nova squad** | `@analytics-migrate --setup` |
| Migracao completa | `@analytics-migrate --fase all --export-csv` |
| Trade-offs negocio | `@analytics-migrate --fase business-impact` |
| Aprovar decisoes | `@analytics-migrate --aprovar` |
| Listar times GitHub | `setup-squad.ps1 -ListTeams` |

## Documentacao

- [`docs/REGRAS_FORMATO_NOVO.md`](docs/REGRAS_FORMATO_NOVO.md)
- [`WORKFLOW.md`](WORKFLOW.md)
- [`PIPELINE_COMPLETO.md`](PIPELINE_COMPLETO.md)
