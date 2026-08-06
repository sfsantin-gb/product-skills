#!/usr/bin/env pwsh
# Sincroniza skills/analytics-migrate a partir do megazord (maintainers)
param(
    [string]$MegazordRoot = 'C:\megazord_mobile'
)

$ErrorActionPreference = 'Stop'
$src = Join-Path $MegazordRoot 'tools\analytics-migrate'
$dest = Join-Path $PSScriptRoot '.'
if (-not (Test-Path $src)) { throw "Nao encontrado: $src" }

@('agents', 'scripts', 'docs', 'templates', 'config', 'output') | ForEach-Object {
    $d = Join-Path $dest $_
    if (Test-Path $d) { Remove-Item $d -Recurse -Force }
    $source = Join-Path $src $_
    if (Test-Path $source) {
        Copy-Item $source $d -Recurse -Force
    }
}

Copy-Item (Join-Path $src 'SKILL.md') (Join-Path $dest 'SKILL.md') -Force
@(
    'PM_QUICKSTART.md', 'WORKFLOW.md', 'PIPELINE_COMPLETO.md', 'CASE.md',
    'analytics-migrate.config.example.yml', 'README.md', 'INSTALACAO_SKILLS_CORPORATIVAS.md'
) | ForEach-Object {
    $file = Join-Path $src $_
    if (Test-Path $file) {
        Copy-Item $file (Join-Path $dest $_) -Force
    }
}

Write-Host "Sincronizado de $src" -ForegroundColor Green
