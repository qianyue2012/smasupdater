::Super Mario All-Stars++ Updater (v1.6.0)
::By Spencer Everly
::Hi there, thanks for analyzing this code. It's... not the best, but it gets the job done.
::Comments will be around this code to explain what each does for easier readability.

::If you want to use a custom folder instead of the usual name, you can rename this below to anything you want.
set "episodeFolder=Super Mario All-Stars++"

@ECHO off
cls
:start
@echo off
setlocal enableDelayedExpansion
::Make sure commands don't get in the way...

set /a size=80-1 & rem screen size minus one

::With that out of the way, we can start
title Super Mario All-Stars++ Updater ^(v1.6.1^)
echo Starting updater...
::This makes sure we go into the root of the .bat, preventing errors
pushd "%~dp0"
@timeout 0 /nobreak>nul
::Check to see if we're running as an admin. If so, don't launch the updater.
fsutil dirty query !systemdrive! >NUL 2>&1
if /i !ERRORLEVEL!==0 (
	cls
	echo You can^'t run this as an admin.
	echo.
	echo Please restart the program as an normal elevated user
	echo and try again.
	pause
	exit
)

if not exist smassav_backup ( mkdir smassav_backup )
if not exist "%cd%\data\worlds\%episodeFolder%" (mkdir "%cd%\data\worlds\%episodeFolder%" )

::We then start the menu.
:start
cls
echo Super Mario All-Stars^+^+ Downloader^/Updater
echo v1.6.1
echo.
echo Make SURE this .bat ^(And PortableGit^) is in the SMBX2 folder
echo before downloading^/updating^^!^^!^^!^^!^^!
echo.
echo Press 1 and enter to download^/update Super Mario All^-Stars^+^+.
echo Press 2 and enter for some settings.
echo Press 3 and enter to exit.
::These are choices set to launch certain parts of the .bat.
set choice=
set /p choice=
if not '%choice%'=='' set choice=%choice:~0,1%
if '%choice%'=='1' goto prechecksmas
if '%choice%'=='2' goto settingsmenu
if '%choice%'=='3' goto exit
echo "%choice%" is not valid, try again.
goto start

::Here's the settings menu.
:settingsmenu
cls
echo SETTINGS
echo Go here for some file management settings. These are here for if there are any
echo downloading issues, or anything else at all.
echo.
echo Press 1 and enter to refresh SMAS^+^+ ^(Saves will be kept^).
echo Press 2 and enter to delete SMAS^+^+ for redownloading ^(Saves will be kept^).
echo Press 3 and enter to copy saves to backup from SMAS^+^+.
echo Press 4 and enter to move backup saves back to SMAS^+^+.
echo Press 5 and enter to return back to the main menu.
set choice=
set /p choice=
if not '%choice%'=='' set choice=%choice:~0,1%
if '%choice%'=='1' goto clearsmas
if '%choice%'=='2' goto clearsmasandgit
if '%choice%'=='3' goto copysavesfromsmas
if '%choice%'=='4' goto movesavestosmas
if '%choice%'=='5' goto start
echo "%choice%" is not valid, try again.
goto settingsmenu

:copysavesfromsmas
cls
echo Backing up saves...
@timeout 0 /nobreak>nul
if not exist "%cd%\data\worlds\%episodeFolder%\save1.sav" then goto nosavesfound
copy /y "%cd%\data\worlds\%episodeFolder%\*.sav" "%cd%\smassav_backup"
copy /y "%cd%\data\worlds\%episodeFolder%\*-ext.dat" "%cd%\smassav_backup"
echo Done^^! Returning to the menu in 5 seconds...
@timeout 5 /nobreak>nul
goto settingsmenu

:movesavestosmas
cls
echo Moving saves...
@timeout 0 /nobreak>nul
if not exist "%cd%\smassav_backup\save1.sav" then goto nosavesfound
move /y "%cd%\smassav_backup\*.sav" "%cd%\data\worlds\%episodeFolder%"
move /y "%cd%\smassav_backup\*-ext.dat" "%cd%\data\worlds\%episodeFolder%"
echo Done^^! Returning to the menu in 5 seconds...
@timeout 5 /nobreak>nul
goto settingsmenu

:clearsmas
::We will now move saves out to it's own folder.
cls
echo Moving saves...
@timeout 0 /nobreak>nul
move /y "%cd%\data\worlds\%episodeFolder%\*.sav" "%cd%\smassav_backup"
move /y "%cd%\data\worlds\%episodeFolder%\*-ext.dat" "%cd%\smassav_backup"
echo Refreshing game for regeneration...
@timeout 0 /nobreak>nul
call Recycle.exe "data/worlds/%episodeFolder%"
mkdir "%cd%\data\worlds\%episodeFolder%"
@timeout 0 /nobreak>nul
echo Done^^! Returning to the menu in 5 seconds... ^(You should find your saves in the
echo ^"smassav_backup^" folder.^)
@timeout 5 /nobreak>nul
goto settingsmenu

:clearsmasandgit
::We will now move saves out to it's own folder.
cls
echo Moving saves...
@timeout 0 /nobreak>nul
mkdir smassav_backup 
move /y "%cd%\data\worlds\%episodeFolder%\*.sav" "%cd%\smassav_backup"
move /y "%cd%\data\worlds\%episodeFolder%\*-ext.dat" "%cd%\smassav_backup"
echo Restarting state for redownloading...
@timeout 0 /nobreak>nul
call Recycle.exe "data/worlds/%episodeFolder%/.git"
@timeout 0 /nobreak>nul
echo Done^^! Returning to the menu in 5 seconds... ^(You should find your saves in the
echo ^"smassav_backup^" folder.^)
@timeout 5 /nobreak>nul
goto settingsmenu

:nosavesfound
echo No saves found^^! Returning to the menu in 5 seconds...
@timeout 5 /nobreak>nul
goto settingsmenu

::Precheck checks to see if there's a .git folder which holds the latest update data. If one doesn't exist, it goes to the nogit part.
:prechecksmas
cls
echo Checking for SMAS^+^+ updates...
@timeout 0 /nobreak>nul
cd data
cd worlds
if not exist .git ( goto nogitsmas )
if exist .git ( goto yesgitsmas )

:yesgitsmas
cd ../..
::Now we start updating the episode if .git wasn't found.
echo Pulling the latest update from GitHub...
::This reads the .git for the repository that's saved
call PortableGit\bin\git.exe -C "data/worlds/%episodeFolder%" fetch --all
::This resets to download a different branch if so
call PortableGit\bin\git.exe -C "data/worlds/%episodeFolder%" reset --hard
::The set stuff improves the connection when downloading the repo
set GIT_TRACE_PACKET=1
set GIT_TRACE=1
set GIT_CURL_VERBOSE=1
::Downloads the specific branch from the repo that is stored
call PortableGit\bin\git.exe -C "data/worlds/%episodeFolder%" pull origin main
::The download is finally complete
goto updatecomplete

:nogitsmas
cd ../..
::Ping the Internet to start a connection
PING -n 5 127.0.0.1>nul
::Make a .git folder
call PortableGit\bin\git.exe -C "data/worlds/%episodeFolder%" init
::Add the SMAS++ repo to the .git list
call PortableGit\bin\git.exe -C "data/worlds/%episodeFolder%" remote add origin https://github.com/SpencerEverly/smasplusplus.git
::The set stuff improves the connection when downloading the repo
set GIT_TRACE_PACKET=1
set GIT_TRACE=1
set GIT_CURL_VERBOSE=1
::Downloads the specific branch from the repo that is stored
call PortableGit\bin\git.exe -C "data/worlds/%episodeFolder%" pull origin main
::The download is finally complete
goto updatecomplete

:updatecomplete
echo.
echo Download complete. Check above to see if there are any errors. If any,
echo you can correct them by doing what is above.
echo.
echo If you want to run SMBX2.exe just press 1 and enter.
echo If you don^'t want to^, just press 2 and enter ^(Or close the window^).
echo If you want to restart the download again^, just press 3 and enter.
echo If you want to restart the program^, press 4 and enter.
set choice=
set /p choice=
if not '%choice%'=='' set choice=%choice:~0,1%
if '%choice%'=='1' goto launchsmbx2
if '%choice%'=='2' goto dontlaunchsmbx2
if '%choice%'=='3' goto prechecksmas
if '%choice%'=='4' goto start
echo "%choice%" is not valid, try again.
goto updatecomplete

:dontlaunchsmbx2
cls
echo The episode has been updated^^! Exiting in 5 seconds...
@timeout 5 /nobreak>nul
exit

:launchsmbx2
cls
start SMBX2.exe
echo The episode has been updated^^! Executing SMBX2.exe and exiting in 5 seconds...
@timeout 5 /nobreak>nul
exit

:exit
cls
echo Exiting in 5 seconds...
@timeout 5 /nobreak>nul
exit