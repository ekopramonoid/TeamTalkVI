@echo off
echo --------------------------------------------------
echo        Uninstalling TeamTalk 4 NT Service
echo --------------------------------------------------
echo Make sure you're member of the administrator group
echo otherwise the installation will fail.
echo.
echo.
tt4svc.exe -e
tt4svc.exe -u
REM sc.exe delete "TeamTalk 4 NT Service"
pause
