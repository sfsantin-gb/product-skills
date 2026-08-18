# Migracao de tagueamento — decisoes PM

> Consolidado em **2026-08-04** a partir de `PERGUNTAS_NEGOCIO.md` (`@analytics-migrate --aprovar`).
> Squad: **Conteudos e Trafego** · Inventario: `TAGUEAMENTO_MIGRADO_CT.csv` (**482 eventos** pos-decisoes PM; 2 excluidos F1/F2).

---

## Resumo

| Acao PM | Itens | Efeito no inventario |
|---------|-------|----------------------|
| **Concordo** (vazio) | Maioria dos vereditos pipeline | Mantem remocoes/migracoes propostas |
| **Remover** | 7 grupos | Confirma ou antecipa remocao |
| **Manter** | 3 grupos | Reverte ou preserva eventos |
| **Revisar** | 2 fechados (V1, V3) · 2 descartados (V2, V4) | Ver secao abaixo |
| **Fora escopo C&T** | VD Studio + Top Ten | Nao entra na entrega desta squad |

---

## Remover — confirmado pelo PM

| # | Contexto | Eventos / tag | Veredito pipeline | Comentario PM |
|---|----------|---------------|-------------------|---------------|
| R1 | Assistente na gestao | `assistant_tag`: `novidades-assistente`, `fechar-novidades-assistente`, `acesso-rapido-assistente-*`, `caixa-de-texto-assistente` (4 eventos, `revisar_pm`) | `revisar_pm` → **remover** | Feature nao existe mais |
| R2 | Encontre RE no app | `find_reseller_place_tag`: `copiar`, `selecionar-cidade` (2 eventos, `revisar_pm`) | `revisar_pm` → **remover** | Fora prioridade / escopo |
| R3 | Modal materiais — filhos | `materials_page_tag`: `agora-nao`, `compartilhar-minha-loja-digital` | `fundir_pai` → **remover** | OK se botao pai dispara share MLD (ver V1) |
| R4 | Navegacao in-app | Cliques `ver-mais*`, `ver-tudo*`, `ir-para-*`, `voltar-*` com PV no destino | `nav_duplicada` → **remover** | Concordo implicito |
| R5 | Anti-padrao | scroll carrossel, swipe in-page galeria | `anti_padrao` → **remover** | Concordo implicito |
| R6 | Gestao / vendas / carteira profunda | ~145 eventos `nao_essencial` fora mapa essencial | `nao_essencial` → **remover** | Concordo implicito |
| R7 | Obsoleto | 2 eventos codigo morto | `obsoleto` → **remover** | Concordo implicito |

---

## Manter — PM discordou do veredito de remocao

| # | Contexto | Eventos / tag | Veredito pipeline | Acao |
|---|----------|---------------|-------------------|------|
| M1 | Cross-tab relatorio pedidos | `financial_report_tag`: `ir-para-pedidos` | `revisar_pm` | **Manter** — migrar como INT |
| M2 | Conclusao de missao | Eventos `task_complete` / granularidade tarefas | `fundir_pai` (fora CSV atual) | **Manter** breakdown por tipo de missao |
| M3 | Botao generico galeria materiais | `materials_page_tag`: `$button:$sectionNameFormatted` | `nao_essencial` | **Manter** — PM nao aceita perda |

---

## Revisoes — resultado

| # | Status | Conclusao |
|---|--------|-----------|
| V1 | **Fechado** | Modal MLD legado e codigo morto — confirmar remocao R3 |
| V2 | **Descartado** | Sem acao nesta entrega |
| V3 | **Fechado** | Funil Home→catalogo→share validado — nav removida com PV substituto |
| V4 | **Descartado** | `ir-para-inicio` permanece `revisar_pm` no CSV |

### V1 — Modal share MLD (materiais)

**Codigo analisado:** `materials_page_tag.dart`, `share_image_modal_widget.dart`, `materials_sections_widget.dart`

| Metodo legado | Dispara na UI? | Decisao |
|---------------|----------------|---------|
| `shareMldModalView` (PV `/app-rev/divulgar/modal/compartilhar-minha-loja-digital`) | **Nao** — nenhum widget de producao chama | **Remover** (obsoleto) |
| `shareMldModalCancelPressed` (`agora-nao`) | **Nao** | **Remover** (confirma R3) |
| `shareMldModalConfirmPressed` (`compartilhar-minha-loja-digital`) | **Nao** | **Remover** (confirma R3) |

**Fluxo ativo:** `ShareImageModalWidget` → `onShareContentOnSocialMedia` → `clique:componente` + `click_baixar_compartilhar_materiais` (custom). Share MLD continua mensuravel sem os eventos de modal legado.

### V3 — Funil Home → catalogo → share

| Etapa | Evento legado | Status migracao | Substituto / nota |
|-------|---------------|-----------------|-------------------|
| 1. Chegada Home | PV `/app-rev/home/` | **manter** | screen_view GA4 |
| 2a. Share catalogo na Home | `home_catalogs_section_tag` · `clique:card` (Compartilhar catalogo / catalogos) | **migrar** | `interaction_inicio` — intent de share preservado |
| 2b. Ver mais na Home | `home_catalogs_section_tag` · `clique:card` (`ver-mais`) | **migrar** | Navega via `PublisherAction.openContentsCatalogs` → `CatalogRoute` |
| 3. Chegada lista catalogos | PV `/app-rev/divulgar/catalogos` | **manter** | Substitui cliques nav removidos abaixo |
| Hub Divulgar → catalogos | `ver-mais-titulo`, `ver-mais-carrossel` (`catalog_module_tag`) | **remover** (`nav_duplicada`) | PV destino acima |
| Lista catalogos → share | `compartilhar-catalogo::$brand`, `divulgar-$type-$brand` | **migrar** | KPI P0 share preservado |
| Lista catalogos → abrir | `abrir-catalogo::$brand`, `abrir-$brand` | **migrar** | KPI P0 open preservado |

**Perda aceita:** intent explicito do clique “ver mais” no hub Divulgar; **chegada** na lista continua via PV. Share e open permanecem com interacoes dedicadas.

---

## Fora escopo desta migracao (C&T)

| # | Escopo | Eventos afetados | Decisao PM |
|---|--------|------------------|------------|
| F1 | **VD Studio inteiro** | `personalize_product_tag` / dominio `VD Studio` (1+ eventos no CSV) | **Nao migrar** — squad nao assume VD Studio nesta entrega |
| F2 | **Vitrine Top Ten (Home)** | `top_ten_show_case_home_tag`: `vitrine-recomendacao-topten` | **Remover da lista C&T** — ownership de outro time/produto |

> Apos F1/F2: regenerar `TAGUEAMENTO_MIGRADO_CT.csv` excluindo ou marcando `fora_escopo_ct` esses eventos.

---

## Lacunas eng — concordo implicito (P0)

| Lacuna | Acao | Prioridade |
|--------|------|------------|
| PV aba financeira `SalesReportPage` | `adicionar_pageview` (3 linhas CSV) | **P0** |
| Deep link aba financeira | PV no load `startAtFinancialTab` | **P0** |
| Remover `ir-para-relatorio` (vendas) | So apos PV aba financeira existir | **P0** bloqueio |
| Callback erro VD Studio | `callback_vdstudio_error` ou correlacao BFF | **P1** — escopo VD fora; baixa prioridade C&T |

---

## Concordo implicito — bulk

PM nao preencheu coluna = aceita veredito pipeline para:

- KPIs P0/P1 de **Divulgacao MLD** (share, open catalog, PV hub)
- **Materiais** share/download (exceto M3 e V1)
- **Conteudos** LP, noticias, open_content (exceto V2)
- **Perfil MLD**, **Carteira**, **Recomendacao**, **Estoque**, **Vendas** funil core
- **Gestao** hub, relatorio, callbacks erro (exceto assistente R1)
- **Menu** cross-cutting
- Remocoes **nav_duplicada** (34) e **fundir_pai** (63) salvo M2

---

## Correcao tecnica — `eventAction: dinamico`

O extrator marca `dinamico (toAnalyticsFormat)` quando o label vem de `FormatterHelper.toAnalyticsFormat(...)` em runtime. **Nao** traduzir para `open:dynamic-content-*`.

| Tag | Antes (errado) | Depois (correto) |
|-----|----------------|------------------|
| `learning_module_tag` | `open:dynamic-content-learning-hub` | `click:card-${formatterhelper.toanalyticsformat(label)}` |
| `materials_module_tag` | `open:dynamic-content-materials-module` | **remover** (`inventario_agregado` — metodos especificos ja no CSV) |
| `news_module_tag` | `open:dynamic-content-news-module` | `click:card-${formatterhelper.toanalyticsformat(label)}` |
| `home_catalogs_section_tag` | `open:dynamic-content-home-catalogs` | `click:card-${formatterhelper.toanalyticsformat(buttonlabel)}` |
| `materials_page_tag` (agregados) | `open:dynamic-content-materials-gallery` | **remover** (`inventario_agregado`) |

Regra documentada em `docs/REGRAS_FORMATO_NOVO.md` secao 2.2.

---

## Proximos passos

1. ~~Regenerar inventario~~ — feito em 2026-08-04 (`TAGUEAMENTO_MIGRADO_CT.csv` / `.md`).
2. ~~Fechar V1 e V3~~ — concluido; V2/V4 descartados.
3. **Cards eng P0:** aba financeira (lacuna confirmada).
4. **Comunicar F1/F2** aos owners de VD Studio e Home/Top Ten.

**Fonte:** [`PERGUNTAS_NEGOCIO.md`](./PERGUNTAS_NEGOCIO.md) · [`TAGUEAMENTO_MIGRADO_CT.csv`](./TAGUEAMENTO_MIGRADO_CT.csv)
