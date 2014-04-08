@echo off
echo --------------------------------------------------
echo        Installing TeamTalk 4 NT Service
echo --------------------------------------------------
echo Make sure you're member of the administrator group
echo otherwise the installation will fail.
echo.
echo.
tt4svc.exe -wizard
tt4svc.exe -i
REM sc.exe create "TeamTalk 4 NT Service" binPath= "tt4svc.exe" start= auto
tt4svc.exe -s
pause
