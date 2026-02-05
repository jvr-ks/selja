/*
 *********************************************************************************
 * 
 * selja.ahk
 * 
 * use UTF-8 (no BOM)
 * 
 * Version -> appVersion
 * 
 *
 * License: GNU GENERAL PUBLIC LICENSE
 * 
 * Take a look at the file "license.txt"   
 * 
 *
 * Copyright (c) 2020 jvr.de. All rights reserved.
 * 
 *
 **********************************************************************************
*/

#NoEnv
#Warn 
#SingleInstance force
#Persistent

#Include %A_ScriptDir%

; https://github.com/zhamlin/AHKhttp
#include, Lib\AHKhttp.ahk

; http://www.autohotkey.com/forum/viewtopic.php?p=355775
#include, Lib\AHKsock.ahk

;auto-include Lib\..
;hkToDescription.ahk
;hotkeyToText.ahk
;ScrollBox.ahk


; force admin rights
full_command_line := DllCall("GetCommandLine", "str")
allparams := ""
for keyGL, valueGL in A_Args {
  allparams .= valueGL . " "
}
    
if (!A_IsAdmin) {
  if (A_IsCompiled){
    if (!RegExMatch(full_command_line, "\/restart")) {
      Run *RunAs %A_ScriptFullPath% /restart %allparams%
      ExitApp
    } else {
      msgbox, SEVERE ERROR, failed to restart as an Admin!
    }
  } else {
    if (!RegExMatch(full_command_line, "\/restart")) {
      Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%" %allparams%
      ExitApp
    } else {
      msgbox, SEVERE ERROR, failed to restart as an Admin!
    }
  }
}


; comment out to use default speed
;SetBatchLines, -1

seljaRestPortDefault := 65500
seljaRestPort := seljaRestPortDefault

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

FileEncoding, UTF-8-RAW

wrkDir := A_ScriptDir . "\"

appName := "Selja"
appnameLower := "selja"
extension := ".exe"
appVersion := "0.137"

bit := (A_PtrSize=8 ? "64" : "32")

if (!A_IsUnicode)
  bit := "A" . bit

bitName := (bit="64" ? "" : bit)

app := appName . " " . appVersion . " (" . bit . " bit)"

configFile := appnameLower . ".ini"
configFileLocal := appnameLower . "_" . A_ComputerName . ".ini"

configFile := appnameLower . "_" . A_ComputerName . ".ini"

if (!FileExist(configFile)){
  createConfig(configFile)
}

seljaFileDefault := "selja.txt"
seljaFile := seljaFileDefault

linkListFileDefault := "seljaLinkList.txt"
linkListFile := linkListFileDefault

listWidthDefault := 800
listWidth := listWidthDefault

fontDefault := "Segoe UI"
font := fontDefault

fontsizeDefault := 9
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

autoconfirm := false

createMime()

pathBackup := "_thePathBackup.txt"

localVersionFileDefault := "version.txt"
serverURLDefault := "https://github.com/jvr-ks/"
serverURLExtensionDefault := "/raw/main/"

;------------------------------- Gui parameter -------------------------------
activeWin := 0
windowPosXDefault := 0
windowPosYDefault := 0
clientWidthDefault := 800
clientHeightDefault := 600

windowPosX := windowPosXDefault
windowPosY := windowPosYDefault
clientWidth := clientWidthDefault
clientHeight := clientHeightDefault


; fixed:
localVersionFile := localVersionFileDefault
serverURL := serverURLDefault
serverURLExtension := serverURLExtensionDefault

updateServer := serverURL . appnameLower . serverURLExtension


borderLeft := 2
borderRight := 2
borderTop := 40 ; reserve statusbar space

;-------------------------------- read param --------------------------------
hasParams := A_Args.Length()
autoSelectName := ""
starthidden := false
restapi := true

if (hasParams != 0){
  Loop % hasParams
  {
    if(eq(A_Args[A_index],"remove")){
      showHint("Selja removed!", 1000)
		sleep,2000
      ExitApp,0
    }

    if(eq(A_Args[A_index],"hidewindow")){
      starthidden := true
    }

    if(eq(A_Args[A_index],"restapioff")){
      restapi := false
    }

      FoundPos := RegExMatch(A_Args[A_index],"\([\w.-]+?\)", found)
    
    If (FoundPos > 0){
      autoSelectName := found
      showHint(app . " selected entry: " . autoSelectName, 3000)
    }
  }
}
  
prepare()

;-------------------------------- serverHttp --------------------------------
paths := {}
paths["/selja"] := Func("seljaRest")

if (restApi){
  serverHttp := new HttpServer()
  serverHttp.LoadMimes(A_ScriptDir . "/mime.types")
  serverHttp.SetPaths(paths)
  serverHttp.Serve(seljaRestPort)
}

if (starthidden){
  hktext := hotkeyToText(menuHotkey)
  tipScreenTopTime("Started " . app . ", Hotkey is: " . hktext, 4000)
}

mainWindow(starthidden)

if (autoSelectName != "")
  autoSelect(autoSelectName)

return
;--------------------------------- seljaRest ---------------------------------
seljaRest(ByRef req, ByRef res) {

; request -> /selja?version=[xy]
  v := req.queries["version"]
  res.SetBodyText("Setting Java version to: " . v)
  autoSelect(v)
  res.status := 200
  
  return
}
;------------------------------ registerWindow ------------------------------
registerWindow(){
  global activeWin
  
  activeWin := WinActive("A")

  return
}
;-------------------------------- checkFocus --------------------------------
checkFocus(){
  global hMain

  h := WinActive("A")
  if (hMain != h){
    hideWindow()
  }
    
  return
}
;-------------------------------- mainWindow --------------------------------
mainWindow(hide := false){
  ; main element is the ListView LV1
  global hMain, font, fontsize
  global seljaEntriesArr
  global seljaFile, configFile, linkListFile, pathBackup
  global app, appName
  global menuHotkey, exitHotkey
  global listWidth, LV1
  global appVersion
  global linesInListMax, linesInListMaxDefault
  global windowPosX, windowPosY, clientWidth, clientHeight
  global windowPosXDefault, windowPosYDefault, clientWidthDefault, clientHeightDefault

  Menu, Tray, UseErrorLevel

  Menu, MainMenu, DeleteAll
  Menu, MainMenuEdit, DeleteAll
  Menu, MainMenuLinklist, DeleteAll
  Menu, MainMenuGithub, DeleteAll
  Menu, MainMenuGraalvm, DeleteAll
  Menu, MainMenuUpdate, DeleteAll
  Menu, MainMenuTools, DeleteAll
  
  Menu, MainMenuEdit,Add,Edit Selja-file: "%seljaFile%" with Notepad++,editseljaFile
  Menu, MainMenuEdit,Add,Edit Config-file: "%configFile%" with Notepad++,editConfigFile
  Menu, MainMenuEdit,Add,Edit Config-file: "%linkListFile%" with Notepad++,editLinkListFile
  Menu, MainMenuEdit,Add,Edit PathBackup-file: "%pathBackup%" with Notepad++,editPathBackupFile
  
  Menu, MainMenuUpdate,Add,Check if new version is available, startCheckUpdate
  Menu, MainMenuUpdate,Add,Start updater, startUpdate
  
  Menu, MainMenuLinklist,Add,Linklist of Java Sources Webpages,showLinkList
  Menu, MainMenuLinklist,Add,Edit Linklist with Notepad++,editLinkListFile
   
  Menu, MainMenuGraalvm,Add,Open GraalVM Download webpage,openGraalVMPage
  Menu, MainMenuGraalvm,Add,Run gu install native-image,guNativeImageInstall
  Menu, MainMenuGraalvm,Add,Run gu list,guList
  Menu, MainMenuGraalvm,Add,Run gu available,guAvailable
  Menu, MainMenuGraalvm,Add,Open JAVA_HOME directory,openJavaDir
  
  Menu, MainMenuGithub,Add,Open %appName% Github webpage,openGithubPage
  
  Menu, MainMenuTools,Add,Windows Environment Tool,windowsEnvTool
  
  Menu, MainMenu, NoDefault  
  Menu, MainMenu, Add,Edit,:MainMenuEdit
  Menu, MainMenu, Add,Show Path,showPath
  Menu, MainMenu, Add,Tools,:MainMenuTools
  Menu, MainMenu, Add,Update,:MainMenuUpdate
  
  Menu, MainMenu, Add,Linklist,:MainMenuLinklist
  Menu, MainMenu, Add,Github,:MainMenuGithub
  Menu, MainMenu, Add,GraalVm,:MainMenuGraalvm
  Menu, MainMenu, Add,Kill %appName%,exit
  
  Gui, guiMain:New, +OwnDialogs +LastFound MaximizeBox HwndhMain +Resize, %app%
  
  Gui, guiMain:Font, s%fontsize%, %font%

  xStart := 8
  yStart := 5
  linesInList := Min(linesInListMax, seljaEntriesArr.length())
  
  Gui, guiMain:Add, ListView, x%xStart% y%yStart% r%linesInList% w%listWidth% GguiMainListViewClick vLV1 AltSubmit -Multi Grid, |Name|JDK-path|JDK-bin-path|Additional-path

  for index, element in seljaEntriesArr
  {
    elementArr := StrSplit(element,",")
    LV_Add("",index,elementArr[1], elementArr[2], elementArr[3], elementArr[4])
  }
  
  LV_ModifyCol(1,"Auto Integer")
  LV_ModifyCol(2,"Auto Text")
  LV_ModifyCol(3,"Auto Text")
  LV_ModifyCol(4,"Auto Text")
  LV_ModifyCol(5,"Auto Text")
  
  Gui, guiMain:Add, StatusBar
  
  showMessageSelja()
  
  Gui, guiMain:Menu, MainMenu
  
  Gui, guiMain:Show, x%windowPosX% y%windowPosY% w%clientWidth% h%clientHeight%
  setTimer,registerWindow,-500
    
  if (!hide){
    setTimer,checkFocus,3000
  } else {
    Gui, guiMain:Hide
  }
  
  ; OnMessage(0x200, "WM_MOUSEMOVE")
  ; OnMessage(0x2a3, "WM_MOUSELEAVE")
  OnMessage(0x03,"WM_MOVE")
  
  return
}
;---------------------------------- WM_MOVE ----------------------------------
WM_MOVE(wParam, lParam){
  global hMain, windowPosX, windowPosY, 

  WinGetPos, windowPosX, windowPosY,,, ahk_id %hMain%
  
  return
}
;------------------------------ guiMainGuiSize ------------------------------
guiMainGuiSize(){
  global hMain, windowPosX, windowPosY, clientWidth, clientHeight
  global windowPosXDefault, windowPosYDefault, clientWidthDefault, clientHeightDefault
  global borderLeft, borderRight, borderTop, LV1

  if (A_EventInfo != 1) {
    ; not minimized
    
    clientWidth := A_GuiWidth
    clientHeight := A_GuiHeight

    width := clientWidth - borderLeft - borderRight
    height := clientHeight - borderTop
    guicontrol, guiMain:move, LV1, x%borderLeft% w%width% h%height%
    
  }
  
  return
}
;-------------------------------- iniReadSave --------------------------------
iniReadSave(name, section, defaultValue){
  global configFile
  
  r := ""
  IniRead, r, %configFile%, %section%, %name%, %defaultValue%
  if (r == "" || r == "ERROR")
    r := defaultValue
    
  return r
}
;-------------------------------- readConfig --------------------------------
readConfig(){
  global configFile
  global menuhotkeyDefault, menuHotkey, exitHotkeyDefault, exitHotkey
  global notepadpath, notepadPathDefault
  global fontDefault, font, fontsizeDefault, fontsize
  global listWidthDefault, listWidth
  global linesInListMax, linesInListMaxDefault
  global seljaRestPortDefault, seljaRestPort
  global setEXE4J, setUTF8

; read Hotkey definition
  IniRead, menuHotkey, %configFile%, hotkeys, menuhotkey , %menuhotkeyDefault%
  Hotkey, %menuHotkey%, showWindowRefreshed
  
  IniRead, exitHotkey, %configFile%, hotkeys, exitHotkey , %exitHotkeyDefault%
  Hotkey, %exitHotkey%, exit
  
  IniRead, notepadpath, %configFile%, external, notepadpath, %notepadPathDefault%
  
  IniRead, font, %configFile%, config, font, %fontDefault%
  IniRead, fontsize, %configFile%, config, fontsize, %fontsizeDefault%
  
  IniRead, listWidth, %configFile%, config, listWidth, %listWidthDefault%
  IniRead, linesInListMax, %configFile%, config, linesInListMax, %linesInListMaxDefault%
  
  IniRead, seljaRestPort, %configFile%, config, seljaRestPort, %seljaRestPortDefault%

  IniRead, setEXE4J, %configFile%, config, setEXE4J_JAVA_HOME, "no"
  IniRead, setUTF8, %configFile%, config, setUTF8, "no"
  
  return
}
;------------------------------- createConfig -------------------------------
createConfig(fn){
  
  content := "
(
[hotkeys]
menuhotkey=""!j""
exithotkey=""+!j""

[config]
listWidth=800
font=""Segoe UI""
fontsize=9
seljaRestPort=65500
linesInListMax=30
windowWidthOffset=3
windowHeightOffset=129
setEXE4J_JAVA_HOME=""no""
setUTF8=""yes""

[external]
notepadpath=""C:\Program Files\Notepad++\notepad++.exe""
linkListFile=""seljaLinkList.txt""

[gui]
windowPosX=0
windowPosY=0
clientWidth=615
clientHeight=362


)"

  FileAppend, %content%, %fn%, UTF-8-RAW

  return
}
;-------------------------------- readGuiData --------------------------------
readGuiData(){
  global configFile, windowPosX, windowPosY, clientWidth, clientHeight
  global windowPosXDefault, windowPosYDefault, clientWidthDefault, clientHeightDefault

  windowPosX := iniReadSave("windowPosX", "gui", windowPosXDefault)
  windowPosY := iniReadSave("windowPosY", "gui", windowPosYDefault)
  clientWidth := iniReadSave("clientWidth", "gui", clientWidthDefault)
  clientHeight := iniReadSave("clientHeight", "gui", clientHeightDefault)
  
  windowPosX := max(windowPosX,-50)
  windowPosY := max(windowPosY,-50)

  return
}
;-------------------------------- saveGuiData --------------------------------
saveGuiData(){
  global hMain, configFile, windowPosX, windowPosY, clientWidth, clientHeight
  
  if (windowPosX < -100)
    windowPosX := 0
    
  if (windowPosY < -100)
    windowPosY := 0
  
  IniWrite, %windowPosX%, %configFile%, gui, windowPosX
  IniWrite, %windowPosY%, %configFile%, gui, windowPosY
  
  IniWrite, %clientWidth%, %configFile%, gui, clientWidth
  IniWrite, %clientHeight%, %configFile%, gui, clientHeight
  
  return
}
;--------------------------------- readSelja ---------------------------------
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
;----------------------------- startCheckUpdate -----------------------------
startCheckUpdate(){

  setTimer,checkFocus,delete
  checkUpdate()
  showWindow()

  return
}
;----------------------------- checkUpdate -----------------------------
checkUpdate(){
  global appname, appnameLower, localVersionFile, updateServer

  localVersion := getLocalVersion(localVersionFile)

  remoteVersion := getVersionFromGithubServer(updateServer . localVersionFile)

  if (remoteVersion != "unknown!" && remoteVersion != "error!"){
    if (remoteVersion > localVersion){
      msg1 := "New version available: (" . localVersion . " -> " . remoteVersion . ")`, please use the Updater (updater.exe) to update " . appname . "!"
      showHint(msg1, 3000)
      
    } else {
      msg2 := "No new version available (" . localVersion . " -> " . remoteVersion . ")"
      showHint(msg2, 3000)
    }
  } else {
    msg := "Update-check failed: (" . localVersion . " -> " . remoteVersion . ")"
    showHint(msg, 3000)
  }

  return
}
;------------------------------ getLocalVersion ------------------------------
getLocalVersion(file){
  
  versionLocal := 0.000
  if (FileExist(file) != ""){
    file := FileOpen(file,"r")
    versionLocal := file.Read()
    file.Close()
  }

  return versionLocal
}
;------------------------ getVersionFromGithubServer ------------------------
getVersionFromGithubServer(url){

  ret := "unknown!"

  whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
  Try
  { 
    whr.Open("GET", url)
    whr.Send()
    status := whr.Status
    if (status == 200){
     ret := whr.ResponseText
    } else {
      msgArr := {}
      msgArr.push("Error while reading actual app version!")
      msgArr.push("Connection to:")
      msgArr.push(url)
      msgArr.push("failed!")
      msgArr.push(" URL -> clipboard")
      msgArr.push("Closing Updater due to an error!")
    
      errorExit(msgArr, url)
    }
  }
  catch e
  {
    ret := "error!"
  }

  return ret
} 
;-------------------------------- startUpdate --------------------------------
startUpdate(){
  global wrkdir, appname, bitName, extension

  updaterExeVersion := "updater" . bitName . extension
  
  if(FileExist(updaterExeVersion)){
    msgbox,Starting "Updater" now, please restart "%appname%" afterwards!
    run, %updaterExeVersion% runMode
    exit()
  } else {
    msgbox, Updater not found!
  }
  
  showWindow()

  return
}
;----------------------------- showMessageSelja -----------------------------
showMessageSelja(hk1 := "", hk2 := ""){
  global menuHotkey
  global exitHotkey

  SB_SetParts(160,300)
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
   
  memory := "[" . GetProcessMemoryUsage() . " MB]      "
  SB_SetText("`t`t" . memory , 3, 2)

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
;------------------------------- showLinkList -------------------------------
showLinkList(){
  global wrkDir
  global configFile
  global linkListFile
  global linkListFileDefault
  global linkListArr
  global LV2
  
  IniRead, linkListFile, %configFile%, external, linkListFile, %linkListFileDefault%
  
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
;---------------------------- linkSelectedAction ----------------------------
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
  
  readConfig()
  readGuiData()
  readSelja()

  return
}
; *********************************** showWindow ******************************
showWindow(){
  global windowPosX, windowPosY, clientWidth, clientHeight
  global windowPosXDefault, windowPosYDefault, clientWidthDefault, clientHeightDefault
  
  setTimer,checkFocus, delete
  setTimer,registerWindow,-500
  Gui, guiMain:Show, x%windowPosX% y%windowPosY% w%clientWidth% h%clientHeight%
  setTimer,checkFocus,3000
  
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

  refreshGui()
  showWindow()
  
  showMessageSelja()
  
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

;--------------------------- guiMainListViewClick ---------------------------
guiMainListViewClick(){
  if (A_GuiEvent = "normal"){
    LV_GetText(rowSelected, A_EventInfo)
    runInDir(rowSelected)
  }

  return
}
;--------------------------------- runInDir ---------------------------------
runInDir(lineNumber){
  global wrkDir
  global pathBackup
  global seljaFile
  global seljaEntriesArr
  global toolsArr
  global setEXE4J, setUTF8
  global autoconfirm

  if (lineNumber != 0){

    ks := getKeyboardState()
    switch ks
    {
    case 1:
      ;*** Capslock ***
      showMessageSelja("Operation inhibited due to [Capslock]!")

    case 2:
      ;*** Alt ***
      showMessageSelja("Click + [Alt] is not yet used!")
  
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
      seljaEntryArr := StrSplit(seljaEntriesArr[lineNumber],",")
      javaPath := envVariConvert(seljaEntryArr[2])
      javaPathBin := StrReplace(envVariConvert(seljaEntryArr[3]),"...",javaPath)
      additionalPath := StrReplace(envVariConvert(seljaEntryArr[4]),"...",javaPath)
      
      ; save Path to file
      MAXQ := 20 ; may 20 path-cmds in log
      Que := ""
      
      dir := inWorkDir(pathBackup)
      if FileExist(dir){
        FileRead, Que, %dir%
        FileDelete, %dir%
        if (ErrorLevel){
          msgbox, Severe error deleting %dir%
          exit()
        }
      }
     
      RegRead, thePathRead,HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment,Path
      
      thePath := strReplace(thePathRead,";;",";")
      
      Que := StrQ( Que, thePath, MAXQ, "`n`n`n" ) ; add a new item to Que 
      
      FormatTime, dateTime 
      
      out := dateTime . ":`n`n" . Que
      
      dir := inWorkDir(pathBackup)
      FileAppend, %out%, %dir%, UTF-8-RAW
      if (ErrorLevel){
        msgbox, Severe error saving %dir%
        exit()
      }
      
      a := StrSplit(thePath,";")

      s := ""
      for index, element in a
      {
        if (!RegExMatch(element,"\\.*?[j,J]ava.*?\\bin") && !RegExMatch(element,"\\.*?[j,J]dk.*?\\bin") && !RegExMatch(element,"\\.*?openjdk.*?\\bin"))
          s := s . element . ";"
      }

      s := SubStr(s,1,-1) ; remove last ";"

      if (FileExist(javaPathBin) == ""){
        msgbox ******** SEVERE ERROR ******`nthe path`n%javaPathBin%`ndoes not exist!
        return
      }
      
      ;prepend
      if (javaPathBin != ""){
        s := javaPathBin . ";" . s
      }

      ;prepend additional
      if (additionalPath != ""){
        s := additionalPath . ";" . s
      }
      pv := strReplace(s,";",";`n")
      
      if (!autoconfirm){
          retScrollBox := ScrollBox(pv,"pb2","Windows-Path")
          if (retScrollBox == 1) {
            setEnv := setSystemEnvCmd(s, "Path")
            Run, %setEnv%,,min
            
            setEnv := setSystemEnvCmd(javaPath, "JAVA_HOME")
            Run, %setEnv%,,min

            if (setEXE4J == "yes"){
              setEnv := setSystemEnvCmd(javaPath, "EXE4J_JAVA_HOME")
              Run, %setEnv%,,min
            }
            
            if (setUTF8 == "yes"){
              setEnv := setSystemEnvCmd("-Dfile.encoding=UTF-8", "JAVA_OPTS")
              Run, %setEnv%,,min
            }
            
            showHint("Finished!", 2000)
          } else {
            showHint("Canceled!", 2000)
          }
      } else {
        setEnv := setSystemEnvCmd(s, "Path")
        Run, %setEnv%,,min
            
        setEnv := setSystemEnvCmd(javaPath, "JAVA_HOME")
        Run, %setEnv%,,min

        if (setEXE4J == "yes"){
          setEnv := setSystemEnvCmd(javaPath, "EXE4J_JAVA_HOME")
          Run, %setEnv%,,min
        }
        
        if (setUTF8 == "yes"){
          setEnv := setSystemEnvCmd("-Dfile.encoding=UTF-8", "JAVA_OPTS")
          Run, %setEnv%,,min
        }
      }
      showMessageSelja()
    }
  }
  
  return
}
;------------------------------ setSystemEnvCmd ------------------------------
setSystemEnvCmd(s := "", p := "Path"){

  theEnv := ""
  if(s != ""){
    theEnv := cvtPath("%SystemRoot%\System32\windowspowershell\v1.0\powershell.exe","")
    theEnv := theEnv . " -NoProfile -ExecutionPolicy Bypass -Command """
    theEnv := theEnv . "$newEnvVari = '" . s . "'`n"
    theEnv := theEnv . "[Environment]::SetEnvironmentVariable('" . p . "', ""$newEnvVari"",'Machine');""`n"
  }
  
  ;msgbox, % theEnv

  return theEnv
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
;------------------------------ openGithubPage ------------------------------
openGithubPage(){
  global appName
  
  csave := clipboardall

  StringLower, name, appName
  clipboard :=  "https://github.com/jvr-ks/" . name
  sendInput,#r
  sleep,1000
  sendInput,^v
  sendInput,{ENTER}
  
  clipboard := csave
  
  return
}
;------------------------------ openGraalVMPage ------------------------------
openGraalVMPage(){
   
  csave := clipboardall

  clipboard :=  "https://github.com/graalvm/graalvm-ce-builds/releases"
  sendInput,#r
  sleep,1000
  sendInput,^v
  sendInput,{ENTER}
  
  clipboard := csave
  
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
  retScrollBox := ScrollBox(s,"pb1","Windows-Path")
  
  showWindow()
  
  return
}
;------------------------------- editseljaFile -------------------------------
editseljaFile() {
  global notepadpath, seljaFile
  
  filename := seljaFile
  
  dir := inWorkDir(filename)
  f := notepadpath . " " . filename
  
  setTimer,checkFocus,delete
  Gui, guiMain:Destroy
  run %f%
  msgbox, Editing %filename% finished?
  exitReload()

  return
}
;-------------------------------- editConfigFile --------------------------------
editConfigFile() {
  global notepadpath, configFile 
  
  filename := configFile
  
  dir := inWorkDir(filename)
  f := notepadpath . " " . filename
  
  setTimer,checkFocus,delete
  Gui, guiMain:Destroy
  run %f%
  msgbox, Editing %filename% finished?
  exitReload()

  return
}
;----------------------------- editLinkListFile -----------------------------
editLinkListFile() {
  global notepadpath, linkListFile

  filename := linkListFile
  
  dir := inWorkDir(filename)
  f := notepadpath . " " . filename
  
  setTimer,checkFocus,delete
  Gui, guiMain:Destroy
  run %f%
  msgbox, Editing %filename% finished?
  exitReload()

  return
}
;---------------------------- editPathBackupFile ----------------------------
editPathBackupFile() {
  global notepadpath, pathBackup

  filename := pathBackup
  
  dir := inWorkDir(filename)
  f := notepadpath . " " . filename
  
  setTimer,checkFocus,delete
  Gui, guiMain:Destroy
  run %f%
  msgbox, Editing %filename% finished?
  exitReload()

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
  showMessageSelja(msg)
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
;--------------------------------- showHint ---------------------------------
showHint(s, n){
  global font
  global fontsize
  
  Gui, hint:Destroy
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
;------------------------------ showHintDestroy ------------------------------
showHintDestroy(){
  global hinttimer

  setTimer,showHintDestroy, delete
  Gui, hint:Destroy
  return
}
;---------------------------------- tipTop ----------------------------------
tipTop(msg, n := 1){

  s := StrReplace(msg,"^",",")
  
  toolX := Floor(A_ScreenWidth / 2)
  toolY := 2

  CoordMode,ToolTip,Screen
  ToolTip,%s%, toolX, toolY, n
  
  WinGetPos, X,Y,W,H, ahk_class tooltips_class32

  toolX := (A_ScreenWidth / 2) - W / 2
  
  ToolTip,%s%, toolX, toolY, n
  
  return
}
;----------------------------- tipScreenTopTime -----------------------------
tipScreenTopTime(msg, t := 2000, n := 1){
  ; Closes all tips after timeout

  CoordMode,ToolTip,Screen
  tipTop(msg, n)
  
  if (t > 0){
    tvalue := -1 * t
    SetTimer,tipTopClose,%tvalue%
  }
  
  CoordMode,ToolTip,Client
  return
}
;-------------------------------- tipTopClose --------------------------------
tipTopClose(){
  
  Loop, 20
  {
    ToolTip,,,,%A_Index%
  }
  
  return
}
;--------------------------- GetProcessMemoryUsage ---------------------------
GetProcessMemoryUsage() {
    PID := DllCall("GetCurrentProcessId")
    size := 440
    VarSetCapacity(pmcex,size,0)
    ret := ""
    
    hProcess := DllCall( "OpenProcess", UInt,0x400|0x0010,Int,0,Ptr,PID, Ptr )
    if (hProcess)
    {
        if (DllCall("psapi.dll\GetProcessMemoryInfo", Ptr, hProcess, Ptr, &pmcex, UInt,size))
            ret := Round(NumGet(pmcex, (A_PtrSize=8 ? "16" : "12"), "UInt") / 1024**2, 2)
        DllCall("CloseHandle", Ptr, hProcess)
    }
    return % ret
}
;-------------------------------- inWorkDir --------------------------------
inWorkDir(p){
  global wrkdir
  
  r := wrkdir . p
    
  return r
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
    
  if (getkeystate("LWin","P") == 1)
    r:= r + 16
    
  if (getkeystate("RWin","P") == 1)
    r:= r + 16

  return r
}
;------------------------------ windowsEnvTool ------------------------------
windowsEnvTool(){
  runWait  C:\Windows\System32\SystemPropertiesAdvanced.exe
  return
}
;----------------------------------- StrQ -----------------------------------
; from https://www.autohotkey.com/boards/viewtopic.php?t=57295#p328684

StrQ(Q, I, Max:=10, D:="|") { ;          StrQ v.0.90,  By SKAN on D09F/D34N @ tiny.cc/strq
Local LQ:=StrLen(Q), LI:=StrLen(I), LD:=StrLen(D), F:=0
Return SubStr(Q:=(I)(D)StrReplace(Q,InStr(Q,(I)(D),,0-LQ+LI+LD)?(I)(D):InStr(Q,(D)(I),0,LQ
-LI)?(D)(I):InStr(Q,(D)(I)(D),0)?(D)(I):"","",,1),1,(F:=InStr(Q,D,0,1,Max))?F-1:StrLen(Q))
}
;------------------------------------ eq ------------------------------------
eq(a, b) {
  if (InStr(a, b) && InStr(b, a))
    return 1
  return 0
}
;---------------------------- guNativeImageInstall ----------------------------
guNativeImageInstall(){

  runcmd := A_ComSpec
  Run, %runcmd%,,max
  sleep, 2000
  sendinput gu install native-image{Enter}
  sleep, 3000
  sendinput exit{Enter}
  
  return
}
;---------------------------------- guList ----------------------------------
guList(){
  Run, %A_ComSpec% /k gu list,,max
  
  return
}
;-------------------------------- guAvailable --------------------------------
guAvailable(){
  Run, %A_ComSpec% /k gu available,,max
  
  return
}   
;-------------------------------- openJavaDir --------------------------------
openJavaDir(){

  EnvGet, runcmd, JAVA_HOME
  Run, %runcmd%,,max  
      
  return
}
;-------------------------------- createMime --------------------------------
createMime(){
  
  if (!FileExist("mime.types")){
    FileAppend,
    (LTrim
    text/html                             html htm shtml
    text/css                              css
    text/xml                              xml
    image/gif                             gif
    image/jpeg                            jpeg jpg
    application/x-javascript              js
    application/atom+xml                  atom
    application/rss+xml                   rss

    text/mathml                           mml
    text/plain                            txt
    text/vnd.sun.j2me.app-descriptor      jad
    text/vnd.wap.wml                      wml
    text/x-component                      htc

    image/png                             png
    image/tiff                            tif tiff
    image/vnd.wap.wbmp                    wbmp
    image/x-icon                          ico
    image/x-jng                           jng
    image/x-ms-bmp                        bmp
    image/svg+xml                         svg svgz
    image/webp                            webp

    application/java-archive              jar war ear
    application/mac-binhex40              hqx
    application/msword                    doc
    application/pdf                       pdf
    application/postscript                ps eps ai
    application/rtf                       rtf
    application/vnd.ms-excel              xls
    application/vnd.ms-powerpoint         ppt
    application/vnd.wap.wmlc              wmlc
    application/vnd.google-earth.kml+xml  kml
    application/vnd.google-earth.kmz      kmz
    application/x-7z-compressed           7z
    application/x-cocoa                   cco
    application/x-java-archive-diff       jardiff
    application/x-java-jnlp-file          jnlp
    application/x-makeself                run
    application/x-perl                    pl pm
    application/x-pilot                   prc pdb
    application/x-rar-compressed          rar
    application/x-redhat-package-manager  rpm
    application/x-sea                     sea
    application/x-shockwave-flash         swf
    application/x-stuffit                 sit
    application/x-tcl                     tcl tk
    application/x-x509-ca-cert            der pem crt
    application/x-xpinstall               xpi
    application/xhtml+xml                 xhtml
    application/zip                       zip

    application/octet-stream              bin exe dll
    application/octet-stream              deb
    application/octet-stream              dmg
    application/octet-stream              eot
    application/octet-stream              iso img
    application/octet-stream              msi msp msm

    audio/midi                            mid midi kar
    audio/mpeg                            mp3
    audio/ogg                             ogg
    audio/x-m4a                           m4a
    audio/x-realaudio                     ra

    video/3gpp                            3gpp 3gp
    video/mp4                             mp4
    video/mpeg                            mpeg mpg
    video/quicktime                       mov
    video/webm                            webm
    video/x-flv                           flv
    video/x-m4v                           m4v
    video/x-mng                           mng
    video/x-ms-asf                        asx asf
    video/x-ms-wmv                        wmv
    video/x-msvideo                       avi
    ), mime.types, UTF-8-RAW
  }
  
  return
}
;-------------------------------- exitReload --------------------------------
exitReload(){
  global allparams, wrkdir
  
  if A_IsCompiled
      Run "%A_ScriptFullPath%" /force %allparams%, %wrkdir%
  else
      Run "%A_AhkPath%" /force "%A_ScriptFullPath%" %allparams% , %wrkdir%
  
  ExitApp

  return
}
;--------------------------------- errorExit ---------------------------------
errorExit(theMsgArr, clp := "") {
 
  saveGuiData()
 
  msgComplete := ""
  for index, element in theMsgArr
  {
    msgComplete .= element . "`n"
  }
  msgbox,48,ERROR,%msgComplete%
  
  exit()
}
;----------------------------------- exit -----------------------------------
exit() {
  global app
  
  saveGuiData()
  
  showHint("""" . app . """ removed from memory!", 1500)
  sleep,1500
  ExitApp,0
  
  return
}
;----------------------------------------------------------------------------


