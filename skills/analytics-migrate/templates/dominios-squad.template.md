# Dominios — {Nome da Squad}

> Mapeamento dos dominios e subdominios do time, com contextos de responsabilidade.
> **Gate 1.** O agente preenche este arquivo e **para**. PM revisa (entra/sai) e diz **pronto**.

**Documentos relacionados:**

- Config: `tools/analytics-migrate/analytics-migrate.config.yml` (megazord)
- PM Quickstart: [PM_QUICKSTART.md](../PM_QUICKSTART.md)
- Sitemap (se existir): `{caminho/SITEMAP_SQUAD.md}`

---

## {Dominio 1 — ex.: Divulgacao MLD}

### {Subdominio — ex.: Catalogo digital}
> **Contexto:** {O que a RE faz neste fluxo e por que o evento importa para produto/analytics.}

### {Subdominio — ex.: Materiais de divulgacao}
> **Contexto:** {Descricao curta.}

---

## {Dominio 2 — ex.: Vendas sellout}

### {Subdominio — ex.: Gestao de vendas}
> **Contexto:** {Descricao curta.}

### {Subdominio — ex.: Cobranca}
> **Contexto:** {Descricao curta.}

---

## Convencoes

| Nivel | Markdown | Uso |
|-------|----------|-----|
| Dominio | `## Titulo` | Agrupa area de produto (vira linha em EVENTOS_ESSENCIAIS) |
| Subdominio | `### Titulo` | Fluxo/tela dentro do dominio |
| Contexto | `> **Contexto:**` | Obrigatorio — explica relevancia para P0/P1 |

Opcional em contexto:

```markdown
> **Caminhos:**
> * Menu > Gestao > Gerenciar vendas
> * Hub Gestao > Adicionar venda
```

## Checklist PM (gate 1)

- [ ] Cada `##` representa um dominio real do time (nao generico)
- [ ] Cada `###` mapeia para fluxo reconhecivel no app
- [ ] Todo subdominio tem bloco `> **Contexto:**`
- [ ] Dizer **pronto** para o agente gerar as perguntas de negocio
- [ ] `analytics-migrate.config.yml` aponta para este arquivo em `workspace.dominios`
