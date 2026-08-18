# PM Quickstart — Analytics Migrate

Guia de 1 pagina. **Somente megazord_mobile** — Product OS nao e necessario.

## Como comecar

No Cursor (aberto **so no megazord**):

```text
@analytics-migrate
quero pesquisar {jornada}
```

Ex.: *quero pesquisar Explorar Produtos*.

O agente **nao** roda tudo de uma vez. Sao **4 revisoes**; em cada uma voce diz o que entra/sai e, quando terminar, **pronto**.

```
[1] Dominios  →  [2] Perguntas  →  [3] Eventos essenciais  →  [4] Impacto
        pronto          pronto                 pronto                 pronto
                                              ↓
                    Planilha completa CSV  +  ENTREGA_ENG.csv
```

---

## As 4 revisoes

| # | Voce revisa | No catalogo (`product-skills`) | Quando terminar |
|---|-------------|-------------------------------|-----------------|
| 1 | Dominios da jornada (entra/sai area) | `docs/{squad}/dominios.md` | **pronto** |
| 2 | Perguntas de negocio P0/P1 | `docs/{squad}/perguntas-negocio.md` | **pronto** |
| 3 | Eventos essenciais | `docs/{squad}/EVENTOS_ESSENCIAIS.md` | **pronto** |
| 4 | Impacto da migracao | `docs/{squad}/IMPACTO_MIGRACAO.md` | **pronto** |

Squads atuais: `docs/conteudos-e-trafego/`, `docs/explorar-produtos/`. CSVs em `outputs/{squad}/`.

Pode editar o arquivo direto ou falar no chat: *entra X, sai Y*.

---

## Depois das 4 revisoes — dois CSVs

| Arquivo | Para | Diferenca |
|---------|------|-----------|
| `TAGUEAMENTO_MIGRADO_{SQUAD}.csv` | **Voce** | Planilha **completa**. Cada linha diz se o evento vai **migrar**, **remover**, **adicionar** ou **manter** e **por que** (coluna `notas`). Baixe, filtre, pinte no Excel. Se mudar um status, fale com o agente. |
| `ENTREGA_ENG.csv` | **Engenharia** | So o que implementar (JSON legado/novo). Sem o ensaio do motivo. |

---

## O que voce recebe no final

| Artefato | Para que serve |
|----------|----------------|
| `docs/{squad}/dominios.md` | Mapa da jornada (gate 1) |
| `docs/{squad}/perguntas-negocio.md` | Perguntas P0/P1 (gate 2) |
| `docs/{squad}/EVENTOS_ESSENCIAIS.md` | Eventos minimos (gate 3) |
| `docs/{squad}/IMPACTO_MIGRACAO.md` | Trade-offs (gate 4) |
| `outputs/{squad}/TAGUEAMENTO_MIGRADO_*.csv` | De-para completo com motivo |
| `outputs/{squad}/ENTREGA_ENG.csv` | Handoff eng |
| `RESUMO_DE_PARA.md` | Contagens (migrar / remover / manter / novo) |

---

## Pre-requisito: acesso ao megazord

Peca ao eng do time para te colocar no **time GitHub da squad** na org `grupoboticario`. Sem isso o clone/leitura do `megazord_mobile` falha.

---

## Instalacao da skill

Catalogo: https://github.com/sfsantin-gb/product-skills

```powershell
git clone https://github.com/sfsantin-gb/product-skills.git
git clone https://github.com/grupoboticario/megazord_mobile.git C:\megazord_mobile

cd product-skills
powershell -ExecutionPolicy Bypass -File install.ps1 -Target C:\megazord_mobile
```

Abra o Cursor **somente** em `C:\megazord_mobile`.

---

## Invocacao rapida

| Intencao | O que dizer |
|----------|-------------|
| Comecar | `quero pesquisar {jornada}` ou `@analytics-migrate --setup` |
| Avancar um gate | **pronto** |
| Pular as 4 revisoes (nao recomendado) | `roda tudo` — o agente pede confirmacao |
| Mudou status no CSV | falar o que mudou; agente regenera `ENTREGA_ENG.csv` |

## Documentacao

- [`docs/REGRAS_FORMATO_NOVO.md`](docs/REGRAS_FORMATO_NOVO.md)
- [`WORKFLOW.md`](WORKFLOW.md)
- [`PIPELINE_COMPLETO.md`](PIPELINE_COMPLETO.md)
