/*
 *********************************************************************************
 * 
 * selja.ahk
 * 
 * use UTF-8 (no BOM)
 * 
 * Version -> appVersion
 * 
 * Copyright (c) 2020 jvr.de. All rights reserved.
 *
 *
 *********************************************************************************
*/

/*
 *********************************************************************************
 * 
 * MIT License
 * 
 * 
 * Copyright (c) 2020 jvr.de. All rights reserved.
 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sub-license, and/or sell copies 
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:

 * The above copyright notice and this permission notice shall be included in all 
 * copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANT-ABILITY, 
 * FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE 
 * UTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
  *********************************************************************************
*/

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance force
#Persistent

#Include, Lib\ahk_common.ahk

OwnPID := DllCall("GetCurrentProcessId")

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

FileEncoding, UTF-8-RAW

wrkDir := A_ScriptDir . "\"

appName := "Selja"
appVersion := "0.086"
app := appName . " " . appVersion

iniFileDefault := "selja.ini"
iniFile := iniFileDefault

seljaFileDefault := "selja.txt"
seljaFile := seljaFileDefault

iniFile := resolvepath(wrkDir,iniFile)
seljaFile := resolvepath(wrkDir,seljaFile)

linkListFileDefault := "seljaLinkList.txt"
linkListFile := linkListFileDefault

listWidthDefault := 800
listWidth := listWidthDefault

fontDefault := "Calibri"
font := fontDefault

fontsizeDefault := 10
fontsize := fontsizeDefault

linesInListMaxDefault := 30
linesInListMax := linesInListMaxDefault

notepadPathDefault := "C:\Program Files\Notepad++\notepad++.exe"
notepadpath := notepadPathDefault

menuhotkeyDefault := "!j"
exitHotkeyDefault := "+!j"
menuHotkey := menuhotkeyDefault
exitHotkey := exitHotkeyDefault

seljaEntriesArr := []
linkListArr := {}

msg_control_array = []

if (!A_IsAdmin){
	msgBox, SEVERE ERROR, NOT ADMIN, Exiting app ...!
	exit()
}

autoconfirm := false

pathBackup := resolvepath(wrkDir,"_thePathBackup.txt")

; *********** Gui parameter ***********
activeWin := 0

windowPosX := 0
windowPosY := 0
windowWidth := 0
windowHeight := 0
windowPosFixed := false

;-------------------------------- read param --------------------------------
hasParams := A_Args.Length()
autoSelectName := ""
starthidden := false

if (hasParams == 0){
	prepare()
	mainWindow(starthidden)
} else {
	Loop % hasParams
	{
		if(eq(A_Args[A_index],"remove")){
			showHint("Selja removed!", 1000)
			ExitApp,0
		}

		if(eq(A_Args[A_index],"hidewindow")){
			starthidden := true
		}

		FoundPos := RegExMatch(A_Args[A_index], "\[.*?]" , argsParam)
		if(FoundPos > 0){
			autoSelectName := A_Args[A_index]
		}
	}
	
	prepare()
	mainWindow(starthidden)
	
	if (starthidden){
		hktext := hotkeyToText(menuHotkey)
		tipTopTime("Started " . app . ", Hotkey is: " . hktext, 4000)
	}
	
	if (autoSelectName != "")
		autoSelect(autoSelectName)
}

return
; ************************************* END

;******************************* showLinkList *******************************
showLinkList(){
	global wrkDir
	global iniFile
	global linkListFile
	global linkListFileDefault
	global linkListArr
	global LV2
	
	IniRead, linkListFile, %iniFile%, external, linkListFile, %linkListFileDefault%
	
	Gui, LinkList:Destroy
	Gui, LinkList:New,+E0x08000000 +Resize +hWndLinkListWindowHandle
	Gui, LinkList:Add, ListView, r10 w500 glinkSelectedAction vLV2 AltSubmit -Multi, |Name|URL
	
	linkListArr := {}
	Loop, read, %wrkDir%%linkListFile%
	{
		elementArr := StrSplit(A_LoopReadLine,",")
		LV_Add("",A_index,elementArr[1], elementArr[2])
		linkListArr.push(elementArr[2]) ; URL
	}
	
	LV_ModifyCol(1,"Auto Integer")
	LV_ModifyCol(2,"Auto Text")
	LV_ModifyCol(3,"Auto Text")
	
	Gui, LinkList:Show
	
	return
}
;**************************** linkSelectedAction ****************************
linkSelectedAction(){
	global linkListArr

	if (A_GuiEvent = "Normal"){
		selectedEntry := linkListArr[A_EventInfo]
		clipboard := selectedEntry
	
		showHint("Copied to clipboard (you are an admin!): " . selectedEntry,3000)
		sleep, 3000
		showWindow()
	}
		
	return
}
; *********************************** prepare ******************************
prepare() {
	
	readIni()
	readSelja()
	readGuiParam()

	return
}
; *********************************** showWindow ******************************
showWindow(){
	global windowPosX
	global windowPosY
	global windowWidth
	global windowHeight
	
	setTimer,checkFocus,3000
	setTimer,registerWindow,-500
	Gui, guiMain:Show, x%windowPosX% y%windowPosY% w%windowWidth% h%windowHeight%
	
	return
}
;********************************* hideWindow *********************************
hideWindow(){

	setTimer,checkFocus,delete
	Gui,guiMain:Hide

	return
}
;---------------------------- showWindowRefreshed ----------------------------
showWindowRefreshed(){
	global menuHotkey
	global OwnPID

	refreshGui()
	showWindow()
	
	showMessageDefaultSelja()
	
	return
}
;********************************** readIni **********************************
readIni(){
	global iniFile
	global menuhotkeyDefault
	global menuHotkey
	global exitHotkeyDefault
	global exitHotkey
	global notepadpath
	global notepadPathDefault
	global fontDefault
	global font
	global fontsizeDefault
	global fontsize
	global listWidthDefault
	global listWidth
	global linesInListMax
	global linesInListMaxDefault
	global setEXE4J
	global setUTF8

; read Hotkey definition
	IniRead, menuHotkey, %iniFile%, hotkeys, menuhotkey , %menuhotkeyDefault%
	Hotkey, %menuHotkey%, showWindowRefreshed
	
	IniRead, exitHotkey, %iniFile%, hotkeys, exitHotkey , %exitHotkeyDefault%
	Hotkey, %exitHotkey%, exit
	
	IniRead, notepadpath, %iniFile%, external, notepadpath, %notepadPathDefault%
	
	IniRead, font, %iniFile%, config, font, %fontDefault%
	IniRead, fontsize, %iniFile%, config, fontsize, %fontsizeDefault%
	
	IniRead, listWidth, %iniFile%, config, listWidth, %listWidthDefault%
	IniRead, linesInListMax, %iniFile%, config, linesInListMax, %linesInListMaxDefault%
	
	IniRead, setEXE4J, %iniFile%, config, setEXE4J_JAVA_HOME, "no"
	
	IniRead, setUTF8, %iniFile%, config, setUTF8, "no"

	return
}
;********************************* readSelja *********************************
readSelja(){
	global seljaFile
	global seljaEntriesArr
	global param

	seljaEntriesArr := []

	Loop, read, %seljaFile%
	{
		if (A_LoopReadLine != "") {
			seljaEntriesArr.Push(A_LoopReadLine)
		}
	}
	
	return
}
;****************************** registerWindow ******************************
registerWindow(){
	global activeWin
	
	activeWin := WinActive("A")

	return
}
;******************************** checkFocus ********************************
checkFocus(){
	global activeWin
	global iniFile
	global windowPosFixed
	global windowPosX
	global windowPosY
	global windowWidth
	global windowHeight

	h := WinActive("A")
	if (activeWin != h){
		hideWindow()
	} else {
		if (!windowPosFixed){
			static xOld := 0
			static yOld := 0
			static wOld := 0
			static hOld := 0

			gui guiMain:+LastFound
			WinGet hwnd1,ID

			WinGetPosEx(hwnd1,xn1,yn1,wn1,hn1,Offset_X1,Offset_Y1)
			hn1 := hn1 - 129
			xn1 := xn1 + Offset_X1

			hn1 := Min(Round(A_ScreenHeight * 0.9),hn1)
			wn1 := Min(Round(A_ScreenWidth * 0.9),wn1)
			
			yn1 := Min(Round(A_ScreenHeight - hn1),yn1)
			xn1 := Min(Round(A_ScreenWidth - wn1),xn1)
		
			if (xOld != xn1 || yOld != yn1 || wOld != wn1 || hOld != hn1){		
				xOld := xn1
				yOld := yn1
				wOld := wn1
				hOld := hn1
				
				IniWrite, %xn1% , %iniFile%, config, windowPosX
				IniWrite, %yn1%, %iniFile%, config, windowPosY
				
				IniWrite, %wn1% , %iniFile%, config, windowWidth
				IniWrite, %hn1%, %iniFile%, config, windowHeight
			}
		}
	}
		
	return
}
; *********************************** mainWindow ******************************
mainWindow(hide := false) {
	global font
	global fontsize
	
	global seljaEntriesArr
	global seljaFile
	global toolsFile
	global iniFile
	global app
	global appName
	global menuHotkey
	global exitHotkey
	global listWidth
	global LV1
	global appVersion
	global linesInListMax
	global linesInListMaxDefault
	global windowPosX
	global windowPosY
	global windowWidth
	global windowHeight
	global OwnPID
	global pathBackup

	Menu, Tray, UseErrorLevel   ; This affects all menus, not just the tray.

	Menu, MainMenu, DeleteAll
	Menu, MainMenuEdit, DeleteAll
	Menu, MainMenuLinklist, DeleteAll
	Menu, MainMenuGithub, DeleteAll
	Menu, MainMenuGraalvm, DeleteAll
	
	Menu, MainMenuEdit,Add,Edit Selja-file: "%seljaFile%" with Notepad++,editseljaFile
	Menu, MainMenuEdit,Add,Edit Ini-file: "%iniFile%" with Notepad++,editIniFile
	Menu, MainMenuEdit,Add,Edit PathBackup-file: "%pathBackup%" with Notepad++,editPathBackupFile
	
	Menu, MainMenuLinklist,Add,Linklist of Java Sources Webpages,showLinkList
	
	Menu, MainMenuGraalvm,Add,Run gu install native-image,nativeImageInstall
	Menu, MainMenuGraalvm,Add,Open Java directory,openJavaDir
	Menu, MainMenuLinklist,Add,Edit Linklist with Notepad++,editLinkListFile
	Menu, MainMenuGithub,Add,Open %appName% Github webpage,openGithubPage
	
	Menu, MainMenu, NoDefault	
	Menu, MainMenu, Add,Edit,:MainMenuEdit
	Menu, MainMenu, Add,Show Path,showPath
	Menu, MainMenu, Add,Windows Path Tool,windowsPathTool
	Menu, MainMenu, Add,Linklist,:MainMenuLinklist
	Menu, MainMenu, Add,Github,:MainMenuGithub
	Menu, MainMenu, Add,GraalVm,:MainMenuGraalvm
	Menu, MainMenu, Add,Kill app,exit
	
	Gui,guiMain:New,+E0x08000000 +OwnDialogs +LastFound MaximizeBox HwndhMain +Resize, %app%
	
	Gui, guiMain:Font, s%fontsize%, %font%

	xStart := 8
	yStart := 5
	linesInList := Min(linesInListMax, seljaEntriesArr.length())
	
	Gui, Add, ListView, x%xStart% y%yStart% r%linesInList% w%listWidth% gLVCommands vLV1 AltSubmit -Multi Grid, |Name|JDK-path|JDK-bin-path|Additional-path

	for index, element in seljaEntriesArr
	{
		elementArr := StrSplit(element,",")
		LV_Add("",index,elementArr[1], elementArr[2], elementArr[3], elementArr[4])
	}
	
	LV_ModifyCol(1,"Auto Integer")
	LV_ModifyCol(2,"Auto Text")
	LV_ModifyCol(3,"Auto Text")
	LV_ModifyCol(4,"Text")
	LV_ModifyCol(5,"Text")
	
	Gui, guiMain:Add, StatusBar
	
	showMessageDefaultSelja()
	
	checkVersionFromGithub()
	
	Gui, guiMain:Menu, MainMenu
	
	
	if (!hide){
		setTimer,registerWindow,-500
		setTimer,checkFocus,3000
		Gui, guiMain:Show, x%windowPosX% y%windowPosY% w%windowWidth% h%windowHeight%
	}
	
	OnMessage(0x200, "WM_MOUSEMOVE")
	OnMessage(0x2a3, "WM_MOUSELEAVE")
	
	return
}
;******************************** refreshGui ********************************
refreshGui(){
	global seljaEntriesArr

	prepare()

	LV_Delete()
	
	for index, element in seljaEntriesArr
	{
		elementArr := StrSplit(element,",")
		LV_Add("",index,elementArr[1], elementArr[2], elementArr[3], elementArr[4])
	}
	
	return
}
;****************************** guiMainGuiSize ******************************
guiMainGuiSize:
; Expand or shrink the ListView in response to the user's resizing of the window.


SetTimer %A_ThisLabel%,Off
	
if (A_EventInfo = 1)  ; The window has been minimized. No action needed.
	return

borderX := 10
borderY := 60 ; reserve statusbar space

GuiControl, Move, LV1, % "W" . (A_GuiWidth - borderX) . " H" . (A_GuiHeight - borderY)

return
;******************************** LVCommands ********************************
LVCommands(){
	
	if (A_GuiEvent == "Normal"){
		runInDir(A_EventInfo) 
	}

	return
}
;-------------------------------- autoSelect --------------------------------
autoSelect(autoSelectName){
	global seljaEntriesArr
	global autoconfirm
	
	;search for the name and get the number
	ln := 0
	
	l := seljaEntriesArr.length()
	Loop, %l%
	{
			seljaEntryArr := StrSplit(seljaEntriesArr[A_Index],",")
			seljaEntryName := seljaEntryArr[1]

		if (eq(autoSelectName,seljaEntryName)){
			ln := A_Index
			autoconfirm := true
			showHint("Selected Java: " . autoSelectName, 2000)
		}
	}

	if(ln != 0)
		runInDir(ln)

	return
}
;********************************* runInDir *********************************
runInDir(lineNumber){
	global wrkDir
	global pathBackup
	global seljaFile
	global seljaEntriesArr
	global toolsArr
	global setEXE4J
	global setUTF8
	global autoconfirm

	if (lineNumber != 0){

		ks := getKeyboardState()
		switch ks
		{
		case 1:
			;*** Capslock ***
			showMessageSelja1("Operation inhibited due to [Capslock]!")

		case 2:
			;*** Alt ***
			showMessageSelja1("Click + [Alt] is not yet used!")
	
		case 4:
			;*** Ctrl ***
			s := seljaEntriesArr[lineNumber]
			
			setTimer,unselect,-100
			
			entry := StrSplit(s,",")
			
			path := entry[2]
			
			Runwait, %path%
			
		case 8:
			;*** Shift = edit ***

			s := seljaEntriesArr[lineNumber]
			
			setTimer,unselect,-100
			InputBox,inp,Edit command,,,,100,,,,,%s%
			
			if (ErrorLevel){
				showHint("Canceled!",2000)
				showWindow()
			} else {
				;save new command
				seljaEntriesArr[lineNumber] := inp
				
				content := ""
				
				l := seljaEntriesArr.Length()
				
				Loop, % l
				{
					content := content . seljaEntriesArr[A_Index] . "`n"
				}

				FileDelete, %seljaFile%
				FileAppend, %content%, %seljaFile%, UTF-8-RAW
			
				showWindowRefreshed()
			}
		default:
			; seljaEntriesArr[lineNumber][1] is the name, whih is uses as a marker only
			
			seljaEntryArr := StrSplit(seljaEntriesArr[lineNumber],",")
			javaPath := envVariConvert(seljaEntryArr[2])
			javaPathBin := StrReplace(envVariConvert(seljaEntryArr[3]),"...",javaPath)
			additionalPath := StrReplace(envVariConvert(seljaEntryArr[4]),"...",javaPath)
			
			setJavaHome := A_ComSpec . " /c setx JAVA_HOME """ . javaPath
			Run, %setJavaHome%,,min
			
			if (setEXE4J == "yes"){
				setJavaHome := A_ComSpec . " /c setx EXE4J_JAVA_HOME """ . javaPath
				Run, %setJavaHome%,,min
			}
			
			if (setUTF8 == "yes"){
				setJavaHome := A_ComSpec . " /c setx JAVA_OPTS """ . "-Dfile.encoding=UTF-8"
				Run, %setJavaHome%,,min
			}
			
			MAXQ := 10 ; may 10 path-cmds in log
			que := ""
			
			if FileExist(pathBackup){
				FileRead,que,%pathBackup%
				FileDelete, %pathBackup%
				if (ErrorLevel){
					msgbox, Severe error deleting %pathBackup%
					exit()
				}
			}
		
			;EnvGet, thePath, path expands all variables = not usable!
			
			RegRead, thePathRead,HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment,Path
			
			thePath := strReplace(thePathRead,";;",";")
			
			Que := StrQ( Que, thePath, MAXQ, "`n`n`n" ) ; add a new item to Que 
			
			FormatTime, dateTime 
			
			out := dateTime . ":`n`n" . Que
			FileAppend, %out%, %pathBackup%, UTF-8-RAW
			if (ErrorLevel){
				msgbox, Severe error saving %pathBackup%
				exit()
			}
			
			a := StrSplit(thePath,";")

			s := ""
			for index, element in a
			{
				if (!RegExMatch(element,"\\.*?[j,J]ava.*?\\bin") && !RegExMatch(element,"\\.*?[j,J]ava.*?\\lib\\svm\\bin"))
					s := s . element . ";"
			}

			s := SubStr(s,1,-1) ; remove last ";"

			;prepend
			if (javaPathBin != ""){
				s := javaPathBin . ";" . s
			}
			
			;prepend additional
			if (additionalPath != ""){
				s := additionalPath . ";" . s
			}
			

			setPath := cvtPath("%SystemRoot%\System32\windowspowershell\v1.0\powershell.exe","")
			setPath := setPath . " -NoProfile -ExecutionPolicy Bypass -Command """
			setPath := setPath . "$newPath = '" . s . "'`n"
			setPath := setPath . "[Environment]::SetEnvironmentVariable('PATH', ""$newPath"",'Machine');""`n"
			
			pv := strReplace(s,";",";`n")
			
			if (!autoconfirm){
					MsgBox,4,Attention please!,Are you sure to set the System-Path to:`n%pv%
					IfMsgBox Yes
					{
						Run, %setPath%,,min
						showHint("Finished!", 2000)
					} else {
						showHint("canceled!", 2000)
					}
			} else {
				Run, %setPath%,,min
			}
			showMessageDefaultSelja()
		}
	}
	
	return
}
;********************************* unselect *********************************
unselect(){
	sendinput {left}
}
;********************************** restart **********************************
restart(){
	exitApp,1
	
	return
}
;****************************** openGithubPage ******************************
openGithubPage(){
	global appName
	
	showHint("WARNING: Remember, you are an admin!", 2000)
	StringLower, name, appName
	Run https://github.com/jvr-ks/%name%
	
	return
}
;******************************* editseljaFile *******************************
editseljaFile() {
	global seljaFile
	global notepadpath
	
	showMessageSelja1("Please close the editor to refresh the menu!")
	f := notepadpath . " " . seljaFile
	runWait %f%,,max
	
	showWindowRefreshed()

	return
}
;--------------------------------- showPath ---------------------------------
showPath(){

	RegRead, thePath,HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment,Path
	
	a := StrSplit(thePath,";")

	s := ""
	for index, element in a
	{
		s := s . element . "`n"
	}
	msgbox, %s%
	
	showWindow()
	
	return
}
;******************************** editIniFile ********************************
editIniFile() {
	global iniFile
	global notepadpath
	
	f := notepadpath . " " . iniFile
	showMessageSelja1("Please close the editor to refresh the menu!")

	runWait %f%
	
	showWindowRefreshed()

	return
}
;***************************** editLinkListFile *****************************
editLinkListFile() {
	global notepadpath
	global linkListFile

	f := notepadpath . " " . linkListFile
	showMessageSelja1("Please close the editor to refresh the menu!")
	runWait %f%
	
	showWindowRefreshed()

	return
}
;---------------------------- editPathBackupFile ----------------------------
editPathBackupFile() {
	global notepadpath
	global pathBackup

	f := notepadpath . " " . pathBackup
	showMessageSelja1("Please close the editor to refresh the menu!")
	runWait %f%
	
	showWindowRefreshed()

	return
}

;************************************ ret ************************************
ret() {
	return
}
;********************************* checkJava *********************************
checkJava(){
	global wrkDir
	
	msg := "Please use the external app ""javaVersion.exe"" to check the Java-version!"
	showMessageSelja1(msg)
}
; *********************************** hkToDescription ******************************
; in Lib
; *********************************** hotkeyToText ******************************
; in Lib

;***************************** getKeyboardState *****************************
; in Lib

;********************************** cvtPath **********************************
cvtPath(s, path){
	r := s
	pos := 0

	While pos := RegExMatch(r,"O)(\[\.\.\.\])", match, pos+1){
		r := RegExReplace(r, "\" . match.1, path, , 1, pos)
	}
	
	While pos := RegExMatch(r,"O)(\[.*?\])", match, pos+1){
		r := RegExReplace(r, "\" . match.1, shortcut(match.1), , 1, pos)
	}

	While pos := RegExMatch(r,"O)(%.+?%)", match, pos+1){
		r := RegExReplace(r, match.1, envVariConvert(match.1), , 1, pos)
	}
	return r
}
;****************************** envVariConvert ******************************
envVariConvert(s){
	r := s
	if (InStr(s,"%")){
		s := StrReplace(s,"`%","")
		EnvGet, v, %s%
		Transform, r, Deref, %v%
	}

	return r
}
;********************************* shortcut *********************************
shortcut(s){
	global shortcutsArr
	
	r := s

	sc := shortcutsArr[r]
	if (sc != "")
		r := sc

	return r
}
;******************************* readGuiParam *******************************
readGuiParam(){
	global iniFile
	global font
	global fontsize
	global fontsizeDefault
	global windowPosX
	global windowPosY
	global windowWidth
	global windowHeight
	global windowPosFixed
	
	IniRead, windowPosFixed, %iniFile%, config, windowPosFixed, 0
	
	IniRead, windowPosX, %iniFile%, config, windowPosX, 0

	windowWidthDefault := A_ScreenWidth - Round(A_ScreenWidth/8)
	IniRead, windowWidth, %iniFile%, config, windowWidth, %windowWidthDefault%
	if (windowWidth == 0)
		windowWidth := windowWidthDefault
		
	IniRead, windowPosY, %iniFile%, config, windowPosY, 0

	windowHeightDefault := A_ScreenHeight - Round(A_ScreenHeight/8)
	IniRead, windowHeight, %iniFile%, config, windowHeight, %windowHeightDefault%
	if (windowHeight < 0)
		windowHeight := windowHeightDefault
	
	IniRead, fontsize, %iniFile%, config, fontsize, %fontsizeDefault%
	
	;DPIScale correction:
	windowWidth := Round(windowWidth * 96/A_ScreenDPI)
	windowHeight := Round(windowHeight * 96/A_ScreenDPI)
	

	return
}
;******************************* s *******************************
WM_MOUSEMOVE(wParam, lParam) {
	global msg_control_array
	
	;Gui, main:submit, nohide

	X := lParam & 0xFFFF
	Y := lParam >> 16
	
	if (A_GuiControl){
		Loop, parse, msg_control_array, `,
		{ 
			if (A_GuiControl == A_LoopField){
				tooltip, %msg%,,,9
				break
			}
			msg := A_LoopField
		}
		sleep 10000
		OnMessage(0x200, "")
	ToolTip,,,,9
	}
	
	return
}      
;******************************* WM_MOUSELEAVE *******************************
WM_MOUSELEAVE(wParam, lParam) {
  ToolTip,,,,9
  
  return
}

;------------------------------ windowsPathTool ------------------------------
windowsPathTool(){
	runWait	C:\Windows\System32\SystemPropertiesAdvanced.exe
  return
}
;---------------------------- nativeImageInstall ----------------------------
nativeImageInstall(){

	runcmd := A_ComSpec
	Run, %runcmd%,,max
	sleep, 2000
	sendinput gu install native-image{Enter}
	sleep, 3000
	sendinput exit{Enter}
	
	return
}
;-------------------------------- openJavaDir --------------------------------
openJavaDir(){

	EnvGet, runcmd, JAVA_HOME
	Run, %runcmd%,,max	
			
	return
}
;------------------------- showMessageDefaultSelja -------------------------
showMessageDefaultSelja(){
	global menuHotkey

	msg1 := "Open Selja hotkey: " . hotkeyToText(menuHotkey ) . ", Edit entry: [Shift] + [Click]"
	msg2 := "Open Path: [Ctrl] + [Click]    "
	memory := "[" . GetProcessMemoryUsage(DllCall("GetCurrentProcessId")) . " MB]    "
	resolution := "[" . A_ScreenWidth . " x " . A_ScreenHeight . "]"
	
	showMessageSelja3(msg1, msg2, memory)
	
	return
}
;---------------------------- showMessageSelja3 ----------------------------
showMessageSelja3(hk1, hk2, memory){

	SB_SetParts(1000,500)
	SB_SetText(" " . hk1 , 1, 1)
	SB_SetText(" " . hk2 , 2, 1)
	SB_SetText("`t`t" . memory , 3, 2)

	return
}
;---------------------------- showMessageSelja1 ----------------------------
showMessageSelja1(hk1){

	memory := "[" . GetProcessMemoryUsage(DllCall("GetCurrentProcessId")) . " MB]    "

	SB_SetParts(1000)
	SB_SetText(" " . hk1 , 1, 1)
	SB_SetText("`t`t" . memory , 2, 2)

	return
}
;*********************************** exit ***********************************
exit() {
	global app
	
	showHint("""" . app . """ removed from memory!", 1500)
	ExitApp,0
	
	return
}
;************************************ *** ************************************



