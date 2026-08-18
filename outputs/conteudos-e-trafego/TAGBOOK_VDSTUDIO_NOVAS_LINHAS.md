# Linhas novas — Tagbook VD Studio

> Gerado por `@analytics-plan`. Tagbook: [Tagueamento VD Studio](https://docs.google.com/spreadsheets/d/1LBr6ioZ-qe72oeYnB1rypoMEpIvimfI7jj5NkuayfG0/edit) · aba **Tagueamento Agnostico**.
> Status de gravacao: `bloqueado-sem-sheets`

## Pedido

Atualizacao da UI de textos no editor do VD Studio (VDI) e no App da RE: menu **Escolha que tipo de texto deseja incluir**, toggle **Incluir todas as opcoes**, chips por tipo de texto, rename **Incluir texto → Editar texto**, e regra do carrossel (textos default na imagem em destaque).

Nao taguear X de fechar o painel nem seta de voltar (navegacao in-app). Nao taguear insercao automatica de textos default no carrossel (efeito colateral do swipe).

## Modelo de referencia

| Campo | Valor |
|-------|--------|
| Linha / ancora | PRD · Edicao de Texto · `screen_view` `/vdstudio/inserir-textos` |
| `screen_name` | `/vdstudio/inserir-textos` |
| Por que este modelo | Mesmo modal: abrir o menu de textos |
| Linha / ancora | PRD · Edicao de Texto · `interaction_vdstudio` clique no item do menu textos |
| `screen_name` | `/vdstudio/inserir-textos` |
| Por que este modelo | Mesmo gatilho (selecionar/desativar chip); so muda o enum |
| Linha / ancora | PRD · Inicio · `interaction_vdstudio` navbar |
| `screen_name` | `/vdstudio` |
| Por que este modelo | Mesmo clique de menu; `inserir-texto` vira `editar-texto` |
| Linha / ancora | (sem Status) · Divulgacao · `interaction_vdstudio` `scroll:carrossel-fotos` |
| `screen_name` | `/vdstudio/divulgar` |
| Por que este modelo | Mesmo gesto de carrossel; tela do editor e `/vdstudio` |

## Classificacao

| Gatilho na spec | Tipo | Acao |
|-----------------|------|------|
| Ver o painel de textos | `screen_view` | **Dedup** — ja existe `/vdstudio/inserir-textos` |
| Chip de tipo de texto (on/off) | `interaction_vdstudio` | **Ajuste** do enum PRD (3 chips novos no VDI) |
| Toggle Incluir todas as opcoes | `interaction_vdstudio` | **Dedup** — ja e `todas-as-opcoes` no mesmo evento |
| Navbar Editar texto / Salvar / Editar fundo / Formato | `interaction_vdstudio` | **Ajuste** do valor `inserir-texto` → `editar-texto` |
| Swipe do carrossel no editor | `interaction_vdstudio` | **Linha nova** (trio inedito: evento + `/vdstudio` + `scroll:carrossel-fotos`) |
| Callback ao sair do menu com textos aplicados | `callback_vdstudio_textos_*` | **Ajuste** do enum DEV |
| Share/salvar card | `card_shared` | **Ajuste** da lista de textos no `cd_interaction_detail` |
| Toggle textos automaticos na tela inicial | `interaction_vdstudio` `click:toggle-textos-[exibir\|ocultar]` | **Depreciar** — spec retira o toggle da tela; o master passou para o menu |
| X / voltar | — | Nao taguear |

## App da RE vs VDI (mesmo evento)

Um unico trio Agnostico (`iOS, Android, VDI`). A plataforma so dispara os chips que existem na UI.

| Chip (`cd_interaction_detail` tail) | VDI / VD Studio | App da RE |
|-------------------------------------|-----------------|-----------|
| `valor-de-compra` | sim (**novo**) | nao (oculto) |
| `valor-de-revenda` | sim | sim |
| `lucro` | sim (**novo**) | nao (oculto) |
| `lucratividade` | sim (**novo**) | nao (oculto) |
| `nome-do-item` | sim | sim |
| `descricao-do-item` | sim | sim |
| `codigo-do-item` | sim | sim |
| `whatsapp` | sim | sim |
| `texto-livre` | sim | sim |
| `todas-as-opcoes` | sim (toggle) | sim (toggle) |

Ordem dos chips difere entre VDI e App; o valor do parametro e o tipo, nao a posicao no grid.

---

## Ajustes em linhas existentes (nao append)

Nao gravar duplicata. Editar G / H / I (e E se o gatilho mudar) nas linhas PRD/DEV abaixo.

### A1. Menu de textos — chips + toggle

**Ancora:** PRD · Edicao de Texto · `Quando eu clicar em um item do menu textos` · `interaction_vdstudio` · `/vdstudio/inserir-textos`

**Enum vigente:** `click:[selecionar-texto | desativar-texto]-[valor-de-revenda | nome-do-item | codigo-do-item | whatsapp | texto-livre | descricao-do-item | todas-as-opcoes]`

**Enum proposto (coluna G):**

```
screen_name: /vdstudio/inserir-textos
cd_interaction_detail: click:[selecionar-texto | desativar-texto]-[valor-de-compra | valor-de-revenda | lucro | lucratividade | nome-do-item | descricao-do-item | codigo-do-item | whatsapp | texto-livre | todas-as-opcoes]
```

**Exemplo (coluna I)** — manter um valor so; sugerir o chip novo mais relevante para QA:

```
screen_name: /vdstudio/inserir-textos
cd_interaction_detail: click:selecionar-texto-lucro
```

**JSON (coluna H):**

```json
{
  "client_id": "[[identificador-unico-usuario]]",
  "session_id": "[[identificador-unico-sessao]]",
  "events": [{
    "name": "interaction_vdstudio",
    "params": {
      "screen_name": "/vdstudio/inserir-textos",
      "cd_interaction_detail": "click:[selecionar-texto | desativar-texto]-[valor-de-compra | valor-de-revenda | lucro | lucratividade | nome-do-item | descricao-do-item | codigo-do-item | whatsapp | texto-livre | todas-as-opcoes]"
    }
  }]
}
```

Regras de disparo (nao mudam o nome do evento):

- Toggle **Incluir todas as opcoes** ON → `click:selecionar-texto-todas-as-opcoes`
- Toggle OFF → `click:desativar-texto-todas-as-opcoes`
- Toggle desabilitado (nenhum texto na imagem): **nao dispara**
- Reativar o toggle restaura os textos anteriores **exceto** `texto-livre` (efeito de produto; o hit continua sendo `todas-as-opcoes`)
- Chip **Texto livre** usa o mesmo padrao `selecionar-texto-texto-livre` / `desativar-texto-texto-livre` (nao criar evento separado porque o botao e outlined)

### A2. Navbar — Incluir texto → Editar texto

**Ancora:** PRD · Inicio · `Quando eu clico em um dos menus de edicao na navbar` · `/vdstudio`

**Enum vigente:** `click:navbar-[salvar | inserir-texto | ver-modelos | trocar-formato | editar-fundo]`

**Enum proposto:**

```
screen_name: /vdstudio
cd_interaction_detail: click:navbar-[salvar | editar-texto | ver-modelos | trocar-formato | editar-fundo]
```

**Exemplo I:** `cd_interaction_detail: click:navbar-editar-texto`

`inserir-texto` fica deprecado. `ver-modelos` permanece no enum (a spec desta tela nao remove o item; so nao aparece neste recorte de UI).

### A3. screen_view do modal

**Ancora:** PRD · Edicao de Texto · `Quando eu clicar no menu textos e visualizar o modal` · `screen_name: /vdstudio/inserir-textos`

Manter o path (continuidade historica). O botao da navbar agora se chama Editar texto; o `screen_name` **nao** muda para `/vdstudio/editar-textos`.

Gatilho E pode ficar: `Quando eu clicar em Editar texto e visualizar o menu de tipos de texto`.

### A4. Callback e demais interacoes de caixa de texto

Incluir `valor-de-compra`, `lucro` e `lucratividade` no mesmo pipe dos eventos de Edicao de Texto que ja listam os tipos:

- DEV `callback_vdstudio_textos_success` / `_error` (`textos-incluidos: …`)
- PRD `click:texto-[…]` (toque na caixa)
- PRD `drag:[…]`
- PRD `width:[…]` / `size:[…]`
- PRD `click:[excluir | estilizar | editar]-[…]`
- PRD `double-click:[…]`
- PRD `callback_vdstudio_textos_apagados_*`
- DEV `callback_vdstudio_textos_estilizados_*` / `_editados_*`

App da RE nunca envia os tres valores novos.

### A5. `card_shared`

No 4o segmento de `cd_interaction_detail` (tipos de texto no card), o vigente e `[none | whatsapp | descriçao | código | livre | preço | nome]`.

**Proposto:** `[none | whatsapp | descricao | codigo | livre | preco | nome | valor-de-compra | lucro | lucratividade]` (multiplos tipos separados como hoje). Nao criar terceira linha de `card_shared`.

### A6. Depreciar toggle da tela inicial

PRD · Inicio · `Quando eu ligo/desligo os textos automaticos` · `click:toggle-textos-[exibir | ocultar]` · `/vdstudio`

A spec desta atualizacao **retira** o toggle de inserir valor de revenda da tela do editor. O master passa a ser `todas-as-opcoes` dentro de `/vdstudio/inserir-textos`. Nao disparar mais `toggle-textos-*` na home do editor.

---

## Linhas propostas (append)

### 1. `interaction_vdstudio` — Inicio (carrossel do editor)

| Col | Campo | Valor |
|-----|--------|--------|
| A | Status | PLANEJADO |
| B | Sistema Operacional | iOS, Android, VDI |
| C | Contexto | Inicio |
| D | Tela | |
| E | Quando deve ser disparado | Quando eu deslizo pelas fotos do carrossel no editor |
| F | Nome do evento | interaction_vdstudio |
| G | Parametros | screen_name: /vdstudio · cd_interaction_detail: scroll:carrossel-fotos |
| H | JSON Payload | ver bloco abaixo |
| I | Exemplo de Disparo Parametros | screen_name: /vdstudio · cd_interaction_detail: scroll:carrossel-fotos |

```json
{
  "client_id": "[[identificador-unico-usuario]]",
  "session_id": "[[identificador-unico-sessao]]",
  "events": [{
    "name": "interaction_vdstudio",
    "params": {
      "screen_name": "/vdstudio",
      "cd_interaction_detail": "scroll:carrossel-fotos"
    }
  }]
}
```

**TSV para colar em A37:I37 (proxima linha vazia da amostra A1:I36 — confirmar no sheet antes de gravar):**

```
PLANEJADO	iOS, Android, VDI	Inicio		Quando eu deslizo pelas fotos do carrossel no editor	interaction_vdstudio	screen_name: /vdstudio
cd_interaction_detail: scroll:carrossel-fotos	{"client_id": "[[identificador-unico-usuario]]", "session_id": "[[identificador-unico-sessao]]", "events": [{"name": "interaction_vdstudio", "params": {"screen_name": "/vdstudio", "cd_interaction_detail": "scroll:carrossel-fotos"}}]}	screen_name: /vdstudio
cd_interaction_detail: scroll:carrossel-fotos
```

Posicao da foto continua no `card_shared` (2o segmento). Este hit so mede o gesto no editor. Textos default (todos menos lucratividade e whatsapp) que saltam para a imagem em destaque **nao** geram evento extra.

## Conflitos / harmonizacao

- Guia C&T pede `cd_page_title` em `screen_view`; o Tagbook Agnostico do VD Studio **nao** usa — manter so `screen_name`.
- Guia pede `cd_interaction_detail` em ingles; o Tagbook vigente de textos usa kebab em portugues (`valor-de-revenda`, `nome-do-item`). Novos chips seguem o Tagbook, nao o guia.
- Dicionario de Parametros: `navbar_item` ainda lista `inserir-texto`; atualizar para `editar-texto`. `extra_text` ainda e `none \| whatsapp \| descriçao \| código \| livre` — incluir compra / lucro / lucratividade.
- `screen_name` do modal permanece `/vdstudio/inserir-textos` apesar do rename visual para Editar texto.
- Sem MCP Google Sheets neste ambiente: **nao gravado** na planilha.

## Validacao

1. VDI: tocco em Editar texto → `screen_view` `/vdstudio/inserir-textos` + navbar `click:navbar-editar-texto`. Seleciono Lucro → `click:selecionar-texto-lucro`. Nao dispara `click:navbar-inserir-texto`.
2. App da RE: o menu mostra so 6 chips; Lucro / Valor de compra / Lucratividade **nao** disparam. WhatsApp on/off → `selecionar-texto-whatsapp` / `desativar-texto-whatsapp`.
3. Com a imagem sem textos, o toggle esta desabilitado e **nao** dispara. Com um chip ativo, ligo o toggle → `selecionar-texto-todas-as-opcoes`; desligo e ligo de novo → os textos voltam menos Texto livre; o hit e de novo `todas-as-opcoes` (nao um evento de restore).
4. Swipe no carrossel do editor → `scroll:carrossel-fotos` em `/vdstudio` (nao confundir com o mesmo detail em `/vdstudio/divulgar`). X do painel e seta de voltar nao disparam.

## Dedup

| Trio | Status |
|------|--------|
| `screen_view` + `/vdstudio/inserir-textos` | ja existe (PRD Edicao de Texto) — nao criar |
| `interaction_vdstudio` + `/vdstudio/inserir-textos` + `click:selecionar-texto-*` | ja existe — **ajustar enum**, nao append |
| `interaction_vdstudio` + `/vdstudio` + `click:navbar-*` | ja existe — **trocar** `inserir-texto` por `editar-texto` |
| `interaction_vdstudio` + `/vdstudio` + `click:toggle-textos-*` | ja existe — **depreciar** neste fluxo |
| `interaction_vdstudio` + `/vdstudio` + `scroll:carrossel-fotos` | **nao existe** (o scroll vigente e em `/vdstudio/divulgar`) — unica linha nova |
| `card_shared` + `/vdstudio` | ja existe (Android vs iOS/VDI) — so ampliar lista de textos |

Confirme se quer (1) editar in-place as linhas PRD/DEV acima e (2) append da linha do carrossel. Gravacao no sheet so depois disso e com ferramenta de Sheets.
