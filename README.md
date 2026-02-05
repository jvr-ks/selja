# Selja  
(**Sel**ect **Ja**va)  
  
#### Purpose
The purpose of "Selja" is to switch between different Java versions.  
It modifies the Windows (System)-PATH and can set the JAVA_HOME environment-variable too.  
**Windows only** (64 bit)  

##### Caution
**This tool changes the Windows (System)-PATH environment variable of your Windows.**  
**Please do not use it, if you cannot handle System-PATH environment variable problems!**   
  
* **Removes System-PATH entries:**  
* * All entries containing the characters "\.*?java.*?\bin" or "\.*?java.*?\lib\svm\bin"
  
* * "C:\Program Files (x86)\Common Files\Oracle\Java\javapath"  
  
The System-PATH is logged to the file "_thePathBackup.txt" before.  
(The last 20 values with a timestamp).
  
#### HINT
The list of locally available Java versions "selja.txt" (if versions are installed!) contains no subversions,  
so rename the folders accordingly.  
Example:  
Rename the folder:  
C:\shared\graalvm-community-openjdk-25.0.0**+37.1**  
to:  
C:\shared\graalvm-community-openjdk-25.0.0  
  
**Remember: An already running shell (console) must be reopened to reflect the changes of the Windows-path!**  
or use the included script "resetvars.vbs", which creates the batchfile "resetvars.bat",  
calling this batchfile then creates all environment including Windows-path the variables inside the running shell.  
Take a look at the included batch-file "restApiTest.bat".  


#### Latest changes  
  
Version (>=)| Change
------------ | -------------  
0.135 | Bugfixes
0.134 | Uses powershell 1.0 to set environment variables ("Path", "JAVA_HOME" and "setEXE4J_JAVA_HOME" if enabled)
0.129 | removes duplicate entries from windows-path, i.e.: "java ... \\bin", "jdk ... \\bin", "openjdk ... \\bin",
0.126 | \[Config-file] changed to ("selja_COMPUTERNAME.ini") (UTF-16 LE-BOM encoded)
0.125 | Updater integration
0.122 | Some Gui-bugs fixed
0.118 | File "mime.type" created auto. if not existent
0.117 | UAC request integrated
0.106 | Default port is: 65500 
  
#### Known issues / bugs 
Issue / Bug | Type | fixed in version
------------ | ------------- | -------------
Scala 3 (sbt console) fails with "graalvm-community-openjdk-21+35.1" | issue | ---
Version-display has the wrong position | issue | 0.105
  
   
#### Download via Updater (preferred method)
Portable, run from any directory, but running from a subdirectory of the windows programm-directories   
(C:\Program Files, C:\Program Files (x86) etc.) is not recommended!  
**Installation-directory (is created by the Updater) must be writable by the app!** 
  
To download **selja.exe** 64 bit Windows from Github please use:  
  
[updater.exe 64bit](https://github.com/jvr-ks/selja/raw/main/updater.exe)  
  
(Updater viruscheck please look at the [Updater repository](https://github.com/jvr-ks/updater)) 

* From time to time there are some false positiv virus detections
[Virusscan](#virusscan) at Virustotal see below.  
  
The default installation-directory is:  
C:\jvrde\selja
  
Open this directory with your filemanger.  
"selja.exe" does the work (stays running as a service).  
The "javaVersion.exe" shows the actual selected Java version (does nothing more than a "java -version" command).  
There are some batch-files to play with:
- testRestApi.bat  
- testDirectCall.bat  
(Run them as an admin)  
Selja does not download or install any Java resources!  
  
#### How it works  
This simple tool can switch among different java runtime versions.  
Uses a Powershell command to set the System-Path (64 bit Powershell must be available),  
must be **run as an administrator** therefor!  
  
With a \[Click] on an entry in the list:  
1. All PATH entries containing the following characters:  
"\\java\\bin"  
(eventually more to come ...)  
are removed!   
  
The Java bin-directory is prepended to the path then.  
  
2. The "JAVA_HOME" environment-variable is set accordingly.   
  
3. If the Configuration-file contains an entry in the section \[config]: setEXE4J_JAVA_HOME="yes",  
the environment-variable "EXE4J_JAVA_HOME" is set to the "JAVA_HOME" path too.  
  
If the Selja window loses the focus (or by a click on the window minimize button),  
Selja goes to the background and can be activated again via the hotkey (default is: \[ALT + j]).   
(or the REST-Api)   
  
**Other click-operations currently defined:**  
  
Click-modifier | Operation
------------ | -------------
\[Shift] | edit selected entry
\[Ctrl] | open the path with the default filemanager

#### Configuration 
Configuration is done by a few configuration-files,  
use [Notepad++](https://notepad-plus-plus.org/) to edit the configuration-files.  
  
Definitions-file:  
**"selja.txt"**,  
contains on each line delimited by a comma or a tab:  
  
Entry 1 | Entry 2 | Entry 3 | Entry 4
------------ | ------------- | ------------- | -------------  
The selection-name, | path of the JDK directory, | path of the JDK bin-directory *) | additional path    
  
selection-name: 
**Blanks are NOT allowed in the selection-name!**  
  
Path of the Java-directory:  
The path to the JDK  
(If you only have a JRE, this tool is not for you).  

*)
Path of the Java bin-directory: In most cases the \bin subdirectory of the JDK.  
Three points "..." is a shortcut of the Path to the Java-directory!  

additional path :  
Can be used if another subdirectory must be added to the path.  
  
**Attention: Remove any trailing "\\" from the path!**  

#### \[Config-file]    
The \[Config-file] ("selja_COMPUTERNAME.ini") is generated automatically, if it doesn't exist already.  
There is a menu-button to edit the \[Config-file] via an external plain-text-editor.  
  
Section [hotkeys]:  
Hotkeys can be set to "off" by adding the word "off" to the definition.  
The two app-hotkeys defaults are:  
menuhotkey="!j", i.e. \[ALT] + \[j] to show the app-window  
exithotkey="+!j", i.e. \[SHIFT] + \[ALT] + \[j] to exit the app and remove it from memory  
(you may use the button "Kill the app" also)  
  
Primary hotkey modifiers:  
Hotkey prefix | Modifier Key |  Remark
------------ | ------------- | ------------- 
! | \[ALT] |
^ | \[CTRL] |
\# | \[WIN] |
\+ | \[SHIFT] |  
    
Other [Autohotkey Hotkeys](https://www.autohotkey.com/docs/Hotkeys.htm) hotkeys-characters are usable,  
but are untested.  
Only simple hotkeys are good to remember and fast to access!  

You may use the included extra app "javaVersion.exe" to check the actual java-version. 
(Just executes a java -version command).  

Section \[config]:  
If the app window is reopened after hiding (autohiding if focus is lost) or at a fresh start of the app,  
the size of the window may be incorrect (due to a bug).  
The parameters:  
windowWidthOffset=VALUE  
and  
windowHeightOffset=VALUE  
may compensate the size error (if app window is not maximized).  
They must be set manually once (trial and change method).  
Examples:  
My laptop J20 has a display resolution of 3840 x 2160 and windows dpi-scaling is set to 350%.  
Using:
\[config]
...
windowWidthOffset=3
windowHeightOffset=129
...
everything is fine then.
My older laptop J70 has a display resolution of 1280 x 800 and windows dpi-scaling is set to 100%.  
Using:
\[config]
...
windowWidthOffset=3
windowHeightOffset=52
...
everything is fine then.
  
#### Start  
"selja.exe" shows the selja gui-window.  
"selja.exe hidewindow" runs selja in the background, use the hotkey to show the gui-window.    
  
If Selja loses the focus, the gui-window is closed and Selja runs in the background, use the hotkey to show the gui-window.    
(It is NOT in the tasklist then!)    
  
**Hotkeys are configurable** by editing the configuration-file "selja.ini".  
Use [Notepad++](https://notepad-plus-plus.org/) to edit the configuration-file.  
[Hotkey modifier symbols](https://www.autohotkey.com/docs/Hotkeys.htm).
Only simple Hotkey modifications are reflected in the menu.  
(Parsing is limited to \[CTRL], \[ALT], \[WIN], \[SHIFT]).  

#### Requirements
* Windows 10 or later only.

#### Sourcecode
Github URL [github](https://github.com/jvr-ks/selja).
[Autohotkey format](https://www.autohotkey.com)

#### Hotkeys
[Overview of all default Hotkeys used by my Autohotkey "tools"](https://github.com/jvr-ks/cmdlinedev/blob/main/hotkeys.md)
  
#### RestApi
If Selja is running it listens to commands of the form:  
curl http://localhost:65500/selja?version=(graalvm-ce-java8-21.2.0)  
or URL in a browser:  
http://localhost:65500/selja?version=(graalvm-ce-java8-21.2.0)  

Setting via the server takes a few seconds!
  
The port-number is defined in the Configuration-file: "seljaRestPort=65500" (65500 is default) 
  
Use "restapioff" start-parameter to disable the RestApi server.  
   
Can set the Scala-version (the Windows-Path) inside a batch-file now, without being an admin,  
but a batch-process gets its environment at the start (and inherits it to any subprocess).    

Using the Visual Basic script, "resetvars.vbs", which generates a batchfile "resetvars.bat" in the temporary directory,    
environment variables can be reread, example batchfile,    
(needs curl and installed jdk8-271-Oracle + graalvm-ce-java11-21.2.0): 

```
@rem restApiTest.bat

@echo off
echo Version is:
call java -version
echo.
timeout /t 5

@rem activate "old" version
call curl http://localhost:65500/selja?version=(jdk8-271-Oracle)
echo.
timeout /t 3

@rem reread environment variables
call %~dp0resetvars.vbs
call %TEMP%\resetvars.bat

echo.
echo Version now is:
call java -version
echo.

timeout /t 5

@rem back to actual version
call curl http://localhost:65500/selja?version=(graalvm-ce-java11-21.2.0)
echo.
timeout /t 3

@rem reread environment variables
call %~dp0resetvars.vbs
call %TEMP%\resetvars.bat

echo.
echo Version now is:
call java -version
echo.

pause

```
  
("resetvars.vbs" must be in the Windows-Path)  
  
** Besides that, the purpose of "selja" is NOT to temporary switch the Scala-version in a batch-file,     
because this can be done with path=scalapathXYZ;%path% and "set SCALA_HOME= ..." etc. !** 
  
#### License: GNU GENERAL PUBLIC LICENSE
Take a look at the file "license.txt" 
  
Start of development: 2020/10/15  
  
Copyright (c) 2020 J. v. Roos

<a name="virusscan">


##### Virusscan at Virustotal 
[Virusscan at Virustotal, selja.exe 64bit-exe, Check here](https://www.virustotal.com/gui/url/006addcfc66aceea65932ed451de3de357dadf3d890d26c0f5011b8a1be1cf33/detection/u-006addcfc66aceea65932ed451de3de357dadf3d890d26c0f5011b8a1be1cf33-1770325282
)  
Use [CTRL] + Click to open in a new window! 
