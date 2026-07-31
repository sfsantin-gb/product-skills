# Contribuindo — product-skills

Skills de produto para Cursor. Processo simples — sem plugin marketplace.

## Nova skill

1. Criar pasta `skills/<nome-kebab>/`
2. Incluir: `SKILL.md`, README da skill, docs necessarios
3. Registrar instalacao em `install.ps1` (switch por skill)
4. PR em portugues com 2-3 cenarios de teste manual

## Padroes

- Nome da skill em ingles kebab-case (`analytics-migrate`)
- Documentacao PM em portugues
- Pre-requisitos explicitos (ex.: acesso read a um repo)
- Acoes destrutivas exigem confirmacao ou gate PM (`--aprovar`)
- Nunca commitar secrets, tokens ou `.env`

## Atualizar analytics-migrate

Fonte de desenvolvimento: `megazord_mobile/tools/analytics-migrate/`

```powershell
powershell -ExecutionPolicy Bypass -File skills\analytics-migrate\sync-from-megazord.ps1
```
