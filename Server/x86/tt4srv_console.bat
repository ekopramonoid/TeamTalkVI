@echo off
echo   --------------------------------------------------------------------------
echo                       TeamTalk 4 Console Server
echo   --------------------------------------------------------------------------
echo.
echo Ensure the server's configuration file 'tt4svc.xml' is in a writable
echo location otherwise no changes made to the file will be saved.
echo.
@echo on
tt4srv.exe -wizard
tt4srv.exe -nd -verbose
pause
