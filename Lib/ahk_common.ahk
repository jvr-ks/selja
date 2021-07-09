; ahk_common.ahk

;----------------------------------- StrQ -----------------------------------
; from https://www.autohotkey.com/boards/viewtopic.php?t=57295#p328684

StrQ(Q, I, Max:=10, D:="|") { ;          StrQ v.0.90,  By SKAN on D09F/D34N @ tiny.cc/strq
Local LQ:=StrLen(Q), LI:=StrLen(I), LD:=StrLen(D), F:=0
Return SubStr(Q:=(I)(D)StrReplace(Q,InStr(Q,(I)(D),,0-LQ+LI+LD)?(I)(D):InStr(Q,(D)(I),0,LQ
-LI)?(D)(I):InStr(Q,(D)(I)(D),0)?(D)(I):"","",,1),1,(F:=InStr(Q,D,0,1,Max))?F-1:StrLen(Q))
}
;--------------------------- getVersionFromGithub ---------------------------
getVersionFromGithub(){
	global appName

	r := "unknown!"
	StringLower, name, appName
	url := "https://github.com/jvr-ks/" . name . "/raw/master/version.txt"
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	Try
	{
		whr.Open("GET", url)
		whr.Send()
		Sleep 500
		status := whr.Status
		if (status == 200)
			r := whr.ResponseText
	}
	catch e
	{
		msgbox, Connection to %url% failed! [Error: %e%]
	}

	return r
}
;-------------------------- checkVersionFromGithub --------------------------
checkVersionFromGithub(){
	global appVersion
	global msgDefault
	global MainStatusBarHwnd
	
	vers := getVersionFromGithub()
	if (vers != "unknown"){
		if (vers > appVersion){
			msg := "New version available, this is: " . appVersion . ", available on Github is: " . vers
			SB_SetParts()
			SB_SetText(" " . msg , 1, 1)
			SendMessage, GuiConstants("CCM_SETBKCOLOR"), 0, 0x9999FF,, ahk_id %MainStatusBarHwnd%
			SendMessage, GuiConstants("WM_CTLCOLOREDIT"), 0, 0xFFFFFF,, ahk_id %MainStatusBarHwnd%
		}
	}
	
	return
}
;******************************** getLenPixel ********************************
;---- generate hidden gui to get pixelsize of string
;not 100% ok
getLenPixel(EditTxt,font,fontsize){
	global MyText

	Gui StringWidth:font, s%fontsize%, %font%
	Gui, StringWidth:Margin,2,2
	Gui StringWidth:Add, Text, R1, %EditTxt%
	GuiControlGet T, StringWidth:Pos, Static1
	Gui StringWidth:Destroy
	
	return TW
}
;----------------------------- SetTextAndResize -----------------------------
SetTextAndResize(controlHwnd, newText) {
	global newtipWindowTextWidth

	dc := DllCall("GetDC", "Ptr", controlHwnd)

; 0x31 = WM_GETFONT
	SendMessage 0x31,,,, ahk_id %controlHwnd%
	hFont := ErrorLevel
	oldFont := 0
	if (hFont != "FAIL")
		oldFont := DllCall("SelectObject", "Ptr", dc, "Ptr", hFont)

	VarSetCapacity(rect, 16, 0)
	; 0x440 = DT_CALCRECT | DT_EXPANDTABS
	h := DllCall("DrawText", "Ptr", dc, "Ptr", &newText, "Int", -1, "Ptr", &rect, "UInt", 0x440)
	; width = rect.right - rect.left
	w := NumGet(rect, 8, "Int") - NumGet(rect, 0, "Int")

	if oldFont
		DllCall("SelectObject", "Ptr", dc, "Ptr", oldFont)
	DllCall("ReleaseDC", "Ptr", controlHwnd, "Ptr", dc)

	GuiControl,, %controlHwnd%, %newText%

	GuiControl Move, %controlHwnd%, % "w" w
	
	newtipWindowTextWidth := w

	return
}

;------------------------------- tipWindow -------------------------------
tipWindow(msg, transp := 0, timeout := 0, refresh := true){
	; using own Gui
	global font
	global fontsize
	static text1Hwnd
	global tipWindowTextWidth
	global newtipWindowTextWidth
	
	s := StrReplace(msg,"^",",")
		
	if (refresh){
		tipWindowClose()
		sleep,100
	}
	
	tipWindowhwnd := WinExist("TheTipWindow")
	
	if ( tipWindowhwnd == 0){
		Gui, tipWindow:New,-Caption +AlwaysOnTop -dpiScale
		;Gui, tipWindow:New,-Caption +AlwaysOnTop
		Gui, tipWindow:Font, s%fontsize%, %font%
		Gui tipWindow:Margin, 2, 2
		Gui, tipWindow:Add, Text, Hwndtext1Hwnd vTipWindow R1 Center
		SetTextAndResize(text1Hwnd, s)
		Gui, tipWindow:Show, xCenter y1 Autosize NoActivate,TheTipWindow
		tipWindowTextWidth := newtipWindowTextWidth
	} else {
		SetTextAndResize(text1Hwnd, s)
		GuiControl,, %text1Hwnd%, %s%
		if (newtipWindowTextWidth > tipWindowTextWidth){
			tipWindowTextWidth := newtipWindowTextWidth
			tipWindowClose()
			Gui, tipWindow:New,-Caption +AlwaysOnTop -dpiScale
			;Gui, tipWindow:New,-Caption +AlwaysOnTop
			Gui, tipWindow:Font, s%fontsize%, %font%
			Gui tipWindow:Margin, 2, 2
			Gui, tipWindow:Add, Text, Hwndtext1Hwnd vTipWindow R1 Center
			SetTextAndResize(text1Hwnd, s)
			Gui, tipWindow:Show, xCenter y1 Autosize NoActivate,TheTipWindow
		}
	}
	
	if (transp != 0)
		WinSet, Transparent, %transp%, ahk_id %tipWindowhwnd%
	
	if (timeout != 0){
		t := -1 * timeout
		setTimer,tipWindowClose,delete
		setTimer,tipWindowClose,%t%
	}

	return
}
;----------------------------- tipWindowClose -----------------------------
tipWindowClose(){
	global TipWindow

	setTimer,tipWindowClose,delete
	Gui,tipWindow:Destroy
	
	return
}
;********************************** tipTop **********************************
tipTop(msg){
	; using ToolTip
	global font
	global fontsize
	
	toolX := Max(0,Floor(A_ScreenWidth / 2) - getLenPixel(msg,font,fontsize))
	toolY := 2
	
	s := StrReplace(msg,"^",",")
	ToolTip, %s%,toolX,toolY,3
}
;******************************** tipTopTime ********************************
tipTopTime(msg, t := 2000){
	global font
	global fontsize
	
	toolX := Max(0,Floor(A_ScreenWidth / 2) - getLenPixel(msg,font,fontsize))
	toolY := 2
	
	s := StrReplace(msg,"^",",")
	ToolTip, %s%,toolX,toolY,3
	tvalue := -1 * t
	SetTimer,tipTopClose,%tvalue%
}
;******************************* tipTopEternal *******************************
tipTopEternal(msg){
	global font
	global fontsize
	
	toolX := Max(0,Floor(A_ScreenWidth / 2) - getLenPixel(msg,font,fontsize))
	toolY := 2
	
	s := StrReplace(msg,"^",",")

	ToolTip, %s%,toolX,toolY,3
}
;-------------------------------- tipTopClose --------------------------------
tipTopClose(){
	ToolTip,,,,1
	ToolTip,,,,2
	ToolTip,,,,3
}
;******************************** GuiGetSize ********************************
GuiGetSize( ByRef W, ByRef H, GuiID=1 ) {
	Gui %GuiID%:+LastFoundExist
	IfWinExist
	{
		VarSetCapacity( rect, 16, 0 )
		DllCall("GetClientRect", uint, MyGuiHWND := WinExist(), uint, &rect )
		W := NumGet( rect, 8, "int" )
		H := NumGet( rect, 12, "int" )
	}
}
;********************************* GuiGetPos *********************************
GuiGetPos( ByRef X, ByRef Y, ByRef W, ByRef H, GuiID=1 ) {
	Gui %GuiID%:+LastFoundExist
	IfWinExist
	{
		WinGetPos X, Y
		VarSetCapacity( rect, 16, 0 )
		DllCall("GetClientRect", uint, MyGuiHWND := WinExist(), uint, &rect )
		W := NumGet( rect, 8, "int" )
		H := NumGet( rect, 12, "int" )
	}
}
;******************************** stringUpper ********************************
stringUpper(s){
	r := ""
	StringUpper, r, s
	
	return r
}
;********************************* StrLower *********************************
StrLower(s){
	r := ""
	StringLower, r, s
	
	return r
}
;******************************** openShell ********************************
openShell(commands) {
	shell := ComObjCreate("WScript.Shell")
	exec := shell.Exec(ComSpec " /Q /K echo off")
	exec.StdIn.WriteLine(commands "`nexit") 
	r := exec.StdOut.ReadAll()
	msgbox, %r%
	
	return
}
;******************************** showObject ********************************
showObject(a){
	s := ""

	for index,element in a
	{
		s := s . element .  ", "
	}
	msgbox, showObject: %s%
}
;*************************** GetProcessMemoryUsage ***************************
GetProcessMemoryUsage(ProcessID)
{
	static PMC_EX, size := NumPut(VarSetCapacity(PMC_EX, 8 + A_PtrSize * 9, 0), PMC_EX, "uint")

	if (hProcess := DllCall("OpenProcess", "uint", 0x1000, "int", 0, "uint", ProcessID)) {
		if !(DllCall("GetProcessMemoryInfo", "ptr", hProcess, "ptr", &PMC_EX, "uint", size))
			if !(DllCall("psapi\GetProcessMemoryInfo", "ptr", hProcess, "ptr", &PMC_EX, "uint", size))
				return (ErrorLevel := 2) & 0, DllCall("CloseHandle", "ptr", hProcess)
		DllCall("CloseHandle", "ptr", hProcess)
		return Round(NumGet(PMC_EX, 8 + A_PtrSize * 8, "uptr") / 1024**2, 2)
	}
	return (ErrorLevel := 1) & 0
}
;--------------------------------- showHint ---------------------------------
showHint(s, n){
	global hinttimer
	global font
	global fontsize
	
	Gui, hint:Font, %fontsize%, %font%
	Gui, hint:Add, Text,, %s%
	Gui, hint:-Caption
	Gui, hint:+ToolWindow
	Gui, hint:+AlwaysOnTop
	Gui, hint:Show
	t := -1 * n
	setTimer,showHintDestroy, %t%
	return
}
;-------------------------------- showHintAt --------------------------------
showHintAt(s, n, x, y){
	global font
	global fontsize
	
	Gui, hint:Font, s%fontsize%, %font%
	Gui, hint:Add, Text,, %s%
	Gui, hint:-Caption
	Gui, hint:+ToolWindow
	Gui, hint:+AlwaysOnTop
	Gui, hint:Show, x%x% y%y%
	t := -1 * n
	setTimer,showHintDestroy, %t%
	
	return
}
;------------------------------ showHintDestroy ------------------------------
showHintDestroy(){
	global hinttimer

	setTimer,showHintDestroy, delete
	Gui, hint:Destroy
	return
}
;------------------------------------ eq ------------------------------------
eq(a, b) {
	if (InStr(a, b) && InStr(b, a))
		return 1
	return 0
}
;-------------------------------- openWindow --------------------------------
openWindow(title){
	SetTitleMatchMode, 2
	wHwnd := 0

	if WinExist(title){
		winActivate,%title%
		sleep, 200
		
		TrialLoop:
		Loop, 20
		{
			if (!WinActive(title)){
				showHint("Waiting for Window: " . title . " to open!", 1000)
				sleep, 1000
				winActivate,%title%
			} else {
				wHwnd := WinActive(title)
				break TrialLoop
			}
		}
	} else {
		showHint("Window: " . title . " not found!", 4000)
		sleep,4000
	}

	
	return wHwnd
}
;--------------------------------- BaseToDec ---------------------------------
BaseToDec(n, Base) {
	static U := A_IsUnicode ? "wcstoui64_l" : "strtoui64"
	return, DllCall("msvcrt\_" U, "Str",n, "Uint",0, "Int",Base, "CDECL Int64")
}
;--------------------------------- DecToBase ---------------------------------
DecToBase(n, Base) {
	static U := A_IsUnicode ? "w" : "a"
	VarSetCapacity(S,65,0)
	DllCall("msvcrt\_i64to" U, "Int64",n, "Str",S, "Int",Base)
	return, S
}
;----------------------------- getKeyboardState -----------------------------
getKeyboardState(){
	r := 0
	if (getkeystate("Capslock","T") == 1)
		r := r + 1
		
	if (getkeystate("Alt","P") == 1)
		r := r + 2
		
	if (getkeystate("Ctrl","P") == 1)
		r:= r + 4
		
	if (getkeystate("Shift","P") == 1)
		r:= r + 8

	return r
}

;-------------------------------- showMessage --------------------------------
showMessage(hk1, hk2){
	global menuHotkey
	global exitHotkey

	SB_SetParts(160,580)
	if (hk1 != ""){
		SB_SetText(" " . hk1 , 1, 1)
	} else {
		SB_SetText(" " . "Hotkey: " . hotkeyToText(menuHotkey) , 1, 1)
	}
		
	if (hk2 != ""){
		SB_SetText(" " . hk2 , 2, 1)
	} else {
		SB_SetText(" " . "Exit-hotkey: " . hotkeyToText(exitHotkey) , 2, 1)
	}
	
	memory := "[" . GetProcessMemoryUsage(DllCall("GetCurrentProcessId")) . " MB]      "
	SB_SetText("`t`t" . memory , 3, 2)

	return
}
;------------------------------- removeMessage -------------------------------
removeMessage(){
	global menuHotkey
	global exitHotkey

	SB_SetParts(160,580)
	SB_SetText(" " . "Hotkey: " . hotkeyToText(menuHotkey) , 1, 1)

	SB_SetText(" " . "Exit-Hotkey: " . hotkeyToText(exitHotkey) , 2, 1)
	
	memory := "[" . GetProcessMemoryUsage(DllCall("GetCurrentProcessId")) . " MB]      "
	SB_SetText("`t`t" . memory , 3, 2)

	return
}
;------------------------------- showMessage4 -------------------------------
showMessage4(hk1, hk2, reso){
	global menuHotkey
	global exitHotkey

	SB_SetParts(300,500,200)
	if (hk1 != ""){
		SB_SetText(" " . hk1 , 1, 1)
	} else {
		SB_SetText(" " . "Hotkey: " . hotkeyToText(menuHotkey) , 1, 1)
	}
		
	if (hk2 != ""){
		SB_SetText(" " . hk2 , 2, 1)
	} else {
		SB_SetText(" " . "Exit-hotkey: " . hotkeyToText(exitHotkey) , 2, 1)
	}
	
	if (reso != ""){
		SB_SetText("`t" . reso , 3, 2)
	} else {
		resolution := "[" . A_ScreenWidth . " x " . A_ScreenHeight . "]"
		SB_SetText("`t" . reso , 3, 2)
	}
	
	memory := "[" . GetProcessMemoryUsage(DllCall("GetCurrentProcessId")) . " MB]      "
	SB_SetText("`t`t" . memory , 4, 2)

	return
}
; ----------------------------------------------------------------------------- 










