[CmdletBinding()]
param(
    [string]$SourceCsv = '',
    [string]$OutCsv = '',
    [switch]$IncludeManter
)

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
if (-not $SourceCsv) {
    $SourceCsv = Join-Path $repoRoot 'tools\analytics-migrate\output\TAGUEAMENTO_MIGRADO_CT.csv'
}
if (-not $OutCsv) {
    $OutCsv = Join-Path $repoRoot 'tools\analytics-migrate\output\ENTREGA_ENG.csv'
}

. (Join-Path $repoRoot 'tools\analytics-migrate\scripts\legacy-cd-params.ps1')

function Get-ClassificacaoEng($status) {
    switch ([string]$status) {
        'adicionar_pageview' { return 'novo' }
        'migrar' { return 'migrar' }
        'remover' { return 'remover' }
        'revisar' { return 'migrar' }
        'manter' { if ($IncludeManter) { return 'manter' } else { return $null } }
        default { return $null }
    }
}

function ConvertTo-CompactJson($obj) {
    return ($obj | ConvertTo-Json -Compress -Depth 8)
}

function Get-ScreenNameFromJsonNovo($jsonNovo) {
    $events = Get-Ga4EventsFromJsonNovo $jsonNovo
    if (-not $events) { return $null }
    foreach ($ev in $events) {
        if ([string]$ev.name -eq 'screen_view' -and $ev.params -and $ev.params.screen_name) {
            return [string]$ev.params.screen_name
        }
    }
    return $null
}

function Get-EntregaLegacyJson($row) {
    $raw = [string]$row.evento_legado_json
    if ($raw.Trim()) {
        try {
            $parsed = $raw | ConvertFrom-Json
            return (ConvertTo-CompactJson $parsed)
        }
        catch {
            return $raw.Trim()
        }
    }

    $screenName = Get-ScreenNameFromJsonNovo $row.json_novo
    if (-not $screenName -and $row.screen_name_legado) {
        $screenName = [string]$row.screen_name_legado
    }
    if (-not $screenName -and $row.nome_pageview) {
        $screenName = [string]$row.nome_pageview
    }

    $cat = [string]$row.event_category_legado
    $act = [string]$row.event_action_legado
    $lbl = [string]$row.event_label_legado
    if ($cat -or $act -or $lbl) {
        $event = [ordered]@{}
        if ($cat) { $event.eventCategory = $cat }
        if ($act) { $event.eventAction = $act }
        if ($lbl) { $event.eventLabel = $lbl }
        return (ConvertTo-CompactJson ([ordered]@{ event = $event }))
    }

    if ($row.acao_legado) {
        return (ConvertTo-CompactJson ([ordered]@{
            lacuna = [ordered]@{
                sem_evento_legado = $true
                acao_legado       = [string]$row.acao_legado
            }
        }))
    }

    return ''
}

if (-not (Test-Path $SourceCsv)) {
    Write-Error "CSV nao encontrado: $SourceCsv"
}

$rows = Import-Csv $SourceCsv -Encoding UTF8
$out = [System.Collections.Generic.List[object]]::new()

foreach ($row in $rows) {
    $classificacao = Get-ClassificacaoEng $row.status
    if (-not $classificacao) { continue }

    $legacyJson = if ($classificacao -eq 'novo') { '' } else { Get-EntregaLegacyJson $row }
    if ($classificacao -eq 'manter' -and -not $legacyJson) {
        $screenName = Get-ScreenNameFromJsonNovo $row.json_novo
        if ($screenName) {
            $legacyJson = ConvertTo-CompactJson ([ordered]@{
                screen_view = [ordered]@{ screen_name = $screenName }
            })
        }
    }

    $out.Add([pscustomobject]@{
        classificacao      = $classificacao
        arquivo_tag        = $row.arquivo_tag
        evento_legado_json = $legacyJson
        json_novo          = $row.json_novo
    })
}

$outDir = Split-Path $OutCsv -Parent
if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

$out | Export-Csv -Path $OutCsv -NoTypeInformation -Encoding UTF8

$emptyLegacy = @($out | Where-Object { -not $_.evento_legado_json }).Count
$stats = $out | Group-Object classificacao | Sort-Object Name
Write-Host "ENTREGA_ENG: $($out.Count) linhas -> $OutCsv"
Write-Host "  evento_legado_json vazio: $emptyLegacy"
foreach ($g in $stats) {
    Write-Host "  $($g.Name): $($g.Count)"
}
