function Parse-GuiaEscopo {
    param(
        [Parameter(Mandatory)][string]$GuiaPath,
        [Parameter(Mandatory)][string]$MegazordRoot
    )

    if (-not (Test-Path $GuiaPath)) { return @() }

    $raw = Get-Content $GuiaPath -Raw -Encoding UTF8
    $microapps = [System.Collections.Generic.HashSet[string]]::new()
    $tagFiles = @()

    foreach ($m in [regex]::Matches($raw, 'microapps/([a-z_]+)/[^\s`|]+\.dart')) {
        [void]$microapps.Add($m.Groups[1].Value)
        $rel = $m.Value -replace '^\`+|\`+$', ''
        $full = Join-Path $MegazordRoot ($rel -replace '/', [IO.Path]::DirectorySeparatorChar)
        if (Test-Path $full) { $tagFiles += $full }
    }

    return @{
        microapps  = @($microapps)
        tag_files  = $tagFiles
    }
}

function Resolve-ExplicitMicroapps {
    param(
        [Parameter(Mandatory)][string]$MegazordRoot,
        [Parameter(Mandatory)][string[]]$MicroappNames
    )

    $resolved = @()
    foreach ($name in $MicroappNames) {
        $full = Join-Path $MegazordRoot "microapps\$name"
        if (Test-Path $full) {
            $resolved += [pscustomobject]@{
                path_pattern = "/microapps/$name/"
                absolute     = $full
                scope_type   = 'microapp'
                folder_name  = $name
                is_shared    = $false
                owners       = 'product_scope'
            }
        }
    }
    return $resolved
}

function Merge-ScopePaths {
    param([array]$Paths)

    $seen = @{}
    $merged = @()
    foreach ($p in $Paths) {
        $key = $p.absolute.ToLower()
        if ($seen.ContainsKey($key)) { continue }
        $seen[$key] = $true
        $merged += $p
    }
    return $merged
}
