# Perguntas de negocio — Conteudos e Trafego

> Input PM para `@analytics-business-impact` e para analise de relevancia/custo por dominio.
> Versao expandida: ver tambem
> `produto/.../migracao-tagueamento/MAPEAMENTO_DOMINIOS_PERGUNTAS_NEGOCIO.md` (Product OS).
> Complementa [EVENTOS_ESSENCIAIS.md](EVENTOS_ESSENCIAIS.md).

---

## Divulgacao MLD

| Prioridade | Pergunta de negocio | Indicador / como medir |
|------------|---------------------|------------------------|
| P0 | RE compartilha MLD ou link da loja? | `app-rev:divulgar-mld*` / pos: `interaction_divulgar` share_* |
| P0 | RE abre catalogo digital? | `abrir-catalogo::*` / pos: `open:catalog-$brand` |
| P0 | RE compartilha catalogo? | `compartilhar-catalogo::*` / pos: `share:catalog-$brand` |
| P1 | Qual modulo gera mais share (catalogo vs MLD vs materiais)? | Breakdown `app-rev:divulgar*` + `cd_interaction_detail` |
| P1 | Home/atalhos convertem para divulgacao? | `app-rev:home` + menu `divulgar` + PV hub |
| P2 | Scroll/ver-mais de carrossel ainda e KPI? | Em geral nao — candidatas a `remover` |

## Materiais de divulgacao

| Prioridade | Pergunta de negocio | Indicador / como medir |
|------------|---------------------|------------------------|
| P0 | RE baixa/compartilha imagem de material? | `app-rev:divulgar:materiais` `clique:imagem` / `divulgar` |
| P1 | RE navega galeria por secao? | PV galeria / labels de secao |
| P2 | Vale manter tags dinamicas de carrossel? | Maioria `remover` no inventario |

## Perfil e configuracao MLD

| Prioridade | Pergunta de negocio | Indicador / como medir |
|------------|---------------------|------------------------|
| P0 | RE edita perfil ou link da loja? | `app-rev:configuracao:editar-*` — `salvar` |
| P0 | RE abre configs da MLD (estoque/recebiveis/perfil)? | `app-rev:minha-loja-digital` labels `configuracao:*` |
| P1 | RE cria MLD pelo app? | label `criar-minha-loja-digital` |

## Vendas sellout

| Prioridade | Pergunta de negocio | Indicador / como medir |
|------------|---------------------|------------------------|
| P0 | RE registra / adiciona venda? | `app-rev:gerenciar-vendas` + `organizar-vendas` / `callback_vendas_create_sale_success` |
| P0 | RE cobra cliente ou envia lembrete? | `cobrar-cliente*`, `enviar-lembrete`, `opcoes-cobranca` |
| P0 | Auto-save de rascunho funciona? | `callback_vendas_auto_save_sale_*` |
| P1 | Onde o funil de venda mais abandona? | Breakdown `gerenciar-vendas:*` + PV etapas |
| P1 | Onboarding produto generico ainda importa? | `onboarding-produto-generico` (0 migrar — validar volume) |
| P1 | Relatorio de vendas e usado? | `app-rev:relatorio-de-vendas` + PV |
| P2 | Motivos de cancelamento sao consumidos? | `modal:cancelar-modal` |

## Estoque RE / Pronta entrega

| Prioridade | Pergunta de negocio | Indicador / como medir |
|------------|---------------------|------------------------|
| P0 | RE adiciona produto ao estoque com sucesso? | `callback:adicionar-produto` / `callback_estoque_add_product_success` |
| P0 | RE edita estoque (sucesso/erro)? | `callback:editar-produto` `$sku:sucesso|erro` |
| P0 | Apos sucesso, RE compartilha MLD? | `pronta-entrega-sucesso` — `compartilhar-minha-loja-digital` |
| P1 | Baixa automatica e usada? | `modal:baixa-automatica` |
| P2 | Instrumentar cada clique modal por SKU? | Nao — preferir callbacks |

## Carteira de clientes

| Prioridade | Pergunta de negocio | Indicador / como medir |
|------------|---------------------|------------------------|
| P0 | RE abre gestao / detalhe de cliente? | `app-rev:gerenciar-clientes*` + PV detalhe |
| P0 | RE cobra / lembra a partir do cliente? | `cobrar-cliente*`, `recebimentos` — `enviar-lembrete` |
| P0 | RE seleciona cliente na venda? | `organizar-vendas:selecionar-cliente` |
| P1 | Aniversarios/agenda geram uso? | `proximos-aniversarios`, `agenda*` (quase so remover) |
| P1 | Indicacoes / conquistar CF tem adocao? | `indicar`, `conquistar-cf` |

## Gestao do negocio (hub) / Tarefas

| Prioridade | Pergunta de negocio | Indicador / como medir |
|------------|---------------------|------------------------|
| P0 | RE acessa relatorio financeiro e age (boleto/pix)? | `app-rev:relatorio-financeiro` |
| P0 | Erros de relatorio financeiro ocorrem? | `callback:relatorio-financeiro` / `callback_gestao_financial_report_error` |
| P1 | Quais atalhos do hub sao usados? | Preferir PV destino vs `gestao-de-negocio` clique |
| P1 | Tarefas diarias tem adocao? | PV tarefas (validar cobertura) |
| P2 | Tagear cada atalho do hub? | Nao — alto `remover` |

## Recomendacao de produtos

| Prioridade | Pergunta de negocio | Indicador / como medir |
|------------|---------------------|------------------------|
| P0 | RE usa fluxo de indicar produtos? | `$_eventCategoryBase:indicar` (8 eventos, todos migrar) |
| P1 | Ativacoes personalizadas vs genericas diferem? | Breakdown detail pos-migracao |
| P1 | Carrinho abandonado gera share com CF? | Cruzar Divulgar + clientes (pode ser lacuna) |

## Conteudos e treinamento

| Prioridade | Pergunta de negocio | Indicador / como medir |
|------------|---------------------|------------------------|
| P0 | RE abre card de dica/treinamento? | `divulgar-dicas-e-treinamentos` / `divulgar-conteudos` (dinamico) |
| P1 | Novidades geram clique? | `app-rev:novidades` |
| P2 | Manter ver-mais/ver-tudo do carrossel? | Nao |

## Aquisicao CF (Encontre)

| Prioridade | Pergunta de negocio | Indicador / como medir |
|------------|---------------------|------------------------|
| P0 | Encontre no APP ainda tem uso (copiar/filtro)? | `app-rev:encontre-seu-er` — 0 migrar |
| P1 | Opt-in Apareca nas Buscas tem funil no APP? | Provavel fora_app / web |

## Menu e atalhos (trafego transversal)

| Prioridade | Pergunta de negocio | Indicador / como medir |
|------------|---------------------|------------------------|
| P0 | Quais secoes do menu levam a jornadas C&T? | `app-rev:menu` labels `divulgar|gestao-*|minha-loja*` |
| P1 | Mix Menu vs hub Gestao vs Home? | Join menu + gestao-de-negocio + home |

## Checklist PM

- [ ] Perguntas P0 cobrem OKRs / review semanal do time
- [ ] Query 90d por dominio (usar `MAPEAMENTO_DOMINIOS_FILTROS_GA4.csv`) antes de aprovar remocoes em massa
- [ ] `analytics-migrate.config.yml` → `workspace.perguntas_negocio` aponta para este arquivo
- [ ] Apos pipeline: revisar `PERGUNTAS_NEGOCIO.md` e preencher **Decisao PM**
- [ ] Dominios so web/BFF (Portal, Voldemort, PDF, Catalogo site) nao forcam tags megazord
