@echo OFF
cd %CD%/..

@echo:
echo Installing Coral Cloud - Base + Employee
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
choice /c yn /n /m "Are the above features enabled? [y]"
@echo:
if /i "%errorlevel%" neq "1" (
  echo Installation aborted.
  exit /b %errorlevel%
)

echo "[1/7] Pushing base source..."
cmd.exe /c sf project deploy start -d cc-base-app
call :checkForError
@echo:

echo "[2/7] Assigning Prompt Template Manage permission set..."
cmd.exe /c sf org assign permset -n EinsteinGPTPromptTemplateManager
call :checkForError
@echo:

echo "[3/7] Pushing employee-app source..."
cmd.exe /c sf project deploy start -d cc-employee-app
call :checkForError
@echo:

echo "[4/7] Assigning Coral Cloud permission sets..."
cmd.exe /c sf org assign permset -n Coral_Cloud_Admin
cmd.exe /c sf org assign permset -n Coral_Cloud_Employee_Agent_Access
call :checkForError
@echo:

echo "[5/7] Importing sample data..."
cmd.exe /c sf data tree import -p data/data-plan.json
call :checkForError
@echo:

echo "[6/7] Generate additional sample data..."
cmd.exe /c sf apex run -f apex-scripts/setup.apex
call :checkForError
@echo:

echo "[7/7] Installing Data Kit..."
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
