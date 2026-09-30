#Requires -Version 5.1
<#
    01_Instalar_JDK.ps1 - instala o Microsoft Build of OpenJDK 25

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
$ScriptName = "01 - JDK / OpenJDK 25"
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

$passo = Get-Passo '01'
if (-not $passo) { Exit-Pause 1 }

# ---- 1) ja esta instalado? isto vem ANTES de qualquer download ----
if (-not $Force) {
    $estado = Test-JavaInstalado
    if ($estado.Ok) {
        Write-Warn ('OpenJDK ja instalado (' + $estado.Detalhe + '). Nada a fazer.')
        Write-Log '   -> Para forcar a reinstalacao, use: .\01_Instalar_JDK.ps1 -Force'
        Write-Log '   -> Para conferir a versao, abra um terminal novo e rode: java -version'
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
    Write-Fail 'Mais de um instalador do JDK encontrado na pasta:'
    $candidates | ForEach-Object { Write-Log ('   -> ' + $_.Name) }
    Write-Log  '   -> Mantenha apenas um e rode novamente.'
    Exit-Pause 1
}
$msi = $candidates[0]
Write-Log ('Instalador: ' + $msi.Name)

# ---- 5) instalar em silencio ----
Write-Log 'Instalando OpenJDK 25 em modo silencioso (PATH + .jar + JAVA_HOME)...'
$p = Start-Process -FilePath 'msiexec.exe' -ArgumentList @('/i', ("`"$($msi.FullName)`""), 'ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome', '/qn', '/norestart') -Wait -PassThru -ErrorAction Stop
if ($p.ExitCode -eq 0 -or $p.ExitCode -eq 3010) {
    Write-Log 'Instalacao do JDK concluida (codigo 0/3010).'
} else {
    Write-Fail ('msiexec retornou codigo de erro: ' + $p.ExitCode)
    Exit-Pause 1
}

# ---- 6) verificacao ----
$javaExe = $null
$javaHome = [Environment]::GetEnvironmentVariable('JAVA_HOME', 'Machine')
if ($javaHome) { $cand = Join-Path $javaHome 'bin\java.exe'; if (Test-Path $cand) { $javaExe = $cand } }
if (-not $javaExe) {
    $jdk = @(Get-ChildItem 'C:\Program Files\Microsoft\jdk-25*' -Directory -ErrorAction SilentlyContinue) | Sort-Object Name -Descending | Select-Object -First 1
    if ($jdk) { $cand = Join-Path $jdk.FullName 'bin\java.exe'; if (Test-Path $cand) { $javaExe = $cand } }
}
if (-not $javaExe) {
    Write-Warn 'java.exe nao localizado (instalacao pode estar em outro caminho).'
    Write-Warn 'Verifique manualmente abrindo um novo terminal e rodando: java -version'
    Exit-Pause 1
}

# o 'java -version' escreve em stderr; o cmd.exe junta os fluxos e o PowerShell
# nao transforma isso em registro de erro
$saida = (& cmd.exe /c "`"$javaExe`" -version 2>&1" | Out-String).Trim()
$primeiraLinha = ($saida -split "`r?`n")[0]
if ($primeiraLinha -match 'openjdk\s+2\d') {
    Write-Pass 'OpenJDK 25 instalado e funcional.'
    Write-Log ('   ' + $primeiraLinha)
} else {
    Write-Fail ('java.exe encontrado, mas versao inesperada: ' + $primeiraLinha)
    Exit-Pause 1
}

Write-Log 'Obs: abra um novo CMD/Terminal para o comando java funcionar no PATH.'
Exit-Pause 0
