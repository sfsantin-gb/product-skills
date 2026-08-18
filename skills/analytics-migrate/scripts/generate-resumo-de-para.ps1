[CmdletBinding()]
param(
    [string]$SourceCsv = '',
    [string]$OutMd = '',
    [string]$PerguntasMd = ''
)

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
if (-not $SourceCsv) {
    $SourceCsv = Join-Path $repoRoot 'tools\analytics-migrate\output\TAGUEAMENTO_MIGRADO_CT.csv'
}
if (-not $OutMd) {
    $OutMd = Join-Path $repoRoot 'tools\analytics-migrate\output\RESUMO_DE_PARA.md'
}
if (-not $PerguntasMd) {
    $outParent = Split-Path $SourceCsv -Parent
    $impacto = Join-Path $outParent 'IMPACTO_MIGRACAO.md'
    $legadoNome = Join-Path $outParent 'PERGUNTAS_NEGOCIO.md'
    $PerguntasMd = if (Test-Path $impacto) { $impacto } else { $legadoNome }
}

$data = Get-Date -Format 'yyyy-MM-dd'
$total = 0
$migrar = 0
$remover = 0
$manter = 0
$novo = 0
$revisar = 0
$comJson = 0

if (Test-Path $SourceCsv) {
    $rows = Import-Csv $SourceCsv -Encoding UTF8
    $total = $rows.Count
    $migrar = @($rows | Where-Object { $_.status -eq 'migrar' }).Count
    $remover = @($rows | Where-Object { $_.status -eq 'remover' }).Count
    $manter = @($rows | Where-Object { $_.status -eq 'manter' }).Count
    $novo = @($rows | Where-Object { $_.status -eq 'adicionar_pageview' }).Count
    $revisar = @($rows | Where-Object { $_.status -eq 'revisar' }).Count
    $comJson = @($rows | Where-Object { $_.json_novo }).Count
}

$impactoNome = Split-Path $PerguntasMd -Leaf
$csvNome = Split-Path $SourceCsv -Leaf
$perguntasExists = Test-Path $PerguntasMd
$entregaExists = Test-Path (Join-Path (Split-Path $SourceCsv -Parent) 'ENTREGA_ENG.csv')

$md = @"
# Resumo de-para — migracao tagueamento

> Gerado em **$data** para revisao PM antes da entrega a engenharia.

## Numeros gerais

| Metrica | Valor |
|---------|-------|
| Inventario C&T (linhas) | $total |
| **Migrar** (interaction/callback) | $migrar |
| **Remover** | $remover |
| **Manter** (pageview ok — sem trabalho eng) | $manter |
| **Novo** (`adicionar_pageview`) | $novo |
| Revisar PM | $revisar |
| Linhas com `json_novo` preenchido | $comJson |

## Proximos passos PM

1. Baixar **[$csvNome](./$csvNome)** — planilha completa: cada linha tem `status` e **motivo** (`notas`)
2. Se discordar, pintar/filtrar no Excel e falar o que muda; o agente aplica
3. Entregar **[ENTREGA_ENG.csv](./ENTREGA_ENG.csv)** para engenharia (so implementacao, sem o ensaio do motivo)
4. Impacto (gate 4): **[$impactoNome](./$impactoNome)** $(if ($perguntasExists) { '(revisado)' } else { '*(ainda nao gerado)*' })

## Dois CSVs

| Artefato | Para quem | Descricao |
|----------|-----------|-----------|
| **[$csvNome](./$csvNome)** | PM | Inventario completo: migrar / remover / adicionar / manter **e por que** (`notas`) |
| **[ENTREGA_ENG.csv](./ENTREGA_ENG.csv)** | Eng | $(if ($entregaExists) { 'navbar + dominio + status + JSON legado/novo' } else { 'Gerar com `export-entrega-eng.ps1`' }) |

### Colunas `ENTREGA_ENG.csv`

| Coluna | Uso |
|--------|-----|
| `navbar` | Area / microapp |
| `dominio_ct` | Dominio C&T |
| `status` | Status do de-para (`migrar`, `remover`, `adicionar_pageview`, …) |
| `classificacao` | Acao eng: `novo` \| `migrar` \| `remover` |
| `contexto_legado` | Contexto legivel do evento legado |
| `evento_legado_json` | JSON legado para ctrl+F (vazio em `novo`; reconstruido se vazio nas demais) |
| `json_novo` | Envelope GA4 completo alvo |

Pageviews ja corretos (`manter`) **nao** entram por padrao — use `export-entrega-eng.ps1 -IncludeManter` se precisar referencia.

"@

$outDir = Split-Path $OutMd -Parent
if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}
Set-Content -Path $OutMd -Value $md -Encoding UTF8
Write-Host "Written: $OutMd"
