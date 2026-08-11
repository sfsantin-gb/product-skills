#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [string]$MegazordRoot,
    [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'
$packageRoot = $PSScriptRoot
if (-not $MegazordRoot) {
    $MegazordRoot = (Resolve-Path (Join-Path $packageRoot '../..')).Path
}
$megazord = (Resolve-Path $MegazordRoot).Path

$items = @(
    @{ Source = Join-Path $packageRoot 'agents'; Target = Join-Path $megazord '.github\agents' }
    @{ Source = Join-Path $packageRoot 'skills'; Target = Join-Path $megazord '.github\skills' }
)

foreach ($map in $items) {
    if (-not (Test-Path $map.Source)) { continue }

    Get-ChildItem $map.Source -File -Recurse | ForEach-Object {
        $rel = $_.FullName.Substring($map.Source.Length).TrimStart('\')
        $target = Join-Path $map.Target $rel
        $dir = Split-Path $target -Parent
        if ($WhatIf) {
            Write-Host "[what-if] $($_.FullName) -> $target"
        } else {
            if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
            Copy-Item $_.FullName $target -Force
            Write-Host "Copiado: $target"
        }
    }
}

$githubSkill = Join-Path $megazord '.github\skills\analytics-migrate'
$cursorSkill = Join-Path $megazord '.cursor\skills\analytics-migrate'
if (Test-Path $githubSkill) {
    if ($WhatIf) {
        Write-Host "[what-if] mirror $githubSkill -> $cursorSkill"
    } else {
        if (Test-Path $cursorSkill) { Remove-Item $cursorSkill -Recurse -Force }
        Copy-Item $githubSkill $cursorSkill -Recurse -Force
        Write-Host "Cursor skill: $cursorSkill"
    }
}

foreach ($subdir in @('docs', 'config', 'output', 'templates')) {
    $dir = Join-Path $packageRoot $subdir
    if (-not (Test-Path $dir)) {
        if ($WhatIf) {
            Write-Host "[what-if] mkdir $dir"
        } else {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
}

$configExample = Join-Path $packageRoot 'analytics-migrate.config.example.yml'
$configTarget = Join-Path $packageRoot 'analytics-migrate.config.yml'
if ((Test-Path $configExample) -and -not (Test-Path $configTarget)) {
    if ($WhatIf) {
        Write-Host "[what-if] $configExample -> $configTarget"
    } else {
        Copy-Item $configExample $configTarget -Force
        Write-Host "Config: $configTarget"
    }
}

Write-Host ""
Write-Host "Instalacao analytics-migrate em $megazord" -ForegroundColor Green
Write-Host "PM: leia tools/analytics-migrate/PM_QUICKSTART.md" -ForegroundColor Cyan
Write-Host "Cursor (somente megazord): @analytics-migrate --setup" -ForegroundColor Cyan
