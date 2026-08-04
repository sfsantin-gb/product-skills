function Parse-PerguntasNegocioMarkdown {
    param([Parameter(Mandatory)][string]$PerguntasPath)

    if (-not (Test-Path $PerguntasPath)) {
        return @()
    }

    $rows = [System.Collections.Generic.List[object]]::new()
    $currentDomain = ''
    $lines = Get-Content $PerguntasPath -Encoding UTF8
    $inTable = $false

    foreach ($line in $lines) {
        if ($line -match '^##\s+(.+)$') {
            $name = $Matches[1].Trim()
            if ($name -notmatch '^(Como preencher|Checklist|Documentos)') {
                $currentDomain = $name
                $inTable = $false
            }
            continue
        }

        if ($line -match '^\|\s*Prioridade\s*\|') {
            $inTable = $true
            continue
        }

        if ($inTable -and $line -match '^\|\s*[-:]') {
            continue
        }

        if ($inTable -and $line -match '^\|\s*(P[012])\s*\|\s*(.+?)\s*\|\s*(.+?)\s*\|\s*$') {
            $rows.Add([pscustomobject]@{
                dominio   = $currentDomain
                prioridade = $Matches[1].Trim()
                pergunta  = $Matches[2].Trim()
                indicador = $Matches[3].Trim()
            })
            continue
        }

        if ($inTable -and $line -notmatch '^\|') {
            $inTable = $false
        }
    }

    return @($rows)
}
