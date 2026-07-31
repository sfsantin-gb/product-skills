#!/usr/bin/env pwsh
# Fase 0 discover: CODEOWNERS + dominios.md -> inventario legado + bootstrap do pipeline.
[CmdletBinding()]
param(
    [string]$ConfigPath,
    [string]$MegazordRoot,
    [string]$GithubTeam,
    [string]$SquadId,
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$scriptRoot = Split-Path $PSScriptRoot -Parent
$defaultMegazord = (Resolve-Path (Join-Path $scriptRoot '../..')).Path

function Resolve-WorkspacePath {
    param(
        [string]$Root,
        [string]$RelativePath
    )
    if ([string]::IsNullOrWhiteSpace($RelativePath)) { return $null }
    if ([IO.Path]::IsPathRooted($RelativePath)) { return $RelativePath }
    return Join-Path $Root ($RelativePath -replace '/', [IO.Path]::DirectorySeparatorChar)
}
. (Join-Path $PSScriptRoot 'parse-codeowners.ps1')
. (Join-Path $PSScriptRoot 'parse-dominios.ps1')
. (Join-Path $PSScriptRoot 'extract-tags.ps1')
. (Join-Path $PSScriptRoot 'parse-guia-escopo.ps1')

function Read-YamlConfig {
    param([string]$Path)
    if (-not (Test-Path $Path)) { throw "Config nao encontrado: $Path" }
    $raw = Get-Content $Path -Raw -Encoding UTF8

    function Get-YamlValue([string]$key) {
        if ($raw -match "(?m)^\s*$([regex]::Escape($key)):\s*(.+)\s*$") {
            return $matches[1].Trim().Trim('"').Trim("'")
        }
        return $null
    }

    return @{
        squad_id      = Get-YamlValue 'id'
        squad_name    = Get-YamlValue 'name'
        github_team   = Get-YamlValue 'github_team'
        megazord_root = Get-YamlValue 'root'
        codeowners    = Get-YamlValue 'codeowners'
        dominios      = Get-YamlValue 'dominios'
        output_dir    = Get-YamlValue 'output_dir'
        guia_escopo   = Get-YamlValue 'guia_escopo'
        scope_mode    = if ($raw -match 'scope_mode:\s*(\w+)') { $matches[1] } else { 'merge' }
        include_shared = $raw -match 'include_shared:\s*true'
        include_packages = -not ($raw -match 'include_packages:\s*false')
        include_megazord_app = $raw -match 'include_megazord_app:\s*true'
        force         = $raw -match 'force:\s*true'
    }
}

if (-not $ConfigPath) {
    $ConfigPath = Join-Path $scriptRoot 'analytics-migrate.config.yml'
    if (-not (Test-Path $ConfigPath)) {
        $ConfigPath = Join-Path $scriptRoot 'analytics-migrate.config.example.yml'
    }
}

$cfg = Read-YamlConfig $ConfigPath
$megazord = if ($MegazordRoot) {
    $MegazordRoot
} elseif ($cfg.megazord_root -and $cfg.megazord_root -ne '.') {
    $cfg.megazord_root
} else {
    $defaultMegazord
}
$team = if ($GithubTeam) { $GithubTeam } else { $cfg.github_team }
$squad = if ($SquadId) { $SquadId } else { $cfg.squad_id }
$squadName = $cfg.squad_name

if (-not $megazord -or -not (Test-Path $megazord)) { throw "megazord.root invalido: $megazord" }
if (-not $team) { throw "github_team obrigatorio (config ou -GithubTeam)" }
if (-not $squad) { throw "squad.id obrigatorio (config ou -SquadId)" }

$megazord = (Resolve-Path $megazord).Path

$codeownersPath = Join-Path $megazord ($cfg.codeowners -replace '^/', '' -replace '/', [IO.Path]::DirectorySeparatorChar)
$dominiosRel = if ($cfg.dominios) { $cfg.dominios } else { "tools/analytics-migrate/config/dominios-$squad.md" }
$outputRel = if ($cfg.output_dir) { $cfg.output_dir } else { "tools/analytics-migrate/output" }
$dominiosPath = Resolve-WorkspacePath -Root $megazord -RelativePath $dominiosRel
$outputDir = Resolve-WorkspacePath -Root $megazord -RelativePath $outputRel

$squadUpper = $squad.ToUpper()
$jsonOut = Join-Path $outputDir "_tag_extract_$squad.json"
$legacyMd = Join-Path $outputDir "TAGUEAMENTO_LEGADO_$squadUpper.md"
$scopeMd = Join-Path $outputDir "ESCOPO_$squadUpper.md"
$essencialMd = Join-Path $outputDir "EVENTOS_ESSENCIAIS_$squadUpper.md"
$discoverMd = Join-Path $outputDir "DISCOVER_REPORT.md"
$configOut = Join-Path $scriptRoot 'analytics-migrate.config.yml'

Write-Host "=== analytics-migrate discover ===" -ForegroundColor Cyan
Write-Host "Squad: $squad ($team)"
Write-Host "Megazord: $megazord"
Write-Host "Dominios: $dominiosPath"
Write-Host "Output: $outputDir"

$ownerEntries = Parse-Codeowners -CodeownersPath $codeownersPath -GithubTeam $team
$scopeFromOwners = Resolve-ScopePaths -MegazordRoot $megazord -CodeownerEntries $ownerEntries `
    -IncludeShared:($cfg.include_shared) -IncludePackages:($cfg.include_packages) `
    -IncludeMegazordApp:($cfg.include_megazord_app)

$scopePaths = @($scopeFromOwners)
$guiaPath = if ($cfg.guia_escopo) { Resolve-WorkspacePath -Root $megazord -RelativePath $cfg.guia_escopo } else { $null }

if ($guiaPath -and (Test-Path $guiaPath)) {
    $guia = Parse-GuiaEscopo -GuiaPath $guiaPath -MegazordRoot $megazord
    $scopePaths += Resolve-ExplicitMicroapps -MegazordRoot $megazord -MicroappNames $guia.microapps
    Write-Host "GUIA escopo: $($guia.microapps.Count) microapps"
}
elseif ($cfg.scope_mode -eq 'explicit' -and $guiaPath) {
    $guia = Parse-GuiaEscopo -GuiaPath $guiaPath -MegazordRoot $megazord
    $scopePaths = Resolve-ExplicitMicroapps -MegazordRoot $megazord -MicroappNames $guia.microapps
}

$scopePaths = Merge-ScopePaths $scopePaths

Write-Host "Escopos CODEOWNERS: $($scopePaths.Count) pastas"

$extract = Extract-TagsFromScope -MegazordRoot $megazord -ScopePaths $scopePaths
$domains = Parse-DominiosMarkdown -DominiosPath $dominiosPath

Write-Host "Arquivos tag: $($extract.files_scanned)"
Write-Host "Eventos extraidos: $($extract.event_count)"

if ($DryRun) {
    Write-Host "[dry-run] Nenhum arquivo gravado." -ForegroundColor Yellow
    $scopePaths | Format-Table folder_name, scope_type, is_shared -AutoSize
    exit 0
}

if (-not (Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir -Force | Out-Null }

if ((Test-Path $jsonOut) -and -not $Force -and -not $cfg.force) {
    Write-Warning "Arquivo existe: $jsonOut. Use -Force para sobrescrever."
} else {
    $extract.events | ConvertTo-Json -Depth 6 | Set-Content $jsonOut -Encoding UTF8
    Write-Host "Gravado: $jsonOut"
}

$scopeLines = @(
    "# Escopo da squad $squadUpper",
    "",
    "> Gerado em $(Get-Date -Format 'yyyy-MM-dd') por ``discover.ps1``.",
    "> Fonte ownership: ``CODEOWNERS`` + time ``$team``.",
    "",
    "## Resumo",
    "",
    "| Metrica | Valor |",
    "|---------|-------|",
    "| Pastas no escopo | $($scopePaths.Count) |",
    "| Arquivos tag | $($extract.files_scanned) |",
    "| Eventos legado | $($extract.event_count) |",
    "| Dominios PM | $($domains.Count) |",
    "",
    "## Pastas (CODEOWNERS)",
    "",
    "| Pasta | Tipo | Compartilhado | Owners |",
    "|-------|------|---------------|--------|"
)
foreach ($s in $scopePaths) {
    $shared = if ($s.is_shared) { 'sim' } else { 'nao' }
    $scopeLines += "| ``$($s.folder_name)`` | $($s.scope_type) | $shared | $($s.owners) |"
}
$scopeLines += @(
    "",
    "## Proximo passo",
    "",
    "1. PM revisar ``EVENTOS_ESSENCIAIS_$squadUpper.md`` (perguntas norte por dominio)",
    "2. Rodar ``@analytics-migrate --fase navigation``",
    "3. Pipeline completo: ``--fase all``"
)
$scopeLines | Set-Content $scopeMd -Encoding UTF8

$essLines = @(
    "# Eventos essenciais - $squadName",
    "",
    "> Rascunho gerado por discover. **PM deve validar** perguntas norte e KPIs por dominio.",
    "> Dominios fonte: ``$dominiosRel``",
    "",
    "## Como usar",
    "",
    "Preencha a coluna **Eventos essenciais (rascunho)** com o minimo para medir saude da area.",
    "O pipeline de migracao usa este arquivo para decidir ``essencial_p0/p1`` vs ``nao_essencial``.",
    "",
    "| Dominio | Contexto (PM) | Pergunta norte | Eventos essenciais (rascunho) |",
    "|---------|---------------|----------------|------------------------------|"
)
foreach ($d in $domains) {
    $ctx = if ($d.context) { $d.context } else { $d.subdomains }
    $essLines += "| $($d.name) | $ctx | *PM: qual decisao esta area habilita?* | PV + interaction/callback a definir |"
}
if ($domains.Count -eq 0) {
    $essLines += "| *Dominio exemplo* | | RE usa esta area? | screen_view + interaction_* |"
}
$essLines | Set-Content $essencialMd -Encoding UTF8

$legacyLines = @(
    "# Tagueamento legado - $squadName",
    "",
    "> Inventario extraido do megazord. Total: **$($extract.event_count)** eventos.",
    "> JSON: ``_tag_extract_$squad.json``",
    "",
    "| Navbar | Contexto | Acao | JSON | Tag | Arquivo |",
    "|--------|----------|------|------|-----|---------|"
)
foreach ($ev in $extract.events | Select-Object -First 500) {
    $jsonEsc = ($ev.json -replace '\|', '/')
    $legacyLines += "| $($ev.navbar) | $($ev.contexto) | $($ev.acao) | ``$jsonEsc`` | ``$($ev.tag)`` | ``$($ev.file)`` |"
}
if ($extract.events.Count -gt 500) {
    $legacyLines += "| ... | +$($extract.events.Count - 500) eventos | ver JSON | | | |"
}
$legacyLines | Set-Content $legacyMd -Encoding UTF8

$discoverReport = @(
    "# Discover report - $squadName",
    "",
    "Gerado: $(Get-Date -Format 'yyyy-MM-dd HH:mm')",
    "",
    "## Input minimo usado",
    "",
    "- [x] megazord: ``$megazord``",
    "- [x] CODEOWNERS + team ``$team``",
    "- $(if (Test-Path $dominiosPath) { '[x]' } else { '[ ]' }) dominios: ``$dominiosRel``",
    "",
    "## Outputs",
    "",
    "| Artefato | Caminho |",
    "|----------|---------|",
    "| Inventario JSON | ``_tag_extract_$squad.json`` |",
    "| Inventario MD | ``TAGUEAMENTO_LEGADO_$squadUpper.md`` |",
    "| Escopo squad | ``ESCOPO_$squadUpper.md`` |",
    "| Eventos essenciais (rascunho) | ``EVENTOS_ESSENCIAIS_$squadUpper.md`` |",
    "",
    "## Bootstrap concluido",
    "",
    "Proximo comando sugerido:",
    "",
    '```',
    "@analytics-migrate --fase all --export-csv",
    '```',
    "",
    "## Avisos",
    ""
)
$shared = $scopePaths | Where-Object { $_.is_shared }
if ($shared.Count -gt 0) {
    $discoverReport += "- **Microapps compartilhados** ($($shared.Count)): $($shared.folder_name -join ', '). PM pode excluir tags de outros times manualmente ou rodar discover com ``include_shared: false``."
}
if (-not (Test-Path $dominiosPath)) {
    $discoverReport += "- **dominios.md ausente**. Crie ``$dominiosRel`` antes de simplificar/transform."
}
$discoverReport | Set-Content $discoverMd -Encoding UTF8

if (-not (Test-Path $configOut)) {
    Copy-Item $ConfigPath $configOut -Force
    Write-Host "Config criado: $configOut"
}

Write-Host ""
Write-Host "Discover concluido." -ForegroundColor Green
Write-Host "  ESCOPO: $scopeMd"
Write-Host "  LEGADO: $jsonOut ($($extract.event_count) eventos)"
Write-Host "  ESSENCIAIS (rascunho): $essencialMd"
Write-Host "  REPORT: $discoverMd"
