@echo off
REM Copyright 2015-2020 Teradata. All rights reserved.
REM
REM File: tar_teradata_client_packages.bat                  17.00.15.00
REM
REM Description: Script to create a tar file of the Teradata Tools
REM              and Utilities from the media for these platforms:
REM              * AIX
REM              * HP-UX
REM              * Linux
REM              * NCR MP-RAS UNIX
REM              * Solaris (Sparc)
REM              * Solaris (Opteron)
REM
REM              The script uses the DOS Batch shell script language.
REM
REM History Revision:
REM   16.10.03.00 01122018 RM185040 CLNTINS-4802 Set copyright/version at build.
REM   16.10.02.00 06202017 PK186046 CLNTINS-8104 Support Ubunt platform
REM   16.10.00.00 05112017 SG255032 CLNTINS-7967 Add TeraGSS Admin package
REM   16.00.00.00 06022015 PP121926 CLNTINS-5469 Update to 16.00
REM   15.10.00.00 04282014 PP121926 CLNTINS-4724 Update to 15.10
REM   15.00.00.00 10312013 PP121926 CLNTINS-4207 Update to 15.00
REM   14.10.00.01 01162013 PP121926 CLNTINS-3816 Add ThirdPartyLicenses-.txt
REM                                              support
REM   14.10.00.00 05022012 PP121926 CLNTINS-3230 Remove package_size.sh.
REM   14.00.00.03 05252011 PP121926 DR151210 Add TeraJDBC to all tars
REM   14.00.00.02 05122011 PP121926 DR147885 Remove script changed to
REM                                          uninstall_ttu.sh
REM   14.00.00.01 04282011 PP121926 DR147885 Add TPTBase and remove PAPI
REM   14.00.00.00 12012010 PP121926 DR145390 TTU1400 and HPUX/Linux dir changes
REM   13.10.01.01 08022010 PP121926 DR144518 Include SETUPFILE5 scripts in tar 
REM                                          Specify as var doesn't work with *.
REM   13.10.01.00 07062010 PP121926 DR141060 Add package_size.sh script.
REM   13.10.00.01 09012009 PP121926 DR127863 Add TeraJDBC support.
REM   13.10.00.00 09012009 PP121926 DR127863 Update for TTU13.10 support.
REM   13.00.00.01 11192008 pp121926 DR121109 Check for remove script and
REM                                          this script for tarring.
REM   13.00.00.00 10282008 PP121926 DR121109 Update for TTU13 support.
REM   01.00.00.01 05162008 PP121926 DR121109 Remove need for "tar" parameter
REM                                          Add USERPROFILE to default dir.
REM   01.00.00.00 04012008 PP121926 DR121109 Initial checkin
REM
REM
REM

REM Initialize Variables
REM
REM Set all variables to be used here.

REM Enable the NT command extensions.  It is enabled by default, but this
REM ensures that it is set for this script.
SETLOCAL ENABLEEXTENSIONS

REM Set the initial values to variables here.  Because DOS variables are
REM inherited outside of the script (the values could be used before the
REM script is called, and when the script exists any values "set" aren't
REM cleared unless explicitly done before the script ends.
REM Also, because any variable set in the environent could be set before
REM this script runs, to help prevent variable names from clashing, all
REM variables add an underscore to the beginning.  

REM Include the UNIX main install script, .setup.sh
set _SETUPFILE1=.setup.sh
set _SETUPFILE2=setup.bat
set _SETUPFILE3=MEDIALABEL
set _SETUPFILE4=uninstall_ttu.sh
set _SETUPFILE5=tar_teradata_client_packages.*
set _SETUPFILE6=ThirdPartyLicense*.txt
set _DEPENDENCIES=cliv2 tdicu piom

REM Include the Solaris Sparc files for the "installer" program
REM These are not needed with TTU 13.00.
set _SPARCFILES=Solaris\.cdtoc Solaris\Copyright Solaris\installer Solaris\README
set _SPARCDIRS=Solaris\Docs Solaris\Misc Solaris\Patches Solaris\Tools .cdtoc

set _VERSION=17.00.15.00
set _TPTVERSION=1620

REM Goto Main Function to call the other functions
goto main

:init
REM The main branch starts here.  For the first parameter passed to the
REM script (%1) go from here.
REM The /I is used for IF so that the comparison is case-insensitive. NT+.
if /I "%1"=="list" goto platforms

if /I "%1"=="help" goto help
if /I "%1"=="/?" goto help
if /I "%1"=="" goto platforms

if /I "%1"=="aix"   goto tar_function
if /I "%1"=="pa-risc" goto tar_function
if /I "%1"=="ia64" goto tar_function
if /I "%1"=="i386" goto tar_function
if /I "%1"=="s390x" goto tar_function
if /I "%1"=="mpras" goto tar_function
if /I "%1"=="sparc" goto tar_function
if /I "%1"=="opteron" goto tar_function
if /I "%1"=="ubuntu" goto tar_function
if /I "%1"=="terajdbc" goto tar_function

goto help

:platforms
REM List all of the available platforms.  With the media the only
REM directories on the disk are those with the name of the platform
REM containing the packages.  This should continue to be maintained.
REM The parameters added to "dir" simplify the output.
REM "/ad" = List only directories
REM "/b"  = Simplify the list (don't display file size, etc.)
REM "/on" = Order by Name.  (i.e. in alphabetical order)
REM These parameters are used throughout the script.
REM
REM Also, this script shouldn't be on a Windows-Only disk.
REM If that happens (except for the Query Director disk), a reminder
REM is to be displayed noting that Windows is not supported by this script.

REM If the file MEDIALABEL exists, display it as it is the label/name
REM of the Media (CD/DVD or otherwise).

if EXIST MEDIALABEL (
  type MEDIALABEL
  ) else (
    echo ERROR: Teradata Client Packages not found.  Please change the directory
    echo        or disk where the Teradata packages are located, and rerun this script.
    goto end
 )

echo.
echo The available platforms are:
echo.

if EXIST AIX (
    echo aix
    echo.
)

if EXIST HP-UX (
    echo HP-UX - one of the following:
    cd HP-UX
    if EXIST pa-risc (
      echo pa-risc
    )
    if EXIST ia64 (
      echo ia64
    )
    cd ..
  echo.
)
if EXIST Linux (
    echo Linux - one of the following:
    cd Linux
    if EXIST i386-x8664 (
      echo i386
    )
    if EXIST s390x (
      echo s390x
    )
    cd ..
  echo.
)
if EXIST Ubuntu (
    echo Ubuntu
    echo.
)
if EXIST Solaris (
    echo Solaris - one of the following:
    cd Solaris
    if EXIST Sparc (
      echo sparc
    )
    if EXIST Opteron (
      echo opteron
    )
    cd ..
  echo.
)
if EXIST TeraJDBC (
    echo terajdbc
    echo.
)

REM Check to see if a directory exists for each known Platform:
REM AIX, HP-UX, Linux, MPRAS, Solaris/Sparc and Solaris/Opteron.
REM And then list the directories there (which contain the packages).
REM Windows is not supported as there is no way to easily
REM break up Windows .cab files.

echo.
echo The available packages are:

REM Allow the second parameter (%2) to list only the packages for
REM a specfic platform.  This will help with having huge lists.

  if /I "%2"=="aix" (
    echo --- AIX Products
    dir /ad /b /on AIX
    echo.
  )

  if /I "%2"=="hp-ux" (
    echo --- HP-UX PA-RISC Products
    dir /ad /b /on HP-UX\pa-risc
    echo.
    echo --- HP-UX IA64 Products
    dir /ad /b /on HP-UX\ia64
    echo.
  )

  if /I "%2"=="pa-risc" (
    echo --- HP-UX PA-RISC Products
    dir /ad /b /on HP-UX\pa-risc
    echo.
  )

  if /I "%2"=="ia64" (
    echo --- HP-UX IA64 Products
    dir /ad /b /on HP-UX\ia64
    echo.
  )

  if /I "%2"=="linux" (
    echo --- Linux i386/x8664 Products
    dir /ad /b /on /w Linux\i386-x8664
    echo.
    echo --- Linux s390x Products
    dir /ad /b /on /d Linux\s390x
    echo.
  )

  if /I "%2"=="i386" (
    echo --- Linux i386/x8664 Products
    dir /ad /b /on Linux\i386-x8664
    echo.
  )

  if /I "%2"=="s390x" (
    echo --- Linux s390x Products
    dir /ad /b /on Linux\s390x
    echo.
  )

  if /I "%2"=="ubuntu" (
    echo --- Ubuntu i386-x8664 Products
    dir /ad /b /on Ubuntu\i386-x8664
    echo.
  )

  if /I "%2"=="mpras" (
    echo --- MP-RAS Products
    dir /ad /b /on MPRAS
    echo.
  )

  if /I "%2"=="sparc" (
    echo --- Solaris Sparc Products
    dir /ad /b /on /w Solaris\Sparc
    echo.
  )

  if /I "%2"=="opteron" (
    echo --- Solaris Opteron Products
    dir /ad /b /on /d Solaris\Opteron
    echo.
  )

  if /I "%2"=="solaris" (
    echo --- Solaris Sparc Products
    dir /ad /b /on /w Solaris\Sparc
    echo.
    echo --- Solaris Opteron Products
    dir /ad /b /on /d Solaris\Opteron
    echo.
  )

  if /I "%2"=="terajdbc" (
    echo --- TeraJDBC Product
    echo terajdbc
    echo.
  )

REM If the second parameter is blank, just list all of the packages
REM for the all of the platforms that exist.
if "%2"=="" (
  if EXIST AIX (
    echo --- AIX Products
    dir /ad /b /on AIX
    )

    echo.
  )
  if EXIST HP-UX (
    cd HP-UX
    if EXIST pa-risc (
      echo --- HP-UX PA-RISC Products
      dir /ad /b /on /d pa-risc
      echo.
    )
    if EXIST ia64 (
      echo --- HP-UX IA64 Products
      dir /ad /b /on /d ia64
      echo.
    )
    cd ..
  )
  if EXIST Linux (
    cd Linux
    if EXIST i386-x8664 (
      echo --- Linux i386/x8664 Products
      dir /ad /b /on /d i386-x8664
      echo.
    )
    if EXIST s390x (
      echo --- Linux s390x Products
      dir /ad /b /on /d s390x
      echo.
    )
    cd ..
  )
  if EXIST Ubuntu (
      cd Ubuntu
      echo --- Ubuntu i386/x8664 Products
      dir /ad /b /on /d i386-x8664
      echo.
      cd ..
  )
  if EXIST MPRAS (
    echo --- MP-RAS Products
    dir /ad /b /on MPRAS
    echo.
  )
  if EXIST Solaris (
    cd Solaris
    if EXIST Sparc (
      echo --- Solaris Sparc Products
      dir /ad /b /on /d Sparc
      echo.
    )
    if EXIST Opteron (
      echo --- Solaris Opteron Products
      dir /ad /b /on /d Opteron
      echo.
    )
    cd ..
  )
  if EXIST TeraJDBC (
    echo --- TeraJDBC Product
    echo terajdbc
    echo.
  )
  if EXIST Windows (
    echo --- Windows Products cannot be archived with this script.
  )
)

REM End because we have nothing more to do here.
goto end

REM This is the main tarring function.  The meat of this script.
REM
:tar_function
REM The 2nd variable starts the package list. If "all" or blank, then tar 
REM all files for a particular platform.
if "%2"=="" set _PACKAGES=ALL
if /I "%2"=="all" set _PACKAGES=ALL

REM If the file MEDIALABEL exists, display it as it is the label/name
REM of the Media (CD/DVD or otherwise).
if EXIST MEDIALABEL (
  type MEDIALABEL
  ) else (
    echo ERROR: Teradata Client Packages not found.  Please change the directory
    echo        or disk where the Teradata packages are located, and rerun this script.
    goto end
 )

REM Get the value from the file MEDIALABEL, put it in a temporary string,
REM replaces the spaces with "-", remove the "/"s and replace triple "---"
REM with a single dash.  Then lower case it using a MSDOS method, and set
REM the final result to a value in called MEDIALABEL

REM Read the information in the file MEDIALABEL into the variable tmpstr
set /p tmpstr=<MEDIALABEL

REM Replace all spaces with dashes "-"
set tmpstr=%tmpstr: =-%

REM Replace the / (in "Load/Unload") with a dash.
set tmpstr=%tmpstr:/=-%

REM Replace triple dashes with a single dash.
set tmpstr=%tmpstr:---=-%

mkdir %TMP%\ttcptmp >NUL

REM Create a file in the TMP directory with the name in tmpstr
echo>%TMP%\ttcptmp\%tmpstr%

REM Pipe the name of the file with DOS "dir" command to a file in TMP
REM called "lower.tmp", in lower-case.  This is the easiest way to do it in DOS.
dir /b/l %TMP%\ttcptmp\%tmpstr% > %TMP%\ttcptmp\lower.tmp

REM Remove the first file
del %TMP%\ttcptmp\%tmpstr%

REM Now set MEDIALABEL to be the information in lower.tmp.
set /p MEDIALABEL=<%TMP%\ttcptmp\lower.tmp

REM Now remove the temp file
del %TMP%\ttcptmp\lower.tmp
rmdir %TMP%\ttcptmp

REM Go through each platform possibility.  If on UNIX this could be a case
REM The "/I" for the IF statement means to do case insensitive matches
REM which would cover any combination of "aix" "AIX" etc.
REM Just being as flexible as we can here.  "/I" is an NT+ addition for "if"
REM The set for _DEPEND could have used _PLATFORM for the path, but for
REM some reason the DOS script wouldn't allow it to be set.
REM Hard coding it here ensures that it is set for _DEPEND.
if /I "%1"=="aix" (
  set _PLATFORM=AIX
  set _PLATFORMDIR=AIX
  set _DEPEND1=AIX\tdicu*
  set _DEPEND2=AIX\cliv2*
  set _DEPEND3=AIX\piom*
  if EXIST AIX\tptbase%_TPTVERSION%  (
      set _DEPEND4=AIX\tptbase*
  )
)
if /I "%1"=="pa-risc" (
  set _PLATFORM=HPUX-pa-risc
  set _PLATFORMDIR=HP-UX\pa-risc
  set _DEPEND1=HP-UX\pa-risc\tdicu*
  set _DEPEND2=HP-UX\pa-risc\cliv2*
  set _DEPEND3=HP-UX\pa-risc\piom*
  if EXIST HP-UX\tptbase%_TPTVERSION%  (
      set _DEPEND4=HP-UX\pa-risc\tptbase*
  )
)
if /I "%1"=="ia64" (
  set _PLATFORM=HPUX-ia64
  set _PLATFORMDIR=HP-UX\ia64
  set _DEPEND1=HP-UX\ia64\tdicu*
  set _DEPEND2=HP-UX\ia64\cliv2*
  set _DEPEND3=HP-UX\ia64\piom*
  if EXIST HP-UX\ia64\tptbase%_TPTVERSION%  (
      set _DEPEND4=HP-UX\ia64\tptbase*
  )
)
if /I "%1"=="i386" (
  set _PLATFORM=Linux-i386
  set _PLATFORMDIR=Linux\i386-x8664
  set _DEPEND1=Linux\i386-x8664\tdicu*
  set _DEPEND2=Linux\i386-x8664\cliv2*
  set _DEPEND3=Linux\i386-x8664\piom*
  if EXIST Linux\i386-x8664\tptbase%_TPTVERSION%  (
      set _DEPEND4=Linux\i386-x8664\tptbase*
  )
)
if /I "%1"=="ubuntu" (
  set _PLATFORM=Ubuntu
  set _PLATFORMDIR=Ubuntu\i386-x8664
  set _DEPEND1=Ubuntu\i386-x8664\tdicu*
  set _DEPEND2=Ubuntu\i386-x8664\cliv2*
  set _DEPEND3=Ubuntu\i386-x8664\piom*
  if EXIST Ubuntu\i386-x8664\tptbase%_TPTVERSION%  (
      set _DEPEND4=Ubuntu\i386-x8664\tptbase*
  )
)
if /I "%1"=="s390x" (
  set _PLATFORM=Linux-s390x
  set _PLATFORMDIR=Linux\s390x
  set _DEPEND1=Linux\s390x\tdicu*
  set _DEPEND2=Linux\s390x\cliv2*
  set _DEPEND3=Linux\s390x\piom*
  if EXIST Linux\s390x\tptbase%_TPTVERSION%  (
      set _DEPEND4=Linux\s390x\tptbase*
  )
)
if /I "%1"=="mpras" (
  set _PLATFORM=MPRAS
  set _PLATFORMDIR=MPRAS
  set _DEPEND1=MPRAS\tdicu*
  set _DEPEND2=MPRAS\cliv2*
  set _DEPEND3=MPRAS\piom*
  if EXIST MPRAS\tptbase%_TPTVERSION%  (
      set _DEPEND4=MPRAS\tptbase*
  )
)
if /I "%1"=="sparc" (
  set _PLATFORM=Solaris-Sparc
  set _PLATFORMDIR=Solaris\Sparc
  set _DEPEND1=Solaris\Sparc\tdicu*
  set _DEPEND2=Solaris\Sparc\cliv2*
  set _DEPEND3=Solaris\Sparc\piom*
  if EXIST Solaris\Sparc\tptbase%_TPTVERSION%  (
      set _DEPEND4=Solaris\Sparc\tptbase*
  )
)
if /I "%1"=="opteron" (
  set _PLATFORM=Solaris-Opteron
  set _PLATFORMDIR=Solaris\Opteron
  set _DEPEND1=Solaris\Opteron\tdicu*
  set _DEPEND2=Solaris\Opteron\cliv2*
  set _DEPEND3=Solaris\Opteron\piom*
  if EXIST Solaris\Opteron\tptbase%_TPTVERSION%  (
      set _DEPEND4=Solaris\Opteron\tptbase*
  )
)

REM Set the platform, but don't set the dependencies as they won't be needed.
if /I "%1"=="terajdbc" (
  set _PLATFORM=TeraJDBC
  set _PLATFORMDIR=TeraJDBC
)

if EXIST TeraJDBC (
  set _TERAJDBC=TeraJDBC
)

REM If we've made it here without _PLATFORM set to a value there's a problem
REM It's best to exit out of it right here.
if "%_PLATFORM%"=="" (
  echo Error: _PLATFORM is not set. "%1" is not a correct value.
  goto help
)

REM Display Product instead of Platform for TeraJDBC as it's not a platform.
if /I "%_PLATFORM%"=="TeraJDBC" (
  echo Product: %_PLATFORM%
) ELSE (
  echo Platform: %_PLATFORM%
)
REM echo DEPENDENCIES: %_DEPEND1% %_DEPEND2%
REM echo             : %_DEPEND3% %_DEPEND4%
REM echo             : %_DEPEND5% 
REM echo SETUPFILES  : %_SETUPFILE1% %_SETUPFILE2% %_SETUPFILE3%
REM echo             : %_SETUPFILE4% %_SETUPFILE5% %_SETUPFILE6%
echo.
echo Default Path and Output File:
if /I "%_PLATFORM%"=="TeraJDBC" (
  echo %USERPROFILE:~2%\teradata-client-terajdbc.tar
) ELSE (
  echo %USERPROFILE:~2%\teradata-client-%_PLATFORM%-%MEDIALABEL%.tar
)
echo.
echo Hit [Enter] to accept the path: "%USERPROFILE%",
set /p _NEWPATH=or input a different save directory :

if "%_NEWPATH%"=="" ( 
  set _NEWPATH=%USERPROFILE%
) ELSE (
  REM Try to create the directory, just in case it doesn't exist.
  mkdir %_NEWPATH% 2>NUL
)

if /I "%_PLATFORM%"=="TeraJDBC" (
  set _TAROUT=%_NEWPATH:~2%\teradata-client-terajdbc.tar
  ) ELSE (
  set _TAROUT=%_NEWPATH:~2%\teradata-client-%_PLATFORM%-%MEDIALABEL%.tar
)


REM Try creating a file at _TAROUT to make sure it's not being written to
REM a read-only file location.  Yes, we will overwrite whatever file is at
REM that location.  This is what we want.
echo "Test File" > "%_TAROUT%"
if EXIST "%_TAROUT%" (
    echo Output File "%_TAROUT%"
    del "%_TAROUT%"
  ) ELSE (
    echo ERROR: "%_TAROUT%" cannot be written.
    echo Please rerun using a different path.
    goto end
  )

  if /I "%_PACKAGES%"=="ALL" (
    echo.
    echo ---Archiving all packages for %1.
    echo tar cvf "%_TAROUT%" %_PLATFORMDIR%
    tar cvf "%_TAROUT%" %_PLATFORMDIR%
    REM If it's TeraJDBC skip adding the setup files, and continue to gzipping.
    if /I "%_PLATFORM%"=="terajdbc" (
      goto continue-tar
    )
    echo tar rvf "%_TAROUT%" %_SETUPFILE1%
    tar rvf "%_TAROUT%" %_SETUPFILE1%
    echo tar rvf "%_TAROUT%" %_SETUPFILE2%
    tar rvf "%_TAROUT%" %_SETUPFILE2%
    echo tar rvf "%_TAROUT%" %_SETUPFILE3%
    tar rvf "%_TAROUT%" %_SETUPFILE3%
    if EXIST "%_SETUPFILE4%" (   
      echo tar rvf "%_TAROUT%" uninstall_ttu*
      tar rvf "%_TAROUT%" uninstall_ttu*
    )
    if EXIST "%_SETUPFILE5%" (
      echo tar rvf "%_TAROUT%" tar_teradata*
      tar rvf "%_TAROUT%" tar_teradata*
    )
    if EXIST "%_SETUPFILE6%" (
      echo tar rvf "%_TAROUT%" ThirdPartyLicense*.txt
      tar rvf "%_TAROUT%" ThirdPartyLicense*.txt
    )
    if EXIST TeraJDBC (   
      echo tar rvf "%_TAROUT%" %_TERAJDBC%
      tar rvf "%_TAROUT%" %_TERAJDBC%
    )
  )  else  (
    echo.
    echo ---Archiving setup files and dependency packages for %1
    REM If it's TeraJDBC skip adding the dependencies and setupfiles goto gzip
    if /I "%_PLATFORM%"=="terajdbc" (
      echo tar cvf "%_TAROUT%" %_PLATFORMDIR%
      tar cvf "%_TAROUT%" %_PLATFORMDIR%
      goto continue-tar
    )

    echo tar rvf "%_TAROUT%" %_DEPEND1%
    tar cvf "%_TAROUT%" %_DEPEND1%
    echo tar rvf "%_TAROUT%" %_DEPEND2%
    tar rvf "%_TAROUT%" %_DEPEND2%
    REM On some media DataConnector (piom) doesn't exist. Don't try to tar it.
    if EXIST "%_DEPEND3%" (
        echo tar rvf "%_TAROUT%" %_DEPEND3%
        tar rvf "%_TAROUT%" %_DEPEND3%
    )
    REM tptbase is on the dependency list, tar it
    if EXIST "%_DEPEND4%" (
         echo tar rvf "%_TAROUT%" %_DEPEND4%
         tar rvf "%_TAROUT%" %_DEPEND4%
    )

    echo tar rvf "%_TAROUT%" %_SETUPFILE1%
    tar rvf "%_TAROUT%" %_SETUPFILE1%
    echo tar rvf "%_TAROUT%" %_SETUPFILE2%
    tar rvf "%_TAROUT%" %_SETUPFILE2%
    echo tar rvf "%_TAROUT%" %_SETUPFILE3%
    tar rvf "%_TAROUT%" %_SETUPFILE3%
    if EXIST "%_SETUPFILE4%" (   
      echo tar rvf "%_TAROUT%" uninstall_ttu*
      tar rvf "%_TAROUT%" uninstall_ttu*
    )
    if EXIST "%_SETUPFILE5%" (
      echo tar rvf "%_TAROUT%" tar_teradata*
      tar rvf "%_TAROUT%" tar_teradata*
    )
    if EXIST "%_SETUPFILE6%" (
      echo tar rvf "%_TAROUT%" ThirdPartyLicense*.txt
      tar rvf "%_TAROUT%" ThirdPartyLicense*.txt
    )
    if EXIST TeraJDBC (   
      echo tar rvf "%_TAROUT%" %_TERAJDBC%
      tar rvf "%_TAROUT%" %_TERAJDBC%
    )

REM Add the additional Sparc files to the tar file with -r (--append)
REM If the "installer" program isn't used, this portion can be removed.
REM This if statement is obsolete.
  if /I "%1"=="sparc" (
    if EXIST Solaris/installer (
      echo "---Adding Pre-TTU13.0 Solaris Sparc files..."
      echo tar rvf "%_TAROUT%" %_SPARCFILES%
      tar rvf "%_TAROUT%" %_SPARCFILES%
      echo tar rvf "%_TAROUT%" %_SPARCDIRS%
      tar rvf "%_TAROUT%" %_SPARCDIRS%
    )
  )

    REM This following bit is because MSDOS/Windows command can't handle more
    REM than 9 parameters.  This looks at the 3rd parameter, which is the
    REM start of the list of packages to include, and if it exists then do
    REM a tar with "r" which adds to the tar file, and add just the one package.
    REM Then "shift /1" shifts all of the paramters from the command line one
    REM to the "left", basically moving %4 to %3. etc. /1 means to leave
    REM the first variable alone.. just in case we need them later.
    REM We probably won't, but just in case.  Once the parameters have
    REM been shifted, to back to the start of the loop.  The parameters, once
    REM shifted, are lost forever!

:start-tar-loop
    REM If parameter 2 is blank, then continue.  We may have used all
    REM of the variables already.
    if "%2"=="" goto continue-tar

    REM Check to make sure that the parameter isn't one of the dependency
    REM packages, and if so don't tar it.
      if /I "%2"=="cliv2" (
        echo ---%2 already included
        shift /1
	goto start-tar-loop
      )
      if /I "%2"=="piom" (
        if NOT EXIST "%2" (
          echo ---%2 not on the media
        ) ELSE (
          echo ---%2 already included
        )
        shift /1
        goto start-tar-loop
      )
      if /I "%2"=="tdicu" (
        echo ---%2 already included
        shift /1
	goto start-tar-loop
      )
      if /I "%2"=="tptbase%_TPTVERSION%" (
        echo ---%2 already included
        shift /1
	goto start-tar-loop
      )
      if EXIST "%_PLATFORMDIR%\%2" (
        echo ---Adding %2 to the archive...
        echo tar rvf "%_TAROUT%" %_PLATFORMDIR%\%2*
        tar rvf "%_TAROUT%" %_PLATFORMDIR%/%2*
      )
      shift /1
    goto start-tar-loop
  )

:continue-tar

gzip 2> NUL
if "%ERRORLEVEL%" == "9009" (
  echo.
  echo Notice: The executable gzip.exe is not found. Download from www.gzip.org for
  echo         MSDOS to automatically compress the output tar file to a gzip file.
  echo.
  echo The file has been saved at :
  if EXIST "%_TAROUT%" (
    echo   %_TAROUT%
  )
  echo.
  ) else (
  gzip "%_TAROUT%"
  echo.
  echo The file has been saved at :
  if EXIST "%_TAROUT%.gz" (
    echo   %_TAROUT%.gz
  )
  if EXIST "%_TAROUT%" (
    echo   %_TAROUT%
  )
  echo.
)

goto end

:help
echo.
echo Tar Teradata Client Packages
echo.
echo Usage: %0 list
echo        %0 list {platform}
echo        %0 {platform} [{package1} {package2} ...]
echo.
echo Parameters:
echo.
echo commands         : help, list, {platform} [{package1} {package2} ...]
echo  help            : Display this help message.
echo  list            : List the available platforms and packages from the media.
echo  list {platform} : List the packages available for the specified platform.
echo  {platform}      : Available platforms: aix, ia64, pa-risc, i386, s390x, 
echo                    mpras, opteron, sparc or terajdbc for the TeraJDBC product.
echo                    (ia64 or pa-risc for HP-UX, i386 or s390x for Linux)
echo                    Create the tar file for the supplied platform and include
echo                    all required dependency packages or individual packages.
echo  {package}       : Specify the packages available on this media for the
echo                    specific platform.  The parameter "all" (or blank) will
echo                    include all available packages.  To specify individual
echo                    packages, list the packages separated by a space.
echo                    Example: %0 i386 bteq fastld
echo.
echo The dependencies will automatically be included and do not need to
echo be listed individually.  The following packages are included:
echo ---%_DEPENDENCIES%
echo.
goto end

:main
echo ***************************************************************************
echo *               Tar Teradata Client Packages v.%_VERSION%                *
echo ***************************************************************************

REM Check to see if tar.exe exists.  If it doesn't, suggest where to download
REM it from, and then exit.  If tar.exe doesn't exist there's no point to run it.
tar 2> NUL
if "%ERRORLEVEL%" == "9009" (
  echo.
  echo ERROR:
  echo.
  echo The executable tar.exe doesn't exist on this system or isn't in the PATH.
  echo Please download the GNU tar executable from the following address:
  echo.
  echo     ftp://ftp.gnu.org/pub/pub/gnu/tar/tar-1.12.msdos.exe
  echo.
  echo Save the file as 'tar.exe' in the %SystemRoot% directory, or to a
  echo directory in the PATH, then rerun this script again.
  echo.
  echo GNU Tar version 1.12 is the recommended tar for DOS to use.
  echo For more information see: http://www.gnu.org/software/tar/
  echo.
  goto end
)

REM Start the main function call
goto init

:end
REM Clear the values set in this script before exiting.
SET _DEPEND1=
SET _DEPEND2=
SET _DEPEND3=
SET _DEPEND4=
SET _DEPENDENCIES=
SET _NEWPATH=
SET _PLATFORM=
SET _PLATFORMDIR=
SET _PACKAGES=
SET _TAROUT=
SET _VERSION=
