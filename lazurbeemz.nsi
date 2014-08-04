!include "MUI2.nsh"
!include "InstallOptions.nsh"
!include "winmessages.nsh"
!include "EnvVarUpdate.nsh"

!define LIBRARY_PACK_VERSION "7.0_DEVELOPMENT"
!define VS_TOOLSET_VERSION "120"
!define BOOST_VERSION "1_55_0"
!define BOTAN_VERSION "1.10.8"
!define SOCI_VERSION "3.1.0"
!define LUA_VERSION "5.2.3"
!define MYSQL_VERSION "5.5 [x86]"

!define ENV_HKCU 'HKCU "Environment"'

Name "LazurBeemz Library Pack ${LIBRARY_PACK_VERSION}"
OutFile "LazurBeemz_${LIBRARY_PACK_VERSION}.exe"

InstallDir "$PROGRAMFILES\LazurBeemz Library Pack"
RequestExecutionLevel admin

!define MUI_ABORTWARNING

Var /GLOBAL SYSTEMROOT
Var /GLOBAL MYSQLDIR

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${VS_TOOLSET_VERSION}\boost_${BOOST_VERSION}\LICENSE_1_0.txt"
!insertmacro MUI_PAGE_LICENSE "${VS_TOOLSET_VERSION}\Botan-${BOTAN_VERSION}\doc\license.txt"
!insertmacro MUI_PAGE_LICENSE "${VS_TOOLSET_VERSION}\lua-${LUA_VERSION}\LICENSE"
!insertmacro MUI_PAGE_LICENSE "${VS_TOOLSET_VERSION}\soci-${SOCI_VERSION}\LICENSE_1_0.txt"
!insertmacro MUI_PAGE_DIRECTORY
Page Custom MySqlEntryPage MySqlEntryLeave
Function MySqlEntryPage
	ReserveFile "MySQL Options.ini"
	!insertmacro INSTALLOPTIONS_EXTRACT "MySQL Options.ini"
	!insertmacro INSTALLOPTIONS_WRITE "MySQL Options.ini" "Field 1" "Text" "Choose your MySQL Server directory (currently built against ${MYSQL_VERSION} [x86])"
	!insertmacro INSTALLOPTIONS_DISPLAY "MySQL Options.ini"
FunctionEnd
Function MySqlEntryLeave
       !insertmacro INSTALLOPTIONS_READ $MYSQLDIR "MySQL Options.ini" "Field 2" "State"
FunctionEnd
!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

Section "Install"
	StrCpy $SYSTEMROOT $WINDIR 2

	IfFileExists "$INSTDIR\Uninstall.exe" 0 +2
		ExecWait '"$INSTDIR\Uninstall.exe" /S'

	SetOutPath $INSTDIR
	File /r ${VS_TOOLSET_VERSION}

	${EnvVarUpdate} $0 "PATH" "A" "HKCU" "$MYSQLDIR\lib"

	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\LazurBeemz Library Pack" "DisplayName" "LazurBeemz Library Pack ${LIBRARY_PACK_VERSION}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ImageMaker" "UninstallString" "$INSTDIR\uninstall.exe"

	WriteRegStr HKLM "Software\LazurBeemz Library Pack" "version" ${LIBRARY_PACK_VERSION}
	WriteRegStr HKLM "Software\LazurBeemz Library Pack" "path" $INSTDIR

	CreateDirectory "$SMPROGRAMS\LazurBeemz Library Pack"
	CreateShortCut "$SMPROGRAMS\LazurBeemz Library Pack\Uninstall.lnk" "$INSTDIR\Uninstall.exe"

	WriteRegExpandStr ${ENV_HKCU} LazurBeemz $INSTDIR
	WriteRegExpandStr ${ENV_HKCU} SociVersion ${SOCI_VERSION}
	WriteRegExpandStr ${ENV_HKCU} BotanVersion ${BOTAN_VERSION}
	WriteRegExpandStr ${ENV_HKCU} BoostVersion ${BOOST_VERSION}
	WriteRegExpandStr ${ENV_HKCU} LuaVersion ${LUA_VERSION}
	WriteRegExpandStr ${ENV_HKCU} MySqlDirectory32 $MYSQLDIR
	SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

	;Create uninstaller
	WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

Section "Uninstall"
	StrCpy $SYSTEMROOT $WINDIR 2

	SetOutPath "$INSTDIR"
	RMDir /r ${VS_TOOLSET_VERSION}
	ReadRegStr $MYSQLDIR HKCU "Environment" "MySqlDirectory32"

	${un.EnvVarUpdate} $0 "PATH" "R" "HKCU" "$MYSQLDIR\lib"

	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\LazurBeemz Library Pack"
	DeleteRegKey HKLM "Software\LazurBeemz Library Pack"

	RMDir /r "$SMPROGRAMS\LazurBeemz Library Pack"

	DeleteRegValue ${ENV_HKCU} LazurBeemz
	DeleteRegValue ${ENV_HKCU} SociVersion
	DeleteRegValue ${ENV_HKCU} BotanVersion
	DeleteRegValue ${ENV_HKCU} BoostVersion
	DeleteRegValue ${ENV_HKCU} LuaVersion
	DeleteRegValue ${ENV_HKCU} MySqlDirectory32
	SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

	Delete "$INSTDIR\Uninstall.exe"
	RMDir /r $INSTDIR
SectionEnd