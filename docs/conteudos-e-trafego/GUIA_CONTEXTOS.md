# Guia de Tagueamento — Conteúdos e Tráfego (C&T)

Inventário de arquivos de analytics (`*_tag*.dart`) no escopo do time **C&T** que **devem ser revisados e alterados** na migração de tagueamento.

**Referências:**

- Padrão GA4 no monorepo: [`packages/flutter_monitor/docs/GUIA_TAGUEAMENTO_GA4.md`](../packages/flutter_monitor/docs/GUIA_TAGUEAMENTO_GA4.md)
- Domínios C&T: [`domínios-c&t.md`](../../contextos/domínios-c&t.md)
- Sitemap C&T: [`SITEMAP_CT.md`](../../contextos/SITEMAP_CT.md)
- **Tabelas por navbar (JSON + rota + ação):** [`TAGUEAMENTO_LEGADO_CT.md`](TAGUEAMENTO_LEGADO_CT.md)
- Novo formato (migracao): [`REGRAS_FORMATO_NOVO.md`](REGRAS_FORMATO_NOVO.md)
- Decisoes de migracao: [`MIGRACAO_DECISOES.md`](MIGRACAO_DECISOES.md)
- Piloto navegacao (leitura): [`NAVEGACAO_AUDITORIA.md`](NAVEGACAO_AUDITORIA.md)
- Piloto cobertura (leitura): [`COBERTURA_AUDITORIA.md`](COBERTURA_AUDITORIA.md)
- Piloto callbacks (leitura): [`CALLBACKS_MIGRACAO.md`](CALLBACKS_MIGRACAO.md)
- Simplificacao jornadas: [`SIMPLIFICACAO_JORNADAS.md`](SIMPLIFICACAO_JORNADAS.md)
- Inventario migrado: [`TAGUEAMENTO_MIGRADO_CT.md`](TAGUEAMENTO_MIGRADO_CT.md)
- Eventos essenciais por area: [`EVENTOS_ESSENCIAIS_CT.md`](EVENTOS_ESSENCIAIS_CT.md)
- Criterio de relevancia: [`CRITERIO_RELEVANCIA.md`](CRITERIO_RELEVANCIA.md)
- Skill/agente: `@analytics-migrate` (`.github/skills/analytics-migrate/SKILL.md`)

---

## Objetivo

Todos os **217 arquivos** listados abaixo estão no escopo de alteração. Marque `[x]` na coluna Status conforme cada par contrato/impl for migrado e validado.

## Como usar

1. Localize o contexto C&T na [seção por contexto](#mapa-contexto--arquivos) ou busque o microapp no [inventário](#inventário-por-microapp).
2. Abra o arquivo `*_tag.dart` (contrato) e `*_tag_impl.dart` (quando existir).
3. Ajuste `eventCategory`, `eventAction` e `eventLabel` conforme o padrão do guia GA4.
4. Atualize os testes espelhados em `test/**/*_tag*_test.dart`.
5. Marque o checklist neste documento.

## Resumo por microapp

| Microapp | Arquivos | Principais contextos |
|----------|----------|----------------------|
| `contents` | 13 | Divulgar, Materiais, Treinamentos, Tráfego MLD |
| `contents_advertising` | 5 | VD Studio |
| `mld_profile` | 10 | Perfil MLD |
| `opt_out` | 2 | Opt-in Catálogo |
| `recommendation` | 3 | Apareça nas Buscas |
| `customer_management` | 45 | Clientes, Tarefas, Promote, Sacola abandonada |
| `sales_management` | 100 | Vendas Sellout VD |
| `stock_management` | 22 | Estoque RE |
| `business_management` | 11 | Relatório financeiro, Hub Gestão |
| `jarvis` (parcial) | 4 | Menu atalhos C&T, Encontre |
| `megazord` (parcial) | 2 | Tráfego MLD na Home |
| **Total** | **217** | |

## Exemplos de `eventCategory` atuais (`contents`)

| Arquivo | eventCategory |
|---------|---------------|
| `home_page_tag.dart` | `app-rev:divulgar` |
| `mld_module_tag.dart` | `app-rev:divulgar-mld` |
| `materials_module_tag.dart` | `app-rev:divulgar:materiais` |
| `learning_module_tag.dart` | `app-rev:divulgar-dicas-e-treinamentos` |
| `home_catalogs_section_tag.dart` | `app-rev:home` |

---

## Mapa contexto → arquivos

| Contexto C&T | Microapps | Tags principais |
|--------------|-----------|-----------------|
| Divulgar APP | `contents`, `mld_profile` | `home_page_tag`, `mld_module_tag`, `catalog_module_tag` |
| Materiais de Divulgação | `contents` | `materials_*_tag`, `full_screen_image_tag` |
| VD Studio | `contents_advertising` | `personalize_product_tag`, `edit_texts_tag` |
| Tráfego geral MLD | `contents`, `megazord` | `home_catalogs_section_tag`, `top_ten_show_case_home_tag` |
| Perfil MLD | `mld_profile` | `config_tag`, `edit_profile_tag`, `store_link_tag` |
| Opt-in Catálogo | `opt_out` | `opt_out_tag` |
| Dicas e treinamentos | `contents` | `learning_module_tag`, `landing_page_tag` |
| Carrinho abandonado | `contents`, `customer_management` | `home_page_tag`, `customers_showcase_tag`, `promote_products_tag` |
| Gestão de clientes / Carteira | `customer_management` | `customer_*_tag`, `contacts_tag`, `share_catalogs_tag` |
| Tarefas | `customer_management` | `tasks_tag` |
| Divulgar Produtos | `customer_management` | `promote_products_tag` |
| Estoque RE | `stock_management` | `stock_page_tag`, `sellin_sellout_tag` |
| Vendas Sellout VD | `sales_management` | `sales_tag`, `sale_details_tag`, `charge_*_tag` |
| Relatório financeiro / Gestão | `business_management` | `financial_report_tag`, `sales_report_tag`, `hub_tag` |
| Apareça nas Buscas | `recommendation` | `app_tags` |
| Encontre (atalho) | `jarvis` | `find_reseller_place_tag` |
| Menu atalhos C&T | `jarvis` | `menu_page_tag` |

---

## Inventário por microapp

### `contents` (13 arquivos)

| Status | Arquivo | Contexto C&T |
|--------|---------|--------------|
| [ ] | `microapps/contents/lib/features/catalogs/presentation/catalog_module/catalog_module_tag.dart` | Divulgar APP / Catálogo / Tráfego MLD |
| [ ] | `microapps/contents/lib/features/catalogs/presentation/catalog_page/catalog_page_tag.dart` | Divulgar APP / Catálogo / Tráfego MLD |
| [ ] | `microapps/contents/lib/features/catalogs/presentation/home_catalogs_module/home_catalogs_section_tag.dart` | Divulgar APP / Catálogo / Tráfego MLD |
| [ ] | `microapps/contents/lib/features/home/presentation/home_page/home_page_tag.dart` | Divulgar APP |
| [ ] | `microapps/contents/lib/features/landing_page/presentation/landing_page/landing_page_tag.dart` | Dicas e treinamentos |
| [ ] | `microapps/contents/lib/features/materials/presentation/full_screen_image/full_screen_image_tag.dart` | Materiais de Divulgação |
| [ ] | `microapps/contents/lib/features/materials/presentation/materials_module/materials_module_tag.dart` | Materiais de Divulgação |
| [ ] | `microapps/contents/lib/features/materials/presentation/materials_page/materials_page_tag.dart` | Materiais de Divulgação |
| [ ] | `microapps/contents/lib/features/materials/presentation/prismic_materials_module/prismic_materials_module_tag.dart` | Materiais de Divulgação |
| [ ] | `microapps/contents/lib/features/mld/presentation/mld_module/mld_module_tag.dart` | Divulgar APP / Tráfego MLD |
| [ ] | `microapps/contents/lib/features/news/presentation/learning_module/learning_module_tag.dart` | Dicas e treinamentos / Notícias |
| [ ] | `microapps/contents/lib/features/news/presentation/news_module/news_module_tag.dart` | Dicas e treinamentos / Notícias |
| [ ] | `microapps/contents/lib/features/news/presentation/news_page/news_page_tag.dart` | Dicas e treinamentos / Notícias |

### `contents_advertising` (5 arquivos)

| Status | Arquivo | Contexto C&T |
|--------|---------|--------------|
| [ ] | `microapps/contents_advertising/lib/src/presentation/personalize_product/modules/texts/presentation/tag/edit_texts_tag.dart` | VD Studio |
| [ ] | `microapps/contents_advertising/lib/src/presentation/personalize_product/modules/texts/presentation/tag/include_texts_tag.dart` | VD Studio |
| [ ] | `microapps/contents_advertising/lib/src/presentation/personalize_product/modules/texts/presentation/tag/tag.dart` | VD Studio |
| [ ] | `microapps/contents_advertising/lib/src/presentation/personalize_product/tag/personalize_product_tag.dart` | VD Studio |
| [ ] | `microapps/contents_advertising/lib/src/presentation/personalize_product/tag/personalize_product_tag_impl.dart` | VD Studio |

### `mld_profile` (10 arquivos)

| Status | Arquivo | Contexto C&T |
|--------|---------|--------------|
| [ ] | `microapps/mld_profile/lib/src/features/config/presentation/config/tag/config_tag.dart` | Perfil & Configuração MLD |
| [ ] | `microapps/mld_profile/lib/src/features/config/presentation/config/tag/config_tag_impl.dart` | Perfil & Configuração MLD |
| [ ] | `microapps/mld_profile/lib/src/features/config/presentation/edit_profile_before_share/tag/edit_profile_before_share_tag.dart` | Perfil & Configuração MLD |
| [ ] | `microapps/mld_profile/lib/src/features/config/presentation/edit_profile_before_share/tag/edit_profile_before_share_tag_impl.dart` | Perfil & Configuração MLD |
| [ ] | `microapps/mld_profile/lib/src/features/profile/presentation/edit_profile/tag/edit_profile_tag.dart` | Perfil & Configuração MLD |
| [ ] | `microapps/mld_profile/lib/src/features/profile/presentation/edit_profile/tag/edit_profile_tag_impl.dart` | Perfil & Configuração MLD |
| [ ] | `microapps/mld_profile/lib/src/features/profile/presentation/edit_slug/tag/edit_slug_tag.dart` | Perfil & Configuração MLD |
| [ ] | `microapps/mld_profile/lib/src/features/profile/presentation/edit_slug/tag/edit_slug_tag_impl.dart` | Perfil & Configuração MLD |
| [ ] | `microapps/mld_profile/lib/src/features/profile/presentation/store_link/tag/store_link_tag.dart` | Perfil & Configuração MLD |
| [ ] | `microapps/mld_profile/lib/src/features/profile/presentation/store_link/tag/store_link_tag_impl.dart` | Perfil & Configuração MLD |

### `opt_out` (2 arquivos)

| Status | Arquivo | Contexto C&T |
|--------|---------|--------------|
| [ ] | `packages/opt_out/lib/src/presentation/tag/opt_out_tag.dart` | Opt-in Catálogo |
| [ ] | `packages/opt_out/lib/src/presentation/tag/opt_out_tag_impl.dart` | Opt-in Catálogo |

### `recommendation` (3 arquivos)

| Status | Arquivo | Contexto C&T |
|--------|---------|--------------|
| [ ] | `microapps/recommendation/lib/shared/tags/app_tags.dart` | Apareça nas Buscas |
| [ ] | `microapps/recommendation/lib/shared/tags/app_tags_impl.dart` | Apareça nas Buscas |
| [ ] | `microapps/recommendation/lib/shared/tags/tags.dart` | Apareça nas Buscas |

### `customer_management` (45 arquivos)

| Status | Arquivo | Contexto C&T |
|--------|---------|--------------|
| [ ] | `microapps/customer_management/lib/shared/tag/activations/activations_tag.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/shared/tag/activations/activations_tag_impl.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/shared/tag/customer_tag.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/shared/tag/customer_tag_impl.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/shared/tag/sales_summary_card_tag.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/birthdays/presentation/tag/birthdays_tag.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/birthdays/presentation/tag/birthdays_tag_impl.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/conquer_customers/presentation/tag/conquer_customers_page_tag.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/conquer_customers/presentation/tag/conquer_customers_page_tag_impl.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/contacts/presentation/tag/contacts_tag.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/contacts/presentation/tag/contacts_tag_impl.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/customer_details/presentation/tag/customer_details_tag.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/customer_details/presentation/tag/customer_details_tag_impl.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/customer_details/presentation/tag/financial_details_tag.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/customer_details/presentation/tag/financial_details_tag_impl.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/customer_details/presentation/tag/notes_tag.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/customer_details/presentation/tag/notes_tag_impl.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/customer_list/presentation/tag/customer_list_tag.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/customer_list/presentation/tag/customer_list_tag_impl.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/customer_list/presentation/tag/customers_filter_tag.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/customer_list/presentation/tag/customers_filter_tag_impl.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/customer_orders/presentation/tag/customer_orders_tag.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/customer_orders/presentation/tag/customer_orders_tag_impl.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/customer_orders/presentation/tag/customer_update_payment_status_tag_impl.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/customers_suggestions_category/presentation/tag/customers_suggestions_category_tag.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/customers_suggestions_category/presentation/tag/customers_suggestions_category_tag_impl.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/delete_customer/presentation/tag/customer_successful_deleted_page_tag.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/delete_customer/presentation/tag/customer_successful_deleted_page_tag_impl.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/delete_customer/presentation/tag/delete_customer_confirmation_modal_tag.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/delete_customer/presentation/tag/delete_customer_confirmation_modal_tag_impl.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/delete_customer/presentation/tag/delete_customer_page_tag.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/delete_customer/presentation/tag/delete_customer_page_tag_impl.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/promote_products/presentation/tag/all_products_showcase/all_products_showcase_tag.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/promote_products/presentation/tag/all_products_showcase/all_products_showcase_tag_impl.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/promote_products/presentation/tag/customers_showcase/customers_showcase_tag.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/promote_products/presentation/tag/customers_showcase/customers_showcase_tag_impl.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/promote_products/presentation/tag/promote_products/promote_products_tag.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/promote_products/presentation/tag/promote_products/promote_products_tag_impl.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/promote_products/presentation/tag/tag.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/select_contact/presentation/tag/select_contact_tag.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/select_contact/presentation/tag/select_contact_tag_impl.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/share_catalogs/presentation/tag/share_catalogs_tag.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/share_catalogs/presentation/tag/share_catalogs_tag_impl.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/tasks/presentation/tag/tasks_tag.dart` | Gestão de clientes / Carteira |
| [ ] | `microapps/customer_management/lib/src/tasks/presentation/tag/tasks_tag_impl.dart` | Gestão de clientes / Carteira |

### `sales_management` (100 arquivos)

| Status | Arquivo | Contexto C&T |
|--------|---------|--------------|
| [ ] | `microapps/sales_management/lib/src/presentation/add_customer/tag/add_customer_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/add_sale/tag/add_sale_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/add_sale/tag/add_sale_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/add_sale/tag/confirm_quit_survey/confirm_quit_survey_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/add_sale/tag/confirm_quit_survey/confirm_quit_survey_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/add_sale/tag/customer_tag/customer_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/add_sale/tag/customer_tag/customer_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/add_sale/tag/delete_product_tag/delete_product_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/add_sale/tag/delete_product_tag/delete_product_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/add_sale/tag/edit_total/edit_total_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/add_sale/tag/edit_total/edit_total_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/add_sale/tag/payment_conditions/payment_conditions_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/add_sale/tag/payment_conditions/payment_conditions_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/add_sale/tag/sale_added/sale_added_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/add_sale/tag/sale_added/sale_added_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/add_sale/tag/sale_added_page_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/change_installments/tag/change_installments_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/change_installments/tag/change_installments_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/charges/charge_customer/charge_customer_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/charges/charge_options/charge_options_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/charges/payment_link_modal/payment_link_modal_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/charges/reminder/send_reminder_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/installment_detail/tag/delete_installment_modal_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/installment_detail/tag/delete_installment_modal_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/installment_detail/tag/delete_payment_modal_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/installment_detail/tag/delete_payment_modal_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/installment_detail/tag/installment_detail_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/installment_detail/tag/installment_detail_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/installment_detail/tag/installment_edit_info_modal_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/installment_detail/tag/payment_detail_model_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/installment_detail/tag/payment_detail_model_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/installment_detail/tag/reminders_history_modal_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/manage_receipts/tag/manage_receipts_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/organize_sales/tag/confirm_delete_product_on_organize_sale_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/organize_sales/tag/confirm_delete_sale/confirm_delete_sale_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/organize_sales/tag/confirm_delete_sale/confirm_delete_sale_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/organize_sales/tag/organize_sales/organize_sales_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/organize_sales/tag/organize_sales/organize_sales_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/payments_link/payments_link_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/product_search/tag/generic_products/generic_products_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/product_search/tag/generic_products/generic_products_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/product_search/tag/product_search/product_search_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/product_search/tag/product_search/product_search_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/quick_sale/tag/quick_sale_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/quick_sale/tag/quick_sale_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/received_sales/tag/received_sales_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/received_sales/tag/received_sales_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sale_details/payment_methods/payment_methods_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sale_details/tag/add_installment_modal_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sale_details/tag/all_products_were_not_added/all_products_were_not_added_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sale_details/tag/all_products_were_not_added/all_products_were_not_added_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sale_details/tag/cancel_sale_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sale_details/tag/cancel_sale_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sale_details/tag/complete_sale/complete_sale_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sale_details/tag/complete_sale/complete_sale_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sale_details/tag/sale_details_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sale_details/tag/sales_details_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sale_details/tag/some_products_were_not_added/some_products_were_not_added_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sale_details/tag/some_products_were_not_added/some_products_were_not_added_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sale_details/tag/update_payment_status/sale_details_update_payment_status_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sales/tag/filter_sale/filter_sale_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sales/tag/filter_sale/filter_sale_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sales/tag/know_how/know_how_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sales/tag/know_how/know_how_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sales/tag/learn_how_to_generate_charges/learn_how_to_generate_charges_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sales/tag/learn_how_to_generate_charges/learn_how_to_generate_charges_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sales/tag/sales_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sales/tag/sales_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sales/tag/update_payment_status/sales_update_payment_status_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sales_added_successfully/tag/sales_added_successfully_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sales_added_successfully/tag/sales_added_successfully_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/select_customer/tag/select_customer/select_customer_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/select_customer/tag/select_customer/select_customer_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/select_products/tag/select_products/select_products_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/select_products/tag/select_products/select_products_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sellin_sellout/tag/sellin_sellout_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sellin_sellout/tag/sellin_sellout_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sellin_sellout/tag/tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sellout_sellin/tag/sellout_sellin_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/sellout_sellin/tag/sellout_sellin_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/update_sale_products/tag/confirm_delete/confirm_delete_product_on_edit_sale_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/update_sale_products/tag/sale_value_updated/sale_value_updated_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/update_sale_products/tag/sale_value_updated/sale_value_updated_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/update_sale_products/tag/update_sale_products/update_sale_products_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/update_sale_products/tag/update_sale_products/update_sale_products_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/upsert_sale_product/tag/create_sale_product_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/upsert_sale_product/tag/edit_sale_product_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/presentation/upsert_sale_product/tag/upsert_sale_product_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/shared/charge_link/charge_link_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/shared/tag/generic_product_onboarding/generic_product_onboarding_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/shared/tag/generic_product_onboarding/generic_product_onboarding_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/shared/widgets/billing_in_progress/billing_in_progress_modal_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/shared/widgets/billing_in_progress/billing_in_progress_modal_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/shared/widgets/confirm_delete_bottom_sheet/tag/confirm_delete_product_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/shared/widgets/confirm_quit/tag/confirm_quit_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/shared/widgets/confirm_quit/tag/confirm_quit_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/shared/widgets/installment_info/tag/installment_info_modal_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/shared/widgets/sale_already_added_to_cart_bottom_sheet/tag/sale_already_added_tag.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/shared/widgets/sale_already_added_to_cart_bottom_sheet/tag/sale_already_added_tag_impl.dart` | Vendas Sellout VD |
| [ ] | `microapps/sales_management/lib/src/utils/tag.dart` | Vendas Sellout VD |

### `stock_management` (22 arquivos)

| Status | Arquivo | Contexto C&T |
|--------|---------|--------------|
| [ ] | `microapps/stock_management/lib/src/presentation/edit_stock/tag/edit_stock_tag.dart` | Estoque RE / Pronta-entrega |
| [ ] | `microapps/stock_management/lib/src/presentation/edit_stock/tag/edit_stock_tag_impl.dart` | Estoque RE / Pronta-entrega |
| [ ] | `microapps/stock_management/lib/src/presentation/edit_stock/widgets/confirm_back_modal/tag/confirm_back_tag.dart` | Estoque RE / Pronta-entrega |
| [ ] | `microapps/stock_management/lib/src/presentation/edit_stock/widgets/confirm_back_modal/tag/confirm_back_tag_impl.dart` | Estoque RE / Pronta-entrega |
| [ ] | `microapps/stock_management/lib/src/presentation/search_product/tag/add_product_tag.dart` | Estoque RE / Pronta-entrega |
| [ ] | `microapps/stock_management/lib/src/presentation/search_product/tag/add_product_tag_impl.dart` | Estoque RE / Pronta-entrega |
| [ ] | `microapps/stock_management/lib/src/presentation/sellin_sellout/tag/sellin_sellout_tag.dart` | Estoque RE / Pronta-entrega |
| [ ] | `microapps/stock_management/lib/src/presentation/sellin_sellout/tag/sellin_sellout_tag_impl.dart` | Estoque RE / Pronta-entrega |
| [ ] | `microapps/stock_management/lib/src/presentation/sellin_sellout_success/tag/sellin_sellout_succes_tag.dart` | Estoque RE / Pronta-entrega |
| [ ] | `microapps/stock_management/lib/src/presentation/sellin_sellout_success/tag/sellin_sellout_succes_tag_impl.dart` | Estoque RE / Pronta-entrega |
| [ ] | `microapps/stock_management/lib/src/presentation/stock/tag/automatic_stock_modal_tag.dart` | Estoque RE / Pronta-entrega |
| [ ] | `microapps/stock_management/lib/src/presentation/stock/tag/automatic_stock_modal_tag_impl.dart` | Estoque RE / Pronta-entrega |
| [ ] | `microapps/stock_management/lib/src/presentation/stock/tag/stock_page_tag.dart` | Estoque RE / Pronta-entrega |
| [ ] | `microapps/stock_management/lib/src/presentation/stock/tag/stock_page_tag_impl.dart` | Estoque RE / Pronta-entrega |
| [ ] | `microapps/stock_management/lib/src/shared/widgets/bottom_sheet/product_already_in_stock/product_already_in_stock_tag.dart` | Estoque RE / Pronta-entrega |
| [ ] | `microapps/stock_management/lib/src/shared/widgets/bottom_sheet/product_already_in_stock/product_already_in_stock_tag_impl.dart` | Estoque RE / Pronta-entrega |
| [ ] | `microapps/stock_management/lib/src/widgets/bottom_sheet/create_stock_bottom_sheet/tag/create_stock_tag.dart` | Estoque RE / Pronta-entrega |
| [ ] | `microapps/stock_management/lib/src/widgets/bottom_sheet/create_stock_bottom_sheet/tag/create_stock_tag_impl.dart` | Estoque RE / Pronta-entrega |
| [ ] | `microapps/stock_management/lib/src/widgets/bottom_sheet/create_stock_success_bottom_sheet/tag/create_stock_success_tag.dart` | Estoque RE / Pronta-entrega |
| [ ] | `microapps/stock_management/lib/src/widgets/bottom_sheet/create_stock_success_bottom_sheet/tag/create_stock_success_tag_impl.dart` | Estoque RE / Pronta-entrega |
| [ ] | `microapps/stock_management/lib/src/widgets/confirm_delete_stock_bottom_sheet/tag/confirm_delete_tag.dart` | Estoque RE / Pronta-entrega |
| [ ] | `microapps/stock_management/lib/src/widgets/confirm_delete_stock_bottom_sheet/tag/confirm_delete_tag_impl.dart` | Estoque RE / Pronta-entrega |

### `business_management` (11 arquivos)

| Status | Arquivo | Contexto C&T |
|--------|---------|--------------|
| [ ] | `microapps/business_management/lib/src/presentation/assistant/tag/assistant_tag.dart` | Relatório financeiro / Gestão vendas |
| [ ] | `microapps/business_management/lib/src/presentation/assistant/tag/assistant_tag_impl.dart` | Relatório financeiro / Gestão vendas |
| [ ] | `microapps/business_management/lib/src/presentation/assistant/tag/tag.dart` | Relatório financeiro / Gestão vendas |
| [ ] | `microapps/business_management/lib/src/presentation/dash/tag/hub_tag.dart` | Relatório financeiro / Gestão vendas |
| [ ] | `microapps/business_management/lib/src/presentation/dash/tag/hub_tag_impl.dart` | Relatório financeiro / Gestão vendas |
| [ ] | `microapps/business_management/lib/src/presentation/dash/tag/instructions_modal_tag.dart` | Relatório financeiro / Gestão vendas |
| [ ] | `microapps/business_management/lib/src/presentation/dash/tag/instructions_modal_tag_impl.dart` | Relatório financeiro / Gestão vendas |
| [ ] | `microapps/business_management/lib/src/presentation/financial_report/tag/financial_report_tag.dart` | Relatório financeiro / Gestão vendas |
| [ ] | `microapps/business_management/lib/src/presentation/financial_report/tag/financial_report_tag_impl.dart` | Relatório financeiro / Gestão vendas |
| [ ] | `microapps/business_management/lib/src/presentation/sales_report/tag/sales_report_tag.dart` | Relatório financeiro / Gestão vendas |
| [ ] | `microapps/business_management/lib/src/presentation/sales_report/tag/sales_report_tag_impl.dart` | Relatório financeiro / Gestão vendas |

### `jarvis (parcial) — Menu` (2 arquivos)

| Status | Arquivo | Contexto C&T |
|--------|---------|--------------|
| [ ] | `microapps/jarvis/lib/presentation/menu/tag/menu_page_tag.dart` | Menu — atalhos C&T |
| [ ] | `microapps/jarvis/lib/presentation/menu/tag/menu_page_tag_impl.dart` | Menu — atalhos C&T |

### `jarvis (parcial) — Encontre` (2 arquivos)

| Status | Arquivo | Contexto C&T |
|--------|---------|--------------|
| [ ] | `microapps/jarvis/lib/presentation/reseller_place/tag/find_reseller_place_tag.dart` | Encontre RE (atalho app) |
| [ ] | `microapps/jarvis/lib/presentation/reseller_place/tag/find_reseller_place_tag_impl.dart` | Encontre RE (atalho app) |

### `megazord (parcial)` (2 arquivos)

| Status | Arquivo | Contexto C&T |
|--------|---------|--------------|
| [ ] | `apps/megazord/lib/domain/home/items/tag/top_ten_show_case_home_tag.dart` | Tráfego geral MLD / Home |
| [ ] | `apps/megazord/lib/domain/home/items/tag/top_ten_show_case_home_tag_impl.dart` | Tráfego geral MLD / Home |



---

## Regenerar inventário

```powershell
powershell -ExecutionPolicy Bypass -File tools/extract-ct-tags/extract_ct_tags.ps1
```

Inventário operacional: [`TAGUEAMENTO_LEGADO_CT.md`](TAGUEAMENTO_LEGADO_CT.md) — **217 arquivos** no escopo (exclui `test/`, `share_product_tag`, `logout_modal_tag`, `terms_and_settings_tag`).
- Novo formato (migracao): [`REGRAS_FORMATO_NOVO.md`](REGRAS_FORMATO_NOVO.md)
- Decisoes de migracao: [`MIGRACAO_DECISOES.md`](MIGRACAO_DECISOES.md)
- Piloto navegacao (leitura): [`NAVEGACAO_AUDITORIA.md`](NAVEGACAO_AUDITORIA.md)
- Piloto cobertura (leitura): [`COBERTURA_AUDITORIA.md`](COBERTURA_AUDITORIA.md)
- Skill/agente: `@analytics-migrate` (`.github/skills/analytics-migrate/SKILL.md`)

Planilha completa: [`TAGUEAMENTO_LEGADO_CT.csv`](TAGUEAMENTO_LEGADO_CT.csv) (481 eventos, gerada pelo mesmo script).
