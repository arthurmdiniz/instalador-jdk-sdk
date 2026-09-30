#Requires -Version 5.1
<#
    00_Verificar_Ambiente.ps1

    Mostra o que ja esta instalado nesta maquina e o que ainda vai ser baixado.
    Roda sozinho (nao exige administrador) e nao altera nada no sistema.

    Exemplos:
        .\00_Verificar_Ambiente.ps1              # so o relatorio na tela
        .\00_Verificar_Ambiente.ps1 -Log         # grava tambem no install-log.txt
        .\00_Verificar_Ambiente.ps1 -Force       # trata tudo como faltando
#>
[CmdletBinding()]
param(
    [switch]$Log,
    [switch]$Force,
    [switch]$NoPause
)

$ErrorActionPreference = 'Continue'
$ScriptName = '00 - Verificar ambiente'
$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) { $ScriptDir = (Get-Location).Path }

. (Join-Path $ScriptDir 'Lib_Comum.ps1')

# a tela do menu nao deve sujar o install-log.txt; so grava quando pedido
if (-not $Log) { $LogFile = $null }

# ==============================================================================
#  Deteccao
# ==============================================================================
$java    = Test-JavaInstalado
$dotnet  = Test-DotNetInstalado
$vscode  = Test-VsCodeInstalado
$codeCmd = Get-CodeCmd

# as extensoes so podem ser conferidas se o VS Code existir; alem disso os passos
# 04 e 05 dependem do 03, entao o motivo entra na linha
# (nomes diferentes de $Script:ListaExt* de proposito: o PowerShell nao diferencia
#  maiusculas, e usar o mesmo nome sobrescreveria a lista da lib)
$resJava   = Compare-Extensoes -Desejadas $Script:ListaExtJava   -CodeCmd $codeCmd
$resCSharp = Compare-Extensoes -Desejadas $Script:ListaExtCSharp -CodeCmd $codeCmd
$semCode   = -not $codeCmd
$depende   = ' (depende do passo 03)'

# o que ainda vai ser baixado
$baixar = @()
foreach ($p in $Script:Passos) {
    $local = @(Get-InstaladorLocal -Passo $p)
    if ($local.Count -eq 0) { $baixar += $p }
}
$cacheMB = Get-CacheInstaladores

# ==============================================================================
#  Relatorio
# ==============================================================================
function Linha {
    param([string]$Item, [string]$Status, [string]$Detalhe, [string]$Cor = 'Gray')
    $preenche = 34 - $Item.Length - $Status.Length
    if ($preenche -lt 1) { $preenche = 1 }
    $texto = ('{0}{1}{2}{3}' -f $Item, (' ' * $preenche), $Status, (' ' * 1))
    Write-Host $texto -NoNewline -ForegroundColor $Cor
    Write-Host $Detalhe -ForegroundColor DarkGray
}

$faltaAlgo = $false

Write-Host ''
Write-Host ' Situacao desta maquina' -ForegroundColor Cyan
Write-Host ' ----------------------------------------------' -ForegroundColor DarkGray

if ($java.Ok) { Linha 'Java (OpenJDK)'      '[ OK ]' $java.Detalhe 'Green' }
else { $faltaAlgo = $true; Linha 'Java (OpenJDK)' '[FALTA]' $java.Detalhe 'Yellow' }

if ($dotnet.Ok) { Linha 'SDK .NET 10'        '[ OK ]' $dotnet.Detalhe 'Green' }
else { $faltaAlgo = $true; Linha 'SDK .NET 10' '[FALTA]' $dotnet.Detalhe 'Yellow' }

if ($vscode.Ok) { Linha 'VS Code'            '[ OK ]' $vscode.Detalhe 'Green' }
elseif ($vscode.SoUsuario) {
    # nao e erro do kit: o passo 03 exige a instalacao system, que nao existe
    $faltaAlgo = $true
    Linha 'VS Code' '[AVISO]' 'instalado so por usuario; o passo 03 instala a system' 'Yellow'
}
else { $faltaAlgo = $true; Linha 'VS Code' '[FALTA]' $vscode.Detalhe 'Yellow' }

if ($semCode) {
    $faltaAlgo = $true
    Linha 'Ext. Java' '[FALTA]' ('VS Code ausente' + $depende) 'Yellow'
    Linha 'Ext. C#'   '[FALTA]' ('VS Code ausente' + $depende) 'Yellow'
} else {
    if ($resJava.Faltando.Count -eq 0) {
        Linha 'Ext. Java' '[ OK ]' $Script:ListaExtJava[0].id 'Green'
    } else {
        $faltaAlgo = $true
        foreach ($e in $resJava.Faltando) { Linha 'Ext. Java' '[FALTA]' $e.id 'Yellow' }
    }
    if ($resCSharp.Faltando.Count -eq 0) {
        Linha 'Ext. C#'   '[ OK ]' ('3 extensoes') 'Green'
    } else {
        $faltaAlgo = $true
        foreach ($e in $resCSharp.Faltando) { Linha 'Ext. C#' '[FALTA]' $e.id 'Yellow' }
    }
}

Write-Host ' ----------------------------------------------' -ForegroundColor DarkGray
if ($Force) {
    Write-Host ' -Force: tudo sera reinstalado, mesmo o que ja esta pronto.' -ForegroundColor Magenta
} elseif ($baixar.Count -eq 0) {
    Write-Host (' Cache: {0:N1} MB em Installers\, nada a baixar.' -f $cacheMB) -ForegroundColor Green
} else {
    $total = 0
    foreach ($p in $baixar) { $total += $p.MB }
    $nomes = ($baixar | ForEach-Object { $_.Nome }) -join ', '
    Write-Host (' Cache: {0:N1} MB ja em Installers\.' -f $cacheMB) -ForegroundColor Gray
    Write-Host (' Baixar: {0:N1} MB ({1})' -f $total, $nomes) -ForegroundColor Yellow
}
Write-Host ''

if ($Force) {
    Write-Host ' O item 7 do menu reinstala todos os passos, com -Force.' -ForegroundColor DarkGray
} elseif ($faltaAlgo) {
    Write-Host ' A opcao 1 do menu instala apenas o que falta.' -ForegroundColor DarkGray
} else {
    Write-Host ' Tudo pronto. A opcao 1 nao tem nada a fazer.' -ForegroundColor DarkGray
}
Write-Host ''

Exit-Pause 0
