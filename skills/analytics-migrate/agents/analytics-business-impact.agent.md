---
name: analytics-business-impact
description: Resume perguntas de negocio respondiveis vs nao respondiveis apos a migracao, explicitando trade-offs para o PM.
handoffs:
  - label: Aprovar decisoes PM
    agent: analytics-migrate
    prompt: Consolide itens revisar_pm em MIGRACAO_DECISOES.md e regenere IMPACTO_MIGRACAO.md se necessario. Nao pule o gate 4.
---

## User Input

```text
$ARGUMENTS
```

## Outline

**Artefato principal (leitura humana, gate 4):**
`tools/analytics-migrate/output/IMPACTO_MIGRACAO.md`

Nao ha export CSV nesta fase. A planilha de-para so sai **depois** do PM dizer **pronto** neste gate.

### 1. Leitura obrigatoria

0. `config/perguntas-negocio-{squad}.md` — **fonte prioritaria** das perguntas P0/P1 do PM (template: `templates/perguntas-negocio-squad.template.md`)
1. `docs/EVENTOS_ESSENCIAIS_CT.md` — catalogo ampliado / rascunho do discover
2. `config/dominios-{squad}.md`
3. `output/SIMPLIFICACAO_JORNADAS.md`
4. `output/TAGUEAMENTO_MIGRADO_CT.md` e `.csv` (preferir CSV para cruzamento em massa)
5. `output/NAVEGACAO_AUDITORIA.md`, `output/COBERTURA_AUDITORIA.md`, `output/CALLBACKS_MIGRACAO.md`
6. `output/MIGRACAO_DECISOES.md` (se existir — respeitar aprovacoes PM)
7. Template: `templates/IMPACTO_MIGRACAO.template.md`

### 2. Objetivo

Produzir um **resumo para PM** que responda:

- Quais perguntas de negocio continuam **totalmente respondiveis** com o inventario migrado?
- Quais ficam **parcialmente respondiveis** (proxy degradado)?
- Quais ficam **nao respondiveis** — o que o PM esta **abrindo mao** ao aprovar remocoes?
- Quais dependem de **lacuna de engenharia** (`adicionar_pageview`, callback novo)?
- Quais sao **fora do app** (web/BFF/backend)?

### 3. Metodo

Para **cada pergunta** em `perguntas-negocio-{squad}.md` (prioridade) e complementarmente em `EVENTOS_ESSENCIAIS_*.md`:

1. Identificar eventos essenciais citados (PV, INT, CB).
2. Localizar cada evento no inventario migrado (`status`: manter | migrar | remover | adicionar_pageview).
3. Classificar a pergunta:

| Status | Regra |
|--------|-------|
| **respondivel** | Todos os eventos essenciais com `manter` ou `migrar` (ou `pageview_ok`) |
| **parcialmente_respondivel** | Pelo menos um proxy P0/P1 permanece, mas evento de intencao/caminho foi `remover` ou `fundir_pai` |
| **nao_respondivel** | Todos os eventos que sustentam a pergunta com `remover` e sem PV/callback substituto |
| **lacuna** | Pergunta desejada no guia, mas `adicionar_pageview` ou callback pendente em `COBERTURA` / `CALLBACKS` |
| **fora_app** | Pergunta explicitamente fora do megazord no guia (portal, BFF, GA web) |

4. Citar **eventos legado removidos** (amostra representativa, nao listar centenas de linhas).
5. Referenciar `criterio` do CSV quando aplicavel.

### 4. Secoes obrigatorias do markdown

Seguir `templates/IMPACTO_MIGRACAO.template.md`:

1. **Resumo executivo** — tabela de contagem + % + secao "O que voce esta abrindo mao"
2. **Decisoes que mudam o quadro** — itens `revisar_pm` e `fundir_pai`
3. **Visao por dominio** — tabela pergunta x status x eventos
4. **Catalogos** separados: respondivel | parcial | nao respondivel | lacuna | fora_app
5. **Cruzamento com vereditos CSV**
6. **Legenda** — incluir instrucoes da coluna `Decisao PM (se discordar)`

Todas as tabelas de pergunta (dominio, catalogos, abrir mao, revisar_pm, lacunas, fora_app) devem ter coluna final **`Decisao PM (se discordar)`** com celula vazia (`| |`) para o PM preencher se discordar do veredito.

Agregar por pergunta de negocio — **nao** listar uma linha por evento legado.

### 5. Regras

- Navegacao in-app removida com PV no destino → pergunta de **chegada na tela** = respondivel; pergunta de **qual botao/caminho** = parcial ou nao respondivel (deixar explicito).
- `screen_view` existente nunca conta como "perda" — e o padrao GA4 esperado.
- Perguntas P0 em `essencial_p0` **nao** podem aparecer como `nao_respondivel` salvo bug confirmado — marcar `lacuna` ou `revisar_pm`.
- Se `MIGRACAO_DECISOES.md` registrar "manter" para item `revisar_pm`, recalcular status antes de publicar.
- Tom: objetivo, orientado a decisao PM — evitar jargao de engenharia na coluna "Implicacao".

### 6. Quando executar

- **Gate 4** — depois de dominios, perguntas e essenciais aprovados. Depois de gravar, **PARE** e espere **pronto**.
- Isolado: `@analytics-migrate --fase business-impact` (nao gera CSV)
- Pode usar o extract do discover + regras; o CSV detalhado vem no passo seguinte
- Reexecutar se o PM mudar perguntas/essenciais antes do de-para
