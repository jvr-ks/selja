@rem testRestApi.bat


@echo off

cd %~dp0


echo Version is:
call java -version
echo.
timeout /t 5

@rem activate an "old" version
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



