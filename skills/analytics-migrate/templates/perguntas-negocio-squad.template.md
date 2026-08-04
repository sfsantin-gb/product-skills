# Perguntas de negocio — {Nome da Squad}

> **Input do PM (fase 1).** Preencha **depois** de `config/dominios-{squad}.md` e **antes** de `@analytics-migrate --fase all`.
> O pipeline usa este arquivo como fonte prioritaria para `PERGUNTAS_NEGOCIO.md` e validacao de remocoes.

**Documentos relacionados:**

- Dominios: `tools/analytics-migrate/config/dominios-{squad}.md`
- Config: `tools/analytics-migrate/analytics-migrate.config.yml` → `workspace.perguntas_negocio`
- Saida PM: `tools/analytics-migrate/output/PERGUNTAS_NEGOCIO.md`
- Entrega eng: `tools/analytics-migrate/output/ENTREGA_ENG.csv`

---

## Como preencher

1. Liste **somente perguntas que a squad realmente usa** em review de produto / OKR / operacao diaria.
2. Marque **P0** (decisao diaria), **P1** (review mensal) ou **P2** (exploratorio).
3. Na coluna **Indicador**, cite eventos quando souber (`screen_view`, `interaction_*`, `callback_*`) ou descreva a acao de negocio.
4. Nao precisa ser exaustivo — o discover gera rascunho em `EVENTOS_ESSENCIAIS_{SQUAD}.md`; este arquivo **prioriza** o que importa para voce.

---

## {Dominio 1 — ex.: Divulgacao MLD}

| Prioridade | Pergunta de negocio | Indicador / como medir |
|------------|---------------------|------------------------|
| P0 | {Ex.: RE compartilha catalogo ou MLD?} | {Ex.: PV hub Divulgar + `interaction_divulgar` share_*} |
| P1 | {Ex.: Qual modulo de divulgacao mais usado?} | {Ex.: breakdown `cd_interaction_detail` por modulo} |

---

## {Dominio 2 — ex.: Vendas sellout}

| Prioridade | Pergunta de negocio | Indicador / como medir |
|------------|---------------------|------------------------|
| P0 | {Ex.: RE registra venda com sucesso?} | {Ex.: `callback_vendas_create_sale_success`} |
| P0 | {Ex.: RE cobra cliente pelo app?} | {Ex.: interaction cobranca + PV vendas} |

---

## Checklist PM

- [ ] Cada dominio de `dominios-{squad}.md` com perguntas P0 tem ao menos 1 linha aqui
- [ ] Perguntas sao **decisoes de negocio**, nao nomes de evento soltos
- [ ] `analytics-migrate.config.yml` aponta para este arquivo em `workspace.perguntas_negocio`
- [ ] Apos pipeline: revisar `PERGUNTAS_NEGOCIO.md` e preencher coluna **Decisao PM (se discordar)**
