# Selja  
(**Sel**ect **Ja**va)  
    
## Caution
**Windows only**  
**This tool changes the Windows (System)-PATH environment variable of your Windows.**  
**Please do not use it, if you cannot handle System-PATH environment variable problems!**   
  
* **Removes System-PATH entries:**  
* * All entries containing the characters "\.*?java.*?\bin" or "\.*?java.*?\lib\svm\bin"
  
* * "C:\Program Files (x86)\Common Files\Oracle\Java\javapath"  
  
The System-PATH is logged to the file "_thePathBackup.txt" before.  
(The last 10 values with a timestamp).
  
#### [-> Latest changes/ bug fixes](latest_changes.md)
   
   
#### App status
Start of development: 2020/10/15  
**Files use UTF-8 encoding (no BOM).**    
  
**Beta!**  
Usable, but development has not finished yet. ...   
  
### HINT
**Remember: An already running shell (console) must be reopened to reflect the changes of the Java-Path!**

#### Files needed to run Selja / Download
(Right-click ... save as ... to download)  
* [selja.exe](https://github.com/jvr-ks/selja/raw/master/selja.exe) App   
* [selja.ini](https://github.com/jvr-ks/selja/raw/master/selja.ini) Configuration-file, created if not existent  
* [selja.txt](https://github.com/jvr-ks/selja/raw/master/selja.txt) Definitions-file  
* [seljaLinkList.txt](https://github.com/jvr-ks/selja/raw/master/seljaLinkList.txt) (optional)  
* [javaVersion.exe](https://github.com/jvr-ks/selja/raw/master/javaVersion.exe) App to show actual Java-version


Virus check see below.  
  
#### Description   
This simple tool can switch among different java runtime versions.  
Uses a Powershell command to set the System-Path (64 bit Powershell must be available),  
must be **run as an administrator** therefor!  
  
Right click "selja.exe", select "Run as administrator", 
   
or  
Prepare once: Right click, select "Create Shortcut".  
Right click on the Shortcut "selja.lnk", -> "Advanced..." -> Select "Run as Administrator".    
  
Then allways click on "selja.lnk" to start selja.  

or  

use the batch-file: "create_selja_exe_link_with_hidewindow.bat" once to create an autostart entry.  
Selja ist started in the background then. Use the hotkey to show the menu.  
  
  
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
Selja goes to the background an can be activated again via the hotkey (default is: \[ALT + j]).    
  
**Other click-operations currently defined:**  
  
Click-modifier | Operation
------------ | -------------
\[Shift] | edit selected entry
\[Ctrl] | open the path with the default filemanager

#### Configuration 
Configuration is done by a few config-files,  
use [Notepad++](https://notepad-plus-plus.org/) to edit the config-files.  
  
Definitions-file:  
**"selja.txt"**,  
contains on each line delimited by a comma or a tab:  

Entry 1 | Entry 2 | Entry 3
------------ | ------------- | -------------
Any name, | path of the JDK directory, | path of the JDK bin-directory *)  
  

The name: What ever name you want :-)  
Path of the Java directory: The path to the JDK  
(If you only have a JRE, this tool is not for you).  

*)
Path of the Java bin-directory: In most cases the \bin subdirectory of the JDK.  
Three points "..." is a shortcut of the Path of the Java directory!  
  
**Attention: Remove any trailing "\\" from the path!**  

Configuration-file:
**"selja.ini"**, 
hotkey configurations etc.  
  
Default hot key is: 
* **\[ALT + j]** open menu  
* **\[SHIFT + ALT + j]** remove app from memory.  

You may use the included extra app "javaVersion.exe" to check the actual java-version. 
(Just does a java -version command).  
  
#### Start
* Start Selja by a right click onto the file "selja.exe".  
Select "Run as administator".

or  
  
Run the script "create_selja_exe_link_with_hidewindow.bat" once.  
  
Start selja by a right click onto the file "selja.lnk".  
Select "Run as administator". 
Selja ist started in the background. Use the hotkey to show the context-menu.
  
**Hotkeys are configurable** by editing the config-file "selja.ini".  
Use [Notepad++](https://notepad-plus-plus.org/) to edit the config-file.  
[Hotkey modifier symbols](https://www.autohotkey.com/docs/Hotkeys.htm).
Only simple Hotkey modifications are reflected in the menu.  
(Parsing is limited to \[CTRL], \[ALT], \[WIN], \[SHIFT]).  

#### Requirements
* Windows 10 or later only.

#### Sourcecode
Github URL [github](https://github.com/jvr-ks/selja).
[Autohotkey format](https://www.autohotkey.com)

#### Hotkeys
[Overview of all default Hotkeys used by my Autohotkey "tools"](https://github.com/jvr-ks/cmdlinedev/blob/master/hotkeys.md)
  

#### License: MIT
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sub-license, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANT-ABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Copyright (c) 2020 J. v. Roos


##### Virus check at Virustotal 
[Check here](https://www.virustotal.com/gui/url/f64aaa1c5045f63cfef9d1701d3b4a8055259366728048d04d8db8fcf4012e23/detection/u-f64aaa1c5045f63cfef9d1701d3b4a8055259366728048d04d8db8fcf4012e23-1618840073
)  
Use [CTRL] + Click to open in a new window! 
