@echo OFF
cd %CD%/..

@echo:
echo Installing Coral Cloud - Base
@echo:

rem Use existing org
echo Using current default org
@echo:

rem Open DC Setup home
cmd.exe /c sf org open -p lightning/setup/SetupOneHome/home?setupApp=audience360
@echo:

rem Wait for DC activation
echo STOP: wait for Data Cloud deployment completion before moving forward.
echo You can check progress in Data Cloud Setup.
choice /c yn /n /m "Is Data Cloud is fully enabled? [y]"
@echo:
if /i "%errorlevel%" neq "1" (
  echo Installation aborted.
  exit /b %errorlevel%
)

echo STOP: ensure that you've toggled on the following features:
echo  * Einstein
echo  * Agents
echo  * Einstein for Sales - Sales Emails
choice /c yn /n /m "Are the above features enabled? [y]"
@echo:
if /i "%errorlevel%" neq "1" (
  echo Installation aborted.
  exit /b %errorlevel%
)

echo Pushing source...
cmd.exe /c sf project deploy start -d cc-base-app
call :checkForError
@echo:

echo Assigning permission sets...
cmd.exe /c sf org assign permset -n Coral_Cloud
call :checkForError
@echo:

echo Importing sample data...
cmd.exe /c sf data tree import -p data/data-plan.json
call :checkForError
@echo:

echo Generate additional sample data...
cmd.exe /c sf apex run -f apex-scripts/setup.apex
call :checkForError
@echo:

echo Installing Data Kit...
cmd.exe /c sf package install -p 04tHr000000ku4k -w 10
call :checkForError
@echo:

rem Report install success if no error
@echo:
if ["%errorlevel%"]==["0"] (
  echo Installation completed.
  @echo:
  cmd.exe /c sf org open -p lightning/page/home
)

:: ======== FN ======
GOTO :EOF

rem Display error if the install has failed
:checkForError
if NOT ["%errorlevel%"]==["0"] (
    echo Installation failed.
    exit /b %errorlevel%
)
