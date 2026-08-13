@rem testDirectCall.bat


@echo off

cd %~dp0

net session >nul 2>&1
if NOT %ERRORLEVEL% == 0 goto noadmin

echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo The current Java-version is (shown with the help of "javaVersion.exe"):
call javaVersion
echo.
pause
cls

echo Activating an "old" Java 8 version (graalvm-ce-java8-22.1.0):
echo.
echo executing: selja.exe hidewindow (graalvm-ce-java8-22.1.0)
echo.
start selja.exe hidewindow (graalvm-ce-java8-22.1.0)
echo.
timeout /t 5

rem reread environment variables
call resetvars.vbs
call %TEMP%\resetvars.bat

echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo The current Java-version is (shown with the help of "javaVersion.exe"):
call javaVersion
echo.
pause
cls


echo.
echo Switching to an actual version (graalvm-ce-java17-22.3.1):
start selja.exe (graalvm-ce-java17-22.3.1)
echo.
timeout /t 6
pause
rem reread environment variables
call resetvars.vbs
call %TEMP%\resetvars.bat

echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo The current Java-version is now (shown with the help of "javaVersion.exe"):
call javaVersion
echo.
timeout /t 4
cls

echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo Finished, removing the still running "Selja"
timeout /t 4

selja remove

goto :EOF


:noadmin
echo Error, run batch as an admin!
echo.
pause


