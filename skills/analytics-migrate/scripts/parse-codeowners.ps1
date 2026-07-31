function Parse-Codeowners {
    param(
        [Parameter(Mandatory)][string]$CodeownersPath,
        [Parameter(Mandatory)][string]$GithubTeam
    )

    $teamNeedle = "@grupoboticario/$GithubTeam"
    $lines = Get-Content $CodeownersPath -Encoding UTF8
    $entries = @()

    foreach ($line in $lines) {
        $trim = $line.Trim()
        if (-not $trim -or $trim.StartsWith('#')) { continue }
        if ($trim -notlike "*$teamNeedle*") { continue }

        $parts = $trim -split '\s+', 2
        $pathPattern = $parts[0]
        $owners = ($trim -replace [regex]::Escape($pathPattern), '').Trim() -split '\s+' | Where-Object { $_ -like '@*' }

        $isShared = ($owners | Where-Object {
            $_ -ne $teamNeedle -and $_ -notlike '*vd-appre-admin*' -and $_ -notlike '*vd-sellin-estruturante*'
        }).Count -gt 0

        $scopeType = 'other'
        if ($pathPattern -like '/microapps/*') { $scopeType = 'microapp' }
        elseif ($pathPattern -like '/packages/*') { $scopeType = 'package' }
        elseif ($pathPattern -like '/apps/*') { $scopeType = 'app' }

        $folderName = $pathPattern.TrimEnd('/') -replace '^/(microapps|packages|apps/megazord)/', ''

        $entries += [pscustomobject]@{
            path_pattern = $pathPattern
            owners       = ($owners -join ' ')
            is_shared    = $isShared
            scope_type   = $scopeType
            folder_name  = $folderName
        }
    }

    return $entries
}

function Resolve-ScopePaths {
    param(
        [Parameter(Mandatory)][string]$MegazordRoot,
        [Parameter(Mandatory)][array]$CodeownerEntries,
        [bool]$IncludeShared = $true,
        [bool]$IncludePackages = $true,
        [bool]$IncludeMegazordApp = $false
    )

    $resolved = @()
    foreach ($entry in $CodeownerEntries) {
        if (-not $IncludeShared -and $entry.is_shared) { continue }
        if (-not $IncludePackages -and $entry.scope_type -eq 'package') { continue }
        if (-not $IncludeMegazordApp -and $entry.scope_type -eq 'app') { continue }

        $relative = $entry.path_pattern.TrimStart('/').TrimEnd('/')
        $full = Join-Path $MegazordRoot ($relative -replace '/', [IO.Path]::DirectorySeparatorChar)
        if (Test-Path $full) {
            $resolved += [pscustomobject]@{
                path_pattern = $entry.path_pattern
                absolute     = $full
                scope_type   = $entry.scope_type
                folder_name  = $entry.folder_name
                is_shared    = $entry.is_shared
                owners       = $entry.owners
            }
        }
    }
    return $resolved
}
