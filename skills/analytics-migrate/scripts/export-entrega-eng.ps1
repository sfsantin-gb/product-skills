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

if (-not (Test-Path $SourceCsv)) {
    Write-Error "CSV nao encontrado: $SourceCsv"
}

$rows = Import-Csv $SourceCsv -Encoding UTF8
$out = [System.Collections.Generic.List[object]]::new()

foreach ($row in $rows) {
    $classificacao = Get-ClassificacaoEng $row.status
    if (-not $classificacao) { continue }

    $out.Add([pscustomobject]@{
        classificacao       = $classificacao
        arquivo_tag         = $row.arquivo_tag
        dominio_ct          = $row.dominio_ct
        evento_legado_json  = $row.evento_legado_json
        json_novo           = $row.json_novo
        cd_interaction_detail = $row.cd_interaction_detail
        nome_pageview       = $row.nome_pageview
        interaction_group   = $row.interaction_group
        status_pipeline     = $row.status
        contexto_legado     = $row.contexto_legado
        notas               = $row.notas
    })
}

$outDir = Split-Path $OutCsv -Parent
if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

$out | Export-Csv -Path $OutCsv -NoTypeInformation -Encoding UTF8

$stats = $out | Group-Object classificacao | Sort-Object Name
Write-Host "ENTREGA_ENG: $($out.Count) linhas -> $OutCsv"
foreach ($g in $stats) {
    Write-Host "  $($g.Name): $($g.Count)"
}
