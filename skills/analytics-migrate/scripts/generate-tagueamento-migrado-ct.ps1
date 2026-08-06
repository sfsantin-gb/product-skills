#Requires -Version 5.1
[CmdletBinding()]
param([string]$OutDir = '')

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
if (-not $OutDir) { $OutDir = Join-Path $repoRoot 'tools\analytics-migrate\output' }

$extractPath = Join-Path $OutDir '_tag_extract_ct.json'
$navPath = Join-Path $OutDir 'NAVEGACAO_AUDITORIA.csv'
$covPath = Join-Path $OutDir 'COBERTURA_AUDITORIA.csv'
$cbPath = Join-Path $OutDir 'CALLBACKS_MIGRACAO.csv'
$outCsv = Join-Path $OutDir 'TAGUEAMENTO_MIGRADO_CT.csv'
$outMd = Join-Path $OutDir 'TAGUEAMENTO_MIGRADO_CT.md'

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
    $itemQty1 = New-EcomItem 1
    $itemQtyN = New-EcomItem '$quantity'
    switch ($eventName) {
        'view_item_list' {
            return New-Envelope 'view_item_list' @{
                currency         = 'BRL'
                item_list_id     = '$itemListId'
                item_list_name   = '$itemListName'
                items            = @($itemQty1)
            }
        }
        'select_item' {
            return New-Envelope 'select_item' @{
                item_list_id     = '$itemListId'
                item_list_name   = '$itemListName'
                items            = @($itemQty1)
            }
        }
        'view_item' {
            return New-Envelope 'view_item' @{
                currency         = 'BRL'
                value            = '$value'
                item_list_name   = '$itemListName'
                items            = @($itemQty1)
            }
        }
        'add_to_wishlist' {
            return New-Envelope 'add_to_wishlist' @{
                currency         = 'BRL'
                value            = '$value'
                item_list_name   = '$itemListName'
                items            = @($itemQty1)
            }
        }
        'add_to_cart' {
            return New-Envelope 'add_to_cart' @{
                currency         = 'BRL'
                value            = '$value'
                item_list_name   = '$itemListName'
                items            = @($itemQtyN)
            }
        }
        'remove_from_cart' {
            return New-Envelope 'remove_from_cart' @{
                currency         = 'BRL'
                value            = '$value'
                item_list_name   = '$itemListName'
                items            = @($itemQtyN)
            }
        }
        'begin_checkout' {
            return New-Envelope 'begin_checkout' @{
                currency = 'BRL'
                value    = '$value'
                items    = @($itemQtyN)
            }
        }
        'add_shipping_info' {
            return New-Envelope 'add_shipping_info' @{
                currency      = 'BRL'
                shipping_tier = '$shippingTier'
            }
        }
        'add_payment_info' {
            return New-Envelope 'add_payment_info' @{
                currency     = 'BRL'
                value        = '$value'
                payment_type = '$paymentType'
                items        = @($itemQtyN)
            }
        }
        'purchase' {
            return New-Envelope 'purchase' @{
                transaction_id = '$transactionId'
                currency       = 'BRL'
                value          = '$value'
                items          = @($itemQtyN)
            }
        }
        'view_promotion' {
            return New-Envelope 'view_promotion' @{
                creative_name   = '$creativeName'
                creative_slot   = '$creativeSlot'
                promotion_id    = '$promotionId'
                promotion_name  = '$promotionName'
            }
        }
        'select_promotion' {
            return New-Envelope 'select_promotion' @{
                creative_name   = '$creativeName'
                creative_slot   = '$creativeSlot'
                promotion_id    = '$promotionId'
                promotion_name  = '$promotionName'
            }
        }
        'search' {
            return New-Envelope 'search' @{ search_term = '$searchTerm' }
        }
        default { return '' }
    }
}

function Test-IsInventoryRegistrationNotPurchase([string]$tag, [string]$category, [string]$label, [string]$file) {
    # Gestao de estoque / pronta-entrega = cadastrar produtos JA comprados — NUNCA ECOM
    $blob = ('{0}|{1}|{2}|{3}' -f $tag, $category, $label, $file).ToLowerInvariant()
    if ($blob -match 'stock_|create_stock|edit_stock|product_already_in_stock|add_product_tag|automatic_stock|confirm_delete_tag|confirm_back_tag') {
        return $true
    }
    if ($blob -match 'gestao-estoque|pronta-entrega|sell-in-sell-out|sellin_sellout|sellout_sellin|stock_management') {
        return $true
    }
    if ($blob -match 'adicionar-ao-estoque|adicionar-produtos-pronta|adicionar-produtos-a-pronto|adicionar-novo-produto|sim-adicionar-mais-produtos') {
        return $true
    }
    return $false
}

function Test-TruePurchaseIntentContext([string]$tag, [string]$category, [string]$label, [string]$file) {
    # ECOM: intencao/ato de compra — inclui Sellout → carrinho de compra p/ repor estoque e entregar
    $blob = ('{0}|{1}|{2}|{3}' -f $tag, $category, $label, $file).ToLowerInvariant()

    # Ponte Sellout → ECOM (carrinho de compra de estoque, nao "adicionar a venda")
    if ($blob -match 'adicionar-produtos-ao-carrinho') { return $true }

    if (Test-IsInventoryRegistrationNotPurchase $tag $category $label $file) { return $false }

    # Funil de venda ao cliente (exceto ponte acima) → nao ECOM
    if ($blob -match 'adicionar-produto-a-venda|cobrar-cliente|nova-venda|callback:nova-venda') {
        return $false
    }
    if ($blob -match 'sales_|product_search|gerenciar-vendas|vendas-recebidas' -and $blob -notmatch 'adicionar-produtos-ao-carrinho') {
        return $false
    }

    if ($blob -match 'begin.?checkout|finalizar-compra|concluir-compra|checkout|add.?payment|add_payment|carrinho-de-compra|cart-checkout|logpurchase|log_add_to_cart|adicionar-produtos-ao-carrinho') {
        return $true
    }
    return $false
}

function Resolve-StockEcomEvent([string]$tag, [string]$category, [string]$label, [string]$action) {
    # Cadastro de estoque (produtos ja comprados) → nunca ECOM
    if (Test-IsInventoryRegistrationNotPurchase $tag $category $label '') {
        # Excecao: se o label for claramente carrinho de compra a partir de venda, nao bloquear
        if (([string]$label).ToLowerInvariant() -notmatch 'adicionar-produtos-ao-carrinho') { return $null }
    }
    if (-not (Test-TruePurchaseIntentContext $tag $category $label '')) { return $null }

    $l = ([string]$label).ToLowerInvariant()
    $a = ([string]$action).ToLowerInvariant()
    $blob = ('{0}|{1}|{2}' -f $l, $a, $tag).ToLowerInvariant()

    if ($l -match 'compartilhar') { return $null }

    if ($blob -match 'begin.?checkout|finalizar-compra|concluir-compra|iniciar-checkout') { return 'begin_checkout' }
    if ($blob -match 'add.?payment|informar-pagamento|pagamento-checkout') { return 'add_payment_info' }
    if ($blob -match 'logpurchase|compra-concluida|purchase-success|^purchase$') { return 'purchase' }
    if ($blob -match 'add.?to.?cart|adicionar-ao-carrinho-de-compra|adicionar-produtos-ao-carrinho') { return 'add_to_cart' }
    if ($blob -match 'remove.?from.?cart|remover-do-carrinho-de-compra') { return 'remove_from_cart' }
    if ($blob -match 'view.?item.?list') { return 'view_item_list' }
    if ($blob -match 'select.?item') { return 'select_item' }
    if ($blob -match 'view.?item') { return 'view_item' }
    if ($blob -match 'view.?promotion') { return 'view_promotion' }
    if ($blob -match 'select.?promotion') { return 'select_promotion' }
    if ($blob -match 'search_term|\$searchterm') { return 'search' }

    return $null
}

function Get-Slug([string]$raw) {
    if ([string]::IsNullOrWhiteSpace($raw)) { return '' }
    $s = $raw.Trim().ToLowerInvariant()
    $s = $s -replace '\s+', '-'
    $s = $s -replace '_', '-'
    $s = $s -replace '[^a-z0-9:\$\{\}\.\-]', ''
    if ($s.Length -gt 100) { $s = $s.Substring(0, 100) }
    return $s
}

function Get-TagBase([string]$arquivoOuTag) {
    if ([string]::IsNullOrWhiteSpace($arquivoOuTag)) { return '' }
    $t = Split-Path -Leaf $arquivoOuTag
    return ($t -replace '_impl\.dart$', '' -replace '\.dart$', '')
}

function Parse-LegacyJson([string]$json) {
    $result = [ordered]@{
        kind = 'unknown'; category = ''; action = ''; label = ''
        screen_name = ''; custom_root = ''; raw = $json
    }
    if ([string]::IsNullOrWhiteSpace($json)) { return $result }
    try { $o = $json | ConvertFrom-Json } catch { return $result }
    if ($o.screen_view) {
        $result.kind = 'screen_view'
        $result.screen_name = [string]$o.screen_view.screen_name
        return $result
    }
    if ($o.event) {
        $result.kind = 'event'
        $result.category = [string]$o.event.eventCategory
        $result.action = [string]$o.event.eventAction
        $result.label = [string]$o.event.eventLabel
        return $result
    }
    $props = @($o.PSObject.Properties.Name)
    if ($props.Count -ge 1) {
        $root = $props[0]
        $result.kind = 'custom'
        $result.custom_root = $root
        $inner = $o.$root
        if ($inner) {
            if ($inner.eventCategory) { $result.category = [string]$inner.eventCategory }
            if ($inner.eventAction) { $result.action = [string]$inner.eventAction }
            if ($inner.eventLabel) { $result.label = [string]$inner.eventLabel }
            if ($inner.screen_name) {
                $result.kind = 'screen_view'
                $result.screen_name = [string]$inner.screen_name
            }
        }
    }
    return $result
}

function Get-InteractionGroup([string]$navbar, [string]$category, [string]$tag) {
    $blob = ('{0}|{1}|{2}' -f $navbar, $category, $tag).ToLowerInvariant()
    if ($blob -match 'vdstudio|compartilhar-produto|contents_advertising|boticard') { return 'interaction_vdstudio' }
    if ($navbar -eq 'Inicio' -or $blob -match 'home_catalog|top.?ten|inicio') { return 'interaction_inicio' }
    if ($navbar -eq 'Menu' -or $blob -match 'menu|minha-loja|configuracao|srr-mld|aparec|recomendacao|senha|notific') {
        return 'interaction_menu'
    }
    if ($navbar -eq 'Divulgar' -or $blob -match 'divulgar|catalogo|materiais|mld|conteudo|imagens') {
        return 'interaction_divulgar'
    }
    return 'interaction_gestao'
}

function Get-Dominio([string]$navbar, [string]$category, [string]$tag, [string]$label) {
    $blob = ('{0}|{1}|{2}' -f $category, $tag, $label).ToLowerInvariant()
    if ($blob -match 'relatorio-financeiro|relatorio-de-vendas|gestao-de-negocio|financial') { return 'Gestao / Relatorio' }
    if ($blob -match 'gestao-estoque|pronta-entrega|sell-in-sell-out|create_stock|edit_stock|stock_') { return 'Estoque RE' }
    if ($blob -match 'gerenciar-vendas|venda|cobrar|parcela|payment|charge|sellout|sale_') { return 'Vendas sellout' }
    if ($blob -match 'gerenciar-cliente|customer|contacts|notes|showcase|indicac') { return 'Carteira clientes' }
    if ($blob -match 'materiais|imagens|full_screen|download_share|promote_product|click_baixar') { return 'Materiais / Conteudos' }
    if ($blob -match 'catalog|mld|divulgar|store_link|home_page') { return 'Divulgacao MLD' }
    if ($blob -match 'minha-loja|edit_profile|edit_slug|config_tag|perfil') { return 'Perfil MLD' }
    if ($blob -match 'srr-mld|aparec|recommendation|encontre') { return 'Aquisicao CF' }
    if ($blob -match 'mission|tarefa|task') { return 'Tarefas' }
    if ($blob -match 'vdstudio|boticard') { return 'VD Studio' }
    if ($navbar -eq 'Menu') { return 'Menu / atalhos' }
    if ($navbar -eq 'Divulgar') { return 'Divulgacao MLD' }
    return 'Gestao / Relatorio'
}

function Build-Detail([string]$acao, [string]$componente, [string]$contexto) {
    $a = Get-Slug $acao
    $c = Get-Slug $componente
    $x = Get-Slug $contexto
    if ([string]::IsNullOrWhiteSpace($x) -or $x -eq 'unknown' -or $x -eq 'unkown') { $x = 'revisar-pm' }
    $detail = '{0}:{1}-{2}' -f $a, $c, $x
    if ($detail.Length -gt 100) { $detail = $detail.Substring(0, 100) }
    return $detail
}

function Infer-AcaoComponente([string]$action, [string]$label, [string]$customRoot) {
    $l = ('{0}|{1}|{2}' -f $label, $action, $customRoot).ToLowerInvariant()
    $acao = 'click'; $comp = 'button'
    if ($l -match 'compartilhar|share|divulgar') { $acao = 'share'; $comp = 'share-button' }
    elseif ($l -match 'abrir-catalogo|abrir-\$brand|open.?url|open_catalog') { $acao = 'open'; $comp = 'catalog' }
    elseif ($l -match 'abrir') { $acao = 'open'; $comp = 'button' }
    elseif ($l -match 'download|baixar') { $acao = 'download'; $comp = 'button' }
    elseif ($l -match 'scroll' -or $action -match 'interacao:scroll') { $acao = 'swipe'; $comp = 'carousel' }
    elseif ($l -match 'tooltip') { $acao = 'view'; $comp = 'tooltip' }
    elseif ($action -match 'click:banner|clique:banner') { $acao = 'click'; $comp = 'banner' }
    return @{ acao = $acao; componente = $comp }
}

function Resolve-Contexto([string]$label, [string]$action, [string]$category, [string]$acaoLegado) {
    $generic = @('selecionar', 'confirmar', 'fechar', 'salvar', 'cancelar', 'sair', 'voltar', 'continuar')
    $ctx = $label
    if ([string]::IsNullOrWhiteSpace($ctx)) {
        if ($acaoLegado -match 'Toca no botao identificado como "([^"]+)"') { $ctx = $Matches[1] }
        elseif ($acaoLegado -match 'Acao registrada:\s*[^/]+/\s*(.+)$') { $ctx = $Matches[1].Trim() }
        else { $ctx = $acaoLegado }
    }
    if ($ctx -and ($generic -contains $ctx.ToLowerInvariant()) -and $category) {
        $parts = $category -split ':'
        $tail = $parts[-1]
        if ($tail -and $tail -ne $ctx -and $tail -match [regex]::Escape($ctx)) { $ctx = $tail }
        elseif ($tail -match 'selecionar-|confirmar-|fechar-') { $ctx = $tail }
    }
    if ([string]::IsNullOrWhiteSpace($ctx)) { $ctx = 'revisar-pm' }
    return $ctx
}

function PageTitleFromScreen([string]$screen, [string]$acao) {
    if ($acao -match 'Exibe tela\s+(.+)$') { return $Matches[1].Trim() }
    if ($screen -match '\$\{?\w+') { return $screen }
    $leaf = ($screen -split '/')[-1]
    if ([string]::IsNullOrWhiteSpace($leaf)) { return $screen }
    return ($leaf -replace '-', ' ')
}

function Is-AntiPadrao($parsed) {
    $a = ('{0}|{1}' -f $parsed.action, $parsed.label).ToLowerInvariant()
    if ($a -match 'tooltip|visualizar-tooltip|info-preco') { return @{ sim = $true; tipo = 'tooltip' } }
    if ($a -match 'interacao:scroll|(^|:)scroll') { return @{ sim = $true; tipo = 'scroll' } }
    if ($parsed.action -match '^show:modal' -or $a -match '^show:modal') { return @{ sim = $true; tipo = 'show_modal' } }
    return @{ sim = $false; tipo = '' }
}

function Is-FundirPai($parsed, [string]$tag) {
    $blob = ('{0}|{1}|{2}' -f $parsed.category, $parsed.label, $tag).ToLowerInvariant()
    if ($blob -match 'alterar-parcelas|detalhe-parcela|detalhes-da-parcela|excluir-parcela|adicionar-parcela|replicar-parcela') { return $true }
    if ($blob -match 'modal:.*:botao|modal:deletar|modal:editar|modal:cancelar|modal:concluir') { return $true }
    if ($blob -match 'adicionar-item|remover-item|increment|decrement|mais-quantidade|menos-quantidade') { return $true }
    if ($blob -match 'onboarding-produto-generico') { return $true }
    if ($blob -match 'motivo-cancelamento|sair-sem-salvar-a-venda:') { return $true }
    return $false
}

function Is-EssencialP0($parsed, [string]$tag, [string]$customRoot) {
    $blob = ('{0}|{1}|{2}|{3}' -f $parsed.label, $parsed.action, $tag, $customRoot).ToLowerInvariant()
    if ($blob -match 'compartilhar|share|divulgar-|abrir-catalogo|abrir-\$brand|open') { return $true }
    if ($blob -match 'salvar-venda|selecionar-cliente|selecionar-produto|gerar-link|criar-novo-link|habilitar-link|compartilhar-lembrete') { return $true }
    if ($blob -match 'download_share|click_baixar|promote_product|click_divulgar_catalogo') { return $true }
    if ($blob -match 'atualizar-relatorio|relatorio-financeiro|relatorio-de-vendas') { return $true }
    if ($blob -match 'add_customer|adicionar-cliente|editar-cliente') { return $true }
    if ($blob -match 'compartilhar-produtos-pronta|compartilhar-produto-pronta|compartilhar-minha-loja|compartilhar-lojas') { return $true }
    return $false
}

function Is-EssencialP1($parsed, [string]$tag) {
    $blob = ('{0}|{1}|{2}|{3}' -f $parsed.label, $parsed.action, $parsed.category, $tag).ToLowerInvariant()
    if ($blob -match 'tentar-novamente|confirmar|continuar-editando|salvar-alteracao|alterar-data|alterar-cliente') { return $true }
    if ($blob -match 'selecionar-data|selecionar-valor|visualizar-previa|editar-valor|editar:\$sku|excluir:\$sku') { return $true }
    if ($blob -match 'adicionar-nova-venda|adicionar-parcelas|organizar|baixa-automatica|editar-perfil|adicionar-foto|salvar|cancelar') { return $true }
    if ($blob -match 'importar-contatos|informacao-telefone|cliente-nao-pagou|sair') { return $true }
    if ($blob -match 'ver-novidade|editar$|banner') { return $true }
    return $false
}

function Is-ObsoletoNav($nav) {
    if (-not $nav) { return $false }
    $m = ('{0}|{1}' -f [string]$nav.motivo, [string]$nav.veredito).ToLowerInvariant()
    return ($m -match 'obsoleto|handler vazio|sem wiring|so testes|indefinido')
}

$extract = Get-Content $extractPath -Raw -Encoding UTF8 | ConvertFrom-Json
$navRows = Import-Csv $navPath -Encoding UTF8
$covRows = Import-Csv $covPath -Encoding UTF8
$cbRows = Import-Csv $cbPath -Encoding UTF8

$navByKey = @{}
foreach ($n in $navRows) {
    $tag = Get-TagBase $n.arquivo_tag
    $lbl = [string]$n.event_label
    $key = ('{0}|{1}' -f $tag, $lbl).ToLowerInvariant()
    $navByKey[$key] = $n
    if ($n.evento_legado_json) {
        $navByKey[('json|{0}' -f ([string]$n.evento_legado_json).Trim())] = $n
    }
}

$covByKey = @{}
foreach ($c in $covRows) {
    $tag = Get-TagBase $c.arquivo_tag
    $parsed = Parse-LegacyJson $c.evento_legado_json
    $key = ('{0}|{1}' -f $tag, $parsed.label).ToLowerInvariant()
    $covByKey[$key] = $c
}

$rows = New-Object System.Collections.Generic.List[object]
$keysSeen = New-Object 'System.Collections.Generic.HashSet[string]'

function Add-Row($props) {
    $key = '{0}|{1}|{2}|{3}|{4}' -f $props.arquivo_tag, $props.evento_legado_json, $props.status, $props.cd_interaction_detail, $props.nome_pageview
    if (-not $keysSeen.Add($key)) { return }
    $rows.Add([pscustomobject]$props) | Out-Null
}

foreach ($ev in $extract) {
    $parsed = Parse-LegacyJson $ev.json
    $tag = Get-TagBase $ev.tag
    $fileLeaf = Split-Path -Leaf $ev.file
    $label = $parsed.label
    $navKey = ('{0}|{1}' -f $tag, $label).ToLowerInvariant()
    $nav = $null
    if ($navByKey.ContainsKey($navKey)) { $nav = $navByKey[$navKey] }
    elseif ($navByKey.ContainsKey(('json|{0}' -f ([string]$ev.json).Trim()))) {
        $nav = $navByKey[('json|{0}' -f ([string]$ev.json).Trim())]
    }
    $cov = $null
    if ($covByKey.ContainsKey($navKey)) { $cov = $covByKey[$navKey] }

    $navbar = [string]$ev.navbar
    if (-not $navbar) { $navbar = 'Gestao' }
    $dominio = Get-Dominio $navbar $parsed.category $tag $label
    $group = Get-InteractionGroup $navbar $parsed.category $tag
    $anti = Is-AntiPadrao $parsed
    $fundir = Is-FundirPai $parsed $tag

    $status = 'migrar'
    $criterio = 'essencial_p1'
    $prioridade = 'P1'
    $interactionGroup = ''
    $cdDetail = ''
    $jsonNovo = ''
    $notas = ''
    $nomePv = ''
    $screenLegado = ''
    $tipoLegado = 'interaction'

    if ($parsed.kind -eq 'screen_view') {
        $tipoLegado = 'screen_view'
        $status = 'manter'
        $criterio = 'pageview_ok'
        $prioridade = 'P0'
        $screenLegado = $parsed.screen_name
        $nomePv = $parsed.screen_name
        $title = PageTitleFromScreen $parsed.screen_name $ev.acao
        $params = @{ screen_name = $parsed.screen_name; cd_page_title = $title }
        if ($parsed.screen_name -match 'sectionName|imagesGallery') { $params.cd_section = '$sectionName' }
        $jsonNovo = New-Envelope 'screen_view' $params
        $notas = 'Pageview existente - manter screen_view + screen_name + cd_page_title'
    }
    elseif ($nav -and [string]$nav.veredito -eq 'remover') {
        $tipoLegado = 'interaction'
        $status = 'remover'
        $prioridade = 'P2'
        if ($cov -and [string]$cov.veredito -eq 'substituir') {
            $criterio = 'lacuna_pageview'
            $notas = 'Nav in-app + lacuna PV destino: {0}. Fonte: COBERTURA substituir' -f [string]$cov.destino_rota_esperada
        }
        elseif ($cov -and [string]$cov.veredito -eq 'revisar_pm') {
            $criterio = 'revisar_pm'
            $status = 'remover'
            $prioridade = 'revisar'
            $notas = 'Nav remover; coverage revisar_pm ({0})' -f [string]$cov.recomendacao
        }
        else {
            $criterio = 'nav_duplicada'
            $notas = 'NAVEGACAO remover - {0}' -f [string]$nav.motivo
        }
        $jsonNovo = ''
    }
    elseif ($nav -and [string]$nav.veredito -eq 'revisar') {
        $tipoLegado = 'interaction'
        if (Is-ObsoletoNav $nav) {
            $status = 'remover'
            $criterio = 'obsoleto'
            $prioridade = 'P2'
            $notas = 'NAVEGACAO revisar/obsoleto - {0}' -f [string]$nav.motivo
        }
        else {
            $status = 'revisar'
            $criterio = 'revisar_pm'
            $prioridade = 'revisar'
            $notas = 'NAVEGACAO revisar - {0}' -f [string]$nav.motivo
        }
        $jsonNovo = ''
    }
    elseif ($anti.sim) {
        $status = 'remover'
        $criterio = 'anti_padrao'
        $prioridade = 'P2'
        $notas = 'Anti-padrao: {0}' -f $anti.tipo
        $jsonNovo = ''
    }
    elseif (($ecomEvent = Resolve-StockEcomEvent $tag $parsed.category $label $parsed.action)) {
        $tipoLegado = 'ecommerce'
        if ($ecomEvent -eq 'revisar_search') {
            $status = 'revisar'
            $criterio = 'revisar_pm'
            $prioridade = 'revisar'
            $notas = 'Busca no funil estoque sem search_term claro - ECOM search ou interaction_gestao'
            $jsonNovo = ''
            $interactionGroup = ''
            $cdDetail = ''
        }
        else {
            $status = 'migrar'
            $criterio = 'essencial_p0'
            $prioridade = 'P0'
            $interactionGroup = ''
            $cdDetail = ''
            $jsonNovo = Build-EcomJsonNovo $ecomEvent
            $notas = 'ECOM compra de estoque (incl. Sellout → carrinho) - {0} (EVENTOS_ESSENCIAIS §8–9 / REGRAS §3)' -f $ecomEvent
        }
    }
    elseif ($fundir) {
        $status = 'remover'
        $criterio = 'fundir_pai'
        $prioridade = 'P2'
        $notas = 'Granularidade modal/parcela/qty - fundir no interaction pai (SIMPLIFICACAO)'
        $jsonNovo = ''
    }
    elseif ($parsed.kind -eq 'custom' -and $parsed.custom_root -match 'added_sale_success|venda_adicionada') {
        $status = 'remover'
        $criterio = 'fundir_pai'
        $prioridade = 'P2'
        $notas = 'Custom duplica callback_vendas_create_sale_success - fundir'
        $jsonNovo = ''
    }
    else {
        $tipoLegado = if ($parsed.kind -eq 'custom') { 'custom' } else { 'interaction' }
        $ac = Infer-AcaoComponente $parsed.action $label $parsed.custom_root
        $ctx = Resolve-Contexto $label $parsed.action $parsed.category $ev.acao

        if ($label -match 'abrir-catalogo::(.+)|abrir-\$brand|abrir-') {
            $ac.acao = 'open'; $ac.componente = 'catalog'
            if ($label -match '::(.+)$') { $ctx = $Matches[1] }
            elseif ($label -match 'abrir-\$brand') { $ctx = '$brand' }
            else { $ctx = $label -replace '^abrir-', '' }
            $cdDetail = Build-Detail 'open' 'catalog' $ctx
        }
        elseif ($label -match 'compartilhar-catalogo') {
            $ac.acao = 'share'; $ac.componente = 'catalog'
            if ($label -match '::(.+)$') { $ctx = $Matches[1] } else { $ctx = '$brand' }
            $cdDetail = Build-Detail 'share' 'catalog' $ctx
        }
        elseif ($label -match 'divulgar-\$type-\$brand|divulgar-') {
            $cdDetail = Build-Detail 'share' 'catalog' $label
        }
        elseif ($label -match 'compartilhar-minha-loja|compartilhar-lojas|compartilhar-produtos-pronta|compartilhar-produto-pronta|compartilhar-lembrete|compartilhar:') {
            $cdDetail = Build-Detail 'share' 'share-button' $label
        }
        elseif ($parsed.custom_root -match 'download_share|click_baixar') {
            $cdDetail = Build-Detail 'download' 'button' 'baixar-compartilhar-materiais'
        }
        elseif ($parsed.custom_root -match 'promote_product') {
            $cdDetail = Build-Detail 'view' 'screen' 'materiais-galeria'
        }
        elseif ($parsed.custom_root -match 'click_divulgar_catalogo') {
            $cdDetail = Build-Detail 'share' 'mld' 'por-marca'
        }
        elseif ($parsed.custom_root -match 'add_customer') {
            $cdDetail = Build-Detail 'click' 'button' 'add-customer'
        }
        else {
            $cdDetail = Build-Detail $ac.acao $ac.componente $ctx
        }

        if ($cdDetail -match 'revisar-pm' -and [string]::IsNullOrWhiteSpace($label) -and [string]::IsNullOrWhiteSpace($parsed.custom_root)) {
            $status = 'revisar'
            $criterio = 'revisar_pm'
            $prioridade = 'revisar'
            $notas = 'Contexto ambiguo - falta eventLabel'
            $jsonNovo = ''
        }
        elseif (Is-EssencialP0 $parsed $tag $parsed.custom_root) {
            $status = 'migrar'
            $criterio = 'essencial_p0'
            $prioridade = 'P0'
            $interactionGroup = $group
            $params = @{ cd_interaction_detail = $cdDetail }
            if ($label -match '\$brand' -or $cdDetail -match '\$brand') { $params.cd_brand = '$brand' }
            if ($label -match '\$saleId' -or $cdDetail -match '\$saleId') { $params.cd_id_venda = '$saleId' }
            if ($label -match '\$sku') { $params.cd_sku = '$sku' }
            $jsonNovo = New-Envelope $group $params
            $notas = 'P0 - share/open/funil core (EVENTOS_ESSENCIAIS)'
        }
        elseif (Is-EssencialP1 $parsed $tag) {
            $status = 'migrar'
            $criterio = 'essencial_p1'
            $prioridade = 'P1'
            $interactionGroup = $group
            $params = @{ cd_interaction_detail = $cdDetail }
            if ($label -match '\$sku') { $params.cd_sku = '$sku' }
            $jsonNovo = New-Envelope $group $params
            $notas = 'P1 - diagnostico / funil secundario'
        }
        elseif ($label -match 'performance-da-loja|configuracao-recebiveis') {
            $status = 'remover'
            $criterio = 'obsoleto'
            $prioridade = 'P2'
            $notas = 'Sem wiring em lib/ (NAVEGACAO revisar)'
            $jsonNovo = ''
            $cdDetail = ''
        }
        elseif ($parsed.category -match 'gestao-de-negocio' -and $label -match 'ver-mais|ir-para|atualize') {
            $status = 'remover'
            $criterio = 'nao_essencial'
            $prioridade = 'P2'
            $notas = 'Hub card sem KPI proprio - PV destino basta'
            $jsonNovo = ''
            $cdDetail = ''
        }
        else {
            $blob = ('{0}|{1}|{2}' -f $parsed.category, $label, $tag).ToLowerInvariant()
            if ($blob -match 'tooltip|scroll|carousel$') {
                $status = 'remover'; $criterio = 'anti_padrao'; $prioridade = 'P2'
                $notas = 'Anti-padrao residual'; $jsonNovo = ''; $cdDetail = ''
            }
            elseif ($blob -match 'onboarding') {
                $status = 'remover'; $criterio = 'nao_essencial'; $prioridade = 'P2'
                $notas = 'Onboarding one-shot - score baixo (SIMPLIFICACAO)'
                $jsonNovo = ''; $cdDetail = ''
            }
            elseif ($blob -match 'gerenciar-vendas|gestao-estoque|cobrar|organizar|relatorio|cliente|estoque|divulgar|materiais|minha-loja|menu') {
                $status = 'migrar'; $criterio = 'essencial_p1'; $prioridade = 'P1'
                $interactionGroup = $group
                $jsonNovo = New-Envelope $group @{ cd_interaction_detail = $cdDetail }
                $notas = 'Interacao de jornada - migrar (default P1)'
            }
            else {
                $status = 'remover'; $criterio = 'nao_essencial'; $prioridade = 'P2'
                $notas = 'Fora do mapa essencial / score baixo'
                $jsonNovo = ''; $cdDetail = ''
            }
        }
    }

    Add-Row ([ordered]@{
            navbar = $navbar; dominio_ct = $dominio; prioridade = $prioridade; tipo_legado = $tipoLegado
            contexto_legado = [string]$ev.contexto; acao_legado = [string]$ev.acao
            evento_legado_json = [string]$ev.json
            event_category_legado = $parsed.category; event_action_legado = $parsed.action
            event_label_legado = $label; arquivo_tag = $fileLeaf
            json_novo = $jsonNovo; status = $status; criterio = $criterio
            interaction_group = $interactionGroup; cd_interaction_detail = $cdDetail
            nome_pageview = $nomePv; screen_name_legado = $screenLegado; notas = $notas
        })
}

foreach ($n in $navRows) {
    $tag = Get-TagBase $n.arquivo_tag
    $lbl = [string]$n.event_label
    $exists = $false
    foreach ($r in $rows) {
        if ((Get-TagBase $r.arquivo_tag) -eq $tag -and [string]$r.event_label_legado -eq $lbl) { $exists = $true; break }
    }
    if ($exists) { continue }
    if ([string]$n.veredito -ne 'remover') { continue }

    $parsed = Parse-LegacyJson $n.evento_legado_json
    $covKey = ('{0}|{1}' -f $tag, $lbl).ToLowerInvariant()
    $cov = if ($covByKey.ContainsKey($covKey)) { $covByKey[$covKey] } else { $null }
    $criterio = 'nav_duplicada'
    $notas = 'Incluido da NAVEGACAO (ausente no extract). {0}' -f $n.motivo
    if ($cov -and $cov.veredito -eq 'substituir') {
        $criterio = 'lacuna_pageview'
        $notas = 'Ausente no extract; COBERTURA substituir - remover clique + PV aba financeira'
    }
    $arquivo = [string]$n.arquivo_tag
    if ($arquivo -notmatch '\.dart$') { $arquivo = '{0}.dart' -f $arquivo }
    Add-Row ([ordered]@{
            navbar = [string]$n.navbar; dominio_ct = 'Gestao / Relatorio'; prioridade = 'P2'
            tipo_legado = 'interaction'
            contexto_legado = ('Interacao em {0}' -f $tag)
            acao_legado = ('Toca no botao identificado como "{0}"' -f $lbl)
            evento_legado_json = [string]$n.evento_legado_json
            event_category_legado = $parsed.category; event_action_legado = $parsed.action
            event_label_legado = $lbl; arquivo_tag = $arquivo
            json_novo = ''; status = 'remover'; criterio = $criterio
            interaction_group = ''; cd_interaction_detail = ''
            nome_pageview = ''; screen_name_legado = ''; notas = $notas
        })
}

$finScreen = '/app-rev/gestao/relatorio-de-vendas/aba-financeira'
$finJson = New-Envelope 'screen_view' @{
    screen_name   = $finScreen
    cd_page_title = 'Relatorio de vendas - aba financeira'
}
Add-Row ([ordered]@{
        navbar = 'Gestao'; dominio_ct = 'Gestao / Relatorio'; prioridade = 'lacuna'
        tipo_legado = 'screen_view'
        contexto_legado = 'SalesReportPage aba financeira'
        acao_legado = 'Exibe aba financeira (startAtFinancialTab / TabController)'
        evento_legado_json = ''; event_category_legado = ''; event_action_legado = ''; event_label_legado = ''
        arquivo_tag = 'sales_report_tag.dart'; json_novo = $finJson
        status = 'adicionar_pageview'; criterio = 'lacuna_pageview'
        interaction_group = ''; cd_interaction_detail = ''
        nome_pageview = $finScreen; screen_name_legado = ''
        notas = 'COBERTURA substituir: ir-para-relatorio (payment_methods_tag e payment_detail_model_tag). Implementar screen_view ao exibir aba financeira.'
    })

foreach ($cb in $cbRows) {
    $parsed = Parse-LegacyJson $cb.evento_legado_json
    $nameNovo = [string]$cb.name_novo
    $obs = [string]$cb.observacoes
    $isRevisar = ([string]::IsNullOrWhiteSpace($nameNovo) -or $obs -match '(?i)^revisar' -or $obs -match '(?i)revisar,')
    $arquivo = [string]$cb.arquivo_tag
    $dom = Get-Dominio $cb.navbar $parsed.category (Get-TagBase $cb.arquivo_tag) $parsed.label

    if ($isRevisar) {
        Add-Row ([ordered]@{
                navbar = [string]$cb.navbar; dominio_ct = $dom; prioridade = 'revisar'; tipo_legado = 'callback'
                contexto_legado = ('Callback em {0}' -f (Get-TagBase $cb.arquivo_tag))
                acao_legado = ('Callback {0} / {1}' -f $cb.event_action_legado, $cb.event_label_legado)
                evento_legado_json = [string]$cb.evento_legado_json
                event_category_legado = $parsed.category
                event_action_legado = [string]$cb.event_action_legado
                event_label_legado = [string]$cb.event_label_legado
                arquivo_tag = $arquivo; json_novo = ''
                status = 'revisar'; criterio = 'revisar_pm'
                interaction_group = ''; cd_interaction_detail = ''
                nome_pageview = ''; screen_name_legado = ''
                notas = ('CALLBACKS revisar - {0}' -f $obs)
            })
        continue
    }

    $params = @{}
    if ($cb.params_novo) {
        foreach ($p in @(([string]$cb.params_novo -split ',') | ForEach-Object { $_.Trim() } | Where-Object { $_ })) {
            if ($p -eq 'cd_quantity') { $params.cd_quantity = '$quantity' }
            elseif ($p -eq 'cd_sku') { $params.cd_sku = '$sku' }
            else { $params[$p] = ('${0}' -f ($p -replace '^cd_', '')) }
        }
    }
    if ($cb.cd_error_message) { $params.cd_error_message = [string]$cb.cd_error_message }

    Add-Row ([ordered]@{
            navbar = [string]$cb.navbar; dominio_ct = $dom; prioridade = 'P0'; tipo_legado = 'callback'
            contexto_legado = ('Callback em {0}' -f (Get-TagBase $cb.arquivo_tag))
            acao_legado = ('Callback {0} / {1}' -f $cb.event_action_legado, $cb.event_label_legado)
            evento_legado_json = [string]$cb.evento_legado_json
            event_category_legado = $parsed.category
            event_action_legado = [string]$cb.event_action_legado
            event_label_legado = [string]$cb.event_label_legado
            arquivo_tag = $arquivo; json_novo = (New-Envelope $nameNovo $params)
            status = 'migrar'; criterio = 'essencial_p0'
            interaction_group = ''; cd_interaction_detail = ''
            nome_pageview = ''; screen_name_legado = ''
            notas = ('CALLBACKS migrar - {0}' -f $obs)
        })
}

$headers = @(
    'navbar', 'dominio_ct', 'prioridade', 'tipo_legado',
    'contexto_legado', 'acao_legado', 'evento_legado_json',
    'event_category_legado', 'event_action_legado', 'event_label_legado',
    'arquivo_tag', 'json_novo', 'status', 'criterio',
    'interaction_group', 'cd_interaction_detail',
    'nome_pageview', 'screen_name_legado', 'notas'
)

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine(($headers -join ','))
foreach ($r in $rows) {
    $vals = foreach ($h in $headers) { Escape-CsvField ([string]$r.$h) }
    [void]$sb.AppendLine(($vals -join ','))
}
[IO.File]::WriteAllText($outCsv, $sb.ToString(), [Text.UTF8Encoding]::new($false))

$byCrit = $rows | Group-Object criterio | Sort-Object Name
$legadoExtract = $extract.Count
$cnt = @{
    migrar = @($rows | Where-Object status -eq 'migrar').Count
    manter = @($rows | Where-Object status -eq 'manter').Count
    remover = @($rows | Where-Object status -eq 'remover').Count
    adicionar_pageview = @($rows | Where-Object status -eq 'adicionar_pageview').Count
    revisar = @($rows | Where-Object status -eq 'revisar').Count
}
$totalRows = $rows.Count
$today = Get-Date -Format 'yyyy-MM-dd'

function Md-Escape([string]$s) {
    if ($null -eq $s) { return '' }
    return (($s -replace '\|', '/') -replace "`r?`n", ' ')
}

$md = New-Object System.Text.StringBuilder
[void]$md.AppendLine('# Tagueamento migrado - Conteudos e Trafego (C&T)')
[void]$md.AppendLine('')
[void]$md.AppendLine(('> Gerado em {0} pelo pipeline `@analytics-transform`.' -f $today))
[void]$md.AppendLine('> Export estruturado: [`TAGUEAMENTO_MIGRADO_CT.csv`](./TAGUEAMENTO_MIGRADO_CT.csv)')
[void]$md.AppendLine('')
[void]$md.AppendLine('## Resumo executivo')
[void]$md.AppendLine('')
[void]$md.AppendLine('| Metrica | Valor |')
[void]$md.AppendLine('|---------|-------|')
[void]$md.AppendLine(('| Eventos legado (extract) | {0} |' -f $legadoExtract))
[void]$md.AppendLine(('| Linhas no de-para | {0} |' -f $totalRows))
[void]$md.AppendLine(('| Migrar | {0} |' -f $cnt.migrar))
[void]$md.AppendLine(('| Manter (pageview) | {0} |' -f $cnt.manter))
[void]$md.AppendLine(('| Remover | {0} |' -f $cnt.remover))
[void]$md.AppendLine(('| Adicionar pageview | {0} |' -f $cnt.adicionar_pageview))
[void]$md.AppendLine(('| Revisar PM | {0} |' -f $cnt.revisar))
$ecomRows = @($rows | Where-Object { $_.tipo_legado -eq 'ecommerce' -and $_.json_novo })
$ecomByName = @{}
foreach ($er in $ecomRows) {
    $en = ''
    if ($er.json_novo -match '"name"\s*:\s*"([^"]+)"') { $en = $Matches[1] }
    if (-not $en) { $en = '(sem nome)' }
    if (-not $ecomByName.ContainsKey($en)) { $ecomByName[$en] = 0 }
    $ecomByName[$en]++
}
[void]$md.AppendLine(('| ECOM (compra p/ estoque) | {0} |' -f $ecomRows.Count))
[void]$md.AppendLine('')
if ($ecomByName.Count -gt 0) {
    [void]$md.AppendLine('### ECOM por evento GA4')
    [void]$md.AppendLine('')
    [void]$md.AppendLine('| Evento | Qtd |')
    [void]$md.AppendLine('|--------|-----|')
    foreach ($k in ($ecomByName.Keys | Sort-Object)) {
        [void]$md.AppendLine(('| `{0}` | {1} |' -f $k, $ecomByName[$k]))
    }
    [void]$md.AppendLine('')
}
[void]$md.AppendLine('### Criterios')
[void]$md.AppendLine('')
[void]$md.AppendLine('| Criterio | Qtd |')
[void]$md.AppendLine('|----------|-----|')
foreach ($g in $byCrit) { [void]$md.AppendLine(('| `{0}` | {1} |' -f $g.Name, $g.Count)) }
[void]$md.AppendLine('')
[void]$md.AppendLine('### Fontes complementares ao extract')
[void]$md.AppendLine('')
[void]$md.AppendLine('- Callbacks de `CALLBACKS_MIGRACAO.csv` (ausentes do extract UA).')
[void]$md.AppendLine('- `ir-para-relatorio` das tags de pagamento (ausente do extract; presente no codigo).')
[void]$md.AppendLine('- `adicionar_pageview` da aba financeira (`COBERTURA_AUDITORIA` substituir).')
[void]$md.AppendLine('')

$navbars = @($rows | Select-Object -ExpandProperty navbar -Unique | Sort-Object)
foreach ($nb in $navbars) {
    [void]$md.AppendLine('---')
    [void]$md.AppendLine('')
    [void]$md.AppendLine(('## {0}' -f $nb))
    [void]$md.AppendLine('')
    $subset = @($rows | Where-Object { $_.navbar -eq $nb })
    $agg = $subset | Group-Object status | Sort-Object Name
    [void]$md.AppendLine('| Status | Qtd |')
    [void]$md.AppendLine('|--------|-----|')
    foreach ($a in $agg) { [void]$md.AppendLine(('| {0} | {1} |' -f $a.Name, $a.Count)) }
    [void]$md.AppendLine('')
    [void]$md.AppendLine('Amostra (migrar / manter / adicionar_pageview - ate 25 linhas):')
    [void]$md.AppendLine('')
    [void]$md.AppendLine('| Contexto | Acao usuario | JSON novo (resumo) | Arquivo tag | Status |')
    [void]$md.AppendLine('|----------|--------------|--------------------|-------------|--------|')
    $sample = @($subset | Where-Object { $_.status -in @('migrar', 'manter', 'adicionar_pageview') } | Select-Object -First 25)
    foreach ($s in $sample) {
        $nameHint = $s.interaction_group
        if ([string]::IsNullOrWhiteSpace($nameHint) -and $s.json_novo -match '"name"\s*:\s*"([^"]+)"') { $nameHint = $Matches[1] }
        if ([string]::IsNullOrWhiteSpace($nameHint) -and $s.nome_pageview) { $nameHint = 'screen_view' }
        $line = '| {0} | {1} | `{2}` | `{3}` | {4} |' -f (Md-Escape $s.contexto_legado), (Md-Escape $s.acao_legado), (Md-Escape $nameHint), (Md-Escape $s.arquivo_tag), $s.status
        [void]$md.AppendLine($line)
    }
    [void]$md.AppendLine('')
}

[void]$md.AppendLine('---')
[void]$md.AppendLine('')
[void]$md.AppendLine('## Removidos (nao entram no migrado)')
[void]$md.AppendLine('')
[void]$md.AppendLine('| Criterio | Qtd | Fonte tipica |')
[void]$md.AppendLine('|----------|-----|--------------|')
$remCrit = $rows | Where-Object status -eq 'remover' | Group-Object criterio | Sort-Object Count -Descending
foreach ($g in $remCrit) {
    $fonte = switch ($g.Name) {
        'nav_duplicada' { 'NAVEGACAO / COBERTURA' }
        'lacuna_pageview' { 'COBERTURA substituir' }
        'anti_padrao' { 'CRITERIO_RELEVANCIA' }
        'fundir_pai' { 'SIMPLIFICACAO' }
        'obsoleto' { 'NAVEGACAO / codigo morto' }
        'nao_essencial' { 'EVENTOS_ESSENCIAIS / score' }
        'revisar_pm' { 'COBERTURA / SIMPLIFICACAO' }
        default { 'pipeline' }
    }
    [void]$md.AppendLine(('| `{0}` | {1} | {2} |' -f $g.Name, $g.Count, $fonte))
}
[void]$md.AppendLine('')
[void]$md.AppendLine('Amostra de removidos (nav / lacuna / obsoleto):')
[void]$md.AppendLine('')
[void]$md.AppendLine('| Contexto | Motivo | Fonte decisao |')
[void]$md.AppendLine('|----------|--------|---------------|')
$remSample = @($rows | Where-Object { $_.status -eq 'remover' -and $_.criterio -in @('nav_duplicada', 'lacuna_pageview', 'obsoleto') } | Select-Object -First 20)
foreach ($s in $remSample) {
    $line = '| {0} / `{1}` | `{2}` - {3} | auditorias |' -f (Md-Escape $s.event_label_legado), (Md-Escape $s.arquivo_tag), $s.criterio, (Md-Escape $s.notas)
    [void]$md.AppendLine($line)
}
[void]$md.AppendLine('')
[void]$md.AppendLine('## Lacunas abertas (TODO)')
[void]$md.AppendLine('')
[void]$md.AppendLine('| Contexto | Acao proposta | Responsavel |')
[void]$md.AppendLine('|----------|---------------|-------------|')
foreach ($s in @($rows | Where-Object status -eq 'adicionar_pageview')) {
    $line = '| {0} | `adicionar_pageview` `{1}` | engenharia |' -f (Md-Escape $s.contexto_legado), (Md-Escape $s.nome_pageview)
    [void]$md.AppendLine($line)
}
[void]$md.AppendLine('| VD Studio (extract vazio) | Validar tags contents_advertising no proximo discover | PM + eng |')
[void]$md.AppendLine('')
[void]$md.AppendLine('## Pendencias revisar_pm')
[void]$md.AppendLine('')
foreach ($s in @($rows | Where-Object { $_.status -eq 'revisar' -or $_.criterio -eq 'revisar_pm' } | Select-Object -First 40)) {
    $line = '- `{0}` / `{1}` (`{2}`) - {3}' -f (Md-Escape $s.event_action_legado), (Md-Escape $s.event_label_legado), (Md-Escape $s.arquivo_tag), (Md-Escape $s.notas)
    [void]$md.AppendLine($line)
}
[void]$md.AppendLine('')
[void]$md.AppendLine('CSV completo: todas as linhas do extract (334) + callbacks + nav ausente + pageview TODO.')
[void]$md.AppendLine('')

[IO.File]::WriteAllText($outMd, $md.ToString(), [Text.UTF8Encoding]::new($false))

Write-Host ("Wrote {0} ({1} rows)" -f $outCsv, $totalRows)
Write-Host ("Wrote {0}" -f $outMd)
Write-Host ("legado_extract={0} migrar={1} manter={2} remover={3} adicionar_pageview={4} revisar={5}" -f $legadoExtract, $cnt.migrar, $cnt.manter, $cnt.remover, $cnt.adicionar_pageview, $cnt.revisar)
Write-Host ("ecom_rows={0}" -f $ecomRows.Count)
foreach ($k in ($ecomByName.Keys | Sort-Object)) { Write-Host ('ecom {0}={1}' -f $k, $ecomByName[$k]) }
foreach ($g in $byCrit) { Write-Host ('criterio {0}={1}' -f $g.Name, $g.Count) }
