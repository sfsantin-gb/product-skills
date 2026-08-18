#!/usr/bin/env pwsh
# Scaffold do contexto de uma squad para @analytics-migrate --setup
# Uso PM/agente:
#   pwsh tools/analytics-migrate/scripts/setup-squad.ps1 -ListTeams
#   pwsh tools/analytics-migrate/scripts/setup-squad.ps1 -SquadId estoque-vendas -SquadName "Estoque e Vendas" -GithubTeam vd-sellout-estoque-e-vendas
[CmdletBinding()]
param(
    [string]$SquadId,
    [string]$SquadName,
    [string]$GithubTeam,
    [string]$OutputDir,
    [string]$MegazordRoot,
    [switch]$ListTeams,
    [switch]$RunDiscover,
    [switch]$Force,
    [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'
$packageRoot = Split-Path $PSScriptRoot -Parent
if (-not $MegazordRoot) {
    $MegazordRoot = (Resolve-Path (Join-Path $packageRoot '../..')).Path
}
$megazord = (Resolve-Path $MegazordRoot).Path
$codeowners = Join-Path $megazord '.github\CODEOWNERS'
$configDir = Join-Path $packageRoot 'config'
$templatesDir = Join-Path $packageRoot 'templates'
$configPath = Join-Path $packageRoot 'analytics-migrate.config.yml'

function Get-GithubTeamsFromCodeowners {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        throw "CODEOWNERS nao encontrado: $Path"
    }
    $teams = [System.Collections.Generic.HashSet[string]]::new()
    Get-Content $Path -Encoding UTF8 | ForEach-Object {
        $line = $_.Trim()
        if (-not $line -or $line.StartsWith('#')) { return }
        [regex]::Matches($line, '@grupoboticario/([\w-]+)') | ForEach-Object {
            [void]$teams.Add($_.Groups[1].Value)
        }
    }
    return ($teams | Sort-Object)
}

function ConvertTo-SquadSlug {
    param([string]$Value)
    $slug = $Value.Trim().ToLowerInvariant()
    $slug = [regex]::Replace($slug, '[àáâãä]', 'a')
    $slug = [regex]::Replace($slug, '[èéêë]', 'e')
    $slug = [regex]::Replace($slug, '[ìíîï]', 'i')
    $slug = [regex]::Replace($slug, '[òóôõö]', 'o')
    $slug = [regex]::Replace($slug, '[ùúûü]', 'u')
    $slug = [regex]::Replace($slug, '[ç]', 'c')
    $slug = [regex]::Replace($slug, '[^a-z0-9]+', '-')
    $slug = $slug.Trim('-')
    if (-not $slug) { throw 'SquadId invalido' }
    return $slug
}

if ($ListTeams) {
    Write-Host "Times encontrados no CODEOWNERS:" -ForegroundColor Cyan
    Get-GithubTeamsFromCodeowners -Path $codeowners | ForEach-Object { Write-Host "  - $_" }
    Write-Host ""
    Write-Host "Peca ao eng do time para te adicionar ao time GitHub da squad na org grupoboticario." -ForegroundColor Yellow
    return
}

if (-not $SquadName) { throw 'Informe -SquadName (ex.: "Estoque e Vendas")' }
if (-not $GithubTeam) { throw 'Informe -GithubTeam (use -ListTeams para ver opcoes)' }
if (-not $SquadId) { $SquadId = ConvertTo-SquadSlug $SquadName }
else { $SquadId = ConvertTo-SquadSlug $SquadId }

$knownTeams = Get-GithubTeamsFromCodeowners -Path $codeowners
if ($knownTeams -notcontains $GithubTeam) {
    Write-Warning "Time '$GithubTeam' nao aparece no CODEOWNERS. Escopo do discover pode ficar vazio. Confirme com o eng."
}

if (-not $OutputDir) {
    $OutputDir = "tools/analytics-migrate/output"
}

$dominiosRel = "tools/analytics-migrate/config/dominios-$SquadId.md"
$perguntasRel = "tools/analytics-migrate/config/perguntas-negocio-$SquadId.md"
$dominiosPath = Join-Path $megazord ($dominiosRel -replace '/', [IO.Path]::DirectorySeparatorChar)
$perguntasPath = Join-Path $megazord ($perguntasRel -replace '/', [IO.Path]::DirectorySeparatorChar)

$dominiosTemplate = Join-Path $templatesDir 'dominios-squad.template.md'
$perguntasTemplate = Join-Path $templatesDir 'perguntas-negocio-squad.template.md'
if (-not (Test-Path $dominiosTemplate)) { throw "Template ausente: $dominiosTemplate" }
if (-not (Test-Path $perguntasTemplate)) { throw "Template ausente: $perguntasTemplate" }

function Write-ScaffoldFile {
    param(
        [string]$TemplatePath,
        [string]$DestPath,
        [string]$Name
    )
    $content = Get-Content $TemplatePath -Raw -Encoding UTF8
    $content = $content -replace '\{Nome da Squad\}', $Name
    $content = $content -replace '\{squad\}', $script:SquadId
    $dir = Split-Path $DestPath -Parent
    if ($WhatIf) {
        Write-Host "[what-if] escrever $DestPath"
        return
    }
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    if ((Test-Path $DestPath) -and -not $Force) {
        Write-Host "Mantido (ja existe): $DestPath" -ForegroundColor Yellow
        Write-Host "  Use -Force para sobrescrever com o template." -ForegroundColor Yellow
        return
    }
    Set-Content -Path $DestPath -Value $content -Encoding UTF8
    Write-Host "Criado: $DestPath" -ForegroundColor Green
}

Write-ScaffoldFile -TemplatePath $dominiosTemplate -DestPath $dominiosPath -Name $SquadName
Write-ScaffoldFile -TemplatePath $perguntasTemplate -DestPath $perguntasPath -Name $SquadName

$configYaml = @"
# Gerado por setup-squad.ps1 — contexto da squad $SquadName
# PM: complete dominios + perguntas, depois rode discover / @analytics-migrate

squad:
  id: $SquadId
  name: "$SquadName"
  github_team: $GithubTeam

megazord:
  root: .
  codeowners: .github/CODEOWNERS

workspace:
  dominios: $dominiosRel
  perguntas_negocio: $perguntasRel
  output_dir: $OutputDir

discover:
  scope_mode: merge
  include_shared: true
  include_packages: true
  include_megazord_app: false
  force: false
"@

if ($WhatIf) {
    Write-Host "[what-if] escrever $configPath"
} else {
    if ((Test-Path $configPath) -and -not $Force) {
        $bak = "$configPath.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item $configPath $bak -Force
        Write-Host "Backup do config anterior: $bak" -ForegroundColor Yellow
    }
    Set-Content -Path $configPath -Value $configYaml -Encoding UTF8
    Write-Host "Config ativo: $configPath" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Setup scaffold concluido ===" -ForegroundColor Cyan
Write-Host "Squad: $SquadName ($SquadId)"
Write-Host "GitHub team: $GithubTeam"
Write-Host "Dominios: $dominiosRel"
Write-Host "Perguntas: $perguntasRel"
Write-Host ""
Write-Host "Proximos passos:" -ForegroundColor Cyan
Write-Host "1. Gate 1: preencher dominios e dizer **pronto**"
Write-Host "2. Gates 2-4: perguntas → essenciais → IMPACTO_MIGRACAO.md (um por vez)"
Write-Host "3. So depois: TAGUEAMENTO_MIGRADO CSV + ENTREGA_ENG.csv"

if ($RunDiscover) {
    $discover = Join-Path $PSScriptRoot 'discover.ps1'
    Write-Host ""
    Write-Host "Rodando discover..." -ForegroundColor Cyan
    if ($WhatIf) {
        & $discover -ConfigPath $configPath -DryRun
    } else {
        & $discover -ConfigPath $configPath -Force:$Force
    }
}
