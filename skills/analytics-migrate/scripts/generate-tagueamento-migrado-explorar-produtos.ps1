#Requires -Version 5.1
# De-para da jornada Explorar Produtos (oraculo). ECOM no funil de compra.
[CmdletBinding()]
param(
    [string]$OutDir = ''
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
if (-not $OutDir) {
    $OutDir = Join-Path $repoRoot 'tools\analytics-migrate\output-explorar-produtos'
}

$extractPath = Join-Path $OutDir '_tag_extract_explorar-produtos.json'
$outCsv = Join-Path $OutDir 'TAGUEAMENTO_MIGRADO_EXPLORAR-PRODUTOS.csv'
$outMd = Join-Path $OutDir 'TAGUEAMENTO_MIGRADO_EXPLORAR-PRODUTOS.md'
$navCsv = Join-Path $OutDir 'NAVEGACAO_AUDITORIA.csv'
$navMd = Join-Path $OutDir 'NAVEGACAO_AUDITORIA.md'
$covCsv = Join-Path $OutDir 'COBERTURA_AUDITORIA.csv'
$covMd = Join-Path $OutDir 'COBERTURA_AUDITORIA.md'
$cbCsv = Join-Path $OutDir 'CALLBACKS_MIGRACAO.csv'
$cbMd = Join-Path $OutDir 'CALLBACKS_MIGRACAO.md'
$simpMd = Join-Path $OutDir 'SIMPLIFICACAO_JORNADAS.md'

function Escape-CsvField([string]$s) {
    if ($null -eq $s) { return '' }
    $t = [string]$s
    if ($t -match '[,"\r\n]') { return '"' + ($t.Replace('"', '""')) + '"' }
    return $t
}

function Compact-Json($obj) {
    return ($obj | ConvertTo-Json -Compress -Depth 12)
}

function New-Envelope([string]$name, [hashtable]$params) {
    if (-not $params) { $params = @{} }
    $orderedParams = [ordered]@{}
    foreach ($k in ($params.Keys | Sort-Object)) { $orderedParams[$k] = $params[$k] }
    return Compact-Json ([ordered]@{
            client_id  = '[[identificador-unico-usuario]]'
            session_id = '[[identificador-unico-sessao]]'
            events     = @([ordered]@{ name = $name; params = $orderedParams })
        })
}

function New-EcomItem([object]$quantity = 1) {
    return [ordered]@{
        item_id     = '$sku'
        item_name   = '$itemName'
        item_brand  = '$brand'
        price       = '$price'
        quantity    = $quantity
    }
}

function Build-EcomJsonNovo([string]$eventName) {
    $item = New-EcomItem 1
    switch ($eventName) {
        'view_item_list' {
            return New-Envelope 'view_item_list' @{
                currency       = 'BRL'
                item_list_id   = '$itemListId'
                item_list_name = '$itemListName'
                items          = @($item)
            }
        }
        'select_item' {
            return New-Envelope 'select_item' @{
                item_list_id   = '$itemListId'
                item_list_name = '$itemListName'
                items          = @($item)
            }
        }
        'view_item' {
            return New-Envelope 'view_item' @{
                currency       = 'BRL'
                value          = '$value'
                item_list_name = '$itemListName'
                items          = @($item)
            }
        }
        'add_to_cart' {
            return New-Envelope 'add_to_cart' @{
                currency       = 'BRL'
                value          = '$value'
                item_list_name = '$itemListName'
                items          = @(New-EcomItem '$quantity')
            }
        }
        'remove_from_cart' {
            return New-Envelope 'remove_from_cart' @{
                currency       = 'BRL'
                value          = '$value'
                item_list_name = '$itemListName'
                items          = @(New-EcomItem '$quantity')
            }
        }
        'add_to_wishlist' {
            return New-Envelope 'add_to_wishlist' @{
                currency       = 'BRL'
                value          = '$value'
                item_list_name = '$itemListName'
                items          = @($item)
            }
        }
        'remove_from_wishlist' {
            return New-Envelope 'remove_from_wishlist' @{
                currency       = 'BRL'
                value          = '$value'
                item_list_name = '$itemListName'
                items          = @($item)
            }
        }
        'view_promotion' {
            return New-Envelope 'view_promotion' @{
                creative_name  = '$creativeName'
                creative_slot  = '$creativeSlot'
                promotion_id   = '$promotionId'
                promotion_name = '$promotionName'
            }
        }
        'select_promotion' {
            return New-Envelope 'select_promotion' @{
                creative_name  = '$creativeName'
                creative_slot  = '$creativeSlot'
                promotion_id   = '$promotionId'
                promotion_name = '$promotionName'
            }
        }
        'search' {
            return New-Envelope 'search' @{ search_term = '$searchTerm' }
        }
        default { return '' }
    }
}

function Get-Slug([string]$raw) {
    if ([string]::IsNullOrWhiteSpace($raw)) { return 'revisar-pm' }
    $s = $raw.ToLowerInvariant()
    $s = [regex]::Replace($s, '[\$\{\}\(\)]', '')
    $s = [regex]::Replace($s, '[^a-z0-9:-]+', '-')
    $s = $s.Trim('-')
    if (-not $s -or $s -eq 'unknown' -or $s -eq 'dynamic') { return 'revisar-pm' }
    if ($s.Length -gt 80) { $s = $s.Substring(0, 80) }
    return $s
}

function Get-Dominio([string]$tag, [string]$file, [string]$category) {
    $blob = ('{0}|{1}|{2}' -f $tag, $file, $category).ToLowerInvariant()
    if ($blob -match 'showcase|prismic|landing') { return 'Landing pages (Prismic)' }
    if ($blob -match 'search_tag|filter_search|filter_tutorial|search_category|medium_card_search|section_in_search') { return 'Busca' }
    if ($blob -match 'product_details|remind_me|stock_status') { return 'PDP (detalhe do produto)' }
    if ($blob -match 'products_list|order_tag') { return 'Lista de produtos (PLP)' }
    if ($blob -match 'exclusive_offers|extra_profit') { return 'Promocoes e ofertas' }
    if ($blob -match 'favorites') { return 'Favoritos' }
    if ($blob -match 'section_|banners') { return 'Vitrines home e banners' }
    return 'Disponibilidade e utilitarios'
}

function Parse-Legacy($json) {
    $result = [pscustomobject]@{ kind = 'event'; category = ''; action = ''; label = ''; screen_name = ''; custom = '' }
    if (-not $json) { return $result }
    try { $o = $json | ConvertFrom-Json } catch { return $result }
    if ($o.screen_view) {
        $result.kind = 'screen_view'
        $result.screen_name = [string]$o.screen_view.screen_name
        return $result
    }
    if ($o.event) {
        $result.category = [string]$o.event.eventCategory
        $result.action = [string]$o.event.eventAction
        $result.label = [string]$o.event.eventLabel
        return $result
    }
    $props = @($o.PSObject.Properties.Name)
    if ($props.Count -ge 1) {
        $root = $props[0]
        $result.custom = $root
        $inner = $o.$root
        if ($inner.screen_name) {
            $result.kind = 'screen_view'
            $result.screen_name = [string]$inner.screen_name
        }
        else {
            $result.kind = 'custom'
            if ($inner.eventCategory) { $result.category = [string]$inner.eventCategory }
            if ($inner.eventAction) { $result.action = [string]$inner.eventAction }
            if ($inner.eventLabel) { $result.label = [string]$inner.eventLabel }
        }
    }
    return $result
}

$extractAll = Get-Content $extractPath -Raw -Encoding UTF8 | ConvertFrom-Json
$foraEscopo = 'share_product|barcode|brand_journey|recommendation_tag|top_ten'
$oraculo = @($extractAll | Where-Object { $_.file -match 'microapps/oraculo/' })
$extract = @($oraculo | Where-Object { $_.tag -notmatch $foraEscopo -and $_.file -notmatch $foraEscopo })
Write-Host ("Inventario oraculo: {0} (jarvis: {1}; fora dominio: {2})" -f $extract.Count, ($extractAll.Count - $oraculo.Count), ($oraculo.Count - $extract.Count))

$ecomAlready = @('view_item', 'view_item_list', 'select_item', 'search', 'add_to_wishlist', 'remove_from_wishlist', 'view_promotion', 'select_promotion', 'add_to_cart', 'remove_from_cart')
$rows = New-Object System.Collections.Generic.List[object]
$navRows = New-Object System.Collections.Generic.List[object]
$covRows = New-Object System.Collections.Generic.List[object]
$cbRows = New-Object System.Collections.Generic.List[object]

foreach ($ev in $extract) {
    $parsed = Parse-Legacy $ev.json
    $tag = [string]$ev.tag
    $method = [string]$ev.method
    $file = [string]$ev.file
    $navbar = if ($ev.navbar) { [string]$ev.navbar } else { 'Inicio' }
    if ($navbar -eq 'Gestao') { $navbar = 'Inicio' }
    $dominio = Get-Dominio $tag $file $parsed.category
    $label = [string]$parsed.label
    $action = [string]$parsed.action
    $blob = ('{0}|{1}|{2}|{3}' -f $method, $label, $action, $parsed.custom).ToLowerInvariant()

    $status = 'migrar'
    $criterio = 'essencial_p1'
    $prioridade = 'P1'
    $tipo = 'interaction'
    $group = 'interaction_explorar'
    $detail = ''
    $jsonNovo = ''
    $notas = ''
    $nomePv = ''
    $screenLegado = ''
    $navVeredito = ''
    $cbName = ''

    $brokenPv = $parsed.kind -eq 'screen_view' -and $parsed.screen_name -match '\$|_appRev| as String|\('

    if ($parsed.kind -eq 'screen_view' -and -not $brokenPv) {
        $tipo = 'screen_view'
        $status = 'manter'
        $criterio = 'pageview_ok'
        $prioridade = 'P0'
        $group = ''
        $screenLegado = $parsed.screen_name
        $nomePv = $parsed.screen_name
        $leaf = ($parsed.screen_name -split '/')[-1]
        $jsonNovo = New-Envelope 'screen_view' @{ screen_name = $parsed.screen_name; cd_page_title = $leaf }
        $notas = 'Pageview existente - manter'
    }
    elseif ($brokenPv) {
        $tipo = 'screen_view'
        $status = 'adicionar_pageview'
        $criterio = 'lacuna_pageview'
        $prioridade = 'P0'
        $group = ''
        $proposed = switch -Regex ("$tag|$blob") {
            'exclusive' { '/app-rev/{origin}/categoria/ofertas-exclusivas' }
            'remind' { '/app-rev/avise-me/{flow}' }
            'favorit' { '/app-rev/busca/favoritos' }
            'order' { '/app-rev/lista/ordenar' }
            'brand|line' { '/app-rev/marca/{line}' }
            'banner' { '/app-rev/inicio/banner' }
            'section_tag' { '/app-rev/inicio/secao' }
            default { '/app-rev/explorar/{tela}' }
        }
        $nomePv = $proposed
        $jsonNovo = New-Envelope 'screen_view' @{ screen_name = $proposed; cd_page_title = ($proposed -split '/')[-1] }
        $notas = "PV com interpolacao no extrator ('$($parsed.screen_name)') - propor $proposed"
        $covRows.Add([pscustomobject]@{
                navbar                  = $navbar
                evento_legado_json      = $ev.json
                arquivo_tag             = $file
                acao_proposta           = 'adicionar_pageview'
                destino_rota_esperada   = $proposed
                tem_pageview            = 'nao'
                fonte_pageview          = 'nenhuma'
                lacuna                  = 'sim'
                recomendacao            = "Implementar setCurrentScreen $proposed"
                veredito                = 'substituir'
            }) | Out-Null
    }
    elseif ($ecomAlready -contains $parsed.custom) {
        $tipo = 'ecommerce'
        $status = 'manter'
        $criterio = 'essencial_p0'
        $prioridade = 'P0'
        $group = ''
        $jsonNovo = Build-EcomJsonNovo $parsed.custom
        $notas = "Ja dispara GA4 $($parsed.custom) no codigo - manter contrato ECOM"
    }
    elseif ($blob -match 'interacao:scroll|sectionScroll|brandCarouselScroll') {
        $tipo = 'interaction'
        $status = 'remover'
        $criterio = 'anti_padrao'
        $prioridade = 'P2'
        $jsonNovo = ''
        $notas = 'Scroll de carrossel - anti-padrao'
        $navVeredito = 'remover'
    }
    elseif ($method -match 'increaseItem|decreaseItem|onInputClick|QuantityButton') {
        $tipo = 'interaction'
        $status = 'remover'
        $criterio = 'fundir_pai'
        $prioridade = 'P2'
        $jsonNovo = ''
        $notas = 'Granularidade +/- quantidade - fundir no add_to_cart pai'
        $navVeredito = 'remover'
    }
    elseif ($blob -match 'lupa:callback|tagResponse') {
        $tipo = 'callback'
        $status = 'migrar'
        $criterio = 'essencial_p0'
        $prioridade = 'P0'
        $group = ''
        $isErr = $blob -match 'error|erro'
        $cbName = if ($isErr) { 'callback_busca_search_error' } else { 'callback_busca_search_success' }
        $params = if ($isErr) { @{ cd_error_message = 'search-failed'; search_term = '$searchTerm' } } else { @{ search_term = '$searchTerm' } }
        $jsonNovo = New-Envelope $cbName $params
        $notas = 'Callback da lupa - padronizar success/error'
        $cbRows.Add([pscustomobject]@{
                navbar               = $navbar
                evento_legado_json   = $ev.json
                arquivo_tag          = $file
                event_action_legado  = $action
                event_label_legado   = $label
                name_novo            = $cbName
                params_novo          = if ($isErr) { 'cd_error_message,search_term' } else { 'search_term' }
                cd_error_message     = if ($isErr) { 'search-failed' } else { '' }
                observacoes          = $notas
            }) | Out-Null
    }
    elseif ($parsed.custom -match '^callback_') {
        $tipo = 'callback'
        $status = 'manter'
        $criterio = 'essencial_p1'
        $prioridade = 'P1'
        $group = ''
        $jsonNovo = New-Envelope $parsed.custom $(if ($parsed.custom -match 'erro|error') { @{ cd_error_message = '$error' } } else { @{} })
        $notas = 'Callback ja no formato novo'
        $cbRows.Add([pscustomobject]@{
                navbar               = $navbar
                evento_legado_json   = $ev.json
                arquivo_tag          = $file
                event_action_legado  = $action
                event_label_legado   = $label
                name_novo            = $parsed.custom
                params_novo          = ''
                cd_error_message     = ''
                observacoes          = $notas
            }) | Out-Null
    }
    elseif ($blob -match 'addItem|add_to_cart|adicionar-item|tagAddToCart') {
        $tipo = 'ecommerce'
        $status = 'migrar'
        $criterio = 'essencial_p0'
        $prioridade = 'P0'
        $group = ''
        $jsonNovo = Build-EcomJsonNovo 'add_to_cart'
        $notas = 'CTA adicionar na lista/PDP/busca - migrar para add_to_cart (funil de compra)'
    }
    elseif ($blob -match 'share|compartilhar|download_share|promote_product') {
        $tipo = 'interaction'
        $status = 'migrar'
        $criterio = 'essencial_p0'
        $prioridade = 'P0'
        $detail = 'share:share-button-compartilhar-produto'
        $jsonNovo = New-Envelope 'interaction_explorar' @{ cd_interaction_detail = $detail; cd_sku = '$sku' }
        $notas = 'Share de produto - manter (nao e nav)'
    }
    elseif ($blob -match 'view_promotion|select_promotion|eventSelectPromotion|interaction_promo') {
        $tipo = 'ecommerce'
        $status = 'migrar'
        $criterio = 'essencial_p0'
        $prioridade = 'P0'
        $group = ''
        $ecomName = if ($blob -match 'select') { 'select_promotion' } else { 'view_promotion' }
        $jsonNovo = Build-EcomJsonNovo $ecomName
        $notas = "Criativo no funil de compra - $ecomName"
    }
    elseif ($blob -match 'clickRedirect|ver-todas|ver-mais|ir-para|voltar') {
        $tipo = 'interaction'
        $status = 'remover'
        $criterio = 'nav_duplicada'
        $prioridade = 'P2'
        $jsonNovo = ''
        $notas = 'Clique de navegacao in-app - PV no destino cobre chegada'
        $navVeredito = 'remover'
        $navRows.Add([pscustomobject]@{
                navbar               = $navbar
                evento_legado_json   = $ev.json
                arquivo_tag          = $file
                event_label          = $label
                comportamento_codigo = 'navegacao_interna'
                veredito             = 'remover'
                motivo               = $notas
                evidencia_arquivo    = $file
                evidencia_metodo     = $method
            }) | Out-Null
    }
    elseif ($blob -match 'coachmark|tutorial|tooltip') {
        $tipo = 'interaction'
        $status = 'remover'
        $criterio = 'anti_padrao'
        $prioridade = 'P2'
        $jsonNovo = ''
        $notas = 'Tutorial/coachmark - anti-padrao'
    }
    elseif ($blob -match 'remind|avise-me') {
        $tipo = 'interaction'
        $status = 'migrar'
        $criterio = 'essencial_p1'
        $prioridade = 'P1'
        $detail = 'click:button-avise-me'
        $jsonNovo = New-Envelope 'interaction_explorar' @{ cd_interaction_detail = $detail; cd_sku = '$sku' }
        $notas = 'Avise-me em ruptura'
    }
    elseif ($blob -match 'similar|similares') {
        $tipo = 'interaction'
        $status = 'migrar'
        $criterio = 'essencial_p1'
        $prioridade = 'P1'
        $detail = 'click:button-produtos-similares'
        $jsonNovo = New-Envelope 'interaction_explorar' @{ cd_interaction_detail = $detail; cd_sku = '$sku' }
        $notas = 'Produtos semelhantes na PDP/busca'
    }
    elseif ($blob -match 'ordenar|order_tag|limpar-ordenacao') {
        $tipo = 'interaction'
        $status = 'migrar'
        $criterio = 'essencial_p1'
        $prioridade = 'P1'
        $detail = "click:button-$(Get-Slug $label)"
        if ($detail -eq 'click:button-revisar-pm') { $detail = 'click:button-ordenar' }
        $jsonNovo = New-Envelope 'interaction_explorar' @{ cd_interaction_detail = $detail }
        $notas = 'Ordenacao da PLP'
    }
    elseif ($blob -match 'filtro|filter|aplicar:') {
        $tipo = 'interaction'
        $status = 'migrar'
        $criterio = 'essencial_p1'
        $prioridade = 'P1'
        $detail = 'click:filter-aplicar'
        $jsonNovo = New-Envelope 'interaction_explorar' @{ cd_interaction_detail = $detail }
        $notas = 'Filtro da busca'
    }
    elseif ($blob -match 'barcode|codigo-de-barras') {
        $tipo = 'interaction'
        $status = 'migrar'
        $criterio = 'essencial_p1'
        $prioridade = 'P1'
        $detail = 'click:barcode-abrir'
        $jsonNovo = New-Envelope 'interaction_explorar' @{ cd_interaction_detail = $detail }
        $notas = 'Scanner como origem de busca'
    }
    elseif ($blob -match 'tagRequest|busque-por-codigo-ou-nome') {
        $tipo = 'ecommerce'
        $status = 'migrar'
        $criterio = 'essencial_p0'
        $prioridade = 'P0'
        $group = ''
        $jsonNovo = Build-EcomJsonNovo 'search'
        $notas = 'Termo digitado - migrar para search + search_term'
    }
    elseif ($parsed.custom -match '^interaction_') {
        $tipo = 'interaction'
        $status = 'manter'
        $criterio = 'essencial_p1'
        $prioridade = 'P1'
        $group = $parsed.custom
        $jsonNovo = New-Envelope $parsed.custom @{ cd_interaction_detail = 'click:chip-busca-recente' }
        $notas = 'Ja no formato interaction_*'
    }
    else {
        $tipo = 'interaction'
        $status = 'migrar'
        $criterio = 'essencial_p1'
        $prioridade = 'P1'
        $ctx = Get-Slug $(if ($label) { $label } else { $method })
        $detail = "click:button-$ctx"
        if ($detail.Length -gt 100) { $detail = $detail.Substring(0, 100) }
        $jsonNovo = New-Envelope 'interaction_explorar' @{ cd_interaction_detail = $detail }
        $notas = 'Interacao da jornada - migrar para interaction_explorar'
    }

    $rows.Add([pscustomobject]@{
            navbar                 = $navbar
            dominio_ct             = $dominio
            prioridade             = $prioridade
            tipo_legado            = $tipo
            contexto_legado        = [string]$ev.contexto
            acao_legado            = [string]$ev.acao
            evento_legado_json     = [string]$ev.json
            event_category_legado  = $parsed.category
            event_action_legado    = $action
            event_label_legado     = $label
            arquivo_tag            = $file
            json_novo              = $jsonNovo
            status                 = $status
            criterio               = $criterio
            interaction_group      = $group
            cd_interaction_detail  = $detail
            nome_pageview          = $nomePv
            screen_name_legado     = $screenLegado
            notas                  = $notas
        }) | Out-Null
}

$headers = @(
    'navbar', 'dominio_ct', 'prioridade', 'tipo_legado',
    'contexto_legado', 'acao_legado', 'evento_legado_json',
    'event_category_legado', 'event_action_legado', 'event_label_legado',
    'arquivo_tag', 'json_novo', 'status', 'criterio',
    'interaction_group', 'cd_interaction_detail',
    'nome_pageview', 'screen_name_legado', 'notas'
)

function Write-Csv($path, $list) {
    if ($list.Count -eq 0) {
        if ($path -match 'NAVEGACAO') {
            Set-Content $path "navbar,evento_legado_json,arquivo_tag,event_label,comportamento_codigo,veredito,motivo,evidencia_arquivo,evidencia_metodo" -Encoding UTF8
        }
        return
    }
    $list | Export-Csv -Path $path -NoTypeInformation -Encoding UTF8
}

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine(($headers -join ','))
foreach ($r in $rows) {
    $vals = foreach ($h in $headers) { Escape-CsvField ([string]$r.$h) }
    [void]$sb.AppendLine(($vals -join ','))
}
[IO.File]::WriteAllText($outCsv, $sb.ToString(), [Text.UTF8Encoding]::new($false))

Write-Csv $navCsv $navRows
$covRows | Export-Csv -Path $covCsv -NoTypeInformation -Encoding UTF8
$cbRows | Export-Csv -Path $cbCsv -NoTypeInformation -Encoding UTF8

$cnt = @{
    migrar   = @($rows | Where-Object status -eq 'migrar').Count
    manter   = @($rows | Where-Object status -eq 'manter').Count
    remover  = @($rows | Where-Object status -eq 'remover').Count
    novo     = @($rows | Where-Object status -eq 'adicionar_pageview').Count
    ecom     = @($rows | Where-Object tipo_legado -eq 'ecommerce').Count
}
$byCrit = $rows | Group-Object criterio | Sort-Object Name
$byDom = $rows | Group-Object dominio_ct | Sort-Object Name

$md = New-Object System.Text.StringBuilder
[void]$md.AppendLine('# Tagueamento migrado — Explorar Produtos')
[void]$md.AppendLine('')
[void]$md.AppendLine("> Gerado em **$(Get-Date -Format 'yyyy-MM-dd')**. Jornada sell-in no microapp ``oraculo``.")
[void]$md.AppendLine('> Agrupamento novo: `interaction_explorar` (aprovar com PM). Funil de compra usa eventos **ECOM** GA4.')
[void]$md.AppendLine('> Fora do escopo: share produto, barcode, jornada de marca, recomendacao/Top Ten, `jarvis`, `contents` (C&T).')
[void]$md.AppendLine('')
[void]$md.AppendLine('## Resumo executivo')
[void]$md.AppendLine('')
[void]$md.AppendLine('| Metrica | Valor |')
[void]$md.AppendLine('|---------|-------|')
[void]$md.AppendLine("| Inventario oraculo | $($rows.Count) |")
[void]$md.AppendLine("| **Migrar** | $($cnt.migrar) |")
[void]$md.AppendLine("| **Manter** (ECOM/PV/callback ja no padrao) | $($cnt.manter) |")
[void]$md.AppendLine("| **Remover** | $($cnt.remover) |")
[void]$md.AppendLine("| **Novo PV** | $($cnt.novo) |")
[void]$md.AppendLine("| Linhas ECOM | $($cnt.ecom) |")
[void]$md.AppendLine('')
[void]$md.AppendLine('### Criterio')
[void]$md.AppendLine('')
[void]$md.AppendLine('| Criterio | Qtd |')
[void]$md.AppendLine('|----------|-----|')
foreach ($g in $byCrit) { [void]$md.AppendLine("| ``$($g.Name)`` | $($g.Count) |") }
[void]$md.AppendLine('')
[void]$md.AppendLine('### Por dominio')
[void]$md.AppendLine('')
[void]$md.AppendLine('| Dominio | Qtd |')
[void]$md.AppendLine('|---------|-----|')
foreach ($g in $byDom) { [void]$md.AppendLine("| $($g.Name) | $($g.Count) |") }
[void]$md.AppendLine('')
[void]$md.AppendLine('## Funil ECOM alvo')
[void]$md.AppendLine('')
[void]$md.AppendLine('```')
[void]$md.AppendLine('search / view_promotion')
[void]$md.AppendLine('  -> view_item_list -> select_item -> view_item')
[void]$md.AppendLine('    -> add_to_cart  (+ add_to_wishlist)')
[void]$md.AppendLine('```')
[void]$md.AppendLine('')
[void]$md.AppendLine('Checkout / purchase ficam com **Checkout e Pedidos** — nao entram nesta jornada.')
[void]$md.AppendLine('')
[void]$md.AppendLine('## P0 — manter ou migrar')
[void]$md.AppendLine('')
[void]$md.AppendLine('| Dominio | Status | Criterio | Evento novo | Tag |')
[void]$md.AppendLine('|---------|--------|----------|-------------|-----|')
foreach ($r in @($rows | Where-Object { $_.prioridade -eq 'P0' -and $_.status -ne 'remover' })) {
    $evName = ''
    if ($r.json_novo) {
        try { $evName = (($r.json_novo | ConvertFrom-Json).events[0].name) } catch { $evName = $r.cd_interaction_detail }
    }
    [void]$md.AppendLine("| $($r.dominio_ct) | ``$($r.status)`` | ``$($r.criterio)`` | ``$evName`` | ``$(Split-Path $r.arquivo_tag -Leaf)`` |")
}
[void]$md.AppendLine('')
[void]$md.AppendLine('## Removidos')
[void]$md.AppendLine('')
[void]$md.AppendLine('| Criterio | Tag | Motivo |')
[void]$md.AppendLine('|----------|-----|--------|')
foreach ($r in @($rows | Where-Object status -eq 'remover')) {
    [void]$md.AppendLine("| ``$($r.criterio)`` | ``$(Split-Path $r.arquivo_tag -Leaf)`` | $($r.notas) |")
}
[void]$md.AppendLine('')
[void]$md.AppendLine('## Lacunas de pageview')
[void]$md.AppendLine('')
$novos = @($rows | Where-Object status -eq 'adicionar_pageview')
if ($novos.Count -eq 0) {
    [void]$md.AppendLine('Nenhuma lacuna de PV com screen_name literal quebrado alem das interpolacoes listadas no CSV.')
}
else {
    [void]$md.AppendLine('| screen_name proposto | Tag | Nota |')
    [void]$md.AppendLine('|---------------------|-----|------|')
    foreach ($r in $novos) {
        [void]$md.AppendLine("| ``$($r.nome_pageview)`` | ``$(Split-Path $r.arquivo_tag -Leaf)`` | $($r.notas) |")
    }
}
[void]$md.AppendLine('')
[void]$md.AppendLine('## Pendencias PM')
[void]$md.AppendLine('')
[void]$md.AppendLine('1. Aprovar agrupamento **`interaction_explorar`** (nao existe no catalogo C&T).')
[void]$md.AppendLine('2. Confirmar que +/- quantidade (`fundir_pai`) pode sair — `add_to_cart` cobre o gesto.')
[void]$md.AppendLine('3. Confirmar remocao de scroll de vitrine (`anti_padrao`).')
[void]$md.AppendLine('4. Landing pages Prismic: confirmar PV da LP + `item_list_name` da pagina.')
[void]$md.AppendLine('')
[void]$md.AppendLine("CSV: [TAGUEAMENTO_MIGRADO_EXPLORAR-PRODUTOS.csv](./TAGUEAMENTO_MIGRADO_EXPLORAR-PRODUTOS.csv)")

[IO.File]::WriteAllText($outMd, $md.ToString(), [Text.UTF8Encoding]::new($false))

# --- auditoria markdowns ---
$navMdText = @"
# Navegacao — Explorar Produtos

> Gerado em $(Get-Date -Format 'yyyy-MM-dd'). Cliques in-app e scroll.

## Resumo

| Veredito | Qtd |
|----------|-----|
| remover | $($navRows.Count + @($rows | Where-Object criterio -eq 'anti_padrao').Count) |
| manter (share) | $(@($rows | Where-Object { $_.cd_interaction_detail -like 'share:*' }).Count) |

Share de produto **nao** e navegacao.

CSV: [NAVEGACAO_AUDITORIA.csv](./NAVEGACAO_AUDITORIA.csv)
"@
Set-Content $navMd $navMdText -Encoding UTF8

$covMdText = @"
# Cobertura pageview — Explorar Produtos

> Gerado em $(Get-Date -Format 'yyyy-MM-dd').

| Veredito | Qtd |
|----------|-----|
| pageview_ok | $(@($rows | Where-Object criterio -eq 'pageview_ok').Count) |
| lacuna / interpolacao | $($covRows.Count) |

PV ja no padrao: ``/app-rev/busca``, ``/app-rev/busca/excluir``, ``/app-rev/busca/categoria``, ``/app-rev/busca/produto-sem-estoque``, ``/app-rev/ver-todas-linhas``.

CSV: [COBERTURA_AUDITORIA.csv](./COBERTURA_AUDITORIA.csv)
"@
Set-Content $covMd $covMdText -Encoding UTF8

$cbMdText = @"
# Callbacks — Explorar Produtos

> Gerado em $(Get-Date -Format 'yyyy-MM-dd').

| Legado | Novo |
|--------|------|
| ``lupa:callback`` sucesso | ``callback_busca_search_success`` |
| ``lupa:callback`` erro | ``callback_busca_search_error`` + ``cd_error_message`` |
| ``callback_excluir_buscas_recentes_*`` | manter (ja no formato novo) |

CSV: [CALLBACKS_MIGRACAO.csv](./CALLBACKS_MIGRACAO.csv)
"@
Set-Content $cbMd $cbMdText -Encoding UTF8

$simp = @"
# Simplificacao de jornadas — Explorar Produtos

> Gerado em $(Get-Date -Format 'yyyy-MM-dd').

## P0 (intocaveis)

- ``view_item_list`` / ``select_item`` / ``view_item``
- ``add_to_cart`` (PDP, PLP, ofertas, LP)
- ``view_promotion`` / ``select_promotion`` (banner e LP)
- PV da LP Prismic e da PDP/lista

## P1 (manter salvo decisao)

- Avise-me, semelhantes, ordenacao, favoritos, lucro extra

## P2 (remover)

- Scroll de secao/carrossel
- +/- quantidade (fundir no ``add_to_cart``)
- Cliques ``ver-mais`` / redirect de card quando ha PV no destino
"@
Set-Content $simpMd $simp -Encoding UTF8

Write-Host "CSV: $outCsv ($($rows.Count) linhas)"
Write-Host "MD:  $outMd"
Write-Host ("migrar={0} manter={1} remover={2} novo_pv={3} ecom={4}" -f $cnt.migrar, $cnt.manter, $cnt.remover, $cnt.novo, $cnt.ecom)
