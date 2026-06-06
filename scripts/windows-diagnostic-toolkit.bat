@echo off
title Windows Diagnostic Toolkit
color 0

:main
cls
echo ================================================
echo             WINDOWS DIAGNOSTIC TOOLKIT
echo ================================================
echo  [1]  Check and Repair Disk (CHKDSK)
echo  [2]  Repair System Files (SFC)
echo  [3]  Clean Temporary Files
echo  [4]  Network Connectivity Test (Ping)
echo  [5]  Restart Network Services
echo  [6]  Flush DNS Cache
echo  [7]  Backup Drivers
echo  [8]  Check Windows Updates
echo  [9]  Display System Information
echo  [10] Execute Custom Command
echo  [0]  Exit
echo ================================================
set /p option=Select an option: 

if "%option%"=="1" goto chkdsk
if "%option%"=="2" goto sfc
if "%option%"=="3" goto clean_temp
if "%option%"=="4" goto ping_test
if "%option%"=="5" goto restart_network
if "%option%"=="6" goto flush_dns
if "%option%"=="7" goto backup_drivers
if "%option%"=="8" goto windows_updates
if "%option%"=="9" goto system_info
if "%option%"=="10" goto custom_command
if "%option%"=="0" exit
goto invalid_option

:chkdsk
cls
echo Checking disk...
chkdsk C:
pause
goto main

:sfc
cls
echo Repairing system files...
sfc /scannow
pause
goto main

:clean_temp
cls
echo Cleaning temporary files...
del /q /s "%TEMP%\*.*"
echo Temporary files cleanup completed.
pause
goto main

:ping_test
cls
echo Testing network connectivity...
ping 8.8.8.8
pause
goto main

:restart_network
cls
echo Restarting network services...
net stop "Dnscache"
net stop "Dhcp"
net stop "Netlogon"
net stop "LanmanServer"
net start "Dnscache"
net start "Dhcp"
net start "Netlogon"
net start "LanmanServer"
echo Network services restarted.
pause
goto main

:flush_dns
cls
echo Flushing DNS cache...
ipconfig /flushdns
pause
goto main

:backup_drivers
cls
echo Creating drivers backup...
mkdir C:\BackupDrivers
pnputil /export-driver * C:\BackupDrivers
echo Drivers backup completed.
pause
goto main

:windows_updates
cls
echo Checking Windows updates...
powershell Get-WindowsUpdateLog
pause
goto main

:system_info
cls
echo Displaying system information...
systeminfo
pause
goto main

:custom_command
cls
set /p command=Enter the command to execute: 
%command%
pause
goto main

:invalid_option
echo Invalid option. Please try again.
pause
goto main