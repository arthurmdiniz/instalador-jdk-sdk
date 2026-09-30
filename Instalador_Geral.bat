@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

rem ---- aviso: executar como administrador ----
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo IMPORTANTE: este arquivo deve ser executado COMO ADMINISTRADOR.
    echo Feche esta janela, clique com o botao DIREITO em
    echo Instalador_Geral.bat e escolha "Executar como administrador".
    echo.
    pause
    exit /b
)

:MENU
cls
echo ================================================
echo    KIT DE INSTALACAO - Java e C# com VS Code
echo   o que falta e instalado, o que ja esta e pulado
echo ================================================
echo.
if exist "00_Verificar_Ambiente.ps1" (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "00_Verificar_Ambiente.ps1" -NoPause
) else (
    echo  [aviso] 00_Verificar_Ambiente.ps1 nao encontrado nesta pasta.
    echo.
)
echo   1 - Instalacao completa (so o que falta)
echo   2 - OpenJDK 25 (Java)
echo   3 - SDK .NET 10 (C#)
echo   4 - Visual Studio Code
echo   5 - Extensoes do Java
echo   6 - Extensoes do C#
echo   7 - Reinstalar TUDO, ignorando o que ja existe
echo   0 - Sair
echo.
set /p OPCAO=  Digite a opcao desejada e tecle Enter: 

rem 'set /p' devolve erro quando a entrada acabou (nao quando o usuario aperta
rem Enter vazio). Sem esta guarda, execucao sem teclado entraria em laco.
if errorlevel 1 exit /b 0

if "%OPCAO%"=="1" goto COMPLETA
if "%OPCAO%"=="2" goto JDK
if "%OPCAO%"=="3" goto DOTNET
if "%OPCAO%"=="4" goto VSCODE
if "%OPCAO%"=="5" goto EXJAVA
if "%OPCAO%"=="6" goto EXCSHARP
if "%OPCAO%"=="7" goto REINSTALAR
if "%OPCAO%"=="0" exit /b 0
goto MENU

rem Cada script ja se pula sozinho quando o que ele instala ja existe,
rem por isso a opcao 1 pode chamar os cinco direto: o que falta e feito,
rem o que ja esta vira [SKIP] sem baixar nada.
:COMPLETA
echo.
echo Iniciando instalacao dos passos que faltam...
rem -NoPause: a janela deste .bat ja esta aberta, entao nao ha
rem necessidade de cada script esperar por Enter ao final.
call :RUN "01_Instalar_JDK.ps1" -NoPause
call :RUN "02_Instalar_SDKDotNet.ps1" -NoPause
call :RUN "03_Instalar_VSCode.ps1" -NoPause
call :RUN "04_Extensoes_Java.ps1" -NoPause
call :RUN "05_Extensoes_CSharp.ps1" -NoPause
echo.
echo ===== Instalacao concluida. =====
echo Resultado completo no install-log.txt. Leia antes de fechar.
pause
goto MENU

:REINSTALAR
echo.
echo ATENCAO: isto vai REINSTALAR tudo, mesmo o que ja esta pronto.
echo Os passos 04 e 05 vao reinstalar as extensoes do zero.
set /p CERTO=  Tem certeza? Digite SIM para continuar: 
if /i not "%CERTO%"=="SIM" (
    echo.
    echo Cancelado. Nada foi alterado.
    pause
    goto MENU
)
echo.
echo Reinstalando tudo...
call :RUN "01_Instalar_JDK.ps1" -NoPause -Force
call :RUN "02_Instalar_SDKDotNet.ps1" -NoPause -Force
call :RUN "03_Instalar_VSCode.ps1" -NoPause -Force
call :RUN "04_Extensoes_Java.ps1" -NoPause -Force
call :RUN "05_Extensoes_CSharp.ps1" -NoPause -Force
echo.
echo ===== Reinstalacao concluida. =====
echo Resultado completo no install-log.txt. Leia antes de fechar.
pause
goto MENU

:JDK
call :RUN "01_Instalar_JDK.ps1"
goto MENU

:DOTNET
call :RUN "02_Instalar_SDKDotNet.ps1"
goto MENU

:VSCODE
call :RUN "03_Instalar_VSCode.ps1"
goto MENU

:EXJAVA
call :RUN "04_Extensoes_Java.ps1"
goto MENU

:EXCSHARP
call :RUN "05_Extensoes_CSharp.ps1"
goto MENU

rem %1 = script   %2 = argumentos extras (ex.: -NoPause -Force)
:RUN
echo.
echo ================================================
echo  Executando: %~1
echo ================================================
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0%~1" %2
goto :eof
