function Parse-DominiosMarkdown {
    param([Parameter(Mandatory)][string]$DominiosPath)

    if (-not (Test-Path $DominiosPath)) {
        return @()
    }

    $domains = @()
    $current = $null
    $lines = Get-Content $DominiosPath -Encoding UTF8

    foreach ($line in $lines) {
        if ($line -match '^##\s+(.+)$') {
            $name = $matches[1].Trim()
            if ($name -notmatch '^(Documentos|Referencias|Visao)') {
                $current = @{ name = $name; subdomains = [System.Collections.Generic.List[string]]::new(); context = '' }
                $domains += $current
            }
            continue
        }
        if ($line -match '^###\s+(.+)$' -and $current) {
            $current.subdomains.Add($matches[1].Trim())
            continue
        }
        if ($line -match '^\>\s+\*\*Contexto:\*\*\s*(.+)$' -and $current) {
            $current.context = $matches[1].Trim()
        }
    }

    return $domains | ForEach-Object {
        [pscustomobject]@{
            name       = $_.name
            subdomains = ($_.subdomains -join '; ')
            context    = $_.context
        }
    }
}
