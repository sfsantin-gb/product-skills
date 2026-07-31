#!/usr/bin/env pwsh
# Sincroniza skills/analytics-migrate a partir do megazord (maintainers)
param(
    [string]$MegazordRoot = 'C:\megazord_mobile'
)

$ErrorActionPreference = 'Stop'
$src = Join-Path $MegazordRoot 'tools\analytics-migrate'
$dest = Join-Path $PSScriptRoot '.'
if (-not (Test-Path $src)) { throw "Nao encontrado: $src" }

@('agents','scripts','docs','templates','config') | ForEach-Object {
    $d = Join-Path $dest $_
    if (Test-Path $d) { Remove-Item $d -Recurse -Force }
    Copy-Item (Join-Path $src $_) $d -Recurse -Force
}
Copy-Item (Join-Path $src 'skills\analytics-migrate\SKILL.md') (Join-Path $dest 'SKILL.md') -Force
@('PM_QUICKSTART.md','WORKFLOW.md','PIPELINE_COMPLETO.md','CASE.md','analytics-migrate.config.example.yml','README.md') | ForEach-Object {
    Copy-Item (Join-Path $src $_) (Join-Path $dest $_) -Force -ErrorAction SilentlyContinue
}
Write-Host "Sincronizado de $src" -ForegroundColor Green
