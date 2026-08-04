# Perguntas de negocio — impacto da migracao

> Gerado em {data} pelo pipeline `@analytics-business-impact`.
> Base: `docs/EVENTOS_ESSENCIAIS_CT.md` + artefatos de migracao (simplify, transform, auditorias).
> Objetivo: deixar explicito **o que o PM continua podendo medir** e **o que deixa de ser respondivel** ao aprovar remocoes.

**Squad:** {squad} | **Dominios:** {dominios_escopo} | **Versao inventario:** {versao_tag_extract}

**Como preencher `Decisao PM (se discordar)`:** deixe vazio se concordar com o veredito. Se discordar, use acao + comentario — ex.: `manter — KPI exige modal filho`, `card eng — priorizar P0`, `remover — aceito perda`. Consolidar depois em `@analytics-migrate --aprovar`.

---

## Resumo executivo (leia primeiro)

| Status | Perguntas | % do total | Implicacao para o PM |
|--------|-----------|------------|----------------------|
| **Respondivel** | {n_respondivel} | {pct_respondivel}% | Mantida integralmente apos migracao |
| **Parcialmente respondivel** | {n_parcial} | {pct_parcial}% | Proxy degradado — validar se KPI aceita |
| **Nao respondivel** | {n_nao_respondivel} | {pct_nao_respondivel}% | **Abrindo mao** — remocao sem substituto |
| **Lacuna (eng)** | {n_lacuna} | {pct_lacuna}% | Nunca teve ou depende de `adicionar_pageview` / callback novo |
| **Fora do app** | {n_fora_app} | {pct_fora_app}% | Requer GA web, BFF ou backend — nao e escopo megazord |

### O que voce esta abrindo mao (top {n_top_abrir_mao})

Perguntas que **deixam de ser respondiveis** se as remocoes propostas forem aprovadas sem compensacao:

| # | Pergunta de negocio | Dominio | Eventos legado removidos | Por que nao ha substituto | Decisao PM (se discordar) |
|---|---------------------|---------|--------------------------|---------------------------|---------------------------|
| 1 | {pergunta} | {dominio} | `{eventCategory}` / `{eventAction}` | {justificativa} | |
| | | | | | |

### Decisoes que mudam o quadro

Itens em `revisar_pm` ou `fundir_pai` cujo veredito do PM altera respondibilidade:

| Pergunta | Veredito pipeline | Se PM aprovar remocao | Se PM mandar manter | Decisao PM (se discordar) |
|----------|--------------------|-----------------------|---------------------|---------------------------|
| {pergunta} | `revisar_pm` / `fundir_pai` | Passa para **nao respondivel** ou **parcial** | Permanece **respondivel** | |

---

## Visao por dominio

### {dominio}

**Pergunta norte:** {pergunta_norte_dominio}

| Pergunta de negocio | Status | Eventos pos-migracao | Eventos legado afetados | Notas | Decisao PM (se discordar) |
|---------------------|--------|----------------------|-------------------------|-------|---------------------------|
| {pergunta} | respondivel | `{evento_novo}` ({tipo}) | — | Cobertura completa | |
| {pergunta} | parcialmente_respondivel | PV `{screen_name}` | removido: `{clique_nav}` | Perde caminho intermediario; chegada na tela ainda mensuravel | |
| {pergunta} | nao_respondivel | — | `{eventCategory}` x{n} | Remocao proposta: `{criterio}` | |
| {pergunta} | lacuna | TODO: `{adicionar_pageview}` | clique removido sem PV destino | Card eng — ver `COBERTURA_AUDITORIA.md` | |
| {pergunta} | fora_app | — | — | Metrica em `{fonte_externa}` | |

**Saldo do dominio:** {n_respondivel} respondiveis · {n_parcial} parciais · {n_nao_respondivel} perdidas · {n_lacuna} lacunas

---

## Catalogo — perguntas respondiveis

Perguntas de saude/performance **totalmente cobertas** pelo inventario migrado (P0/P1 mantidos + PV + callbacks).

| Dominio | Pergunta | Indicador proxy | Eventos essenciais (pos-migracao) | Decisao PM (se discordar) |
|---------|----------|-----------------|-----------------------------------|---------------------------|
| {dominio} | {pergunta} | {indicador} | {lista_eventos} | |

---

## Catalogo — perguntas parcialmente respondiveis

Ainda ha sinal util, mas com **perda de granularidade** ou dependencia de unico proxy.

| Dominio | Pergunta | O que permanece | O que se perde | Risco KPI | Decisao PM (se discordar) |
|---------|----------|-----------------|----------------|-----------|---------------------------|
| {dominio} | {pergunta} | {proxy_restante} | {detalhe_perdido} | {baixo/medio/alto} | |

**Exemplos tipicos pos-migracao:**

- Clique `ver-mais` / `ir-para-*` removido, mas PV no destino existe → funil de **chegada** ok; funil de **intencao no componente** nao.
- Modal filho `fundir_pai` no evento pai → volume agregado ok; breakdown por parcela/SKU/modal nao.
- Hub com PV unico → uso do hub ok; qual modulo foi tocado antes do share nao.

---

## Catalogo — perguntas nao respondiveis

Perguntas **sem evento substituto** apos remocoes propostas. Sao o nucleo do trade-off da migracao.

| Dominio | Pergunta | Eventos removidos (amostra) | Criterio pipeline | Recuperavel? | Decisao PM (se discordar) |
|---------|----------|----------------------------|-------------------|--------------|---------------------------|
| {dominio} | {pergunta} | `{eventCategory}` / `{eventAction}` | `nao_essencial` / `anti_padrao` / `nav_duplicada` | Nao, salvo PM reverter | |
| {dominio} | {pergunta} | scroll / tooltip / `{modal_granular}` | `anti_padrao` / `fundir_pai` | So se PM exigir filho | |

---

## Catalogo — lacunas abertas (engenharia)

Perguntas que o time **quer responder**, mas o app ainda nao instrumenta (ou pageview do destino falta).

| Dominio | Pergunta | Lacuna | Acao proposta | Referencia | Decisao PM (se discordar) |
|---------|----------|--------|---------------|------------|---------------------------|
| {dominio} | {pergunta} | destino sem PV | `adicionar_pageview` `{screen_name}` | `COBERTURA_AUDITORIA.md` | |
| {dominio} | {pergunta} | callback ausente | `callback_{keyword}_success/error` | `CALLBACKS_MIGRACAO.md` | |

---

## Fora do escopo APP

Perguntas listadas em `EVENTOS_ESSENCIAIS_CT.md` que dependem de superficie fora do megazord — **nao entram** no saldo de abrir mao do app.

| Pergunta | Fonte esperada | Observacao | Decisao PM (se discordar) |
|----------|----------------|------------|---------------------------|
| {pergunta} | GA web / portal / BFF `{repo}` | Contexto ops; correlacao manual | |

---

## Cruzamento com vereditos do CSV

Distribuicao de perguntas afetadas por `criterio` em `TAGUEAMENTO_MIGRADO_CT.csv`:

| Criterio | Perguntas impactadas | Efeito tipico na respondibilidade |
|----------|---------------------|-----------------------------------|
| `essencial_p0` | {n} | Mantem — nao abrir mao |
| `essencial_p1` | {n} | Mantem salvo decisao PM |
| `nav_duplicada` | {n} | Parcial ou respondivel via PV |
| `fundir_pai` | {n} | Parcial — perde filho |
| `nao_essencial` | {n} | Nao respondivel |
| `anti_padrao` | {n} | Nao respondivel |
| `lacuna_pageview` | {n} | Lacuna ate eng |
| `revisar_pm` | {n} | **PM decide** o saldo |

---

## Legenda

| Status | Definicao | PM deve |
|--------|-----------|---------|
| **respondivel** | Pergunta respondida com eventos mantidos/migrados no inventario final | Nada — cobertura ok |
| **parcialmente_respondivel** | Proxy existe, mas perdeu granularidade ou caminho | Validar se KPI/produto aceita degradacao |
| **nao_respondivel** | Remocao proposta sem substituto | **Consciente do trade-off** — aprovar ou reverter em `MIGRACAO_DECISOES.md` |
| **lacuna** | Pergunta desejada, instrumentacao ausente | Priorizar card eng (`adicionar_pageview` / callback) |
| **fora_app** | Nao mensuravel no megazord | Buscar outra fonte; nao bloquear migracao do app |

**Coluna Decisao PM:** vazio = concordo. Sugestoes: `concordo` · `manter` · `remover` · `card eng` · `revisar` + texto livre. Decisoes preenchidas aqui alimentam `MIGRACAO_DECISOES.md` no `--aprovar`.

### Como este doc foi montado

1. Extrair perguntas de `docs/EVENTOS_ESSENCIAIS_CT.md` (ou rascunho do discover) por dominio.
2. Para cada pergunta, mapear eventos essenciais citados no guia.
3. Cruzar com `TAGUEAMENTO_MIGRADO_CT.md` / `.csv` (`status`, `criterio`, `veredito`).
4. Incorporar remocoes de `NAVEGACAO_AUDITORIA.md`, lacunas de `COBERTURA_AUDITORIA.md`, callbacks de `CALLBACKS_MIGRACAO.md`.
5. Respeitar decisoes ja registradas em `MIGRACAO_DECISOES.md` quando existirem.

**Regenerar:** `@analytics-migrate --fase business-impact` ou como ultima etapa de `--fase all`.
