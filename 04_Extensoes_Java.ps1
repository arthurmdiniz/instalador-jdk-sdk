#Requires -Version 5.1
<#
    04_Extensoes_Java.ps1 - instala o Extension Pack for Java pelo VS Code

    Sem argumentos: pula as extensoes que ja estiverem instaladas.
    -Force         : reinstala todas, mesmo as que ja existem.
    -NoPause       : nao espera Enter no final (usado pelo menu).

    O proprio VS Code baixa da loja oficial; por isso este passo usa a internet.
#>
[CmdletBinding()]
param(
    [switch]$NoPause,
    [switch]$Force
)

$ErrorActionPreference = 'Continue'
$ScriptName = "04 - Extensoes Java"
$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) { $ScriptDir = (Get-Location).Path }

. (Join-Path $ScriptDir 'Lib_Comum.ps1')

# ---- aviso: deve ser executado como administrador ----
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host 'ATENCAO: este script deve ser executado como ADMINISTRADOR.'
    Write-Host 'Feche e abra novamente com botao direito > Executar como administrador.'
    Exit-Pause 1
}

Write-Log ('========================================')
Write-Log (' ' + $ScriptName)
Write-Log ('========================================')

$codeCmd = Get-CodeCmd
if (-not $codeCmd) {
    Write-Fail 'VS Code nao encontrado. Execute primeiro o passo 03 (Instalar VS Code).'
    Exit-Pause 1
}
Write-Log ('VS Code: ' + $codeCmd)

# ---- o que ja esta instalado ----
$desejadas = $Script:ListaExtJava
$comparacao = Compare-Extensoes -Desejadas $desejadas -CodeCmd $codeCmd
$aInstalar = $comparacao.Faltando
if ($Force) { $aInstalar = @($desejadas) }

if ($aInstalar.Count -eq 0) {
    foreach ($e in $desejadas) { Write-Warn ($e.nome + ' ja instalada (' + $e.id + ').') }
    Write-Log '   -> Para reinstalar, use: .\04_Extensoes_Java.ps1 -Force'
    Exit-Pause 0
}

# ---- instalar pelo identificador ----
$falhas = 0
foreach ($e in $aInstalar) {
    Write-Log ('Instalando ' + $e.nome + ' (' + $e.id + ') ...')
    & $codeCmd --install-extension $e.id --force 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Pass $e.nome
    } else {
        Write-Fail ('Falha ao instalar ' + $e.id + ' (codigo ' + $LASTEXITCODE + ')')
        $falhas++
    }
}

if ($falhas -gt 0) {
    Write-Warn ("$falhas extensao(oes) com problema - reinicie o VS Code e tente de novo.")
    Write-Log '   -> Se persistir, instale pelo VS Code: Ctrl+Shift+X e busque'
    Write-Log '      por "Extension Pack for Java".'
    Exit-Pause 1
}

Write-Pass 'Extensoes do Java instaladas.'
Exit-Pause 0
