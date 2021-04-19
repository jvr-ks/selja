#### Latest changes: [-> README](README.md)
  
  
* Path to remove can contain "Java" or "java"
* EXE4J_JAVA_HOME can be set too 
* Menu entry "Show Path"  
Shows the actual System-Path, one entry on a line.
  
* Menu entry "GraalVM"
* Menu entry "Edit PathBackup-file: ..."  
* "_thePathSaved.log" renamed to "_thePathBackup.txt"  
* Menu entry "Hide ..." removed  
  
* "hidemenu" start-parameter renamed to "hidewindow" !  
* Reads the Path from the Windows-Registry, keeping the environment variables (not expanding them)  
* Uses a Powershell command to set the path (not the buggy "setx")  
* Config-file "selja.txt" update  
* removing "\\java\\" and "\\zulu\\" from path   
* Additional entry added: can set a 2nd path entry (used by Graal-VM native-image exe)  
* Minor gui changes, Configuration-file is UTF-8 now  
* Gui redesigned: Autohide (not in list of runningapps!), Autoheight of the window, Commands moved to a menu  
* Exe is 64bit now  
* Edit entry with [Shift]-click (not Ctrl)  
* Bug setting JAVA_HOME removed  
* New menu entry: "Linklist of Java-Sources webpages"   
Relies on Windows default https: ... -> open webpage.    
  
* "compile.bat" must be run as adminitrator (to stop the possible running app)  
* Helper app "javaVersion.exe" (source: javaVersion.ahk)  
Shows actual java version.  
The result from "java -version" is shown as a tooltip (12 seconds).   
It is written to the file "actualJava.txt" also.   
  
* Start parameter ~~"hidemenu"~~ "hidewidow"  
  
[-> README](README.md)  


