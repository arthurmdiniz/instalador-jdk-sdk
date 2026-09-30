#Requires -Version 5.1
<#
    02_Instalar_SDKDotNet.ps1 - instala o SDK .NET 10

    Sem argumentos: pula se ja estiver instalado.
    -Force         : reinstala mesmo se ja estiver instalado.
    -NoPause       : nao espera Enter no final (usado pelo menu).
#>
[CmdletBinding()]
param(
    [switch]$NoPause,
    [switch]$Force
)

$ErrorActionPreference = 'Continue'
$ScriptName = "02 - SDK .NET 10"
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

$passo = Get-Passo '02'
if (-not $passo) { Exit-Pause 1 }

# ---- 1) ja esta instalado? isto vem ANTES de qualquer download ----
if (-not $Force) {
    $estado = Test-DotNetInstalado
    if ($estado.Ok) {
        Write-Warn ('SDK .NET ja instalado (' + $estado.Detalhe + '). Nada a fazer.')
        Write-Log '   -> Para forcar a reinstalacao, use: .\02_Instalar_SDKDotNet.ps1 -Force'
        Write-Log '   -> Para conferir a versao, abra um terminal novo e rode: dotnet --version'
        Exit-Pause 0
    }
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
    Write-Fail 'Mais de um instalador do SDK .NET encontrado na pasta:'
    $candidates | ForEach-Object { Write-Log ('   -> ' + $_.Name) }
    Write-Log  '   -> Mantenha apenas um e rode novamente.'
    Exit-Pause 1
}
$exe = $candidates[0]
Write-Log ('Instalador: ' + $exe.Name)

# ---- 5) instalar em silencio ----
Write-Log 'Instalando o SDK .NET 10 em modo silencioso...'
$p = Start-Process -FilePath $exe.FullName -ArgumentList @('/install', '/quiet', '/norestart') -Wait -PassThru -ErrorAction Stop
if ($p.ExitCode -eq 0 -or $p.ExitCode -eq 3010) {
    Write-Log 'Instalacao do SDK .NET concluida (codigo 0/3010).'
} else {
    Write-Fail ('Instalador retornou codigo de erro: ' + $p.ExitCode)
    Exit-Pause 1
}

# ---- 6) verificacao ----
$dotnetExe = Join-Path $env:ProgramFiles 'dotnet\dotnet.exe'
if (-not (Test-Path -LiteralPath $dotnetExe)) {
    Write-Fail 'dotnet.exe nao encontrado em C:\Program Files\dotnet\'
    Write-Warn 'Verifique manualmente abrindo um novo terminal e rodando: dotnet --version'
    Exit-Pause 1
}
$ver = (& $dotnetExe --version 2>$null | Out-String).Trim()
if ($ver -match '^10\.') {
    Write-Pass ('SDK .NET funcional. Versao: ' + $ver)
} else {
    Write-Fail ('Versao inesperada do SDK .NET: ' + $ver)
    Exit-Pause 1
}

Write-Log 'Obs: abra um novo CMD/Terminal para o comando dotnet funcionar no PATH.'
Exit-Pause 0
