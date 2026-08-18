# Impacto da migracao

> Gerado em 2026-08-04 pelo pipeline `@analytics-business-impact`.
> Base: `docs/EVENTOS_ESSENCIAIS_CT.md` + `output/TAGUEAMENTO_MIGRADO_CT.csv` (484 eventos).
> Objetivo: deixar explicito **o que o PM continua podendo medir** e **o que deixa de ser respondivel** ao aprovar remocoes.

**Squad:** Conteudos e Trafego (`vd-sellout-conteudos-e-trafego-mld`) | **Inventario:** `_tag_extract_ct.json` | **Escopo:** megazord_mobile (microapps C&T)

**Como preencher** `Decisao PM (se discordar)`**:** deixe vazio se concordar com o veredito. Se discordar, use acao + comentario — ex.: `manter — KPI exige modal filho`, `card eng — priorizar P0`, `remover — aceito perda`. Consolidar depois em `@analytics-migrate --aprovar`.

---



## Resumo executivo (leia primeiro)


| Status                       | Perguntas | % do total | Implicacao para o PM                                |
| ---------------------------- | --------- | ---------- | --------------------------------------------------- |
| **Respondivel**              | 28        | 62%        | KPIs P0/P1 mantidos — nada critico perdido          |
| **Parcialmente respondivel** | 10        | 22%        | Proxy existe, mas perdeu caminho ou granularidade   |
| **Nao respondivel**          | 3         | 7%         | **Abrindo mao** — remocao sem substituto            |
| **Lacuna (eng)**             | 3         | 7%         | Pergunta desejada; falta instrumentacao             |
| **Fora do app**              | 1         | 2%         | Metrica em GA web / backend — nao bloqueia migracao |


**Saldo do inventario:** 484 eventos legado → **189 migrar** · **19 manter (PV)** · **265 remover** · **3 adicionar_pageview** · **8 revisar_pm**

### O que voce esta abrindo mao (top 5)

Perguntas que **deixam de ser respondiveis** se as remocoes propostas forem aprovadas:


| #   | Pergunta de negocio                                                         | Dominio        | Eventos legado removidos                                        | Por que nao ha substituto                         | Decisao PM (se discordar)                                                                     |
| --- | --------------------------------------------------------------------------- | -------------- | --------------------------------------------------------------- | ------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| 1   | Qual botao generico RE toca no feed de novidades (fora open_content)?       | Conteudos      | `app-rev:novidades` / `$buttonFormatted:$cardFormatted`         | `nao_essencial` — fora do mapa share/open         | revisar se tem pageview no destino, esses eventos são de clique pra abrir as LPs de conteudos |
| 2   | RE interage com carrossel de catalogos via scroll?                          | Divulgacao MLD | `interacao:scroll` / `carousel`                                 | `anti_padrao` — scroll nao e KPI de produto       |                                                                                               |
| 3   | RE escolhe opcao granular no modal "compartilhar MLD" (agora nao vs share)? | Materiais      | `clique:modal` / `agora-nao`, `compartilhar-minha-loja-digital` | `fundir_pai` — volume agregado no share principal | revisar se esse botao dispara o evento compartilhar MLD. se sim, remover                      |
| 4   | RE navega entre imagens da galeria via swipe na mesma rota?                 | Materiais      | `navegacao` / swipe in-page                                     | `anti_padrao` — PV + click_image cobrem consumo   |                                                                                               |
| 5   | KPI do assistente/novidades na gestao (engajamento)?                        | Gestao         | `novidades-assistente`, `fechar-*`, `acesso-rapido-*`           | `revisar_pm` — produto nao definiu KPI            |                                                                                               |




### Decisoes que mudam o quadro


| Pergunta                                           | Veredito pipeline                    | Se PM aprovar remocao         | Se PM mandar manter                       | Decisao PM (se discordar) |
| -------------------------------------------------- | ------------------------------------ | ----------------------------- | ----------------------------------------- | ------------------------- |
| RE usa assistente na gestao?                       | `revisar_pm` (4 eventos)             | **Nao respondivel**           | **Respondivel** via `interaction_gestao`  |                           |
| RE copia link / filtra cidade no Encontre?         | `revisar_pm` (2 eventos)             | **Nao respondivel** no app    | **Respondivel** se prioridade Encontre RE |                           |
| RE navega de vendas para aba pedidos no relatorio? | `revisar_pm` (`ir-para-pedidos`)     | **Parcial** (so PV relatorio) | **Respondivel** com INT cross-tab         | manter                    |
| RE conclui missao diaria?                          | `fundir_pai` (fora escopo CSV atual) | **Parcial** — volume agregado | Breakdown por tipo de missao              | manter                    |


---



## Visao por dominio



### Divulgacao MLD

**Pergunta norte:** RE divulga e gera trafego?


| Pergunta de negocio                  | Status                   | Eventos pos-migracao                           | Eventos legado afetados         | Notas                                       | Decisao PM (se discordar)      |
| ------------------------------------ | ------------------------ | ---------------------------------------------- | ------------------------------- | ------------------------------------------- | ------------------------------ |
| RE acessa a aba Divulgar?            | respondivel              | PV hub `/app-rev/divulgar`                     | —                               | `pageview_ok`                               |                                |
| RE compartilha MLD/catalogo?         | respondivel              | `interaction_divulgar` share_* (16 eventos P0) | —                               | KPI core mantido                            |                                |
| Qual canal de divulgacao mais usado? | respondivel              | Breakdown `cd_interaction_detail` por modulo   | —                               | catalog, mld, home                          |                                |
| RE abre catalogo digital (link)?     | respondivel              | `open:catalog-{brand}`                         | —                               | `essencial_p0`                              |                                |
| Funil Home → catalogo → share?       | parcialmente_respondivel | PV Home + PV catalogos + share                 | removidos: `ver-mais-*` (4 nav) | Chegada e share ok; perde clique no caminho | revisar o que perde no caminho |
| RE explora carrossel por scroll?     | nao_respondivel          | —                                              | `interacao:scroll` / carousel   | `anti_padrao`                               |                                |


**Saldo:** 4 respondiveis · 1 parcial · 1 perdida · 0 lacunas

---



### Materiais de divulgacao

**Pergunta norte:** RE consome e repassa conteudo pronto?


| Pergunta de negocio                          | Status                   | Eventos pos-migracao                         | Eventos legado afetados                        | Notas                               | Decisao PM (se discordar)                                                |
| -------------------------------------------- | ------------------------ | -------------------------------------------- | ---------------------------------------------- | ----------------------------------- | ------------------------------------------------------------------------ |
| RE abre galeria de materiais?                | respondivel              | PV `$imagesGalleryPage/$sectionName`         | —                                              | `pageview_ok`                       |                                                                          |
| RE compartilha material?                     | respondivel              | share fullscreen, download+share custom (P0) | —                                              | 3 eventos P0 migrados               |                                                                          |
| RE explora secao/campanha?                   | parcialmente_respondivel | `click:image-*`, PV galeria                  | swipe in-page removido                         | Perde navegacao swipe entre imagens |                                                                          |
| RE escolhe opcao no modal share MLD?         | parcialmente_respondivel | PV modal + share principal                   | `agora-nao`, `compartilhar-minha-loja-digital` | `fundir_pai` — agregado no pai      | revisar se esse botao dispara o evento compartilhar MLD. se sim, remover |
| RE usa botao generico fora share na galeria? | nao_respondivel          | —                                            | `$button:$sectionNameFormatted`                | `nao_essencial`                     | manter                                                                   |


**Saldo:** 2 respondiveis · 2 parciais · 1 perdida · 0 lacunas

---



### Conteudos e treinamento

**Pergunta norte:** RE consome dicas, treinamentos e noticias?


| Pergunta de negocio                       | Status          | Eventos pos-migracao                      | Eventos legado afetados           | Notas              | Decisao PM (se discordar) |
| ----------------------------------------- | --------------- | ----------------------------------------- | --------------------------------- | ------------------ | ------------------------- |
| RE abre LP de treinamento?                | respondivel     | PV `/app-rev/conteudo/novidade/{title}`   | —                                 | `landing_page_tag` |                           |
| RE abre noticias?                         | respondivel     | PV novidades + hub modulos                | nav `ver-tudo` removido           | Chegada via PV ok  |                           |
| RE engaja com card de conteudo?           | respondivel     | `open:dynamic-content-*` (learning, news) | —                                 | P1 migrado         |                           |
| RE toca botao generico no feed novidades? | nao_respondivel | —                                         | `$buttonFormatted:$cardFormatted` | `nao_essencial`    |                           |


**Saldo:** 3 respondiveis · 0 parciais · 1 perdida · 0 lacunas

---



### VD Studio

**Pergunta norte:** RE cria e compartilha cards personalizados?


| Pergunta de negocio              | Status      | Eventos pos-migracao                                         | Eventos legado afetados | Notas                                         | Decisao PM (se discordar)                                          |
| -------------------------------- | ----------- | ------------------------------------------------------------ | ----------------------- | --------------------------------------------- | ------------------------------------------------------------------ |
| RE entra no editor?              | respondivel | PV `/divulgar/compartilhar-produto` + `interaction_vdstudio` | —                       | 1 evento P0 migrado                           | ignora todos os eventos do vd studio. nao faremos a migração deles |
| RE conclui edicao e compartilha? | respondivel | `interaction_vdstudio` + share subsequente                   | —                       | Fluxo intacto                                 |                                                                    |
| Erro ao gerar card?              | lacuna      | —                                                            | —                       | Callback backend (`vd-sel-vd-studio-service`) |                                                                    |


**Saldo:** 2 respondiveis · 0 parciais · 0 perdidas · 1 lacuna

---



### Perfil e configuracao MLD

**Pergunta norte:** Loja configurada e compartilhavel?


| Pergunta de negocio                | Status      | Eventos pos-migracao                | Eventos legado afetados | Notas                    | Decisao PM (se discordar) |
| ---------------------------------- | ----------- | ----------------------------------- | ----------------------- | ------------------------ | ------------------------- |
| RE acessa configuracao da loja?    | respondivel | PV `/app-rev/minha-loja-digital`    | —                       |                          |                           |
| RE completa perfil antes de share? | respondivel | PV editar-perfil                    | —                       |                          |                           |
| RE altera opt-in catalogo fisico?  | respondivel | `interaction_menu` physical_catalog | —                       |                          |                           |
| RE salva slug/link?                | respondivel | `interaction_menu` edit_slug        | voltar nav removido     | Nav irrelevante para KPI |                           |


**Saldo:** 4 respondiveis · 0 parciais · 0 perdidas · 0 lacunas

---



### Tráfego Home

**Pergunta norte:** MLD visivel na entrada do app?


| Pergunta de negocio                | Status      | Eventos pos-migracao               | Eventos legado afetados | Notas        | Decisao PM (se discordar)                        |
| ---------------------------------- | ----------- | ---------------------------------- | ----------------------- | ------------ | ------------------------------------------------ |
| RE compartilha catalogo pela Home? | respondivel | `interaction_inicio` share_catalog | —                       | 100% mantido |                                                  |
| RE ve vitrine Top Ten?             | respondivel | `view_component:topten_showcase`   | —                       |              | remover da lista, acho que esse evento não é meu |


**Saldo:** 2 respondiveis · 0 parciais · 0 perdidas · 0 lacunas

---



### Carteira de clientes

**Pergunta norte:** Carteira ativa e crescendo?


| Pergunta de negocio                  | Status                   | Eventos pos-migracao             | Eventos legado afetados              | Notas                                  | Decisao PM (se discordar) |
| ------------------------------------ | ------------------------ | -------------------------------- | ------------------------------------ | -------------------------------------- | ------------------------- |
| RE usa hub de clientes?              | respondivel              | PV `/app-rev/gerenciar-clientes` | —                                    |                                        |                           |
| RE cadastra/edita cliente?           | respondivel              | INT add/edit customer (P0/P1)    | 48 eventos `nao_essencial` removidos | KPI core intacto; hub profundo podado  |                           |
| Operacao de cliente falhou?          | parcialmente_respondivel | callbacks normalizados (subset)  | modais granulares `fundir_pai`       | Taxa erro ok; breakdown modal reduzido |                           |
| RE compartilha catalogo com cliente? | respondivel              | PV + INT share_catalogs          | —                                    |                                        |                           |


**Saldo:** 3 respondiveis · 1 parcial · 0 perdidas · 0 lacunas

---



### Recomendacao de produtos e carrinho abandonado

**Pergunta norte:** RE indica produto e recupera sacola?


| Pergunta de negocio                        | Status                   | Eventos pos-migracao        | Eventos legado afetados   | Notas                                 | Decisao PM (se discordar) |
| ------------------------------------------ | ------------------------ | --------------------------- | ------------------------- | ------------------------------------- | ------------------------- |
| RE abre vitrine de indicacoes?             | respondivel              | PV indicacoes               | —                         | 0 remocoes no dominio                 |                           |
| RE divulga produto para cliente?           | respondivel              | showcase INT                | —                         |                                       |                           |
| RE ve card sacola abandonada?              | respondivel              | PV Divulgar + INT share PLP | —                         |                                       |                           |
| RE compartilha produto da busca (Oraculo)? | parcialmente_respondivel | share flow parcial          | inventario C&T incompleto | Validar tag oraculo fora escopo squad |                           |


**Saldo:** 3 respondiveis · 1 parcial · 0 perdidas · 0 lacunas

---



### Estoque RE (pronta-entrega)

**Pergunta norte:** RE gerencia estoque de pronta-entrega?


| Pergunta de negocio               | Status                   | Eventos pos-migracao                 | Eventos legado afetados                 | Notas                                  | Decisao PM (se discordar) |
| --------------------------------- | ------------------------ | ------------------------------------ | --------------------------------------- | -------------------------------------- | ------------------------- |
| RE acessa estoque?                | respondivel              | PV `/app-rev/gestao-de-estoque`      | —                                       |                                        |                           |
| RE adiciona produto?              | respondivel              | INT modal + `callback_add_product_*` | 10 `nao_essencial` removidos            |                                        |                           |
| RE edita item RE?                 | respondivel              | `callback_edit_product_*`            | —                                       |                                        |                           |
| RE compartilha pos-sucesso?       | respondivel              | `share_mld:after_sale`               | —                                       |                                        |                           |
| Fluxo sell-in/sell-out detalhado? | parcialmente_respondivel | PV sellin-sellout + sucesso          | modais `fundir_pai` (63 no total squad) | Volume agregado; perde filhos de modal |                           |


**Saldo:** 4 respondiveis · 1 parcial · 0 perdidas · 0 lacunas

---



### Vendas Sellout

**Pergunta norte:** RE registra vendas e cobra clientes?


| Pergunta de negocio                  | Status                   | Eventos pos-migracao           | Eventos legado afetados                        | Notas                            | Decisao PM (se discordar) |
| ------------------------------------ | ------------------------ | ------------------------------ | ---------------------------------------------- | -------------------------------- | ------------------------- |
| RE acessa vendas?                    | respondivel              | PV `/app-rev/gerenciar-vendas` | —                                              |                                  |                           |
| RE cria venda?                       | respondivel              | `callback_create_sale_*`       | 128 remocoes no dominio (nao_essencial/fundir) | Funil core preservado            |                           |
| RE salva rascunho?                   | respondivel              | `callback_auto_save_sale_*`    | —                                              |                                  |                           |
| RE gera link cobranca?               | respondivel              | generate_charge_link INT       | —                                              |                                  |                           |
| RE organiza vendas (novato)?         | respondivel              | PV organizar-vendas            | nav `ir-para-*` removidos                      | Chegada via PV                   |                           |
| Caminho entre telas do funil vendas? | parcialmente_respondivel | PVs de destino                 | 34 nav_duplicada squad-wide                    | Perde clique; chegada mensuravel |                           |


**Saldo:** 5 respondiveis · 1 parcial · 0 perdidas · 0 lacunas

---



### Gestao do negocio e relatorio financeiro

**Pergunta norte:** RE entende saude do negocio?


| Pergunta de negocio                 | Status      | Eventos pos-migracao              | Eventos legado afetados                  | Notas                          | Decisao PM (se discordar) |
| ----------------------------------- | ----------- | --------------------------------- | ---------------------------------------- | ------------------------------ | ------------------------- |
| RE acessa hub gestao?               | respondivel | PV hub gestao                     | 29 `nao_essencial` removidos no dominio  | Hub profundo podado            |                           |
| RE abre relatorio de vendas?        | respondivel | PV relatorio-de-vendas            | —                                        |                                |                           |
| RE ve aba financeira?               | **lacuna**  | TODO: 3x `adicionar_pageview`     | `ir-para-relatorio` removido (2x vendas) | **P0 eng** — ver secao lacunas |                           |
| Relatorio financeiro falha?         | respondivel | `callback_financial_report_error` | —                                        |                                |                           |
| RE atualiza cache relatorio?        | respondivel | click atualizar-relatorio         | —                                        |                                |                           |
| RE usa assistente/novidades gestao? | revisar_pm  | —                                 | 4 eventos assistant                      | PM decide KPI                  | remover. nao existe mais  |


**Saldo:** 4 respondiveis · 0 parciais · 0 perdidas · **1 lacuna P0** · 1 pendente PM

---



### Aquisicao CF (Encontre)

**Pergunta norte:** RE aparece nas buscas?


| Pergunta de negocio                     | Status      | Eventos pos-migracao      | Eventos legado afetados   | Notas                                          | Decisao PM (se discordar) |
| --------------------------------------- | ----------- | ------------------------- | ------------------------- | ---------------------------------------------- | ------------------------- |
| RE entra no fluxo recomendacao?         | respondivel | PV `/dash/recomendacao/*` | —                         |                                                |                           |
| RE faz opt-in aparecer nas buscas?      | respondivel | search_opt_in INT         | —                         |                                                |                           |
| RE copia link / filtra cidade Encontre? | revisar_pm  | —                         | copiar, selecionar-cidade | Prioridade produto indefinida                  | remover                   |
| Metricas do site Encontre RE?           | fora_app    | —                         | —                         | GA web / `vd-sellout-aq-encontre-revendedores` | remover                   |


**Saldo:** 2 respondiveis · 0 parciais · 0 perdidas · 0 lacunas · 1 fora_app · 1 pendente PM

---



### Menu e atalhos (cross-cutting)

**Pergunta norte:** Por onde RE entra nos fluxos C&T?


| Pergunta de negocio           | Status      | Eventos pos-migracao             | Eventos legado afetados | Notas                 | Decisao PM (se discordar) |
| ----------------------------- | ----------- | -------------------------------- | ----------------------- | --------------------- | ------------------------- |
| Por onde RE entra nos fluxos? | respondivel | `interaction_menu` click_section | —                       | 9 eventos, 0 remocoes |                           |
| Distribuicao Menu vs navbar?  | respondivel | Breakdown por secao              | —                       |                       |                           |


**Saldo:** 2 respondiveis · 0 parciais · 0 perdidas · 0 lacunas

---



## Catalogo — perguntas respondiveis (28)

Perguntas **totalmente cobertas** pelo inventario migrado.


| Dominio        | Pergunta                                    | Indicador proxy       | Eventos essenciais (pos-migracao)                 | Decisao PM (se discordar) |
| -------------- | ------------------------------------------- | --------------------- | ------------------------------------------------- | ------------------------- |
| Divulgacao MLD | RE acessa Divulgar?                         | PV hub                | `screen_view` `/app-rev/divulgar`                 |                           |
| Divulgacao MLD | RE compartilha MLD/catalogo?                | Volume share_*        | `interaction_divulgar` share:catalog, share:mld-* |                           |
| Divulgacao MLD | Qual canal mais usado?                      | cd_interaction_detail | Breakdown por modulo                              |                           |
| Divulgacao MLD | RE abre catalogo digital?                   | open_catalog          | `open:catalog-{brand}`                            |                           |
| Materiais      | RE abre galeria?                            | PV secao              | `screen_view` galeria                             |                           |
| Materiais      | RE compartilha material?                    | share/download        | custom download+share, share fullscreen           |                           |
| Conteudos      | RE abre LP treinamento?                     | PV novidade           | `landing_page_tag`                                |                           |
| Conteudos      | RE abre noticias?                           | PV feed               | `news_page_tag`                                   |                           |
| Conteudos      | RE engaja card?                             | open_content          | `open:dynamic-content-*`                          |                           |
| VD Studio      | RE entra no editor?                         | PV + INT              | `interaction_vdstudio`                            |                           |
| VD Studio      | RE conclui e compartilha?                   | INT + share           | fluxo pos-edicao                                  |                           |
| Perfil MLD     | Configuracao da loja                        | PV + INT menu         | 4 perguntas — 100% cobertas                       |                           |
| Tráfego Home   | Share catalogo Home                         | INT inicio            | `share:catalog-*`                                 |                           |
| Tráfego Home   | Vitrine Top Ten                             | view_component        | top_ten_showcase                                  |                           |
| Carteira       | Hub, cadastro, share catalogo               | PV + INT + CB         | core P0                                           |                           |
| Recomendacao   | Vitrine, showcase, sacola                   | PV + INT              | 0 remocoes                                        |                           |
| Estoque        | Acesso, add, edit, share                    | PV + CB + INT         | callbacks mantidos                                |                           |
| Vendas         | Funil core (PV, create, rascunho, cobranca) | PV + CB + INT         | 63 P0/P1 mantidos vs 128 removidos                |                           |
| Gestao         | Hub, relatorio, erro CB, refresh            | PV + CB + INT         | exceto aba financeira                             |                           |
| Aquisicao CF   | Fluxo + opt-in                              | PV + INT              |                                                   |                           |
| Menu           | Entrada nos fluxos                          | interaction_menu      | 100% mantido                                      |                           |


---



## Catalogo — perguntas parcialmente respondiveis (10)


| Dominio        | Pergunta                           | O que permanece           | O que se perde                  | Risco KPI                         | Decisao PM (se discordar) |
| -------------- | ---------------------------------- | ------------------------- | ------------------------------- | --------------------------------- | ------------------------- |
| Divulgacao MLD | Funil Home → catalogo → share      | PV destinos + share       | Cliques ver-mais no hub         | **Baixo** — funil de conversao ok |                           |
| Materiais      | RE explora secao/campanha          | click_image + PV          | Swipe entre imagens             | **Baixo**                         |                           |
| Materiais      | Escolha no modal share MLD         | PV modal + share agregado | Clique agora-nao vs share modal | **Medio** — se KPI exige modal    |                           |
| Carteira       | Operacao cliente falhou            | callback agregado         | Breakdown modal filho           | **Baixo**                         |                           |
| Recomendacao   | Share produto Oraculo              | Parcial fora inventario   | Tag oraculo incompleta          | **Medio** — validar escopo        |                           |
| Estoque        | Sell-in/sell-out detalhado         | PV + CB pai               | Modais filhos fundidos          | **Baixo**                         |                           |
| Vendas         | Caminho entre telas funil          | PV cada tela              | ir-para / voltar (34 nav)       | **Baixo** — by design             |                           |
| Vendas         | Cross-tab relatorio pedidos        | PV relatorio              | ir-para-pedidos (`revisar_pm`)  | **Medio** — depende PM            |                           |
| Gestao         | Hub gestao profundo                | PV hub                    | 29 eventos gestao nao_essencial | **Baixo** — fora mapa essencial   |                           |
| Divulgacao MLD | Intencao no componente antes do PV | PV destino                | ver-mais-carrossel/titulo       | **Baixo**                         |                           |


---



## Catalogo — perguntas nao respondiveis (3)


| Dominio        | Pergunta                            | Eventos removidos                 | Criterio        | Recuperavel?           | Decisao PM (se discordar) |
| -------------- | ----------------------------------- | --------------------------------- | --------------- | ---------------------- | ------------------------- |
| Conteudos      | Botao generico feed novidades       | `$buttonFormatted:$cardFormatted` | `nao_essencial` | Nao, salvo PM reverter |                           |
| Divulgacao MLD | Scroll carrossel catalogos          | `interacao:scroll` / carousel     | `anti_padrao`   | Nao — anti-padrao      |                           |
| Materiais      | Botao generico galeria (fora share) | `$button:$sectionNameFormatted`   | `nao_essencial` | Nao                    |                           |


> **Nota:** 145 eventos `nao_essencial` no CSV alimentam sobretudo **gestao profunda, vendas e carteira** — perguntas que **nunca estiveram** no mapa essencial (`EVENTOS_ESSENCIAIS_CT.md`). So 3 perguntas explicitas do guia ficam **nao respondiveis**.

---



## Catalogo — lacunas abertas (3)


| Dominio         | Pergunta                           | Lacuna                  | Acao proposta                                         | Prioridade | Decisao PM (se discordar) |
| --------------- | ---------------------------------- | ----------------------- | ----------------------------------------------------- | ---------- | ------------------------- |
| Gestao / Vendas | RE ve aba financeira no relatorio? | Destino sem PV dedicado | `adicionar_pageview` aba financeira `SalesReportPage` | **P0**     |                           |
| Gestao          | Deep link abre aba financeira?     | PV deep link ausente    | PV no load `startAtFinancialTab`                      | **P0**     |                           |
| VD Studio       | Erro ao gerar card?                | Callback so no backend  | `callback_vdstudio_error` no app ou correlacao BFF    | **P1**     |                           |


**Bloqueio:** remover `ir-para-relatorio` (2 eventos vendas, `lacuna_pageview`) **so apos** PV da aba financeira existir.

---



## Fora do escopo APP


| Pergunta                           | Fonte esperada                | Observacao                                                                          | Decisao PM (se discordar) |
| ---------------------------------- | ----------------------------- | ----------------------------------------------------------------------------------- | ------------------------- |
| Trafego site catalogo digital      | GA web catalogo               | Link aberto via `open_catalog` no app e rastreavel; sessao no site e outra property |                           |
| Metricas Boticards / VD Studio web | `gb-cards-frontend` GA        | Editor web fora do megazord                                                         |                           |
| Erros API VD Studio (ops)          | `vd-sel-vd-studio-service`    | Correlacionar com INT app quando callback existir                                   |                           |
| Site Encontre RE                   | GA web Encontre               | App so tem atalho menu                                                              |                           |
| Dashboard ops relatorio financeiro | `vd-financial-management-api` | Dados server-side                                                                   |                           |


---



## Cruzamento com vereditos do CSV


| Criterio          | Eventos | Perguntas tipicamente impactadas   | Efeito na respondibilidade          |
| ----------------- | ------- | ---------------------------------- | ----------------------------------- |
| `essencial_p0`    | 130     | Funis core, share, open, callbacks | **Mantem** — nao abrir mao          |
| `pageview_ok`     | 19      | Chegada em telas                   | **Mantem** — padrao GA4             |
| `essencial_p1`    | 59      | Diagnostico, conteudo, retry       | **Mantem** salvo decisao PM         |
| `nav_duplicada`   | 34      | Caminho entre telas                | **Parcial** — PV destino substitui  |
| `fundir_pai`      | 63      | Modal parcela/SKU/modal filho      | **Parcial** — perde filho           |
| `nao_essencial`   | 145     | Gestao hub profundo, granularidade | **Nao respondivel** para micro-KPIs |
| `anti_padrao`     | 19      | scroll, swipe, tooltip             | **Nao respondivel** — anti-padrao   |
| `lacuna_pageview` | 5       | Aba financeira                     | **Lacuna** ate eng                  |
| `revisar_pm`      | 8       | Assistant, Encontre, cross-tab     | **PM decide**                       |
| `obsoleto`        | 2       | Codigo morto                       | Remocao segura                      |


---



## Legenda


| Status                       | Definicao                                            | PM deve                                |
| ---------------------------- | ---------------------------------------------------- | -------------------------------------- |
| **respondivel**              | Todos eventos essenciais com `manter` ou `migrar`    | Nada — cobertura ok                    |
| **parcialmente_respondivel** | Proxy P0/P1 existe, granularidade ou caminho perdido | Validar se KPI aceita degradacao       |
| **nao_respondivel**          | Remocao sem substituto para pergunta do guia         | **Consciente do trade-off**            |
| **lacuna**                   | Instrumentacao ausente                               | Priorizar card eng (aba financeira P0) |
| **fora_app**                 | Nao mensuravel no megazord                           | Outra fonte GA/API                     |
| **revisar_pm**               | Ambiguidade produto                                  | Decidir antes de `--aprovar`           |


**Coluna Decisao PM:** vazio = concordo. Sugestoes: `concordo` · `manter` · `remover` · `card eng` · `revisar` + texto livre. Decisoes preenchidas aqui alimentam `MIGRACAO_DECISOES.md` no `--aprovar`.

---



## Proximo passo PM

1. ~~Consolidar comentarios~~ — feito em [`MIGRACAO_DECISOES.md`](./MIGRACAO_DECISOES.md) (2026-08-04).
2. **Fechar revisoes V1–V4** (modal MLD, cliques novidades, funil Home, `ir-para-inicio`).
3. **Regenerar CSV:** `@analytics-migrate --fase transform --export-csv` aplicando decisoes.
4. **Cards eng P0:** aba financeira.

**Fontes:** `[EVENTOS_ESSENCIAIS_CT.md](../docs/EVENTOS_ESSENCIAIS_CT.md)` · `[TAGUEAMENTO_MIGRADO_CT.csv](./TAGUEAMENTO_MIGRADO_CT.csv)` · `[CRITERIO_RELEVANCIA.md](../docs/CRITERIO_RELEVANCIA.md)`