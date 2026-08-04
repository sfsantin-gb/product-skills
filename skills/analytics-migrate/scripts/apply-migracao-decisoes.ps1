[CmdletBinding()]
param(
    [string]$SourceCsv = 'C:\produto-conteudos-e-trafego\produto\product-context\dados-e-analytics\migracao-tagueamento\TAGUEAMENTO_MIGRADO_CT.csv',
    [string]$OutCsv = 'C:\megazord_mobile\tools\analytics-migrate\output\TAGUEAMENTO_MIGRADO_CT.csv',
    [string]$OutMd = 'C:\megazord_mobile\tools\analytics-migrate\output\TAGUEAMENTO_MIGRADO_CT.md'
)

. (Join-Path (Split-Path $PSScriptRoot -Parent) 'scripts\legacy-cd-params.ps1')

function Get-GenericButtonLabels() {
    return @(
        'selecionar', 'confirmar', 'voltar', 'fechar', 'continuar', 'cancelar',
        'salvar', 'ok', 'sim', 'nao', 'nao-agora', 'proximo', 'anterior', 'entendi', 'concluir',
        'avancar', 'pular', 'fechar-modal'
    )
}

function Test-GenericButtonLabel($label) {
    if (-not $label) { return $false }
    $norm = (($label -split '::')[0]).ToLower().Trim()
    return $norm -in (Get-GenericButtonLabels)
}

function Get-CategoryTailSlug($category) {
    if (-not $category) { return "" }
    $c = [string]$category
    if ($c -match ':([^:]+)$') {
        return ($Matches[1] -replace '_', '-').ToLower()
    }
    return ($c -replace '_', '-').ToLower()
}

function Resolve-GenericButtonContext($label, $category) {
    if (-not (Test-GenericButtonLabel $label)) { return $null }
    $tail = Get-CategoryTailSlug $category
    if (-not $tail -or (Test-GenericButtonLabel $tail)) { return $null }
    $lbl = (($label -split '::')[0]).ToLower().Trim()
    if ($tail -eq $lbl -or $tail -like "$lbl-*") {
        return $tail
    }
    return $null
}

function Fix-GenericButtonLabelRow($row) {
    $action = [string]$row.event_action_legado
    $label = [string]$row.event_label_legado
    $category = [string]$row.event_category_legado
    $status = [string]$row.status

    if ($status -ne 'migrar' -or $action -ne 'clique:botao') {
        return @{ row = $row; fixed = $false }
    }

    $contextSlug = Resolve-GenericButtonContext $label $category
    if (-not $contextSlug) {
        return @{ row = $row; fixed = $false }
    }

    $expectedDetail = "click:button-$contextSlug"
    if ([string]$row.cd_interaction_detail -eq $expectedDetail) {
        return @{ row = $row; fixed = $false }
    }

    $group = if ([string]$row.interaction_group) { [string]$row.interaction_group } else { 'interaction_gestao' }
    $row.cd_interaction_detail = $expectedDetail
    $extraCd = Get-LegacyCdParams ([string]$row.arquivo_tag) '' $label $action $category ([string]$row.acao_legado)
    $row.json_novo = (New-InteractionJson $group $expectedDetail $extraCd)
    $note = 'contexto de botao generico derivado do slug da categoria'
    if ([string]$row.notas) {
        if ($row.notas -notlike "*$note*") {
            $row.notas = "$($row.notas); $note"
        }
    } else {
        $row.notas = $note
    }

    return @{ row = $row; fixed = $true }
}

function Set-RowRemover($row, $criterio, $nota) {
    $row.status = 'remover'
    $row.criterio = $criterio
    $row.revisar_pm = 'nao'
    $row.regra_decisiva = 'pm_decisao'
    $row.interaction_group = ''
    $row.cd_interaction_detail = ''
    $row.json_novo = ''
    $row.notas = $nota
    return $row
}

function Get-DinamicoInteractionDetail($tag) {
    switch ($tag) {
        'learning_module_tag' {
            return @{ detail = 'click:card-${formatterhelper.toanalyticsformat(label)}'; group = 'interaction_divulgar' }
        }
        'news_module_tag' {
            return @{ detail = 'click:card-${formatterhelper.toanalyticsformat(label)}'; group = 'interaction_divulgar' }
        }
        'home_catalogs_section_tag' {
            return @{ detail = 'click:card-${formatterhelper.toanalyticsformat(buttonlabel)}'; group = 'interaction_inicio' }
        }
    }
    return $null
}

function Test-DinamicoAggregateDuplicate($tag) {
    return $tag -in @('materials_module_tag', 'materials_page_tag')
}

function Fix-DinamicoRow($row) {
    $tag = [string]$row.arquivo_tag
    $action = [string]$row.event_action_legado
    $label = [string]$row.event_label_legado
    $detail = [string]$row.cd_interaction_detail

    if ($action -ne 'dinamico' -and $detail -notlike '*dynamic-content*') {
        return $row
    }
    if ($action -eq 'dinamico' -and $label -notlike '*toAnalyticsFormat*' -and $detail -notlike '*dynamic-content*') {
        return $row
    }

    if (Test-DinamicoAggregateDuplicate $tag) {
        return (Set-RowRemover $row 'inventario_agregado' 'Linha agregada dinamico duplica metodos especificos no inventario')
    }

    $mapped = Get-DinamicoInteractionDetail $tag
    if ($mapped) {
        $row.status = 'migrar'
        $row.criterio = 'dinamico_label_variavel'
        $row.regra_decisiva = 'dinamico_toanalyticsformat'
        $row.revisar_pm = 'nao'
        $row.interaction_group = $mapped.group
        $row.cd_interaction_detail = $mapped.detail
        $extraCd = Get-LegacyCdParams $tag '' $label $action ([string]$row.event_category_legado) ([string]$row.acao_legado)
        $row.json_novo = (New-InteractionJson $mapped.group $mapped.detail $extraCd)
        $row.notas = 'Label runtime via FormatterHelper.toAnalyticsFormat - nao traduzir dinamico para dynamic'
        return $row
    }

    if ($detail -like '*dynamic-content*') {
        $row.status = 'revisar'
        $row.criterio = 'revisar_pm'
        $row.revisar_pm = 'sim'
        $row.interaction_group = ''
        $row.cd_interaction_detail = ''
        $row.json_novo = ''
        $row.notas = 'dinamico sem mapeamento - validar parametro toAnalyticsFormat no codigo'
    }

    return $row
}

$sectionButtonLabel = '$' + 'button:$sectionNameFormatted'
$sectionButtonDetail = 'click:button-$button-$sectionnameformatted'

$rows = @(Import-Csv $SourceCsv -Encoding UTF8)
$excluded = [System.Collections.Generic.List[object]]::new()
$kept = [System.Collections.Generic.List[object]]::new()
$genericLabelFixes = 0
$cdParamFixes = 0
$specialDetailFixes = 0
$callbackDomainFixes = 0
$pageviewFixes = 0
$missingPageTitles = [System.Collections.Generic.List[string]]::new()
$envelopeFixes = 0

foreach ($row in $rows) {
    $tag = [string]$row.arquivo_tag
    $label = [string]$row.event_label_legado
    $dominio = [string]$row.dominio_ct
    $json = [string]$row.evento_legado_json

    if ($tag -eq 'personalize_product_tag' -or $dominio -eq 'VD Studio') {
        $excluded.Add($row)
        continue
    }
    if ($tag -eq 'top_ten_show_case_home_tag') {
        $excluded.Add($row)
        continue
    }

    if ($tag -eq 'assistant_tag') {
        $kept.Add((Set-RowRemover $row 'pm_decisao_r1' 'PM R1: assistente removido - feature nao existe'))
        continue
    }

    if ($tag -eq 'find_reseller_place_tag') {
        $kept.Add((Set-RowRemover $row 'pm_decisao_r2' 'PM R2: Encontre RE fora escopo C&T'))
        continue
    }

    if ($tag -eq 'financial_report_tag' -and $label -eq 'ir-para-pedidos') {
        $row.status = 'migrar'
        $row.criterio = 'pm_decisao_m1'
        $row.revisar_pm = 'nao'
        $row.prioridade = 'P1'
        $row.regra_decisiva = 'pm_decisao_m1'
        $row.interaction_group = 'interaction_gestao'
        $row.cd_interaction_detail = 'click:button-ir-para-pedidos'
        $row.json_novo = (New-InteractionJson 'interaction_gestao' 'click:button-ir-para-pedidos' @{})
        $row.notas = 'PM M1: manter cross-tab relatorio para pedidos'
        $kept.Add($row)
        continue
    }

    if ($tag -eq 'materials_page_tag' -and $label -eq $sectionButtonLabel) {
        $row.status = 'migrar'
        $row.criterio = 'pm_decisao_m3'
        $row.prioridade = 'P1'
        $row.regra_decisiva = 'pm_decisao_m3'
        $row.essencial_match = 'p1'
        $row.interaction_group = 'interaction_divulgar'
        $row.cd_interaction_detail = $sectionButtonDetail
        $extraCdM3 = Get-LegacyCdParams $tag '' $label ([string]$row.event_action_legado) ([string]$row.event_category_legado) ([string]$row.acao_legado)
        $row.json_novo = (New-InteractionJson 'interaction_divulgar' $sectionButtonDetail $extraCdM3)
        $row.notas = 'PM M3: manter botao generico por secao na galeria'
        $kept.Add($row)
        continue
    }

    if ($tag -eq 'materials_page_tag' -and $json -like '*compartilhar-minha-loja-digital*' -and $row.tipo_legado -eq 'screen_view') {
        $kept.Add((Set-RowRemover $row 'obsoleto_v1' 'V1: shareMldModalView nunca chamado - modal legado substituido por ShareImageModalWidget'))
        continue
    }

    if ($tag -eq 'materials_page_tag' -and $label -in @('agora-nao', 'compartilhar-minha-loja-digital')) {
        $row.notas = 'V1 confirmado: modal legado obsoleto; share ativo via clique:componente + click_baixar_compartilhar_materiais'
        $kept.Add($row)
        continue
    }

    $fixedRow = Fix-GenericButtonLabelRow (Fix-DinamicoRow $row)
    if ($fixedRow.fixed) { $genericLabelFixes++ }

    $specialFixed = Fix-RowSpecialInteractionDetail $fixedRow.row
    if ($specialFixed.updated) { $specialDetailFixes++ }

    $cbFixed = Fix-RowCallbackDomain $specialFixed.row
    if ($cbFixed.updated) { $callbackDomainFixes++ }

    $pvFixed = Refresh-PageviewJsonNovo $cbFixed.row
    if ($pvFixed.updated) { $pageviewFixes++ }

    $cdFixed = Merge-RowJsonNovoCdParams $pvFixed.row
    if ($cdFixed.updated) { $cdParamFixes++ }

    $envFixed = Ensure-JsonNovoEnvelope $cdFixed.row
    if ($envFixed.updated) { $envelopeFixes++ }
    if (($envFixed.row.tipo_legado -eq 'screen_view' -or $envFixed.row.status -in @('manter', 'adicionar_pageview')) -and
        $envFixed.row.json_novo -notlike '*cd_page_title*') {
        $missingPageTitles.Add("$($envFixed.row.arquivo_tag)|$($envFixed.row.contexto_legado)")
    }
    $kept.Add((Set-RowNomePageview $envFixed.row))
}

$outDir = Split-Path $OutCsv -Parent
if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

$kept | Export-Csv -Path $OutCsv -NoTypeInformation -Encoding UTF8

$stats = $kept | Group-Object status | Sort-Object Name
$total = $kept.Count
$migrar = ($kept | Where-Object { $_.status -eq 'migrar' }).Count
$remover = ($kept | Where-Object { $_.status -eq 'remover' }).Count
$manter = ($kept | Where-Object { $_.status -eq 'manter' }).Count
$lacuna = @($kept | Where-Object { $_.status -eq 'adicionar_pageview' }).Count
$revisarCount = @($kept | Where-Object { $_.status -eq 'revisar' }).Count
$fora = $excluded.Count
$data = Get-Date -Format 'yyyy-MM-dd'

$statusLines = ($stats | ForEach-Object { "| $($_.Name) | $($_.Count) |" }) -join "`n"
$excludedLines = ($excluded | ForEach-Object {
    "| ``$($_.arquivo_tag)`` / $($_.dominio_ct) | $($_.event_label_legado) | F1/F2 - ownership outro squad |"
}) -join "`n"
$revisarLines = if ($revisarCount -eq 0) {
    '- Nenhuma pendencia aberta no escopo C&T.'
} else {
    ($kept | Where-Object { $_.status -eq 'revisar' } | ForEach-Object {
        "- ``$($_.arquivo_tag)`` / ``$($_.event_label_legado)`` - $($_.notas)"
    }) -join "`n"
}
$criterioLines = ($kept | Where-Object { $_.status -eq 'remover' } |
    Group-Object criterio | Sort-Object Count -Descending | Select-Object -First 12 |
    ForEach-Object { "| $($_.Name) | $($_.Count) |" }) -join "`n"

$md = @"
# Tagueamento migrado - Conteudos e Trafego (C&T)

> Gerado em **$data** apos analytics-transform + MIGRACAO_DECISOES.md (V1/V3 fechados; V2/V4 descartados).
> Export estruturado: [TAGUEAMENTO_MIGRADO_CT.csv](./TAGUEAMENTO_MIGRADO_CT.csv)

## Resumo executivo

| Metrica | Valor |
|---------|-------|
| Eventos legado (base pipeline) | $($rows.Count) |
| Inventario C&T (pos-decisoes PM) | $total |
| Migrados | $migrar |
| Removidos | $remover |
| Manter (PV) | $manter |
| Adicionar pageview | $lacuna |
| Revisar PM | $revisarCount |
| Fora escopo C&T (excluidos) | $fora |

Decisoes aplicadas: R1-R7, M1-M3, F1/F2, V1 (modal MLD obsoleto), V3 (funil catalogo validado).

---

## Por status

| Status | Qtd |
|--------|-----|
$statusLines

---

## Fora escopo C&T (excluidos do CSV)

| Tag / dominio | Evento | Motivo |
|---------------|--------|--------|
$excludedLines

---

## Overrides PM (desta regeneracao)

| Ref | Acao | Linhas afetadas |
|-----|------|-----------------|
| R1 | Assistente - remover | 4 |
| R2 | Encontre RE - remover | 2 |
| M1 | ir-para-pedidos - migrar | 1 |
| M3 | botao secao galeria - migrar | 1 |
| V1 | PV modal MLD legado - remover (codigo morto) | 1 |
| F1/F2 | VD Studio + Top Ten - excluidos | $fora |

---

## Lacunas abertas (TODO eng)

| Contexto | Acao proposta | Responsavel |
|----------|---------------|-------------|
| Aba financeira SalesReportPage | adicionar_pageview (3 linhas CSV) | engenharia |
| Remover ir-para-relatorio (vendas) | Apos PV aba financeira | engenharia |
| CDs sem linha no inventario | Ver [LACUNAS_CD.md](./LACUNAS_CD.md) - filtros, lembrete parcelas, promote share/addToCart | PM + eng |

---

## Pendencias revisar_pm

$revisarLines

---

## Removidos - amostra por criterio

| Criterio | Qtd |
|----------|-----|
$criterioLines

Detalhe completo: ver colunas criterio, notas e diagnostico no CSV.

"@

Set-Content -Path $OutMd -Value $md -Encoding UTF8

Write-Host "Source rows: $($rows.Count)"
Write-Host "Excluded (F1/F2): $fora"
Write-Host "Output rows: $total"
Write-Host "Generic button label fixes: $genericLabelFixes"
Write-Host "Legacy cd_* param enrichments: $cdParamFixes"
Write-Host "Special interaction detail fixes: $specialDetailFixes"
Write-Host "Callback domain prefix fixes: $callbackDomainFixes"
Write-Host "Pageview cd_page_title enrichments: $pageviewFixes"
Write-Host "Rows missing cd_page_title: $($missingPageTitles.Count)"
Write-Host "GA4 envelope / cd_page_title fixes: $envelopeFixes"
Write-Host "Written: $OutCsv"
Write-Host "Written: $OutMd"

& (Join-Path $PSScriptRoot 'export-entrega-eng.ps1') -SourceCsv $OutCsv
& (Join-Path $PSScriptRoot 'generate-resumo-de-para.ps1') -SourceCsv $OutCsv
$stats | ForEach-Object { Write-Host "  $($_.Name): $($_.Count)" }
