#Requires -Version 5.1
# ==============================================================================
#  Lib_Comum.ps1 - funcoes compartilhadas pelos scripts do kit
#
#  Carregado com dot-sourcing no inicio de cada script:
#      . (Join-Path $ScriptDir 'Lib_Comum.ps1')
#
#  Este arquivo nao deve ser executado diretamente.
# ==============================================================================

# ---- valores padrao (so definidos se o script que carregou a lib nao os definiu) ----
if (-not $ScriptDir)     { $ScriptDir     = (Get-Location).Path }
if (-not $LogFile)       { $LogFile       = Join-Path $ScriptDir 'install-log.txt' }
if (-not $InstallerDir)  { $InstallerDir  = Join-Path $ScriptDir 'Installers' }

# ---- passos do kit: fonte unica de verdade para URLs, padroes de arquivo e tamanho ----
# 'Url'      endereco oficial usado quando o instalador nao esta no cache
# 'Padrao'   como o arquivo e localizado dentro da pasta (usado com -like)
# 'MB'       tamanho aproximado, so para mostrar ao usuario no relatorio
$Script:Passos = @(
    @{ Passo = '01'; Nome = 'OpenJDK 25';   Url = 'https://aka.ms/download-jdk/microsoft-jdk-25.0.4.1-windows-x64.msi'
       Padrao = 'microsoft-jdk-*windows-x64*'; Ext = '.msi'; MB = 188.8 }
    @{ Passo = '02'; Nome = 'SDK .NET 10';  Url = 'https://builds.dotnet.microsoft.com/dotnet/Sdk/10.0.401/dotnet-sdk-10.0.401-win-x64.exe'
       Padrao = 'dotnet-sdk-*win-x64*';       Ext = '.exe'; MB = 205.5 }
    @{ Passo = '03'; Nome = 'VS Code';       Url = 'https://update.code.visualstudio.com/latest/win32-x64/stable'
       Padrao = 'VSCode*Setup*x64*';          Ext = '.exe'; MB = 222.1 }
)

# ---- extensoes instaladas pelo VS Code: fonte unica de verdade ----
# Atencao ao nome: estes nomes nao podem se repetir em variaveis locais dos
# scripts, porque o PowerShell diferencia maiusculas/minusculas ($extJava e o
# mesmo que $Script:ExtJava e acabaria sobrescrevendo esta lista).
$Script:ListaExtJava = @(
    @{ id = 'vscjava.vscode-java-pack'; nome = 'Extension Pack for Java' }
)

$Script:ListaExtCSharp = @(
    @{ id = 'ms-dotnettools.csharp';                nome = 'C#' },
    @{ id = 'ms-dotnettools.csdevkit';              nome = 'C# Dev Kit' },
    @{ id = 'ms-dotnettools.vscode-dotnet-runtime'; nome = '.NET Runtime' }
)

# ---- registro em log / console ----
function Write-Log {
    param([string]$m)
    $linha = '{0}  {1}' -f (Get-Date -Format 'HH:mm:ss'), $m
    Write-Host $linha
    if ($LogFile) { Add-Content -LiteralPath $LogFile -Value $linha -ErrorAction SilentlyContinue }
}
function Write-Pass {
    param([string]$m)
    $linha = '  [PASS] ' + $m
    Write-Host $linha -ForegroundColor Green
    if ($LogFile) { Add-Content -LiteralPath $LogFile -Value $linha -ErrorAction SilentlyContinue }
}
function Write-Fail {
    param([string]$m)
    $linha = '  [FAIL] ' + $m
    Write-Host $linha -ForegroundColor Red
    if ($LogFile) { Add-Content -LiteralPath $LogFile -Value $linha -ErrorAction SilentlyContinue }
}
function Write-Warn {
    param([string]$m)
    $linha = '  [SKIP] ' + $m
    Write-Host $linha -ForegroundColor Yellow
    if ($LogFile) { Add-Content -LiteralPath $LogFile -Value $linha -ErrorAction SilentlyContinue }
}

# ---- sai do script, com pausa a menos quando chamado com -NoPause ----
function Exit-Pause {
    param([int]$code = 0)
    if (-not $NoPause -and $Host.Name -eq 'ConsoleHost') {
        Read-Host "`nPressione Enter para finalizar..." | Out-Null
    }
    exit $code
}

# ---- dados do passo (URL, padrao de arquivo, tamanho) ----
function Get-Passo {
    param([Parameter(Mandatory = $true)][string]$Id)
    $achado = $Script:Passos | Where-Object { $_.Passo -eq $Id }
    if (-not $achado) {
        Write-Fail ("Passo '{0}' nao encontrado em Lib_Comum.ps1" -f $Id)
        return $null
    }
    return $achado
}

# ==============================================================================
#  Deteccao do que ja esta instalado
#  Cada funcao devolve @{ Ok = $true|false ; Detalhe = 'texto curto' }
# ==============================================================================

# ---- Java (OpenJDK / Temurin) pelo registro do Windows ----
function Test-JavaInstalado {
    $achados = @()
    foreach ($raiz in @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )) {
        # -Path e nao -LiteralPath: o caminho tem curinga e so o -Path expande
        $achados += @(Get-ItemProperty -Path $raiz -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -like '*OpenJDK*' -or $_.DisplayName -like '*Temurin*' })
    }
    if ($achados.Count -gt 0) {
        $versao = ''
        foreach ($a in $achados) {
            if ($a.DisplayVersion) { $versao = $a.DisplayVersion; break }
        }
        return @{ Ok = $true; Detalhe = $(if ($versao) { "OpenJDK $versao" } else { 'OpenJDK' }) }
    }
    # fallback: o comando java no PATH
    # o 'java -version' escreve em stderr; passing pelo cmd.exe faz a fusao dos
    # dois fluxos no SO, e o PowerShell nao cria registro de erro na tela
    $cmd = Get-Command 'java.exe' -ErrorAction SilentlyContinue
    if ($cmd) {
        $v = (& cmd.exe /c 'java -version 2>&1' | Select-Object -First 1 | Out-String).Trim()
        $v = ($v -replace '.*?version\s+"?', '' -replace '".*', '').Trim()
        if (-not $v) { $v = 'versao desconhecida' }
        return @{ Ok = $true; Detalhe = "java $v (PATH)" }
    }
    return @{ Ok = $false; Detalhe = 'nao instalado' }
}

# ---- SDK .NET 10 pela pasta sdk do dotnet ----
function Test-DotNetInstalado {
    $dotnet = Join-Path $env:ProgramFiles 'dotnet\dotnet.exe'
    $sdkDirs = @(Get-ChildItem (Join-Path $env:ProgramFiles 'dotnet\sdk') -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -like '10.*' })
    if ($sdkDirs.Count -gt 0) {
        $versao = ''
        if (Test-Path -LiteralPath $dotnet) {
            $versao = (& $dotnet --version 2>$null | Out-String).Trim()
        }
        if (-not $versao) { $versao = $sdkDirs[0].Name }
        return @{ Ok = $true; Detalhe = "SDK .NET $versao" }
    }
    return @{ Ok = $false; Detalhe = 'SDK .NET 10 nao instalado' }
}

# ---- caminho do executavel do VS Code (system primeiro, depois usuario) ----
function Get-CodeCmd {
    foreach ($c in @(
        (Join-Path $env:ProgramFiles 'Microsoft VS Code\bin\code.cmd'),
        (Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin\code.cmd')
    )) {
        if (Test-Path -LiteralPath $c) { return $c }
    }
    return $null
}

# ---- VS Code ----
# Ok       = existe instalacao SYSTEM (e a que o passo 03 exige)
# SoUsuario= existe, mas so por usuario -> o passo 03 precisa instalar a system
function Test-VsCodeInstalado {
    $system = Test-Path -LiteralPath (Join-Path $env:ProgramFiles 'Microsoft VS Code\Code.exe')
    $usuario = Test-Path -LiteralPath (Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\Code.exe')
    $versao = ''
    $cmd = Get-CodeCmd
    if ($cmd) { $versao = (& $cmd --version 2>$null | Select-Object -First 1 | Out-String).Trim() }
    if ($system) {
        return @{ Ok = $true; SoUsuario = $false; Detalhe = "$versao (system)" }
    }
    if ($usuario) {
        return @{ Ok = $false; SoUsuario = $true; Detalhe = "$versao (so por usuario)" }
    }
    return @{ Ok = $false; SoUsuario = $false; Detalhe = 'nao instalado' }
}

# ---- extensoes ja instaladas no VS Code ----
# Le a lista UMA vez e compara com os ids desejados.
# Devolve @{ Instaladas = @(); Faltando = @( @{id=..; nome=..} ) }
function Compare-Extensoes {
    param(
        [Parameter(Mandatory = $true)]$Desejadas,
        [string]$CodeCmd
    )
    if (-not $CodeCmd) {
        return @{ Instaladas = @(); Faltando = @($Desejadas) }
    }
    $instaladas = @()
    try { $instaladas = @(& $CodeCmd --list-extensions 2>$null | ForEach-Object { $_.Trim() } | Where-Object { $_ }) } catch { $instaladas = @() }
    $faltando = @($Desejadas | Where-Object { $instaladas -notcontains $_.id })
    return @{ Instaladas = $instaladas; Faltando = $faltando }
}

# ==============================================================================
#  Cache local e download
# ==============================================================================

# ---- tamanho, em MB, do que ja esta em cache em Installers\ ----
function Get-CacheInstaladores {
    if (-not (Test-Path -LiteralPath $InstallerDir)) { return 0.0 }
    $bytes = (Get-ChildItem -LiteralPath $InstallerDir -File -ErrorAction SilentlyContinue |
        Measure-Object -Property Length -Sum).Sum
    if ($null -eq $bytes) { return 0.0 }
    return [math]::Round($bytes / 1MB, 1)
}

# ---- procura o instalador de um passo no cache e na raiz da pasta ----
function Get-InstaladorLocal {
    param([Parameter(Mandatory = $true)]$Passo)
    $achados = @()
    foreach ($pasta in @($InstallerDir, $ScriptDir)) {
        if (Test-Path -LiteralPath $pasta) {
            $achados += @(Get-ChildItem -LiteralPath $pasta -File -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -like $Passo.Padrao -and $_.Extension -eq $Passo.Ext })
        }
    }
    return $achados
}

# ---- baixa o instalador quando ele nao esta no cache ----
function Get-Installer {
    param([Parameter(Mandatory = $true)][string]$Url)

    if (-not (Test-Path -LiteralPath $InstallerDir)) {
        New-Item -ItemType Directory -Path $InstallerDir -Force | Out-Null
    }

    $tmp = Join-Path $InstallerDir '_download.tmp'
    $destino = $null

    # sobra de um download anterior interrompido nao pode ficar no caminho
    if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue }

    try {
        Write-Log 'Instalador ausente na pasta local. Consultando o endereco...'

        $req = [Net.HttpWebRequest]::Create($Url)
        $req.Method = 'HEAD'
        $req.AllowAutoRedirect = $true
        $req.Timeout = 60000
        $resp = $req.GetResponse()
        $status = [int]$resp.StatusCode
        $tipo   = [string]$resp.ContentType
        $nome   = [IO.Path]::GetFileName($resp.ResponseUri.AbsolutePath)
        $total  = [int64]$resp.ContentLength
        $resp.Close()

        if ($status -ne 200) { throw "o servidor respondeu HTTP $status" }
        if ($tipo -and $tipo -match '^(text/|application/xhtml)') { throw "o endereco devolveu uma pagina web ($tipo) em vez do instalador" }
        if ([string]::IsNullOrWhiteSpace($nome) -or $nome -notmatch '\.') { throw 'o endereco nao devolveu um nome de arquivo valido' }
        if ($total -le 0) { throw 'o servidor nao informou o tamanho do arquivo' }

        $destino = Join-Path $InstallerDir $nome
        Write-Log ('Baixando ' + $nome + ' (' + ('{0:N1}' -f ($total / 1MB)) + ' MB). Aguarde...')

        $wc = New-Object Net.WebClient
        $wc.DownloadFile($Url, $tmp)
        $wc.Dispose()
        Move-Item -LiteralPath $tmp -Destination $destino -Force
    } catch {
        if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue }
        Write-Fail ('Falha no download: ' + $_.Exception.Message)
        Write-Log ('   -> Endereco: ' + $Url)
        Write-Log '   -> Confira a conexao com a internet e tente de novo, ou baixe'
        Write-Log '      o arquivo em outra maquina e coloque na pasta Installers\'
        return $null
    }

    $item = Get-Item -LiteralPath $destino
    if ($item.Length -ne $total) {
        Write-Fail ('Download incompleto: esperado {0:N1} MB, veio {1:N1} MB.' -f ($total / 1MB), ($item.Length / 1MB))
        Remove-Item -LiteralPath $destino -Force -ErrorAction SilentlyContinue
        return $null
    }
    Write-Pass ('Instalador baixado: ' + $item.Name + ' (' + ('{0:N1}' -f ($item.Length / 1MB)) + ' MB)')
    return $item
}

# ---- TLS 1.2 para as conexoes de download ----
try {
    [Net.ServicePointManager]::SecurityProtocol =
        [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11
} catch {
    # versao antiga do .NET: segue com o padrao do sistema
}
