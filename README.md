# product-skills

Catalogo de **Agent Skills de produto** para PMs, TPMs e analistas — estilo Spec Kit: clone + `install.ps1`. Sem Cursor Plugin marketplace.

Repo piloto em conta pessoal; destino futuro: org `grupoboticario/product-skills` (quando houver permissao).

## Instalacao rapida

```powershell
git clone https://github.com/sfsantin-gb/product-skills.git
git clone https://github.com/grupoboticario/megazord_mobile.git C:\megazord_mobile

cd product-skills
powershell -ExecutionPolicy Bypass -File install.ps1 -Target C:\megazord_mobile
```

Abra o Cursor **somente** no megazord → primeira vez:

```text
@analytics-migrate --setup
```

O agente pergunta squad, time GitHub, dominios e perguntas P0/P1; gera o contexto e roda o discover.

## Skills disponiveis

| Skill | Pre-requisito | Uso |
|-------|---------------|-----|
| [analytics-migrate](skills/analytics-migrate/) | megazord_mobile (read) | Migracao tagueamento legado → GA4 (`--setup` para onboarding) |

## Como funciona

1. Clone este repo (catalogo)
2. `install.ps1` copia a skill para o **repo alvo** (megazord)
3. Skills ficam em `.cursor/skills/` e ferramentas em `tools/` no repo alvo
4. Invoca no Cursor: `@analytics-migrate --setup` (primeira vez) ou `@analytics-migrate --fase all --export-csv`

## Manter analytics-migrate atualizado

Fonte de dev: `megazord_mobile/tools/analytics-migrate/`

```powershell
powershell -ExecutionPolicy Bypass -File skills\analytics-migrate\sync-from-megazord.ps1
```

Ver [CONTRIBUTING.md](CONTRIBUTING.md).
