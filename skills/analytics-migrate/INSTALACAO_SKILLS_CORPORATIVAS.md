# Instalacao — Skill `analytics-migrate`

Guia para **consumir** a skill ADTM. Duas formas equivalentes:

| Canal | Quando usar |
|-------|-------------|
| **[product-skills](https://github.com/sfsantin-gb/product-skills)** (recomendado) | Compartilhar link do catalogo de produto; clone + `install.ps1` (estilo Spec Kit) |
| **megazord local** | Pacote ja em `tools/analytics-migrate/` no clone — `install-agents.ps1` |

Em ambos os casos: **megazord_mobile read e obrigatorio**.

> **Nota:** `plat-eng-stgb-skills` e catalogo de **engenharia** (Sonar, New Relic, etc.). Skills de produto ficam em `product-skills`.

---

## Instalacao via product-skills (recomendado)

### 1. Clonar catalogo + megazord

```powershell
git clone https://github.com/sfsantin-gb/product-skills.git
git clone https://github.com/grupoboticario/megazord_mobile.git C:\megazord_mobile
```

### 2. Instalar no megazord

```powershell
cd product-skills
powershell -ExecutionPolicy Bypass -File install.ps1 -Target C:\megazord_mobile
```

Isso cria `tools/analytics-migrate/` e copia agentes para `.github/` + `.cursor/skills/`.

### 3. Configurar squad

```powershell
cd C:\megazord_mobile
copy tools\analytics-migrate\analytics-migrate.config.example.yml tools\analytics-migrate\analytics-migrate.config.yml
```

PM preenche `config/dominios-{squad}.md` (template em `templates/`).

### 4. Rodar

Abrir Cursor **somente** no megazord:

```
@analytics-migrate --fase discover
@analytics-migrate --fase all --export-csv
@analytics-migrate --aprovar
```

Guia PM: [`PM_QUICKSTART.md`](PM_QUICKSTART.md)

---

## Instalacao local (Spec Kit — sem product-skills)

Se o pacote ja estiver em `tools/analytics-migrate/` no clone:

```powershell
cd C:\megazord_mobile
powershell -ExecutionPolicy Bypass -File tools\analytics-migrate\install-agents.ps1
```

---

## Quem pode usar

| Requisito | Detalhe |
|-----------|---------|
| Acesso Git **read** ao `megazord_mobile` | PM nao edita Dart, mas pipeline le o codigo |
| Cursor | `@analytics-migrate` |
| Papel | PM, TPM, analista ou dev |

**Nao precisa:** Product OS, merge aprovado no megazord, Cursor Plugin marketplace.

---

## Publicar / atualizar no catalogo

Maintainers C&T:

1. Evoluir em `megazord_mobile/tools/analytics-migrate/`
2. Sincronizar para product-skills:

```powershell
powershell -ExecutionPolicy Bypass -File C:\product-skills\skills\analytics-migrate\sync-from-megazord.ps1
```

3. Commit + push em [sfsantin-gb/product-skills](https://github.com/sfsantin-gb/product-skills)

---

## Compartilhar com outra squad (Slack)

```
Skill @analytics-migrate — migracao tagueamento UA → GA4

git clone https://github.com/sfsantin-gb/product-skills
git clone megazord_mobile
cd product-skills && install.ps1 -Target C:\megazord_mobile

Cursor so no megazord → @analytics-migrate --fase all --export-csv
Pre-requisito: acesso read ao megazord
```

---

## Troubleshooting

| Problema | Solucao |
|----------|---------|
| `@analytics-migrate` nao aparece | Rodar `install.ps1` ou `install-agents.ps1` de novo |
| Discover 0 eventos | Conferir `squad.github_team` no CODEOWNERS |
| Agente sem evidencia | Abrir workspace so megazord; `git pull` |
| PM sem acesso Git | Dev roda pipeline e envia `output/*.md` |

---

## Product OS (legado)

Artefatos em `produto/.../migracao-tagueamento/` sao snapshot historico. Fonte atual: megazord + **product-skills**.
