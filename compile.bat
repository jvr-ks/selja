@rem compile.bat

@echo off

cd %~dp0

set appname=selja

net session >nul 2>&1
if NOT %ERRORLEVEL% == 0 goto noadmin

call %appname%.exe remove

call "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in %appname%.ahk /out %appname%.exe /icon %appname%.ico /bin "C:\Program Files\AutoHotkey\Compiler\Unicode 64-bit.bin"

goto EOF


:noadmin
echo Error, run batch as an admin!!
echo.
pause

