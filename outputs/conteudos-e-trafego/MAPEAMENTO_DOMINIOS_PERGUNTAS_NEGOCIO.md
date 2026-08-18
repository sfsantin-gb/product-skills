# Perguntas de negocio por dominio — C&T

> Objetivo: orientar **queries de relevancia/performance** e decisoes de **manter vs cortar** tagueamento, balanceando custo de manutencao (`n_migrar` no inventario).
>
> Fontes: [`domínios-c&t.md`](../../contextos/domínios-c&t.md) · [`MAPEAMENTO_DOMINIOS_RESUMO.csv`](./MAPEAMENTO_DOMINIOS_RESUMO.csv) · [`MAPEAMENTO_DOMINIOS_FILTROS_GA4.csv`](./MAPEAMENTO_DOMINIOS_FILTROS_GA4.csv) · `ENTREGA_ENG.csv`

**Como usar**

| Coluna | Significado |
|--------|-------------|
| **P** | P0 = decisao semanal/OKR · P1 = review mensal · P2 = exploratorio / custo |
| **Pergunta** | Decisao de negocio (nao nome de evento) |
| **Indicador legado (query)** | `event_category` / `event_action` / labels tipicos — use com `MAPEAMENTO_DOMINIOS_FILTROS_GA4.csv` |
| **Proxy pos-migracao** | O que permanece apos GA4 (`interaction_*` / `callback_*` / PV) |
| **Sinal de corte** | Quando volume baixo + alto `n_remover` sugere nao manter |

**Legenda inventario (APP):** volume = eventos legados com JSON em `ENTREGA_ENG` · migrar/remover = `classificacao`.

---

## 1. Divulgacao MLD

**Pergunta norte:** A RE usa o app para gerar trafego para a MLD (share / catalogo / materiais)?

| Inventario | `dominio_ct` | Eventos | Migrar | Remover |
|------------|--------------|---------|--------|---------|
| Divulgacao MLD | Divulgacao MLD | 19 | 15 | 4 |
| Materiais | Materiais de divulgacao | 23 | 9 | 14 |
| Trafego Home | Trafego Home | 1 | 1 | 0 |

| P | Pergunta de negocio | Indicador legado (query) | Proxy pos-migracao | Sinal de corte |
|---|---------------------|--------------------------|--------------------|----------------|
| P0 | Quantas REs compartilham MLD / link da loja por semana? | `app-rev:divulgar-mld*`, `app-rev:divulgar-mld-por-marca*`, labels `compartilhar*` / `divulgar*` | `interaction_divulgar` share_* | Volume share << PV hub Divulgar → hub sem valor de trafego |
| P0 | Quantas REs abrem ou compartilham catalogo digital? | `app-rev:divulgar:catalogos` / `app-rev:divulgar-catalogos` — `abrir-catalogo::*`, `compartilhar-catalogo::*`, `abrir-$brand` | `open:catalog-$brand`, `share:catalog-$brand` | Abrir alto e share baixo → catalogo sem conversao de divulgacao |
| P0 | Quantas REs baixam/compartilham materiais (imagem)? | `app-rev:divulgar:materiais`, `app-rev:divulgacao:imagens`, `clique:imagem` / `divulgar` | `download:imagem`, `share:imagem` | Poucos shares vs muitos scrolls/ver-mais → galeria cara demais |
| P1 | Qual modulo de Divulgar gera mais shares (catalogo vs materiais vs MLD)? | Breakdown `event_category` + label sob `app-rev:divulgar*` | Breakdown `cd_interaction_detail` | Modulo com share residual + muitos `remover` → cortar tags do modulo |
| P1 | Home / atalhos convertem para divulgacao? | `app-rev:home` + entradas menu `app-rev:menu` label `divulgar` | PV Home + `interaction_divulgar` | Trafego home irrelevante se share nao sobe |
| P2 | Vale manter tags de scroll / ver-mais em catalogos e materiais? | `interacao:scroll`, labels `ver-mais*`, `carousel` | Em geral **nao** (nav/anti-padrao) | Ja marcados `remover` — so manter se KPI de engajamento de carrossel for P0 |

**Subdominios produto sem cobertura clara no inventario APP:** Divulgar Portal (manutencao), VD Studio (em expansao), Catalogo digital (site), Trafego geral MLD (parcialmente em Menu/Home).

---

## 2. Dados Sellout RE — Perfil & Configuracao MLD

**Pergunta norte:** A RE configura e mantem a MLD ativa (perfil, link, estoque/recebiveis)?

| Inventario | Eventos | Migrar | Remover |
|------------|---------|--------|---------|
| Perfil e configuracao MLD | 13 | 12 | 1 |

| P | Pergunta de negocio | Indicador legado (query) | Proxy pos-migracao | Sinal de corte |
|---|---------------------|--------------------------|--------------------|----------------|
| P0 | Quantas REs editam perfil / link da loja? | `app-rev:configuracao:editar-perfil`, `app-rev:configuracao:editar-link` — `salvar`, `adicionar-foto` | `interaction_*` config + callbacks save | Edicao baixa vs criacao → onboarding ok, retencao fraca |
| P0 | Quantas REs abrem configuracoes da MLD (estoque, recebiveis, perfil)? | `app-rev:minha-loja-digital` — `configuracao:*`, `perfil-da-loja`, `link-da-loja` | PV config MLD + interactions | Config sem uso → feature cara de manter |
| P1 | REs criam MLD a partir do app? | `app-rev:minha-loja-digital` — `criar-minha-loja-digital` | interaction create store | Funil de ativacao MLD |
| P1 | Opt-in catalogo fisico ainda gera aceite? | `app-rev:divulgacao:catalogo-fisico` (se houver volume) | PV + interaction opt-in | Baixo volume → candidata a nao migrar |

---

## 3. Pronta Entrega RE (Estoque)

**Pergunta norte:** A RE gerencia estoque de pronta-entrega e divulga disponibilidade?

| Inventario | Eventos | Migrar | Remover |
|------------|---------|--------|---------|
| Estoque RE | 43 | 11 | 32 |

| P | Pergunta de negocio | Indicador legado (query) | Proxy pos-migracao | Sinal de corte |
|---|---------------------|--------------------------|--------------------|----------------|
| P0 | Quantas REs adicionam produto ao estoque com sucesso? | `app-rev:gestao-estoque*` — `callback:adicionar-produto` / labels `*:sucesso` | `callback_estoque_add_product_success` | Callbacks raros vs muitos cliques modal → ruido de UI |
| P0 | Quantas REs editam estoque (SKU) com sucesso/erro? | `callback:editar-produto` — `$sku:sucesso` / `$sku:erro` | `callback_estoque_*` | Erro alto → saude do fluxo, nao cortar |
| P0 | Apos pronta-entrega, RE compartilha MLD? | `app-rev:sell-in-sell-out:pronta-entrega-sucesso` — `compartilhar-minha-loja-digital` | share MLD pos-sucesso | Sem share → dominio estoque nao gera trafego |
| P1 | Baixa automatica e usada? | `app-rev:gestao-estoque:modal:baixa-automatica` | interaction opt-in baixa | Quase so `remover` — validar se ainda e produto |
| P2 | Vale instrumentar cada clique de modal por SKU? | `app-rev:gestao-estoque:modal` (15 eventos, 0 migrar) | Em geral **nao** — fundir em callback | Alto custo, baixo valor analitico |

---

## 4. Vendas Sellout VD

**Pergunta norte:** A RE registra, organiza e conclui vendas sellout no app?

| Inventario | Eventos | Migrar | Remover |
|------------|---------|--------|---------|
| Vendas sellout | 191 | 63 | 128 |

| P | Pergunta de negocio | Indicador legado (query) | Proxy pos-migracao | Sinal de corte |
|---|---------------------|--------------------------|--------------------|----------------|
| P0 | Quantas vendas sao adicionadas / concluidas? | `app-rev:gerenciar-vendas`, `app-rev:gestao:organizar-vendas` — `adicionar-nova-venda`, conclusao | `callback_vendas_create_sale_success` + PV vendas | Coracao do dominio — nao cortar P0 |
| P0 | RE cobra cliente / envia lembrete? | `app-rev:gerenciar-vendas:cobrar-cliente*`, `enviar-lembrete`, `opcoes-cobranca` | `interaction_gestao` cobranca + share lembrete | Cobranca e KPI de adocao sellout |
| P0 | Auto-save / rascunho de venda funciona? | callbacks / labels de save em gerenciar-vendas (quando existirem) | `callback_vendas_auto_save_sale_*` | Erro de save = P0 eng |
| P1 | Qual etapa do funil de venda mais abandona (produto → cliente → parcelas → concluir)? | Breakdown categories `gerenciar-vendas:*`, `detalhe-parcela:*`, `modal:concluir-venda` | PV etapas + interactions chave | Etapas so com `remover` e sem PV → lacuna ou corte |
| P1 | Onboarding de produto generico ainda importa? | `app-rev:gerenciar-vendas:onboarding-produto-generico` (10 eventos, 0 migrar) | — | Forte candidato a nao migrar se volume baixo |
| P1 | Relatorio de vendas e usado? | `app-rev:relatorio-de-vendas` | PV relatorio + poucas interactions | Quase so remover — medir PV antes de migrar cliques |
| P2 | Cancelamento de venda: motivos ainda sao lidos? | `app-rev:modal:cancelar-modal` | interaction cancel + motivo (se KPI) | Se motivo nao entra em dashboard → cortar granularidade |

**Fora do inventario APP (produto):** Experiencia Venda Portal, Conexao Sellin↔Sellout, Registro/Comprovacao — metricas em portal/BFF.

---

## 5. Carteira de Clientes CF VD

**Pergunta norte:** A RE consulta e age sobre a carteira (detalhe, cobranca, aniversarios, indicacoes)?

| Inventario | Eventos | Migrar | Remover |
|------------|---------|--------|---------|
| Carteira de clientes | 73 | 21 | 52 |

| P | Pergunta de negocio | Indicador legado (query) | Proxy pos-migracao | Sinal de corte |
|---|---------------------|--------------------------|--------------------|----------------|
| P0 | Quantas REs abrem gestao de clientes / detalhe de CF? | `app-rev:gerenciar-clientes`, `...:detalhes` (muitos sem action — PV/legado) | PV clientes + PV detalhe | Chegada importa mais que cliques internos |
| P0 | RE cobra a partir do cliente / recebimentos? | `app-rev:gerenciar-vendas:cobrar-cliente`, `...:recebimentos` — `enviar-lembrete`, `cobrar-*` | interactions cobranca (migrar alto) | Manter P0; recebimentos quase so `remover` → validar PV |
| P0 | RE seleciona/adiciona cliente na venda? | `app-rev:gestao:organizar-vendas:selecionar-cliente` | `interaction_gestao` select client | Ligacao carteira ↔ vendas |
| P1 | Aniversarios / agenda geram engajamento? | `app-rev:gerenciar-clientes:proximos-aniversarios`, `app-rev:agenda*` | PV aniversarios | 0 migrar — candidata a corte se volume baixo |
| P1 | Indicacoes / conquistar CF ainda sao usados? | `app-rev:gerenciar-clientes:indicar`, `conquistar-cf`, `categoria:indicacoes-*` | interactions indicar | Cruzar com dominio Recomendacao |
| P2 | Excluir CF precisa de tag dedicada? | `...:excluir-cf` | callback delete se critico | So se compliance/ops exigir |

**Produto:** Relatorio Financeiro APP pode aparecer em Gestao do negocio (`relatorio-financeiro`) — ver secao 6.

---

## 6. Gestao / Tarefas (hub)

**Pergunta norte:** A aba Gestao e um hub util (atalhos, relatorio, tarefas) ou so ruido de navegacao?

| Inventario | Eventos | Migrar | Remover |
|------------|---------|--------|---------|
| Gestao do negocio | 72 | 32 | 40 |

| P | Pergunta de negocio | Indicador legado (query) | Proxy pos-migracao | Sinal de corte |
|---|---------------------|--------------------------|--------------------|----------------|
| P0 | Quantas REs acessam relatorio financeiro e concluem acoes (boleto, pix, pagamento)? | `app-rev:relatorio-financeiro` — `acessar-todos-*`, `adicionar-pix-*` | PV relatorio + interactions P0 | Relatorio e o pedaco mais “migrar” do hub |
| P0 | Callback de erro do relatorio ainda ocorre? | `callback:relatorio-financeiro` | `callback_gestao_financial_report_error` | Saude tecnica P0 |
| P1 | Quais atalhos do hub Gestao sao clicados? | `app-rev:gestao-de-negocio` — `acesso-rapido-*`, `acessar-relatorio` | PV destino > clique (muitos `remover`) | 24/32 remocoes em gestao-de-negocio → preferir PV dos destinos |
| P1 | Tarefas diarias (produto Tarefas) tem adocao? | Buscar labels/tarefas em gestao-de-negocio / novidades | PV tarefas se existir | Se nao houver eventos claros → lacuna ou fora do inventario |
| P2 | Vale taguear cada atalho do hub? | `app-rev:gestao-de-negocio` clique:botao (32 eventos) | Em geral **nao** — pageview destino | Alto custo / baixo insight incremental |

**Atencao ownership:** parte do hub pode ser compartilhada com outras squads — cruzar CODEOWNERS antes de migrar em massa.

---

## 7. Recomendacao de Produtos CF VD

**Pergunta norte:** A RE indica/ativa produtos ou compartilha listas (ex.: carrinho abandonado) com clientes?

| Inventario | Eventos | Migrar | Remover |
|------------|---------|--------|---------|
| Recomendacao de produtos | 8 | 8 | 0 |

| P | Pergunta de negocio | Indicador legado (query) | Proxy pos-migracao | Sinal de corte |
|---|---------------------|--------------------------|--------------------|----------------|
| P0 | Quantas REs usam fluxo de indicar produtos? | `$_eventCategoryBase:indicar` (8) | `interaction_*` indicar / share lista | Poucos eventos mas 100% migrar — validar volume real na query |
| P1 | Ativacoes personalizadas vs genericas tem uso distinto? | Labels/contexto em indicar (quando houver) | breakdown `cd_interaction_detail` | Se indistinguivel no legado → 1 pergunta agregada |
| P1 | Carrinho abandonado gera compartilhamento com CF? | Cruzar com Divulgar + clientes (pode estar em outro dominio_ct) | share PLP abandonado | Se ausente no inventario → lacuna eng ou fora APP |

---

## 8. Conteudos e treinamento

**Pergunta norte:** A RE consome dicas/treinamentos na aba Divulgar?

| Inventario | Eventos | Migrar | Remover |
|------------|---------|--------|---------|
| Conteudos e treinamento | 7 | 2 | 5 |

| P | Pergunta de negocio | Indicador legado (query) | Proxy pos-migracao | Sinal de corte |
|---|---------------------|--------------------------|--------------------|----------------|
| P0 | Quantas REs abrem um card de dica/treinamento? | `app-rev:divulgar-dicas-e-treinamentos`, `app-rev:divulgar-conteudos` — label dinamico / card | PV LP ou `open:conteudo-*` | Se so `ver-mais`/`ver-tudo` → quase so ruido |
| P1 | Novidades geram clique? | `app-rev:novidades` | interaction novidades | 1 evento remover — medir antes de investir |
| P2 | Manter tags de carrossel ver-mais? | labels `ver-mais*`, `ver-tudo*` | **Nao** (nav) | Ja `remover` |

---

## 9. Aquisicao CF (Encontre)

**Pergunta norte:** Fluxos de Encontre/opt-in no APP ainda geram acao mensuravel?

| Inventario | Eventos | Migrar | Remover |
|------------|---------|--------|---------|
| Aquisicao CF | 2 | 0 | 2 |

| P | Pergunta de negocio | Indicador legado (query) | Proxy pos-migracao | Sinal de corte |
|---|---------------------|--------------------------|--------------------|----------------|
| P0 | Ha uso de Encontre no APP (copiar / filtro cidade)? | `app-rev:encontre-seu-er` — `copiar`, `selecionar-cidade` | — | **0 migrar** — dominio quase so web; APP candidata a nao manter |
| P1 | Opt-in “Apareca nas Buscas” tem funil no APP? | (nao aparece no inventario atual) | fora_app / lacuna | Medir no produto web Encontre |

---

## 10. Trafego transversal (Menu e atalhos)

**Pergunta norte:** De onde a RE entra nas jornadas C&T?

| Inventario | Eventos | Migrar | Remover |
|------------|---------|--------|---------|
| Menu e atalhos | 9 | 9 | 0 |

| P | Pergunta de negocio | Indicador legado (query) | Proxy pos-migracao | Sinal de corte |
|---|---------------------|--------------------------|--------------------|----------------|
| P0 | Quais secoes do menu levam a dominios C&T? | `app-rev:menu` — `divulgar`, `gestao-de-clientes`, `gestao-de-estoque`, `gestao-de-vendas`, `minha-loja-di*` | Preferir **PV do destino**; menu so se attribution for P0 | Manter so se attribution de entrada for KPI |
| P1 | Mix de entrada Menu vs hub Gestao vs Home? | Join menu + gestao-de-negocio + home | PV por rota de entrada | Ajuda a priorizar onde instrumentar |

---

## 11. Dominios produto sem (ou com pouco) inventario APP

Use estas perguntas com **fonte externa** (GA web, BFF, backend). Nao forcar migracao megazord.

| Dominio / subdominio | Pergunta tipica | Fonte sugerida | Nota |
|----------------------|-----------------|----------------|------|
| BFF APP Sellout (Voldemort) | Latencia/erro por agregacao sellout? | Logs BFF / APM | Sem eventos UI |
| Divulgar Portal | Share MLD no portal ainda tem volume? | GA portal | So manutencao |
| VD Studio | Cards criados / compartilhados? | Tags VD Studio (quando existirem) | Em expansao na aba Divulgar |
| Catalogo digital (site) | Sessoes / downloads de catalogo no site? | GA web catalogo | Sem carrinho |
| PDF Inteligente | Downloads / cliques em pin SKU? | Analytics PDF / MLD web | Canal escuta |
| Experiencia Venda Portal | Vendas registradas no portal? | Portal analytics | Fora APP |
| Conexao Sellin ↔ Sellout | Taxa de vinculo sellin-sellout? | Backend / BFF | Fora APP |
| Registro e comprovacao de vendas | Gatilhos de comprovacao disparam? | Backend + APP se houver tags | Validar se entrou no inventario |

---

## Matriz decisao rapida (relevancia × custo)

Use apos rodar a query de volume (90d) por `dominio_produto`:

| Volume (query) | Custo (`n_migrar`) | Decisao tipica |
|----------------|--------------------|----------------|
| Alto | Alto | **Priorizar migracao P0**; cortar so anti-padrao/nav |
| Alto | Baixo | Manter com pouco esforco — bom ROI |
| Baixo | Alto | **Cortar / nao migrar** salvo P0 de risco (callback erro) |
| Baixo | Baixo | Remover legado; nao criar tags novas |
| Zero APP | — | Medir fora do app; nao inchamento megazord |

**Ordem sugerida de analise (pelo inventario atual):** Vendas → Carteira → Gestao/hub → Estoque → Divulgacao/Materiais → Perfil MLD → Menu → Recomendacao → Conteudos → Encontre.

---

## Artefatos relacionados

| Arquivo | Uso |
|---------|-----|
| [`MAPEAMENTO_DOMINIOS_EVENTOS_LEGADOS.csv`](./MAPEAMENTO_DOMINIOS_EVENTOS_LEGADOS.csv) | Evento a evento |
| [`MAPEAMENTO_DOMINIOS_FILTROS_GA4.csv`](./MAPEAMENTO_DOMINIOS_FILTROS_GA4.csv) | Predicados SQL |
| [`MAPEAMENTO_DOMINIOS_RESUMO.csv`](./MAPEAMENTO_DOMINIOS_RESUMO.csv) | Custo por dominio |
| Input skill PM | `megazord_mobile/tools/analytics-migrate/config/perguntas-negocio-ct.md` |
