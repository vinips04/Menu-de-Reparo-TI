@echo off
title Menu de Reparo e Diagnostico de TI
color 0

:inicio
cls
echo ===============================================
echo          MENU DE REPARO E DIAGNOSTICO DE TI
echo ===============================================
echo  [1]  Verificar e Reparar Disco (CHKDSK)
echo  [2]  Reparar Arquivos de Sistema (SFC)
echo  [3]  Limpar Arquivos Temporarios
echo  [4]  Verificar Conectividade de Rede (Ping)
echo  [5]  Reiniciar Servicos de Rede
echo  [6]  Limpar Cache DNS
echo  [7]  Backup de Drivers
echo  [8]  Verificar Atualizacoes do Windows
echo  [9]  Exibir Informacoes do Sistema
echo  [10] Executar Comando Personalizado
echo  [0]  Sair
echo ===============================================
set /p op=Escolha uma opcao: 

if "%op%"=="1" goto chkdsk
if "%op%"=="2" goto sfc
if "%op%"=="3" goto limpar_temp
if "%op%"=="4" goto ping
if "%op%"=="5" goto restart_net
if "%op%"=="6" goto dns
if "%op%"=="7" goto backup
if "%op%"=="8" goto updates
if "%op%"=="9" goto info
if "%op%"=="10" goto cmd
if "%op%"=="0" exit
goto invalido

:chkdsk
cls
echo Verificando disco...
chkdsk C:
pause
goto inicio

:sfc
cls
echo Reparando arquivos de sistema...
sfc /scannow
pause
goto inicio

:limpar_temp
cls
echo Limpando arquivos temporarios...
del /q /s "%TEMP%\*.*"
echo Limpeza concluida!
pause
goto inicio

:ping
cls
echo Testando conectividade de rede...
ping 8.8.8.8
pause
goto inicio

:restart_net
cls
echo Reiniciando servicos de rede...
net stop "Dnscache"
net stop "Dhcp"
net stop "Netlogon"
net stop "LanmanServer"
net start "Dnscache"
net start "Dhcp"
net start "Netlogon"
net start "LanmanServer"
echo Servicos reiniciados!
pause
goto inicio

:dns
cls
echo Limpando cache DNS...
ipconfig /flushdns
pause
goto inicio

:backup
cls
echo Criando backup dos drivers...
mkdir C:\BackupDrivers
pnputil /export-driver * C:\BackupDrivers
echo Backup concluido!
pause
goto inicio

:updates
cls
echo Verificando atualizacoes do Windows...
powershell Get-WindowsUpdateLog
pause
goto inicio

:info
cls
echo Exibindo informacoes do sistema...
systeminfo
pause
goto inicio

:cmd
cls
set /p comando=Digite o comando desejado: 
%comando%
pause
goto inicio

:invalido
echo Opcao invalida. Tente novamente.
pause
goto inicio
