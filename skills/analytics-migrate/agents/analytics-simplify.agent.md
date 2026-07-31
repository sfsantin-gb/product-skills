---
name: analytics-simplify
description: Classifica eventos C&T por prioridade P0/P1/P2 e recomenda manter, fundir ou remover por jornada e dominio.
handoffs:
  - label: Gerar inventario migrado
    agent: analytics-transform
    prompt: Aplique REGRAS_FORMATO_NOVO e decisoes de simplificacao no TAGUEAMENTO_MIGRADO_CT.md.
---

## User Input

```text
$ARGUMENTS
```

## Outline

**Artefato principal (leitura humana):**
`tools/analytics-migrate/output/SIMPLIFICACAO_JORNADAS.md`

Nao ha export CSV para esta fase — markdown e o unico artefato.

### 1. Leitura obrigatoria

0. `EVENTOS_ESSENCIAIS_CT.md` - perguntas norte e KPIs por area

1. `dominios-c&t.md`
2. `TAGUEAMENTO_LEGADO_CT.csv`
3. `NAVEGACAO_AUDITORIA.md` e `COBERTURA_AUDITORIA.md` (preferir) ou `.csv` (fallback)
4. `REGRAS_FORMATO_NOVO.md` - secao 5
5. Template: `templates/SIMPLIFICACAO_JORNADAS.template.md`

### 2. Agrupamento

Agrupe por:

- Dominio C&T (Divulgar, Gestao clientes, Vendas, Estoque, etc.)
- `eventCategory` legado
- Navbar (Inicio, Divulgar, Gestao, Menu)

### 3. Classificacao

| Prioridade | Criterios |
|------------|-----------|
| **P0** | Evento listado em EVENTOS_ESSENCIAIS_CT.md (share, callback, PV, funil core) |
| **P1** | Diagnostico periodico, modais de confirmacao relevantes |
| **P2** | Fora do mapa essencial; scroll/tooltip; modal granular (fundir_pai); hub duplica PV |

### 4. Recomendacao por grupo

`manter` | `fundir` | `remover` | `revisar_pm`

Gestao concentra ~400 eventos - priorizar consolidacao de `eventCategory` profundos (`...:modal:...`).

### 5. Formato do markdown (obrigatorio)

1. **Resumo por dominio** — tabela com contagem P0/P1/P2 e recomendacao dominante
2. **Secao por dominio** — tabela `eventCategory` × prioridade × recomendacao × justificativa
3. Subsecoes **candidatos a fundir** e **candidatos a remover (P2)**
4. Referenciar decisoes ja tomadas em `MIGRACAO_DECISOES.md` e auditorias de navegacao
5. **Legenda** de prioridades

Evite listar 400 linhas individuais — agregar por `eventCategory` ou grupo semantico.
