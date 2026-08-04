$Script:Ga4ClientIdPlaceholder = '[[identificador-unico-usuario]]'
$Script:Ga4SessionIdPlaceholder = '[[identificador-unico-sessao]]'

function New-Ga4EnvelopeJson($events) {
    $o = [ordered]@{
        client_id  = $Script:Ga4ClientIdPlaceholder
        session_id = $Script:Ga4SessionIdPlaceholder
        events     = @($events)
    }
    return ($o | ConvertTo-Json -Compress -Depth 6)
}

function Get-Ga4EventsFromJsonNovo($jsonNovo) {
    if (-not $jsonNovo) { return $null }
    try {
        $parsed = $jsonNovo | ConvertFrom-Json
    }
    catch {
        return $null
    }
    if ($parsed.events) {
        return @($parsed.events)
    }
    if ($parsed.PSObject.Properties.Name -contains 'name') {
        return @($parsed)
    }
    return $null
}

function New-InteractionJson($group, $detail, $extraParams) {
    $params = [ordered]@{ cd_interaction_detail = $detail }
    if ($extraParams) {
        foreach ($key in ($extraParams.Keys | Sort-Object)) {
            if ($key -ne 'cd_interaction_detail') {
                $params[$key] = $extraParams[$key]
            }
        }
    }
    return (New-Ga4EnvelopeJson @([ordered]@{ name = $group; params = $params }))
}

function New-PageviewJson($screenName, $contextoLegado, $acaoLegado) {
    $params = [ordered]@{ screen_name = [string]$screenName }
    $pageTitle = Get-PageTitleFromPageview $screenName $contextoLegado $acaoLegado
    if ($pageTitle) {
        $params.cd_page_title = $pageTitle
    }
    if ([string]$screenName -match '\$imagesGalleryPage/\$sectionName') {
        $params.cd_section = '${sectionName}'
    }
    return (New-Ga4EnvelopeJson @([ordered]@{ name = 'screen_view'; params = $params }))
}

function New-CallbackJson($name, $errorMsg, $extraParams) {
    $params = [ordered]@{}
    if ($errorMsg) { $params.cd_error_message = $errorMsg }
    if ($extraParams) {
        foreach ($key in ($extraParams.Keys | Sort-Object)) {
            if ($key -ne 'cd_error_message') {
                $params[$key] = $extraParams[$key]
            }
        }
    }
    return (New-Ga4EnvelopeJson @([ordered]@{ name = $name; params = $params }))
}

function Get-CallbackDomainSlug($tag, $dominioCt) {
    $d = [string]$dominioCt
    if ($d -match 'Estoque') { return 'estoque' }
    if ($d -match 'Vendas') { return 'vendas' }
    if ($d -match 'Gestao') { return 'gestao' }
    switch ([string]$tag) {
        { $_ -in @('create_stock_tag', 'edit_stock_tag', 'stock_page_tag') } { return 'estoque' }
        'financial_report_tag' { return 'gestao' }
        { $_ -in @('add_sale_tag', 'sales_tag', 'sales_details_tag') } { return 'vendas' }
        default { return 'gestao' }
    }
}

function Get-CallbackKeywordMap() {
    return @{
        'callback:adicionar-produto'    = 'add_product'
        'callback:editar-produto'       = 'edit_product'
        'callback:relatorio-financeiro' = 'financial_report'
        'callback:auto_save_sale'       = 'auto_save_sale'
        'callback:alterar-data'         = 'change_date'
        'callback:nova-venda'           = 'create_sale'
    }
}

function Get-CallbackErrorCodes() {
    return @{
        'add_product'      = 'add-product-failed'
        'edit_product'     = 'edit-product-failed'
        'financial_report' = 'unexpected-error'
        'auto_save_sale'   = 'auto-save-failed'
        'change_date'      = 'change-date-failed'
        'create_sale'      = 'create-sale-failed'
    }
}

function Format-CallbackEventName($domain, $keyword, $isError) {
    $suffix = if ($isError) { 'error' } else { 'success' }
    return "callback_${domain}_${keyword}_$suffix"
}

function Get-CallbackMapping($action, $label, $tag, $dominioCt, $method, $category, $acaoLegado) {
    $extraCd = Get-LegacyCdParams $tag $method $label $action $category $acaoLegado
    $keywordMap = Get-CallbackKeywordMap
    $kw = $keywordMap[[string]$action]
    if (-not $kw) { return $null }
    $domain = Get-CallbackDomainSlug $tag $dominioCt
    $isError = [string]$label -match 'erro'
    $errorCodes = Get-CallbackErrorCodes
    $eventName = Format-CallbackEventName $domain $kw $isError
    $group = "callback_${domain}_$kw"
    if ($isError) {
        return @{
            group   = $group
            json    = (New-CallbackJson $eventName $errorCodes[$kw] $extraCd)
            notas   = 'callback erro'
            sucesso = $false
        }
    }
    return @{
        group   = $group
        json    = (New-CallbackJson $eventName $null $extraCd)
        notas   = 'callback sucesso'
        sucesso = $true
    }
}

function Resolve-SpecialInteractionDetail($tag, $label, $acaoLegado) {
    $t = [string]$tag
    $l = [string]$label
    $al = [string]$acaoLegado

    if ($t -eq 'full_screen_image_tag' -and $l -eq 'divulgar') {
        return 'share:imagem'
    }
    if ($t -eq 'materials_page_tag') {
        if ($al -match 'Baixa a imagem') {
            return 'download:imagem'
        }
        if ($al -match 'download materials custom event') {
            return 'download:imagens-${sectionName}'
        }
    }
    return $null
}

function Fix-RowSpecialInteractionDetail($row) {
    if ([string]$row.status -ne 'migrar') {
        return @{ row = $row; updated = $false }
    }

    $detail = Resolve-SpecialInteractionDetail `
        ([string]$row.arquivo_tag) `
        ([string]$row.event_label_legado) `
        ([string]$row.acao_legado)
    if (-not $detail) {
        return @{ row = $row; updated = $false }
    }
    if ([string]$row.cd_interaction_detail -eq $detail) {
        return @{ row = $row; updated = $false }
    }

    $group = if ([string]$row.interaction_group) { [string]$row.interaction_group } else { 'interaction_divulgar' }
    $row.cd_interaction_detail = $detail
    $extraCd = Get-LegacyCdParams `
        ([string]$row.arquivo_tag) '' `
        ([string]$row.event_label_legado) `
        ([string]$row.event_action_legado) `
        ([string]$row.event_category_legado) `
        ([string]$row.acao_legado)
    $row.json_novo = (New-InteractionJson $group $detail $extraCd)
    $note = 'cd_interaction_detail simplificado (materiais/imagem)'
    if ([string]$row.notas) {
        if ($row.notas -notlike "*$note*") {
            $row.notas = "$($row.notas); $note"
        }
    } else {
        $row.notas = $note
    }
    return @{ row = $row; updated = $true }
}

function Fix-RowCallbackDomain($row) {
    $action = [string]$row.event_action_legado
    if ($action -notlike 'callback:*') {
        return @{ row = $row; updated = $false }
    }
    if ([string]$row.status -ne 'migrar') {
        return @{ row = $row; updated = $false }
    }

    $cb = Get-CallbackMapping `
        $action `
        ([string]$row.event_label_legado) `
        ([string]$row.arquivo_tag) `
        ([string]$row.dominio_ct) `
        '' `
        ([string]$row.event_category_legado) `
        ([string]$row.acao_legado)
    if (-not $cb) {
        return @{ row = $row; updated = $false }
    }

    $changed = ([string]$row.interaction_group -ne $cb.group) -or ([string]$row.json_novo -ne $cb.json)
    if (-not $changed) {
        return @{ row = $row; updated = $false }
    }

    $row.interaction_group = $cb.group
    $row.json_novo = $cb.json
    return @{ row = $row; updated = $true }
}

function Get-NomePageviewFromRow($row) {
    $json = [string]$row.json_novo
    if ($json -match '"screen_name"\s*:\s*"([^"]*)"') {
        return $Matches[1]
    }
    $legacyJson = [string]$row.evento_legado_json
    if ($legacyJson -match 'screen_name"\s*:\s*"([^"]*)"') {
        return $Matches[1]
    }
    return ''
}

function Set-RowNomePageview($row) {
    $row | Add-Member -NotePropertyName nome_pageview -NotePropertyValue (Get-NomePageviewFromRow $row) -Force
    return $row
}

function Get-PageTitleFromPageview($screenName, $contextoLegado, $acaoLegado) {
    $screen = [string]$screenName
    $contexto = [string]$contextoLegado
    $acao = [string]$acaoLegado

    if ($screen -match 'FormatterHelper\.toLowerHyphenated\(screenTitle\)|\$screenTitle|\$\{screenTitle\}') {
        return '${screenTitle}'
    }
    if ($screen -match '\$sectionName|\$\{sectionName\}|\$imagesGalleryPage') {
        return '${sectionName}'
    }
    if ($screen -match '\$screen\b|\$\{screen\}') {
        return '${screen}'
    }
    if ($screen -match '\$videoId|\$\{videoId\}') {
        return '${videoId}'
    }
    if ($screen -match '\$_pageViewPath') {
        if ($screen -match '-vazio$') { return 'Pedidos do cliente - vazio' }
        if ($screen -match '-erro$') { return 'Pedidos do cliente - erro' }
        return 'Pedidos do cliente'
    }
    if ($screen -match '\$_screenBase') {
        return '${screen}'
    }

    if ($contexto -match '^Visualizacao de\s+(.+)$') {
        return $Matches[1].Trim()
    }
    if ($contexto -match '^Interacao em\s+(.+)$') {
        return $Matches[1].Trim()
    }
    if ($acao -and $acao -notmatch 'registrada no analytics|visualizacao de pagina|screen view') {
        return $acao.Trim()
    }
    if ($contexto) {
        return $contexto.Trim()
    }

    $tail = ($screen -split '/') | Where-Object { $_ } | Select-Object -Last 1
    if ($tail) { return $tail }
    return $screen
}

function Add-CdParam($params, $key, $value) {
    if (-not $key -or -not $value) { return }
    if (-not $params.ContainsKey($key)) {
        $params[$key] = $value
    }
}

function Get-LegacyCdParams($tag, $method, $label, $action, $category, $acaoLegado) {
    $params = @{}
    $l = [string]$label
    $a = [string]$action
    $c = [string]$category
    $t = [string]$tag
    $m = [string]$method

    if ($l -match '\$brand|\{brand\}') {
        $brandVal = if ($l -match '::(\$brand|\{brand\})') { $Matches[1] }
                    elseif ($l -match '-(\$brand|\{brand\})$') { $Matches[1] }
                    else { '$brand' }
        Add-CdParam $params 'cd_brand' $brandVal
    }

    if ($l -match 'divulgar-\$type-\$brand') {
        Add-CdParam $params 'cd_catalog_type' '$type'
        Add-CdParam $params 'cd_brand' '$brand'
    }

    if ($l -match '^\$quantity:\$sku:') {
        Add-CdParam $params 'cd_quantity' '$quantity'
        Add-CdParam $params 'cd_sku' '$sku'
    }
    elseif ($l -match '^\$sku:(erro|sucesso)$') {
        Add-CdParam $params 'cd_sku' '$sku'
    }
    elseif ($l -match ':\$sku$' -or $l -match '-:\$sku$' -or $l -match '-\$sku$') {
        Add-CdParam $params 'cd_sku' '$sku'
    }
    elseif ($l -match 'excluir-produto:\$sku') {
        Add-CdParam $params 'cd_sku' '$sku'
    }

    if ($l -match '\$saleId') {
        Add-CdParam $params 'cd_id_venda' '$saleId'
    }

    if ($l -match 'detalhes-da-sua-venda-\$saleId') {
        Add-CdParam $params 'cd_id_venda' '$saleId'
    }

    if ($l -match '\$saleId:\$\{status\.name\}') {
        Add-CdParam $params 'cd_id_venda' '$saleId'
        Add-CdParam $params 'cd_sale_status' '${status.name}'
    }

    if ($l -match 'gerar-link:\$\{type\.name\}') {
        Add-CdParam $params 'cd_charge_type' '${type.name}'
        if ($l -match 'origin') {
            Add-CdParam $params 'cd_origin' '${origin.value}'
        }
    }

    if ($l -match 'tipo-pagamento:\$type') {
        Add-CdParam $params 'cd_payment_type' '$type'
    }

    if ($l -match 'filtro:\$\{filter\.toAnalyticsFormat\(\)\}') {
        Add-CdParam $params 'cd_filter' '${filter.toanalyticsformat()}'
    }

    if ($l -match '\$imageNameFormatted:\$index:\$sectionNameFormatted') {
        Add-CdParam $params 'cd_image_name' '$imageNameFormatted'
        Add-CdParam $params 'cd_index' '$index'
        Add-CdParam $params 'cd_section' '$sectionNameFormatted'
    }

    if ($l -match '^\$button:\$sectionNameFormatted$') {
        Add-CdParam $params 'cd_section' '$sectionNameFormatted'
    }

    if ($t -eq 'sellin_sellout_tag' -and (
            $l -eq 'adicionar-produtos-pronta-entrega' -or
            $m -eq 'onPressAddProducts' -or $al -match 'onpressaddproducts|adicionar-produtos-pronta-entrega'
        )) {
        Add-CdParam $params 'cd_edicao_produtos' '${changedquantity}'
        Add-CdParam $params 'cd_qtd_produtos_pedido' '${totalpossiblequantity}'
        Add-CdParam $params 'cd_qtd_produtos_pronta_entrega' '${totalselectedquantity}'
        Add-CdParam $params 'cd_qtd_selecao_total' '${howmanytotalproductswereadded}'
        Add-CdParam $params 'cd_qtd_selecao_parcial' '${howmanypartialproductswereadded}'
    }

    if ($t -eq 'installment_detail_tag' -and $l -eq 'enviar-lembrete') {
        Add-CdParam $params 'cd_id_venda' '${orderid}'
        Add-CdParam $params 'cd_id_parcela' '${installmentid}'
    }

    if ($t -eq 'manage_receipts_tag' -and $l -in @('enviar-lembrete', 'parcela-alvo:enviar-lembrete')) {
        Add-CdParam $params 'cd_id_venda' '${orderid}'
        Add-CdParam $params 'cd_id_parcela' '${installmentid}'
    }

    if ($t -eq 'confirm_quit_survey_tag' -and (
            $l -like 'sair-sem-salvar*' -or $m -eq 'onPressConfirmQuit' -or
            $al -match 'press confirm quit|confirm quit'
        )) {
        Add-CdParam $params 'cd_reason' '${reasondescription}'
    }

    $al = ([string]$acaoLegado).ToLower()

    if ($t -eq 'promote_products_tag' -and (
            $a -in @('clique:compartilhar', 'clique:divulgar', 'clique:produto') -or
            $m -eq 'onShareButton' -or $al -match 'share button|share m l d|compartilhar'
        )) {
        Add-CdParam $params 'cd_profile_re' '${resellercategory}'
        if ($m -eq 'onShareButton' -or $al -match 'share button|share m l d') {
            Add-CdParam $params 'cd_sku' '${product.productcode}'
        }
    }

    if ($t -eq 'promote_products_tag' -and (
            $m -eq 'onAddToCart' -or $al -match 'add to cart|addtocart'
        )) {
        Add-CdParam $params 'cd_its_from_wishlist' '${product.isfavorite}'
        Add-CdParam $params 'cd_profile_re' '${resellercategory}'
    }

    if ($t -eq 'promote_products_tag' -and (
            $m -in @('onPromoteClick', 'onProductClick') -or
            $al -match 'promote click|product click'
        )) {
        Add-CdParam $params 'cd_profile_re' '${resellercategory}'
    }

    if ($t -eq 'customers_filter_tag' -and $l -in @('aplicar-filtros', 'adicionar-novo-cliente')) {
        Add-CdParam $params 'cd_filtros' '${filters}'
    }

    if ($t -eq 'activations_tag' -and ($m -match 'logViewItem|onProduct|onAddToWishlist|onRemoveFromWishlist')) {
        Add-CdParam $params 'cd_profile_re' '${resellercategory}'
    }

    return $params
}

function Refresh-PageviewJsonNovo($row) {
    if ([string]$row.tipo_legado -ne 'screen_view') {
        return @{ row = $row; updated = $false }
    }
    if ([string]$row.status -notin @('manter', 'adicionar_pageview')) {
        return @{ row = $row; updated = $false }
    }

    $screenName = $null
    $legacyJson = [string]$row.evento_legado_json
    if ($legacyJson -match 'screen_name"\s*:\s*"([^"]+)"') {
        $screenName = $Matches[1]
    }
    else {
        $events = Get-Ga4EventsFromJsonNovo ([string]$row.json_novo)
        if ($events -and $events[0].params -and $events[0].params.screen_name) {
            $screenName = [string]$events[0].params.screen_name
        }
    }

    if (-not $screenName) {
        return @{ row = $row; updated = $false }
    }

    $newJson = New-PageviewJson $screenName ([string]$row.contexto_legado) ([string]$row.acao_legado)
    if ([string]$row.json_novo -eq $newJson) {
        return @{ row = $row; updated = $false }
    }

    $row.json_novo = $newJson
    return @{ row = $row; updated = $true }
}

function Ensure-JsonNovoEnvelope($row) {
    $jsonNovo = [string]$row.json_novo
    if (-not $jsonNovo) { return @{ row = $row; updated = $false } }

    $events = Get-Ga4EventsFromJsonNovo $jsonNovo
    if (-not $events -or $events.Count -eq 0) {
        return @{ row = $row; updated = $false }
    }

    $event = $events[0]
    $updated = ($jsonNovo -notmatch '"client_id"')

    if (-not $updated -and $event.name -ne 'screen_view') {
        return @{ row = $row; updated = $false }
    }

    if ($event.name -eq 'screen_view') {
        if (-not $event.params) {
            $event.params = [pscustomobject]@{}
            $updated = $true
        }
        $keys = @($event.params.PSObject.Properties | ForEach-Object { $_.Name })
        if ($keys -contains 'page_title' -and $keys -notcontains 'cd_page_title') {
            Add-Member -InputObject $event.params -NotePropertyName cd_page_title -NotePropertyValue ([string]$event.params.page_title) -Force
            $updated = $true
        }
        if ($keys -notcontains 'cd_page_title') {
            $pageTitle = Get-PageTitleFromPageview `
                ([string]$event.params.screen_name) `
                ([string]$row.contexto_legado) `
                ([string]$row.acao_legado)
            if ($pageTitle) {
                Add-Member -InputObject $event.params -NotePropertyName cd_page_title -NotePropertyValue $pageTitle -Force
                $updated = $true
            }
        }
        if ([string]$event.params.screen_name -match '\$imagesGalleryPage/\$sectionName' -and $keys -notcontains 'cd_section') {
            Add-Member -InputObject $event.params -NotePropertyName cd_section -NotePropertyValue '${sectionName}' -Force
            $updated = $true
        }
    }

    if (-not $updated) {
        return @{ row = $row; updated = $false }
    }

    $row.json_novo = (New-Ga4EnvelopeJson $events)
    return @{ row = $row; updated = $true }
}

function Merge-RowJsonNovoCdParams($row) {
    $jsonNovo = [string]$row.json_novo
    if (-not $jsonNovo) { return @{ row = $row; updated = $false } }

    $extra = Get-LegacyCdParams `
        ([string]$row.arquivo_tag) `
        ([string]$row.acao_legado) `
        ([string]$row.event_label_legado) `
        ([string]$row.event_action_legado) `
        ([string]$row.event_category_legado) `
        ([string]$row.acao_legado)

    if ($extra.Count -eq 0) {
        return @{ row = $row; updated = $false }
    }

    $events = Get-Ga4EventsFromJsonNovo $jsonNovo
    if (-not $events -or $events.Count -eq 0) {
        return @{ row = $row; updated = $false }
    }

    $event = $events[0]
    if (-not $event.params) {
        $event.params = [pscustomobject]@{}
    }

    $existingKeys = @($event.params.PSObject.Properties | ForEach-Object { $_.Name })
    $changed = $false
    foreach ($key in $extra.Keys) {
        if ($existingKeys -notcontains $key) {
            Add-Member -InputObject $event.params -NotePropertyName $key -NotePropertyValue $extra[$key] -Force
            $changed = $true
        }
    }

    if (-not $changed) {
        return @{ row = $row; updated = $false }
    }

    $row.json_novo = (New-Ga4EnvelopeJson $events)
    $note = 'cd_* legado preservados em json_novo.params'
    if ([string]$row.notas) {
        if ($row.notas -notlike "*$note*") {
            $row.notas = "$($row.notas); $note"
        }
    } else {
        $row.notas = $note
    }

    return @{ row = $row; updated = $true }
}
