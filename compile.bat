@rem compile.bat

@echo off

@cd %~dp0

@net session >nul 2>&1
@if NOT %ERRORLEVEL% == 0 goto noadmin

@call selja.exe remove

@callo "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in selja.ahk /out selja.exe /icon selja.ico /bin "C:\Program Files\AutoHotkey\Compiler\Unicode 64-bit.bin"

@goto end


:noadmin
@echo Fehler, Script muss als Administrator ausgefuehrt werden...Abbruch!
@echo.
@pause
@goto end


:end
exit