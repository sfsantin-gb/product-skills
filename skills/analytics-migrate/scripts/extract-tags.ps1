function Get-NavbarFromCategory {
    param([string]$Category)
    $c = ($Category + "").ToLower()
    if ($c -match 'divulgar|catalogo|conteudo|mld|vdstudio|materiais|novidade|treinamento|noticia') { return 'Divulgar' }
    if ($c -match 'menu|minha-loja|perfil|slug|opt-in|opt_in') { return 'Menu' }
    if ($c -match 'pdp|busca|oferta|vitrine|explorar|produto|marca|favorit|barcode|promoc') { return 'Inicio' }
    if ($c -match 'inicio|home|dash/') { return 'Inicio' }
    return 'Gestao'
}

function Get-TagStem {
    param([string]$FilePath)
    $name = [IO.Path]::GetFileNameWithoutExtension($FilePath)
    return ($name -replace '_impl$', '')
}

function Get-EventCategoryFromContent {
    param([string]$Content)
    if ($Content -match "String get eventCategory\s*=>\s*'([^']+)'") { return $matches[1] }
    if ($Content -match 'String get eventCategory\s*=>\s*"([^"]+)"') { return $matches[1] }
    if ($Content -match "eventCategory'\s*,\s*'([^']+)'") { return $matches[1] }
    return ''
}

function New-LegacyJson {
    param(
        [string]$EventCategory,
        [string]$EventAction,
        [string]$EventLabel,
        [string]$ScreenName = '',
        [string]$CustomEventName = ''
    )

    if ($ScreenName) {
        return (@{ screen_view = @{ screen_name = $ScreenName } } | ConvertTo-Json -Compress -Depth 4)
    }
    if ($CustomEventName) {
        $obj = @{ }
        $obj[$CustomEventName] = @{
            eventCategory = $EventCategory
            eventAction   = $EventAction
            eventLabel    = $EventLabel
        }
        return ($obj | ConvertTo-Json -Compress -Depth 4)
    }
    return (@{ event = @{ eventCategory = $EventCategory; eventAction = $EventAction; eventLabel = $EventLabel } } | ConvertTo-Json -Compress -Depth 4)
}

function Humanize-Method {
    param([string]$MethodName)
    $s = $MethodName -replace '^on', '' -replace '([a-z])([A-Z])', '$1 $2'
    return ($s -replace 'Pressed|Click|Tap', 'toca').ToLower()
}

function Extract-EventsFromTagFile {
    param(
        [Parameter(Mandatory)][string]$FilePath,
        [Parameter(Mandatory)][string]$MegazordRoot
    )

    $content = Get-Content $FilePath -Raw -Encoding UTF8
    $rel = $FilePath.Substring($MegazordRoot.Length).TrimStart('\', '/')
    $category = Get-EventCategoryFromContent $content
    $tagStem = Get-TagStem $FilePath
    $events = @()

    $methodMatches = [regex]::Matches($content, 'Future<[^>]+>\s+(\w+)\s*\([^)]*\)\s*(?:=>|{)')
    $methods = @{}
    foreach ($m in $methodMatches) { $methods[$m.Groups[1].Value] = $true }

    foreach ($mm in [regex]::Matches($content, '(\w+)\s*\([^)]*\)\s*=>\s*sendButtonClickEvent\(\s*''([^'']+)''')) {
        $method = $mm.Groups[1].Value
        $label = $mm.Groups[2].Value
        $events += @{
            method = $method
            action = 'clique:botao'
            label  = $label
            json   = (New-LegacyJson $category 'clique:botao' $label)
            acao   = "Toca no botao identificado como `"$label`""
        }
    }

    foreach ($mm in [regex]::Matches($content, '(\w+)\s*\([^)]*\)\s*=>\s*sendComponentSeeEvent\(\s*''([^'']+)''')) {
        $label = $mm.Groups[2].Value
        $events += @{
            method = $mm.Groups[1].Value
            action = 'view:componente'
            label  = $label
            json   = (New-LegacyJson $category 'view:componente' $label)
            acao   = "Visualiza componente `"$label`""
        }
    }

    foreach ($mm in [regex]::Matches($content, 'setCurrentScreen\(\s*''([^'']+)''\s*\)')) {
        $screen = $mm.Groups[1].Value
        $events += @{
            method = 'setCurrentScreen'
            action = 'screen_view'
            label  = $screen
            json   = (New-LegacyJson '' '' '' $screen)
            acao   = "Exibe tela $screen"
        }
    }

    if ($content -match "String get currentScreenName\s*=>\s*'([^']+)'") {
        $screen = $matches[1]
        $events += @{
            method = 'setCurrentScreen'
            action = 'screen_view'
            label  = $screen
            json   = (New-LegacyJson '' '' '' $screen)
            acao   = "Exibe tela $screen"
        }
    }

    foreach ($mm in [regex]::Matches($content, "sendEvent\(\s*'event',\s*\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}", [System.Text.RegularExpressions.RegexOptions]::Singleline)) {
        $block = $mm.Groups[1].Value
        $ec = if ($block -match "eventCategory'\s*:\s*'([^']+)'") { $matches[1] } else { $category }
        $ea = if ($block -match "eventAction'\s*:\s*'([^']+)'") { $matches[1] } else { '' }
        $el = if ($block -match "eventLabel'\s*:\s*'([^']+)'") { $matches[1] } else { '' }
        if ($ea -or $el) {
            $events += @{
                method = 'sendEvent'
                action = $ea
                label  = $el
                json   = (New-LegacyJson $ec $ea $el)
                acao   = "Acao registrada: $ea / $el"
            }
        }
    }

    foreach ($mm in [regex]::Matches($content, "sendEvent\(\s*'(\w+)',\s*\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}", [System.Text.RegularExpressions.RegexOptions]::Singleline)) {
        $customName = $mm.Groups[1].Value
        if ($customName -eq 'event') { continue }
        $block = $mm.Groups[2].Value
        $ec = if ($block -match "eventCategory'\s*:\s*'([^']+)'") { $matches[1] } else { $category }
        $ea = if ($block -match "eventAction'\s*:\s*'([^']+)'") { $matches[1] } else { '' }
        $el = if ($block -match "eventLabel'\s*:\s*'([^']+)'") { $matches[1] } else { '' }
        $events += @{
            method = "sendEvent:$customName"
            action = $ea
            label  = $el
            json   = (New-LegacyJson $ec $ea $el '' $customName)
            acao   = "Evento custom $customName"
        }
    }

    $constMap = @{}
    foreach ($cm in [regex]::Matches($content, "(?m)(?:static\s+)?const\s+(\w+)\s*=\s*'([^']*)'")) {
        $constMap[$cm.Groups[1].Value] = $cm.Groups[2].Value
    }

    function Resolve-DartExpr([string]$expr) {
        $t = ($expr + '').Trim().TrimEnd(',')
        if ($t -match "^'([^']*)'$") { return $matches[1] }
        if ($t -match '^"([^"]*)"$') { return $matches[1] }
        if ($constMap.ContainsKey($t)) { return $constMap[$t] }
        if ($t -match 'addItemEventLabel|removeItemEventLabel|remindMeEventLabel') { return 'adicionar-item:$product' }
        if ($t -match 'analyticsFormatter|toAnalyticsFormat|toLowerHyphenated') { return '$dynamic' }
        return $t
    }

    $methodAt = @()
    foreach ($m in [regex]::Matches($content, '@override\s+(?:[\w<>,\s\[\]]+\s+)?(\w+)\s*\(')) {
        $methodAt += @{ name = $m.Groups[1].Value; index = $m.Index }
    }
    function Get-EnclosingMethod([int]$idx) {
        $name = 'sendEvent'
        foreach ($mp in $methodAt) {
            if ($mp.index -le $idx) { $name = $mp.name }
        }
        return $name
    }

    $ecomMap = @{
        logViewItemList     = 'view_item_list'
        logViewItem         = 'view_item'
        logSelectItem       = 'select_item'
        logAddToCart        = 'add_to_cart'
        logRemoveFromCart   = 'remove_from_cart'
        logViewPromotion    = 'view_promotion'
        logSelectPromotion  = 'select_promotion'
        logAddToWishlist    = 'add_to_wishlist'
        logSearch           = 'search'
    }
    foreach ($ecomName in ($ecomMap.Keys | Sort-Object { $_.Length } -Descending)) {
        $ga4 = $ecomMap[$ecomName]
        foreach ($mm in [regex]::Matches($content, "analyticsProvider\.$ecomName\s*\(")) {
            $method = Get-EnclosingMethod $mm.Index
            $events += @{
                method = $method
                action = $ga4
                label  = $ga4
                json   = (New-LegacyJson $category $ga4 $ga4 '' $ga4)
                acao   = "ECOM $ga4 ($method)"
            }
        }
    }

    foreach ($mm in [regex]::Matches($content, "sendEvent\(\s*(\w+)\s*,\s*\{([\s\S]*?)\}\s*\)")) {
        $first = $mm.Groups[1].Value
        $block = $mm.Groups[2].Value
        $method = Get-EnclosingMethod $mm.Index
        $customResolved = if ($constMap.ContainsKey($first)) { $constMap[$first] } else { $first }
        $eaExpr = if ($block -match "(?:_eventActionKey|eventActionKey)\s*:\s*([^\n,]+)") { $matches[1] } else { '' }
        $elExpr = if ($block -match "(?:_eventLabelKey|eventLabelKey)\s*:\s*([^\n,]+)") { $matches[1] } else { '' }
        $ecExpr = if ($block -match "(?:_eventCategoryKey|eventCategoryKey)\s*:\s*([^\n,]+)") { $matches[1] } else { '' }
        $ea = Resolve-DartExpr $eaExpr
        $el = Resolve-DartExpr $elExpr
        $ec = Resolve-DartExpr $ecExpr
        if (-not $ec) { $ec = $category }
        if ($first -match 'searchEventName|interactionEvent|SuccessEvent|ErrorEvent' -or ($customResolved -and $customResolved -ne 'event' -and $customResolved -ne '_event')) {
            $events += @{
                method = $method
                action = $ea
                label  = if ($el) { $el } else { $customResolved }
                json   = (New-LegacyJson $ec $ea $el '' $customResolved)
                acao   = "Evento custom $customResolved ($method)"
            }
            continue
        }
        if ($ea -or $el) {
            $events += @{
                method = $method
                action = $ea
                label  = $el
                json   = (New-LegacyJson $ec $ea $el)
                acao   = "Acao registrada: $ea / $el ($method)"
            }
        }
    }

    foreach ($mm in [regex]::Matches($content, 'setCurrentScreen\(\s*([^)]+)\)')) {
        $arg = $mm.Groups[1].Value.Trim()
        $screen = Resolve-DartExpr $arg
        if ([string]::IsNullOrWhiteSpace($screen) -or $screen -eq $arg) {
            if ($arg -match "'([^']+)'") { $screen = $matches[1] }
        }
        if ($screen -and $screen -notmatch "^[\w\.]+$" ) {
            $method = Get-EnclosingMethod $mm.Index
            $events += @{
                method = $method
                action = 'screen_view'
                label  = $screen
                json   = (New-LegacyJson '' '' '' $screen)
                acao   = "Exibe tela $screen"
            }
        }
        elseif ($screen -match '^/') {
            $method = Get-EnclosingMethod $mm.Index
            $events += @{
                method = $method
                action = 'screen_view'
                label  = $screen
                json   = (New-LegacyJson '' '' '' $screen)
                acao   = "Exibe tela $screen"
            }
        }
    }

    $unique = @{}
  $result = foreach ($ev in $events) {
        $key = "$($ev.action)|$($ev.label)|$($ev.json)"
        if ($unique.ContainsKey($key)) { continue }
        $unique[$key] = $true
        $navCat = if ($ev.json -like '*screen_view*') {
            if ($ev.label -match 'divulgar|catalogo|conteudo') { 'Divulgar' } else { Get-NavbarFromCategory $ev.label }
        } else {
            $parsed = $ev.json | ConvertFrom-Json
            $ec = if ($parsed.event) { $parsed.event.eventCategory } else { $category }
            Get-NavbarFromCategory $ec
        }
        [pscustomobject]@{
            navbar   = $navCat
            route    = ''
            desc     = $ev.method
            json     = $ev.json
            tag      = $tagStem
            file     = ($rel -replace '\\', '/')
            method   = $ev.method
            contexto = "Interacao em $($tagStem -replace '_tag$','' -replace '_',' ')"
            acao     = $ev.acao
        }
    }
    return $result
}

function Extract-TagsFromScope {
    param(
        [Parameter(Mandatory)][string]$MegazordRoot,
        [Parameter(Mandatory)][array]$ScopePaths
    )

    $all = @()
    $filesScanned = 0

    foreach ($scope in $ScopePaths) {
        $tagFiles = Get-ChildItem -Path $scope.absolute -Recurse -File -Filter '*_tag*.dart' -ErrorAction SilentlyContinue |
            Where-Object {
                $_.FullName -notmatch '\\test\\' -and
                $_.Name -notmatch '_test\.dart$' -and
                $_.Name -match '_tag(_impl)?\.dart$'
            }

        foreach ($file in $tagFiles) {
            $filesScanned++
            $all += Extract-EventsFromTagFile -FilePath $file.FullName -MegazordRoot $MegazordRoot
        }
    }

    return @{
        events       = $all
        files_scanned = $filesScanned
        event_count  = $all.Count
    }
}
