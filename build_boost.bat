@ECHO OFF
SETLOCAL

:: time measurement start
set start=%time%

ECHO ###############################################################################
ECHO ########################## -BUILDING BJAM BINARIES- ###########################
ECHO ###############################################################################
SET MYPATH="%CD%"
cd "%~dp0"
if exist .\b2.exe del .\b2.exe
if exist .\bjam.exe del .\bjam.exe
call .\bootstrap.bat
if exist .\bin.v2 rmdir .\bin.v2 /s/q
if exist .\stage rmdir .\stage /s/q

ECHO ###############################################################################
ECHO ########## -BUILDING BOOST LIBRARIES Static 32bit 					 ###########
ECHO ###############################################################################
if exist .\stage_x86 rmdir .\stage_x86 /s/q
b2.exe --toolset=msvc-14.1 --clean-all
b2.exe --toolset=msvc-14.1 architecture=x86 link=static address-model=32 define=BOOST_CONFIG_SUPPRESS_OUTDATED_MESSAGE=1 --stagedir=".\stage_x86" threading=multi --build-type=complete stage 
if not exist .\stage\lib md .\stage\lib
move /y .\stage_x86\lib\*.* .\stage\lib
if exist .\bin.v2 rmdir .\bin.v2 /s/q
if exist .\stage_x86 rmdir .\stage_x86 /s/q

ECHO ###############################################################################
ECHO ########## -BUILDING BOOST LIBRARIES Static 64bit					############
ECHO ###############################################################################
if exist .\stage_x64 rmdir \stage_x64 /s/q
b2.exe --toolset=msvc-14.1 --clean-all
b2.exe --toolset=msvc-14.1 architecture=x86 link=static address-model=64 define=BOOST_CONFIG_SUPPRESS_OUTDATED_MESSAGE=1 --stagedir=".\stage_x64" threading=multi --build-type=complete stage
if not exist .\stage\lib md .\stage\lib
move /y .\stage_x64\lib\*.* .\stage\lib
if exist .\bin.v2 rmdir .\bin.v2 /s/q
if exist .\stage_x64 rmdir .\stage_x64 /s/q

CD %MYPATH%

:: time measurement end
set end=%time%
set options="tokens=1-4 delims=:.,"
for /f %options% %%a in ("%start%") do set start_h=%%a&set /a start_m=100%%b %% 100&set /a start_s=100%%c %% 100&set /a start_ms=100%%d %% 100
for /f %options% %%a in ("%end%") do set end_h=%%a&set /a end_m=100%%b %% 100&set /a end_s=100%%c %% 100&set /a end_ms=100%%d %% 100

set /a hours=%end_h%-%start_h%
set /a mins=%end_m%-%start_m%
set /a secs=%end_s%-%start_s%
set /a ms=%end_ms%-%start_ms%
if %ms% lss 0 set /a secs=%secs%-1 & set /a ms=100%ms%
if %secs% lss 0 set /a mins=%mins%-1 & set /a secs=60%secs%
if %mins% lss 0 set /a hours=%hours%-1 & set /a mins=60%mins%
if %hours% lss 0 set /a hours=24%hours%
if 1%ms% lss 100 set ms=0%ms%

set /a totalsecs = %hours%*3600 + %mins%*60 + %secs% 

if %secs% lss 10 set secs=0%secs%
if %mins% lss 10 set mins=0%mins%
if %hours% lss 10 set hours=0%hours%

ECHO
ECHO It took %hours%:%mins%:%secs%.%ms% (%totalsecs%.%ms%s total) to build

ENDLOCAL
@ECHO ON