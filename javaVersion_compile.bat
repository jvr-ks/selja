@rem javaVersion_compile.bat

@cd %~dp0

@echo off

@call "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in javaVersion.ahk /out javaVersion.exe  /icon javaVersion.ico

@exit
