; javaVersion.ahk

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance force
#Persistent
	
wrkDir := A_ScriptDir . "\"
showversion()

sleep, 8000

exitApp,0

; ***********************************
showversion(){
	global wrkDir
	
	FileDelete, actualJava.txt

	cmd := "cmd.exe /c java -version > " . wrkDir . "actualJava.txt 2>&1"

	RunWait, %cmd%,,min
			
	s := ""
	Loop, read, actualJava.txt
	{
		s := s . A_LoopReadLine . "`n"
	}
	tipTop(s)
}
; ***********************************
tipTop(msg){
	
	toolX := 20
	toolY := 20

	ToolTip, %msg%,toolX,toolY,1
}
; ***********************************

