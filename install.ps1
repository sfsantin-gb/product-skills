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

    Publish-SquadCatalog -CatalogRoot (Split-Path (Split-Path $SkillRoot -Parent) -Parent) -ToolsPath $toolsPath

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

function Publish-SquadCatalog {
    param([string]$CatalogRoot, [string]$ToolsPath)

    $squads = @(
        @{
            Id = 'conteudos-e-trafego'
            Files = @{
                'dominios.md'            = 'config\dominios-ct.md'
                'perguntas-negocio.md'   = 'config\perguntas-negocio-ct.md'
                'EVENTOS_ESSENCIAIS.md'  = 'docs\EVENTOS_ESSENCIAIS_CT.md'
                'GUIA_CONTEXTOS.md'      = 'docs\GUIA_CONTEXTOS_TAGUEAMENTO_CT.md'
                'IMPACTO_MIGRACAO.md'    = 'output\IMPACTO_MIGRACAO.md'
            }
            OutputDest = 'output'
        }
        @{
            Id = 'explorar-produtos'
            Files = @{
                'dominios.md'            = 'config\dominios-explorar-produtos.md'
                'perguntas-negocio.md'   = 'config\perguntas-negocio-explorar-produtos.md'
                'EVENTOS_ESSENCIAIS.md'  = 'docs\EVENTOS_ESSENCIAIS_EXPLORAR-PRODUTOS.md'
                'GUIA_CONTEXTOS.md'      = 'docs\GUIA_CONTEXTOS_TAGUEAMENTO_EXPLORAR_PRODUTOS.md'
                'IMPACTO_MIGRACAO.md'    = 'output-explorar-produtos\IMPACTO_MIGRACAO.md'
            }
            OutputDest = 'output-explorar-produtos'
        }
    )

    foreach ($s in $squads) {
        $docsSrc = Join-Path $CatalogRoot "docs\$($s.Id)"
        $outSrc  = Join-Path $CatalogRoot "outputs\$($s.Id)"
        if (-not (Test-Path $docsSrc)) { continue }

        foreach ($pair in $s.Files.GetEnumerator()) {
            $from = Join-Path $docsSrc $pair.Name
            if (-not (Test-Path $from)) { continue }
            $to = Join-Path $ToolsPath $pair.Value
            $toDir = Split-Path $to -Parent
            if ($WhatIf) {
                Write-Host "[what-if] $($s.Id)/$($pair.Name) -> $to"
            } else {
                if (-not (Test-Path $toDir)) { New-Item -ItemType Directory -Path $toDir -Force | Out-Null }
                Copy-Item $from $to -Force
            }
        }

        if (Test-Path $outSrc) {
            $outDest = Join-Path $ToolsPath $s.OutputDest
            if ($WhatIf) {
                Write-Host "[what-if] outputs/$($s.Id) -> $outDest"
            } else {
                if (-not (Test-Path $outDest)) { New-Item -ItemType Directory -Path $outDest -Force | Out-Null }
                Get-ChildItem $outSrc -File | Where-Object { $_.Name -ne 'README.md' } | ForEach-Object {
                    Copy-Item $_.FullName (Join-Path $outDest $_.Name) -Force
                }
                Write-Host "Squad $($s.Id): docs + outputs -> $outDest"
            }
        }
    }
}

function Install-CursorSkillPack {
    param(
        [string]$SkillRoot,
        [string]$SkillName,
        [string]$TargetRoot
    )

    $dest = Join-Path $TargetRoot ".cursor\skills\$SkillName"
    $copyNames = @('SKILL.md', 'README.md', 'mcp-setup.md', 'templates')

    if ($WhatIf) {
        Write-Host "[what-if] $SkillRoot -> $dest"
        return
    }

    if (-not (Test-Path $dest)) {
        New-Item -ItemType Directory -Path $dest -Force | Out-Null
    }

    foreach ($name in $copyNames) {
        $source = Join-Path $SkillRoot $name
        if (-not (Test-Path $source)) { continue }
        $target = Join-Path $dest $name
        if (Test-Path $source -PathType Container) {
            if (Test-Path $target) { Remove-Item $target -Recurse -Force }
            Copy-Item $source $target -Recurse -Force
        } else {
            Copy-Item $source $target -Force
        }
        Write-Host "Copiado: $target"
    }

    Write-Host "Skill: $dest"
}

foreach ($skill in $Skills) {
    $skillPath = Join-Path $repoRoot "skills\$skill"
    if (-not (Test-Path $skillPath)) {
        throw "Skill nao encontrada: $skill (esperado em skills/$skill)"
    }
    switch ($skill) {
        'analytics-migrate' { Install-AnalyticsMigrate -SkillRoot $skillPath -Megazord $targetRoot }
        'weekly-meetings-digest' {
            Install-CursorSkillPack -SkillRoot $skillPath -SkillName $skill -TargetRoot $targetRoot
        }
        default { throw "Instalador nao implementado para skill: $skill" }
    }
}

Write-Host ""
Write-Host "Instalacao concluida em $targetRoot" -ForegroundColor Green
if ($Skills -contains 'analytics-migrate') {
    Write-Host "PM: quero pesquisar {jornada} — 4 revisoes com 'pronto', depois o CSV" -ForegroundColor Cyan
    Write-Host "Guia: tools/analytics-migrate/PM_QUICKSTART.md" -ForegroundColor Cyan
}
if ($Skills -contains 'weekly-meetings-digest') {
    Write-Host "Cursor: @weekly-meetings-digest (MCP Google Drive autenticado)" -ForegroundColor Cyan
}
