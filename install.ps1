#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Target,
    [string[]]$Skills = @('analytics-migrate'),
    [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path $PSScriptRoot).Path
$targetRoot = (Resolve-Path $Target).Path

function Install-AnalyticsMigrate {
    param([string]$SkillRoot, [string]$Megazord)

    $toolsPath = Join-Path $Megazord 'tools\analytics-migrate'
    $copyDirs = @('agents', 'scripts', 'docs', 'templates', 'config')
    $copyFiles = @(
        'PM_QUICKSTART.md', 'WORKFLOW.md', 'PIPELINE_COMPLETO.md', 'CASE.md',
        'analytics-migrate.config.example.yml', 'README.md'
    )

    if ($WhatIf) {
        Write-Host "[what-if] Materializar em $toolsPath"
    } else {
        if (-not (Test-Path $toolsPath)) {
            New-Item -ItemType Directory -Path $toolsPath -Force | Out-Null
        }
        foreach ($d in @('output')) {
            $p = Join-Path $toolsPath $d
            if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p -Force | Out-Null }
        }
    }

    foreach ($dir in $copyDirs) {
        $source = Join-Path $SkillRoot $dir
        if (-not (Test-Path $source)) { continue }
        $dest = Join-Path $toolsPath $dir
        if ($WhatIf) {
            Write-Host "[what-if] $source -> $dest"
        } else {
            if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
            Copy-Item $source $dest -Recurse -Force
            Write-Host "Copiado: $dest"
        }
    }

    foreach ($file in $copyFiles) {
        $source = Join-Path $SkillRoot $file
        if (-not (Test-Path $source)) { continue }
        $dest = Join-Path $toolsPath $file
        if ($WhatIf) {
            Write-Host "[what-if] $source -> $dest"
        } else {
            Copy-Item $source $dest -Force
            Write-Host "Copiado: $dest"
        }
    }

    $outputReadme = Join-Path $SkillRoot 'output\README.md'
    if (Test-Path $outputReadme) {
        $dest = Join-Path $toolsPath 'output\README.md'
        if (-not $WhatIf) { Copy-Item $outputReadme $dest -Force }
    }

    $skillMd = Join-Path $SkillRoot 'SKILL.md'
    $githubSkillDir = Join-Path $Megazord '.github\skills\analytics-migrate'
    $cursorSkillDir = Join-Path $Megazord '.cursor\skills\analytics-migrate'
    if (Test-Path $skillMd) {
        if ($WhatIf) {
            Write-Host "[what-if] $skillMd -> skills dirs"
        } else {
            foreach ($dir in @($githubSkillDir, $cursorSkillDir)) {
                if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
                Copy-Item $skillMd (Join-Path $dir 'SKILL.md') -Force
            }
            Write-Host "Skill: $cursorSkillDir"
        }
    }

    $agentsSource = Join-Path $SkillRoot 'agents'
    $agentsTarget = Join-Path $Megazord '.github\agents'
    if (Test-Path $agentsSource) {
        Get-ChildItem $agentsSource -Filter 'analytics-*.agent.md' | ForEach-Object {
            $dest = Join-Path $agentsTarget $_.Name
            if ($WhatIf) {
                Write-Host "[what-if] $($_.FullName) -> $dest"
            } else {
                if (-not (Test-Path $agentsTarget)) {
                    New-Item -ItemType Directory -Path $agentsTarget -Force | Out-Null
                }
                Copy-Item $_.FullName $dest -Force
                Write-Host "Copiado: $dest"
            }
        }
    }

    $configExample = Join-Path $toolsPath 'analytics-migrate.config.example.yml'
    $configTarget = Join-Path $toolsPath 'analytics-migrate.config.yml'
    if ((Test-Path $configExample) -and -not (Test-Path $configTarget)) {
        if ($WhatIf) {
            Write-Host "[what-if] criar $configTarget"
        } else {
            Copy-Item $configExample $configTarget -Force
            Write-Host "Config: $configTarget"
        }
    }
}

foreach ($skill in $Skills) {
    $skillPath = Join-Path $repoRoot "skills\$skill"
    if (-not (Test-Path $skillPath)) {
        throw "Skill nao encontrada: $skill (esperado em skills/$skill)"
    }
    switch ($skill) {
        'analytics-migrate' { Install-AnalyticsMigrate -SkillRoot $skillPath -Megazord $targetRoot }
        default { throw "Instalador nao implementado para skill: $skill" }
    }
}

Write-Host ""
Write-Host "Instalacao concluida em $targetRoot" -ForegroundColor Green
if ($Skills -contains 'analytics-migrate') {
    Write-Host "PM: leia tools/analytics-migrate/PM_QUICKSTART.md" -ForegroundColor Cyan
    Write-Host "Cursor: abra somente o megazord e use @analytics-migrate" -ForegroundColor Cyan
}
