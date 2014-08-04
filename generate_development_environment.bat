@ECHO OFF

REM Example Visual Studio toolset version: 120
REM You can identify this from the project properties in a Vana project
REM e.g. Right click ChannelServer -> Properties -> General -> General -> Platform Toolset: Visual Studio 2013 (v120)

SET toolset=FIXME

IF "%toolset%"=="FIXME" (
	ECHO Variables must be set before a directory structure can be compiled
	PAUSE
	GOTO:EOF
)

IF EXIST "%CD%\%toolset%" (
	ECHO Development environment already set up
	PAUSE
	GOTO:EOF
)

REM Create registry key file to allow reverting of environment variables after a broken installation
reg export "HKEY_CURRENT_USER\Environment" "revert_registry.reg"

REM Create directory structure
mkdir %toolset%
cd %toolset%

mkdir lib
cd lib

mkdir Debug
mkdir Release

cd ..
cd ..

ECHO Operations successful, development environment ready
PAUSE
GOTO:EOF