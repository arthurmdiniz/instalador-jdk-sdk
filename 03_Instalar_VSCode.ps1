#Requires -Version 5.1
<#
    03_Instalar_VSCode.ps1 - instala o Visual Studio Code para a maquina (SYSTEM)

    Sem argumentos: pula se ja houver instalacao em Program Files.
    -Force         : reinstala mesmo se ja estiver instalado.
    -NoPause       : nao espera Enter no final (usado pelo menu).

    Usa sempre o instalador SYSTEM (/ALLUSERS). O User Setup nao serve: ele
    instala em %LOCALAPPDATA% e este passo exige C:\Program Files.
#>
[CmdletBinding()]
param(
    [switch]$NoPause,
    [switch]$Force
)

$ErrorActionPreference = 'Continue'
$ScriptName = "03 - Visual Studio Code (system-wide)"
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

$passo = Get-Passo '03'
if (-not $passo) { Exit-Pause 1 }

# ---- 1) ja esta instalado (system)? isto vem ANTES de qualquer download ----
$estado = Test-VsCodeInstalado
if ($estado.Ok -and -not $Force) {
    Write-Warn ('VS Code ja instalado para a maquina (' + $estado.Detalhe + '). Nada a fazer.')
    Write-Log '   -> Para forcar a reinstalacao, use: .\03_Instalar_VSCode.ps1 -Force'
    Exit-Pause 0
}
if ($estado.SoUsuario -and -not $Force) {
    # nao e a instalacao que este passo exige, entao segue para instalar a system
    Write-Warn 'Existe VS Code instalado so por usuario (User Setup).'
    Write-Warn 'Este passo instala a versao system, em C:\Program Files.'
}

# ---- 2) procurar o instalador no cache local ----
$candidates = @(Get-InstaladorLocal -Passo $passo)

# ---- 3) cache vazio: baixar ----
if ($candidates.Count -eq 0) {
    $baixado = Get-Installer $passo.Url
    if (-not $baixado) { Exit-Pause 1 }
    $candidates = @($baixado)
}

# ---- 4) mais de um instalador: nao adivinhar ----
if ($candidates.Count -gt 1) {
    Write-Fail 'Mais de um instalador do VS Code encontrado na pasta:'
    $candidates | ForEach-Object { Write-Log ('   -> ' + $_.Name) }
    Write-Log  '   -> Mantenha apenas um e rode novamente.'
    Exit-Pause 1
}
$exe = $candidates[0]
Write-Log ('Instalador: ' + $exe.Name)

# ---- 5) instalar em silencio para a maquina ----
Write-Log 'Instalando o VS Code para a maquina (Program Files), sem icone na area de trabalho e sem abrir ao terminar...'
$argsInstalador = @('/VERYSILENT', '/NORESTART', '/SP-', '/ALLUSERS', '/MERGETASKS=!runcode,!desktopicon,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath')
$p = Start-Process -FilePath $exe.FullName -ArgumentList $argsInstalador -Wait -PassThru -ErrorAction Stop
if ($p.ExitCode -eq 0) {
    Write-Log 'Instalacao do VS Code concluida.'
} else {
    Write-Fail ('Instalador retornou codigo de erro: ' + $p.ExitCode)
    Exit-Pause 1
}

# ---- 6) verificacao ----
$codeExe = Join-Path $env:ProgramFiles 'Microsoft VS Code\Code.exe'
$codeCmd = Join-Path $env:ProgramFiles 'Microsoft VS Code\bin\code.cmd'
if (-not (Test-Path -LiteralPath $codeExe)) {
    Write-Fail 'VS Code nao foi encontrado em C:\Program Files apos a instalacao.'
    Exit-Pause 1
}
if (Test-Path -LiteralPath $codeCmd) {
    $ver = (& $codeCmd --version 2>$null | Select-Object -First 1 | Out-String).Trim()
    if ($ver) {
        Write-Pass ('VS Code funcional. Versao: ' + $ver)
    } else {
        Write-Pass 'VS Code instalado (Code.exe presente em Program Files).'
    }
} else {
    Write-Pass 'VS Code instalado (Code.exe presente em Program Files).'
}

Write-Log 'Tarefas marcadas: abrir com Code (arquivos e pastas), registrar como editor e adicionar ao PATH.'
Exit-Pause 0
