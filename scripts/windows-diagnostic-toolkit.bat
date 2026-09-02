@echo off
setlocal EnableExtensions DisableDelayedExpansion

title Windows Diagnostic Toolkit
color 07

set "TOOL_NAME=Windows Diagnostic Toolkit"
set "TOOL_VERSION=2.0.0"
set "TOOL_AUTHOR=Vinicius Pereira"

for %%I in ("%~dp0..") do set "PROJECT_ROOT=%%~fI"
if not defined SystemDrive set "SystemDrive=C:"

call :init_logging
call :check_admin
call :write_log "INFO" "Administrator status: %ADMIN_STATUS%"

goto main


:main
cls
call :show_header

echo  [1]  Scan System Drive (CHKDSK)
echo  [2]  Repair System Files (SFC)
echo  [3]  Clean Current User Temporary Files
echo  [4]  Test Network Connectivity (Ping)
echo  [5]  Display Network Configuration
echo  [6]  Flush DNS Cache
echo  [7]  Backup Installed Drivers
echo  [8]  Export System Information
echo  [0]  Exit
echo.
echo ==================================================

choice /c 123456780 /n /m "Select an option: "
set "OPTION=%errorlevel%"

if "%OPTION%"=="9" goto exit_tool
if "%OPTION%"=="8" goto system_info
if "%OPTION%"=="7" goto backup_drivers
if "%OPTION%"=="6" goto flush_dns
if "%OPTION%"=="5" goto network_info
if "%OPTION%"=="4" goto ping_test
if "%OPTION%"=="3" goto clean_temp
if "%OPTION%"=="2" goto sfc
if "%OPTION%"=="1" goto chkdsk

goto invalid_option


:show_header
echo ==================================================
echo              %TOOL_NAME%
echo                   Version %TOOL_VERSION%
echo ==================================================
echo  Developed by: %TOOL_AUTHOR%
echo  Administrator: %ADMIN_STATUS%
echo  Logging: %LOGGING_STATUS%
echo ==================================================
echo.
exit /b 0


:init_logging
set "LOGGING_ENABLED=0"
set "LOGGING_STATUS=Disabled"
set "LOG_DIR=%PROJECT_ROOT%\logs"

set "RUN_TIMESTAMP="
for /f "usebackq delims=" %%I in (`powershell.exe -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'" 2^>nul`) do set "RUN_TIMESTAMP=%%I"
if not defined RUN_TIMESTAMP set "RUN_TIMESTAMP=session_%RANDOM%_%RANDOM%"

if not exist "%LOG_DIR%\" mkdir "%LOG_DIR%" >nul 2>&1
if not exist "%LOG_DIR%\" exit /b 1

set "LOG_FILE=%LOG_DIR%\windows-diagnostic-toolkit_%RUN_TIMESTAMP%.log"
type nul >"%LOG_FILE%" 2>nul
if errorlevel 1 exit /b 1

set "LOGGING_ENABLED=1"
set "LOGGING_STATUS=Enabled"
call :write_log "INFO" "%TOOL_NAME% started."
call :write_log "INFO" "Version: %TOOL_VERSION%"
exit /b 0


:write_log
if not "%LOGGING_ENABLED%"=="1" exit /b 0
setlocal DisableDelayedExpansion
set "LOG_LEVEL=%~1"
set "LOG_MESSAGE=%~2"
setlocal EnableDelayedExpansion
>>"!LOG_FILE!" echo([!date! !time!] [!LOG_LEVEL!] !LOG_MESSAGE!
endlocal
endlocal
exit /b 0


:check_admin
fltmc >nul 2>&1

if errorlevel 1 (
    set "IS_ADMIN=0"
    set "ADMIN_STATUS=No"
) else (
    set "IS_ADMIN=1"
    set "ADMIN_STATUS=Yes"
)

exit /b 0


:require_admin
if "%IS_ADMIN%"=="1" exit /b 0

echo.
echo ==================================================
echo  Administrator privileges are required.
echo ==================================================
echo.
echo  Close the toolkit and run the script using:
echo  Right-click ^> Run as administrator
echo.
call :write_log "WARNING" "Operation blocked because administrator privileges are required."
pause
exit /b 1


:new_output_file
set "OUTPUT_DIR=%TEMP%"
if "%LOGGING_ENABLED%"=="1" set "OUTPUT_DIR=%LOG_DIR%"
if not defined OUTPUT_DIR set "OUTPUT_DIR=%PROJECT_ROOT%"
if not exist "%OUTPUT_DIR%\" set "OUTPUT_DIR=%PROJECT_ROOT%"
set "OUTPUT_FILE=%OUTPUT_DIR%\wdt_%RANDOM%_%RANDOM%.tmp"
exit /b 0


:show_output
if not exist "%OUTPUT_FILE%" exit /b 0
type "%OUTPUT_FILE%"
if "%LOGGING_ENABLED%"=="1" type "%OUTPUT_FILE%" >>"%LOG_FILE%"
del /q "%OUTPUT_FILE%" >nul 2>&1
exit /b 0


:report_result
if "%~2"=="0" (
    echo.
    echo [SUCCESS] %~3
    call :write_log "SUCCESS" "%~1 completed with exit code %~2."
) else (
    echo.
    echo [WARNING] %~3 Review the command output and execution log.
    call :write_log "WARNING" "%~1 completed with exit code %~2."
)
exit /b 0


:chkdsk
cls
call :show_header

call :require_admin
if errorlevel 1 goto main

echo Scanning %SystemDrive% with CHKDSK...
echo.
call :write_log "INFO" "CHKDSK scan started for %SystemDrive%."
call :new_output_file
chkdsk %SystemDrive% /scan >"%OUTPUT_FILE%" 2>&1
set "RESULT=%errorlevel%"
call :show_output
call :report_result "CHKDSK" "%RESULT%" "Disk scan finished."
echo.
pause
goto main


:sfc
cls
call :show_header

call :require_admin
if errorlevel 1 goto main

echo Scanning and repairing protected system files...
echo.
call :write_log "INFO" "SFC scan started."
call :new_output_file
sfc /scannow >"%OUTPUT_FILE%" 2>&1
set "RESULT=%errorlevel%"
call :show_output
call :report_result "SFC" "%RESULT%" "System file scan finished."
echo.
pause
goto main


:clean_temp
cls
call :show_header

set "TEMP_ROOT="
if not defined TEMP goto invalid_temp_path
for %%I in ("%TEMP%") do set "TEMP_ROOT=%%~fI"

if not defined TEMP_ROOT goto invalid_temp_path
if not exist "%TEMP_ROOT%\" goto invalid_temp_path
if "%TEMP_ROOT:~3%"=="" goto invalid_temp_path
if /i "%TEMP_ROOT%"=="%PROJECT_ROOT%" goto invalid_temp_path
if /i "%TEMP_ROOT%"=="%USERPROFILE%" goto invalid_temp_path

echo This operation removes files and folders from:
echo "%TEMP_ROOT%"
echo.
echo Files currently in use will be skipped.
echo.
choice /c YN /n /m "Continue? [Y/N]: "
if errorlevel 2 (
    call :write_log "INFO" "Temporary files cleanup cancelled by the user."
    goto main
)

echo.
echo Cleaning temporary files...
call :write_log "INFO" "Temporary files cleanup started."

del /f /q "%TEMP_ROOT%\*" >nul 2>&1
for /d %%D in ("%TEMP_ROOT%\*") do rd /s /q "%%~fD" >nul 2>&1

echo.
echo Cleanup attempt completed. Locked or in-use items may remain.
call :write_log "INFO" "Temporary files cleanup attempt completed."
echo.
pause
goto main


:invalid_temp_path
echo Unable to validate the current user temporary directory.
call :write_log "ERROR" "Temporary files cleanup blocked because the path could not be validated."
echo.
pause
goto main


:ping_test
cls
call :show_header

set "PING_TARGET=8.8.8.8"
echo Testing connectivity to %PING_TARGET%...
echo.
call :write_log "INFO" "Ping test started for %PING_TARGET%."
call :new_output_file
ping -n 4 %PING_TARGET% >"%OUTPUT_FILE%" 2>&1
set "RESULT=%errorlevel%"
call :show_output
call :report_result "Ping test" "%RESULT%" "Connectivity test finished."
echo.
pause
goto main


:network_info
cls
call :show_header

echo Collecting network configuration...
echo.
call :write_log "INFO" "Network configuration collection started."
call :new_output_file
ipconfig /all >"%OUTPUT_FILE%" 2>&1
set "RESULT=%errorlevel%"
call :show_output
call :report_result "IPCONFIG" "%RESULT%" "Network configuration collection finished."
echo.
pause
goto main


:flush_dns
cls
call :show_header

call :require_admin
if errorlevel 1 goto main

echo Flushing the DNS resolver cache...
echo.
call :write_log "INFO" "DNS cache flush started."
call :new_output_file
ipconfig /flushdns >"%OUTPUT_FILE%" 2>&1
set "RESULT=%errorlevel%"
call :show_output
call :report_result "DNS cache flush" "%RESULT%" "DNS cache operation finished."
echo.
pause
goto main


:backup_drivers
cls
call :show_header

call :require_admin
if errorlevel 1 goto main

set "DRIVER_BACKUP_DIR=%PROJECT_ROOT%\backups\drivers\%RUN_TIMESTAMP%"
mkdir "%DRIVER_BACKUP_DIR%" >nul 2>&1

if not exist "%DRIVER_BACKUP_DIR%\" (
    echo Unable to create the driver backup directory.
    call :write_log "ERROR" "Unable to create the driver backup directory."
    echo.
    pause
    goto main
)

echo Exporting installed third-party drivers...
echo Destination: "%DRIVER_BACKUP_DIR%"
echo.
call :write_log "INFO" "Driver backup started."
call :new_output_file
pnputil /export-driver * "%DRIVER_BACKUP_DIR%" >"%OUTPUT_FILE%" 2>&1
set "RESULT=%errorlevel%"
call :show_output
call :report_result "Driver backup" "%RESULT%" "Driver export finished."
echo.
pause
goto main


:system_info
cls
call :show_header

set "REPORT_DIR=%PROJECT_ROOT%\reports"
set "SYSTEM_REPORT=%REPORT_DIR%\system-information_%RUN_TIMESTAMP%.txt"
mkdir "%REPORT_DIR%" >nul 2>&1

if not exist "%REPORT_DIR%\" (
    echo Unable to create the report directory.
    call :write_log "ERROR" "Unable to create the report directory."
    echo.
    pause
    goto main
)

echo Collecting system information...
echo.
call :write_log "INFO" "System information export started."
systeminfo >"%SYSTEM_REPORT%" 2>&1
set "RESULT=%errorlevel%"

type "%SYSTEM_REPORT%"
if "%LOGGING_ENABLED%"=="1" type "%SYSTEM_REPORT%" >>"%LOG_FILE%"

call :report_result "SYSTEMINFO" "%RESULT%" "System information export finished."
echo Report: "%SYSTEM_REPORT%"
call :write_log "INFO" "System information report created."
echo.
pause
goto main


:invalid_option
echo.
echo Invalid option. Enter a number displayed in the menu.
echo.
pause
goto main


:exit_tool
call :write_log "INFO" "%TOOL_NAME% closed by the user."
cls
call :show_header
echo Closing the toolkit...
echo.
endlocal
exit /b 0
