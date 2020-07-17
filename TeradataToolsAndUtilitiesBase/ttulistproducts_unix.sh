#!/bin/bash 
#******************************************************************************
#*
#*    TITLE: ttulistproducts.sh                                     17.00.15.00
#*
#*    Copyright 2016-2020 Teradata. All rights reserved.
#*
#*    This shell script is used to list Teradata Client Packages.
#*
#*    History:
#* 15.10.01.00 07222015 PP121926 CLNTINS-5249 Start file
#* 16.00.00.00 02192016 RJ255010 CLNTINS-5910 UNIX: Provide a script to switch
#*                                            active version.
#* 16.00.00.00 06132016 RM185040 CLNTINS-6360 Provide an option that doesn't
#*                                            prompt to change version in
#*                                            silent mode.
#* 16.00.00.00 07042016 RM185040 CLNTINS-6722 Add support for kafkaaxsmod.
#* 16.00.02.00 12142016 RM185040 CLNTINS-7165 Add support for s3axsmod.
#* 16.00.05.00 03212017 RM185040 CLNTINS-7497 Add Support for azureaxsmod.
#* 16.10.00.00 05042017 RM185040 CLNTINS-7818 Add support for teragssAdmin.
#* 16.10.00.00 05232017 RM185040 CLNTINS-7813 Add support for Ubuntu.
#* 16.10.00.00 05232017 RM185040 CLNTINS-8014 Use same uninstall_ttu.sh for all
#*                                            supported TTU versions.
#* 16.20.03.00 01122018 RM185040 CLNTINS-4802 Update copyright year and version
#*                                            during build.
#* 16.20.07.00 05092018 AW186011 CLNTINS-9639 ttulistproducts should list the 64-bit
#*                                            bteq package if it's installed
#* 16.20.11.00 09252018 PK186046 CLNTINS-10239 Adding 64-bit BTEQ package
#* 16.20.12.00 10192018 AW186011 CLNTINS-10370 use /bin/sh instead of /bin/ksh
#* 17.00.14.00 04212020 PK186046 CLNTINS-12608 Solaris - add the redistlibs packages
#* 17.00.15.00 05122020 PK186046 CLNTINS-12635 Adding Google Cloud storage
#*                                             access module.
#*
#******************************************************************************

#The version of the script
CRYEAR="2016-2020"
SCRIPTVER="17.00.15.00"

#Add TPT Versions - Remove numerical part for check
TPTVER_1200="c"  #c000
TPTVER_1300="d"  #d000
TPTVER_1310="da" #da00
TPTVER_1400="e"  #e000
TPTVER_1500="f"  #f000

OS=`uname -s`

SYSTEMPACKAGESOUT="/tmp/ttu-systempackagesout.out$$"

###############################################################################
# Function: display_usage
#
# Description: Diplays the usage for the script.
#
# Input : None
#
# Output: Displays how to use the script.
#
# Note  : None

display_usage ()
{
  echo ""
  echo "Usage: $0"
  echo ""
  echo " This script displays installed Teradata Tools and Utilities packages."
  echo ""
}

###############################################################################
# Function: get_installed_package_version
#
# Description: Get the version of the package being installed
#
# Input: The path to the package file or directory
#
#
# Output: The version number of the package

get_installed_package_version ()
{
  case $PLATFORM in
    $NAME_LINUX)
      rpm -q $1 --queryformat "%{VERSION}"
      return 1
    ;;
    $NAME_AIX)
      if [ ! -f "$SYSTEMPACKAGESOUT" ]; then
        $PKGINFO 1> $SYSTEMPACKAGESOUT 2>/dev/null
      fi
      TMPVERSION=`grep -w $1 $SYSTEMPACKAGESOUT | awk -F: '{ print $3 }' | sort | head -1 | awk -F. '{ printf( "%02d.%02d.%02d.%02d" , $1, $2, $3, $4) }'`
      echo $TMPVERSION
      return 1
    ;;
    $NAME_HPUX)
      if [ ! -f "$SYSTEMPACKAGESOUT" ]; then
        $PKGINFO > $SYSTEMPACKAGESOUT
      fi
      TMPVERSION=`grep $1 $SYSTEMPACKAGESOUT | awk '{print $2}' | sort` 
      #Echo the version numbers back to the value that called this function
      echo $TMPVERSION
      #Return the number of version numbers sent back
      RET=`echo $TMPVERSION | wc -l`
      return $RET
    ;;
    $NAME_SOLARIS)
      #This method is slower: $PKGINFO -l $1 | grep VERSION | awk '{print $2}'
      $PKGINFO -x $1 | awk '{ print $2 }' | sort | head -1 
      return 1
    ;;
    $NAME_UBUNTU)
      $PKGINFO -s $1 | grep ^Version | awk -F: '{ print $2 }' | tr -d " " | awk -F- '{ print $1 }'
      return 1
    ;;
  esac
}       

###############################################################################
# Function: display_fullinfo
#
# Description: Displays all of the information on all of the packages selected.
#
# Input : None
#
# Output: None
#
# Note  : None

display_fullinfo ()
{
#Each platform gives more information for all of the packages.

echo "The following Teradata Tools and Utilities are installed:"
$PKGFULLINFO ${PACKAGEARRAY[*]} | more
}

###############################################################################
# Function: display_help
#
# Description: Displays a brief help display about the program.
#              Different from display_usage, as it gives more explanation
#              inside of the script itself.
#
# Input : None
#
# Output: None
#
# Note  : None

display_help ()
{
  echo ""
  echo "This script will list all Teradata Tools and Utilities packages."
  echo "It looks for packages with \"Teradata\" in the package name and"
  echo "checks it against a list of known Teradata Tools and Utilities"
  echo "packages."
}

###############################################################################
# Function: display_active_release
#
# Description: Displays the active release.
#
# Input : None
#
# Output: None
#
# Note  : None

display_active_release ()
{
ICUTMPFILE=/tmp/icupkg-$$.out

case $PLATFORM in
  $NAME_AIX)
    #With AIX we can run this once, as all the info is on the colon separated line.
    #(It runs quicker only calling lslpp_r a single time.)
    lslpp_r -R ALL -Lc 2>/dev/null | grep tdicu > $ICUTMPFILE
    TDICULIST=`grep tdicu $ICUTMPFILE | awk -F: '{ print $2 }'`
  ;;
  $NAME_HPUX)
    swlist | grep tdicu > $ICUTMPFILE
    TDICULIST=`grep tdicu $ICUTMPFILE | awk '{ print $1 }'`
  ;;
  $NAME_LINUX)
    TDICULIST=`rpm -qa | grep tdicu`
  ;;
  $NAME_SOLARIS)
    TDICULIST=`pkginfo -l | grep tdicu | awk '{ print $2 }'`
  ;;
  $NAME_UBUNTU)
    TDICULIST=`dpkg -l \*tdicu\* | grep tdicu | grep "ii" | tr -s " " " " | awk '{ print $2 }'`
  ;;
esac

for icupkg in $TDICULIST
do
  case $PLATFORM in
    $NAME_AIX)
      SHORTVER=`grep $icupkg $ICUTMPFILE | awk -F: '{ print $3 }' | sed 's/[a-z]*//g' | awk -F. '{ printf ("%02d.%02d", $1, $2) }'` #i.e. 15.10
      SHORTVERNODOT=`echo $SHORTVER | awk -F. '{ print $1 $2 }'` #i.e. 1510
      BASEDIR=`grep $icupkg $ICUTMPFILE | awk -F: '{ print $17 '}`
      if [ "$BASEDIR" = "/" ]; then
        BASEDIR="${BASEDIR}opt/teradata/client/$SHORTVER"
      else 
        BASEDIR="$BASEDIR/teradata/client/$SHORTVER"
      fi
    ;;
    $NAME_HPUX)
      SHORTVER=`grep $icupkg $ICUTMPFILE | awk '{ print $2 }' | sed 's/[a-z]*//g' | awk -F. '{ printf ("%02d.%02d", $1, $2) }'` #i.e. 15.10
      SHORTVERNODOT=`echo $SHORTVER | awk -F. '{ print $1 $2 }'` #i.e. 1510
      BASEDIR=`swverify $icupkg 2>/dev/null | grep $icupkg | awk -F, '{ print $2 '} | awk -F= '{ print $2 }'`
      if [ "$BASEDIR" = "/" ]; then
        BASEDIR="${BASEDIR}opt/teradata/client/$SHORTVER"
      else 
        BASEDIR="$BASEDIR/teradata/client/$SHORTVER"
      fi
    ;;
    $NAME_LINUX)
      rpm -qil $icupkg > $ICUTMPFILE
      #The last awk is the equivalent of "basename", but all on one command
      SHORTVER=`grep "Version     :" $ICUTMPFILE | awk '{ print $3 '} | sed 's/[a-z]*//g' | awk -F. '{ print $1 "." $2 }'` #i.e. 15.10
      SHORTVERNODOT=`echo $SHORTVER | awk -F. '{ print $1 $2 }'` #i.e. 1510
      BASEDIR=`grep "${SHORTVER}$" $ICUTMPFILE`
    ;;
    $NAME_SOLARIS)
      pkginfo -l $icupkg > $ICUTMPFILE
      SHORTVER=`grep VERSION $ICUTMPFILE | awk '{ print $2 '} | sed 's/[a-z]*//g' | awk -F. '{ print $1 "." $2 }'` #i.e. 15.10
      SHORTVERNODOT=`echo $SHORTVER | awk -F. '{ print $1 $2 }'` #i.e. 1510
      BASEDIR=`grep BASEDIR $ICUTMPFILE | awk '{ print $2 '}`
      BASEDIR="$BASEDIR/teradata/client/$SHORTVER"
    ;;
    $NAME_UBUNTU)
      dpkg -s $icupkg > $ICUTMPFILE
      INSTALLED_STATUS=`grep ^Status $ICUTMPFILE | awk -F: '{ print $2 }' | tr -d " "`
      if [ "${INSTALLED_STATUS}" = "installokinstalled" ]; then
        SHORTVER=`grep ^Version $ICUTMPFILE | awk -F: '{ print $2 }' | tr -d " " | awk -F- '{ print $1 }' | awk -F. '{ print $1 $2 }'` #i.e. 15.10
        SHORTVERNODOT=`grep ^Version $ICUTMPFILE | awk -F: '{ print $2 }' | tr -d " " | awk -F- '{ print $1 }' | awk -F. '{ print $1 "." $2 }'` #i.e. 1510
        BASEDIR=`dpkg -L $icupkg | grep "${SHORTVER}$"`
      fi
      ;;
  esac
  if [ "$BASEDIR" ]; then
    if [ -f "$BASEDIR/ttu_softlinks_yes_${SHORTVERNODOT}" ] || \
       [ -f "$BASEDIR/ttu_softlinks_no_${SHORTVERNODOT}" ]; then
      RELEASEVER=$SHORTVER
      break #Only one active release so break.
    fi
  fi
done

#Cleanup this file
rm $ICUTMPFILE 2>/dev/null

if [ "$RELEASEVER" ]; then
  echo ""
  echo "Active Release: $RELEASEVER"
  echo ""
fi
}

###############################################################################
# Function: switch_active_versions
#
# Description: List the multi-version supported versions and option to switch
#              between them.
#
# Input: None
#
#
# Output: The short-versions of the installed multi-version packages.
switch_active_versions ()
{

if [ -z "$RELEASEVER" ]; then
  return 0
fi
ICUTMPFILE=/tmp/icupkg-$$.out

case $PLATFORM in
  $NAME_AIX)
    #With AIX we can run this once, as all the info is on the colon separated line.
    #(It runs quicker only calling lslpp_r a single time.)
    lslpp_r -R ALL -Lc 2>/dev/null | grep tdicu | sort > $ICUTMPFILE
    TDICULIST=`grep tdicu $ICUTMPFILE | awk -F: '{ print $2 }'`
  ;;
  $NAME_HPUX)
    swlist | grep tdicu | sort > $ICUTMPFILE
    TDICULIST=`grep tdicu $ICUTMPFILE | awk '{ print $1 }'`
  ;;
  $NAME_LINUX)
    TDICULIST=`rpm -qa | grep tdicu | sort`
  ;;
  $NAME_SOLARIS)
    TDICULIST=`pkginfo -l | grep tdicu | awk '{ print $2 }' | sort`
  ;;
  $NAME_UBUNTU)
    TDICULIST=`dpkg -l \*tdicu\* | grep tdicu | grep "ii" | tr -s " " " " | awk '{ print $2 }' | sort`
  ;;
esac

NOOFVERSIONS=0
if [ -n "$TDICULIST" ]; then
  for icupkg in $TDICULIST
  do
    case $PLATFORM in
      $NAME_AIX)
        TMPVERSION=`grep $icupkg $ICUTMPFILE | awk -F: '{ print $3 }' | sed 's/[a-z]*//g' | awk -F. '{ printf ("%02d%02d%02d%02d", $1, $2, $3, $4) }'`
        SHORTVER=`grep $icupkg $ICUTMPFILE | awk -F: '{ print $3 }' | sed 's/[a-z]*//g' | awk -F. '{ printf ("%02d.%02d", $1, $2) }'` #i.e. 15.10
        BASEDIR=`grep $icupkg $ICUTMPFILE | awk -F: '{ print $17 }'`
        if [ "$BASEDIR" = "/" ]; then
          BASEDIR="${BASEDIR}opt/teradata/client/$SHORTVER"
        else
          BASEDIR="$BASEDIR/teradata/client/$SHORTVER"
        fi
      ;;
      $NAME_HPUX)
        TMPVERSION=`grep $icupkg $ICUTMPFILE | awk '{ print $2 }' | sed 's/[a-z]*//g' | awk -F. '{ printf ("%02d%02d%02d%02d", $1, $2, $3, $4) }'`
        SHORTVER=`grep $icupkg $ICUTMPFILE | awk '{ print $2 }' | sed 's/[a-z]*//g' | awk -F. '{ printf ("%02d.%02d", $1, $2) }'` #i.e. 15.10
        BASEDIR=`swverify $icupkg 2>/dev/null | grep $icupkg | awk -F, '{ print $2 }' | awk -F= '{ print $2 }'`
        if [ "$BASEDIR" = "/" ]; then
          BASEDIR="${BASEDIR}opt/teradata/client/$SHORTVER"
        else
          BASEDIR="$BASEDIR/teradata/client/$SHORTVER"
        fi
      ;;
      $NAME_LINUX)
        rpm -qil $icupkg > $ICUTMPFILE
        TMPVERSION=`grep "Version     :" $ICUTMPFILE | awk '{ print $3 }' | sed 's/[a-z]*//g' | awk -F. '{ printf ("%02d%02d%02d%02d", $1, $2, $3, $4) }'`
        SHORTVER=`grep "Version     :" $ICUTMPFILE | awk '{ print $3 }' | sed 's/[a-z]*//g' | awk -F. '{ printf ("%02d.%02d", $1, $2) }'`
        BASEDIR=`grep "${SHORTVER}$" $ICUTMPFILE`
      ;;
      $NAME_SOLARIS)
        pkginfo -l $icupkg > $ICUTMPFILE
        TMPVERSION=`grep VERSION $ICUTMPFILE | awk '{ print $2 }' | sed 's/[a-z]*//g' | awk -F. '{ printf ("%02d%02d%02d%02d", $1, $2, $3, $4) }'`
        SHORTVER=`grep VERSION $ICUTMPFILE | awk '{ print $2 }' | sed 's/[a-z]*//g' | awk -F. '{ printf ("%02d.%02d", $1, $2) }'`
        BASEDIR=`grep BASEDIR $ICUTMPFILE | awk '{ print $2 }'`
        BASEDIR="$BASEDIR/teradata/client/$SHORTVER"
      ;;
      $NAME_UBUNTU)
      dpkg -s $icupkg > $ICUTMPFILE
      INSTALLED_STATUS=`grep ^Status $ICUTMPFILE | awk -F: '{ print $2 }' | tr -d " "`
      if [ "${INSTALLED_STATUS}" = "installokinstalled" ]; then
        SHORTVER=`grep ^Version $ICUTMPFILE | awk -F: '{ print $2 }' | tr -d " " | awk -F- '{ print $1 }' | awk -F. '{ print $1 $2 }'` #i.e. 15.10
        SHORTVERNODOT=`grep ^Version $ICUTMPFILE | awk -F: '{ print $2 }' | tr -d " " | awk -F- '{ print $1 }' | awk -F. '{ print $1 "." $2 }'` #i.e. 1510
        BASEDIR=`dpkg -L $icupkg | grep "${SHORTVER}$"`
      fi
      ;;
    esac
    if [ "$TMPVERSION" -ge "15100100" ]; then
      ((NOOFVERSIONS=$NOOFVERSIONS+1))
      SHORTARRAY[${#SHORTARRAY[@]}]="$SHORTVER"
      PKGLOCATIONARRAY[${#PKGLOCATIONARRAY[@]}]=$BASEDIR
    fi
  done
  if [ "$NOOFVERSIONS" -gt "1" ]; then
    printf "\nCurrent Installed Versions:\n"
    serial=1
    count=0
    for tmp in ${SHORTARRAY[*]}
    do
      if [ "$RELEASEVER" = "${SHORTARRAY[$count]}" ]; then
        printf "%d. %s - active release\n" "$serial" "${SHORTARRAY[$count]}"
      else
        printf "%d. %s\n" "$serial" "${SHORTARRAY[$count]}"
      fi
      ((count=$count+1))
      ((serial=$serial+1))
    done
    while [ 1 ]
    do
      printf "\nEnter a number to change the active release (e.g., '1' to switch to ${SHORTARRAY[0]}) or q to quit: "
      read input
      if [ "$input" = "q" -o "$input" = "Q" -o "$input" = "quit" -o "$input" = "QUIT" ]; then
        return 0
      fi
      if [ "$input" -gt "0" -a "$input" -le "$count" ]; then
        break
      else
        printf "Error: Invalid selection. Try again."
      fi
    done
    if [ -f "${PKGLOCATIONARRAY[(($input-1))]}/bin/setactiverel.sh" ]; then
      . ${PKGLOCATIONARRAY[(($input-1))]}/bin/setactiverel.sh
    fi
  fi
fi

#Cleanup this file
rm $ICUTMPFILE 2>/dev/null

}

###############################################################################
# Function: display_packages
#
# Description: Gives a brief display of the packages to display.
#
# Input : None
#
# Output: None
#
# Note  : None

display_packages ()
{
    i=0
    case $OS in
    AIX)
      SEP="-F."
    ;;
    *Linux*) 
      SEP="-F-"
    ;;
    esac
    for pkg in ${PACKAGEARRAY[*]}
    do
      PACKAGENAME=`echo ${pkg} | awk $SEP '{print $1 }'`
      TMPLOC=`echo ${pkg} | awk $SEP '{print $2 }'`
      if [ "$TMPLOC" = "32bit" ]; then
        PACKAGENAME=${PACKAGENAME}-$TMPLOC
      fi
      case $PACKAGENAME in
        teradata_arc* | arc*) TeradataToolsAndUtilities="Teradata Archive Recovery Utility";;
        bteq*-32*) TeradataToolsAndUtilities="Teradata BTEQ 32-bit";;
        bteq*) TeradataToolsAndUtilities="Teradata BTEQ";;
        cliv2*) TeradataToolsAndUtilities="Teradata CLIv2";;
        cobpp*) TeradataToolsAndUtilities="Teradata Cobol Preprocessor";;
        fastexp*) TeradataToolsAndUtilities="Teradata FastExport Utility";;
        fastld*) TeradataToolsAndUtilities="Teradata FastLoad Utility";;
        mload*) TeradataToolsAndUtilities="Teradata MultiLoad Utility";;
        odbc* | tdodbc* ) TeradataToolsAndUtilities="ODBC Driver for Teradata";;
        piom*) TeradataToolsAndUtilities="Teradata Data Connector";;
        sqlpp*) TeradataToolsAndUtilities="Teradata C Preprocessor";;
        tdicu*) TeradataToolsAndUtilities="Shared ICU Libraries for Teradata";;
        tdwallet*) TeradataToolsAndUtilities="Teradata Wallet";;
        teragss1* | TeraGSS*) TeradataToolsAndUtilities="Teradata GSS Client";;
        teragssAdmin*) TeradataToolsAndUtilities="Teradata GSS Administration Package";;
        tptbase*) TeradataToolsAndUtilities="Teradata Parallel Transporter Base";;
        tptstream*) TeradataToolsAndUtilities="Teradata Parallel Transporter Stream";;
        tpump*) TeradataToolsAndUtilities="Teradata Parallel Data Pump Utility";;
        npaxsmod*) TeradataToolsAndUtilities="Teradata Named Pipes Access Module";;
        mqaxsmod*) TeradataToolsAndUtilities="WebSphere Access Module for Teradata";;
        s3axsmod*) TeradataToolsAndUtilities="Teradata Access Module for Amazon S3";;
        azureaxsmod*) TeradataToolsAndUtilities="Teradata Access Module for Azure";;
        kafkaaxsmod*) TeradataToolsAndUtilities="Teradata Kafka Access Module";;
        jmsaxsmod*) TeradataToolsAndUtilities="Teradata Access Module for JMS";;
        gcsaxsmod*) TeradataToolsAndUtilities="Teradata Access Module for Google Cloud Storage";;
	*redistlibs*) TeradataToolsAndUtilities="Solaris Redistributable Libraries for Teradata";;
        *) TeradataToolsAndUtilities="$PACKAGENAME";;
      esac
      if [ "${DEBUG}" ]; then
        echo "TeradataToolsAndUtilities=$TeradataToolsAndUtilities ($PACKAGENAME)"
      fi

      #printf "%2s. %-21s - ${VERSIONARRAY[$i]}\n" $(($i +1 )) ${TeradataToolsAndUtilities} 
      #printf "%-21s - ${VERSIONARRAY[$i]}\n" ${PACKAGENAME} 
      printf "%-50s - ${VERSIONARRAY[$i]}\n" "${TeradataToolsAndUtilities}"
      ((i=$i+1))
    done
}

###############################################################################
# Function: order_packages
#
# Description: Orders the packages in the order to correctly display based on
#              dependencies, etc.
#
# Input : None
#
# Output: None
#
# Note  : None
order_packages ()
{
#Listed are the TPT package names that are dependencies for others.
#These should be removed first before the Teradata CLI dependencies.

#Add TPT Packages - Dependency packages
TPT_DEP_PKGS="tptbase pdatacon tbuild pdtc tbld posl picu papi posl${TPTVER_1200}"
TPT_DEP_PKGS="$TPT_DEP_PKGS tbld${TPTVER_1200} papi${TPTVER_1200} picu${TPTVER_1200} tbld${TPTVER_1300} papi${TPTVER_1300} picu${TPTVER_1300} tbld${TPTVER_1310} papi${TPTVER_1310} tbld${TPTVER_1400} papi${TPTVER_1400}"

#We have a lot of client packages to search through.  In order to not run into
#any long line issues (1024 character lines, for example), we'll just dump
#all the packages we know about into a single file and search through that.

#This will contain all of the dependencies in the correct order.
DEP_PKG_ORDER="$TPT_DEP_PKGS piom cliv tdicu TeraGSS ssredistlibs soredistlibs"
echo $DEP_PKG_ORDER > $TMPFILE

#Main Client Packages
echo "fastld mload fastexp tpump sqlpp tdodbc tdodbc cobpp mqaxsmod" >> $TMPFILE
echo "npaxsmod s3axsmod gcsaxsmod azureaxsmod kafkaaxsmod jmsaxsmod qrydir sockclient bteq tdwallet arc teradata_arc teragssAdmin bteq32" >> $TMPFILE

#Teradata Warehouse Builder packages before TTU5.0
echo "pipc tbuild pdatacon pcommon pselect pinsert pexport pload" >> $TMPFILE
echo "pupdate pstream pddl podbc pcnvflod pcnvmlod pcnvtpmp" >> $TMPFILE
echo "pcnvfexp pmlinop twbvi" >> $TMPFILE

#Teradata Warehouse Builder - TTU5.0 - TTU 8.2
echo "pdtc posl psel pins pexp plod pupd pstm pddl podbc posc" >> $TMPFILE

#Teradata Parallel Transporter - TTU12.0
echo "plod${TPTVER_1200} pddl${TPTVER_1200} pstm${TPTVER_1200}"  >> $TMPFILE
echo "pupd${TPTVER_1200} pins${TPTVER_1200} psel${TPTVER_1200}"  >> $TMPFILE
echo "posc${TPTVER_1200} podbc${TPTVER_1200} pexp${TPTVER_1200} pdtc${TPTVER_1200}" >> $TMPFILE

#Teradata Parallel Transporter - TTU13.0
echo "plod${TPTVER_1300} pupd${TPTVER_1300} pexp${TPTVER_1300} pstm${TPTVER_1300} pdtc${TPTVER_1300}" >> $TMPFILE

#DR127863 TTU 13.1 additions - Add 13.10 packages.
echo "plod${TPTVER_1310} pupd${TPTVER_1310} pexp${TPTVER_1310} pstm${TPTVER_1310} pdtc${TPTVER_1310}" >> $TMPFILE

#Teradata Parallel Transporter TTU14.00 - Pre Consolidation
echo "plod${TPTVER_1400} pupd${TPTVER_1400} pexp${TPTVER_1400} pstm${TPTVER_1400}" >> $TMPFILE

#Teradata Parallel Transporter TTU14.00 - Post Consolidation
echo "tptstream" >> $TMPFILE

#Copy necessary information to the DEBUGFILE
if [ "${DEBUG}" ];then
  echo "*** Known Teradata Tools and Utilities Packages" > $DEBUGFILE
  cat $TMPFILE >> $DEBUGFILE
  echo "*** " >> $DEBUGFILE
  echo "*** Initial set to remove" >> $DEBUGFILE
  echo $PACKAGES >> $DEBUGFILE
  echo "*** Debug file is located at $DEBUGFILE"
fi

#Clear out this variable if this function is to be reused.
NEWPACKAGE=""

#Loop to put the packages into NEWPACKAGE. Check for valid Teradata
#Client packages against the known list in the $TMPFILE

TOTALPACKAGES=`echo $PACKAGES | awk '{ print NF}'`
COUNT=0
if [ "${DEBUG}" ]; then
  echo "TOTAL=$TOTALPACKAGES, PACKAGES=$PACKAGES"
fi

for pkg in `echo $PACKAGES`
  do
    printf "." #Print a . for every loop...
    ### Get the name of the package from the package list without a
    #   version number attached to it.
    #Take the package name, the first field, remove all numbers and dots,
    #and then remove any "-" at the end of the variable
    check=`echo $pkg | awk -F'[.-]' '{ print $1 }' | sed 's/[0-9.]*//g' | sed s'/-$//'`
    #Because we need teradata_arc, but don't want TeraGSS_linux, etc. just
    #check if the first part is TeraGSS, and use that for the check value.
    #case $check in
    #  TeraGSS*)
    #    check="TeraGSS"
    #  ;;
    #esac
    if [ "${DEBUG}" ]; then
      echo "check=$check, pkg=$pkg"
    fi
    version=`get_installed_package_version $pkg`
    totalreturned="$?"
    for versionnum in $version
    do
      #No non-digits - turns 13.00.00.00 to 13000000 for comparison later
      #Removed: Only checks for xx.xx.xx.xx: checkversion=`echo $versionnum | sed 's#[^0-9]##g'`
      #Added  : Allows for 3 digit fourth fields, xx.xx.xx.xxx or xx.xx.xx.xx.
      checkversion=`echo $versionnum | awk -F. '{ printf "%2d%02d%02d%03d", $1, $2, $3, $4 }'`
      if [ "${DEBUG}" ]; then
        echo "pkg=$pkg, version=$versionnum, checkversion=$checkversion, PRIORTO=$PRIORTO"
      fi

      #Verify packages that are allowed to be removed and add to NEWPACKAGE
      if [ "$(grep -i -c "${check}" $TMPFILE )" != 0 ]; then
        NEWPACKAGE="$NEWPACKAGE $pkg,$versionnum" #Add the package, if known.
      fi
      (( COUNT=$COUNT + $totalreturned))
    done
done

#Loop through each package in the list at $TMPFILE
#and if the package name is in the PKGORDER list, use sed to remove
#it from any place in the string, and place it at the end of the string.

if [ "$NEWPACKAGE" != "" ]; then
  if [ -f "$TMPFILE" ]; then
    rm $TMPFILE
  fi
  #Create the TMPFILE, with all packages on a single line
  for TOFILE in $NEWPACKAGE
  do
    echo $TOFILE >> $TMPFILE.sort
  done
  #Order the packages in alphabetical order
  sort $TMPFILE.sort > $TMPFILE
  rm $TMPFILE.sort

  #Loop through the packages listed in the variable of package dependency order
  #Not all of these packages are installed, but when they exist, we want to put
  #the package at the end of the list so that piom, cliv2, tdicu, and TeraGSS
  #are removed last.
  for pkg in $DEP_PKG_ORDER
    do
      #Is the package found in the TMPFILE (list of installed packages)?
      SORTPKG=`grep -i $pkg $TMPFILE`
      if [ "$?" = "0" ]; then
        #Dump the installed packages list *without* that package to TMPFILE.1
        grep -i -v $pkg $TMPFILE > $TMPFILE.1
        #Dump the installed packages list *with* that package to TMPFILE.1
        #This orders the dependenc products to the end of the list.
        grep -i $pkg $TMPFILE >> $TMPFILE.1
        #Move the output back to TMPFILE for the next loop
        mv $TMPFILE.1 $TMPFILE
      fi
    done
  #Set PACKAGES to have all the files from TMPFILE
  PACKAGES=`cat $TMPFILE`

  #Create two arrays with the package names and the version number
  for PACKAGEVER in $PACKAGES
  do
    PACKAGEARRAY[${#PACKAGEARRAY[@]}]=`echo $PACKAGEVER | awk -F, '{ print $1 }'`
    VERSIONARRAY[${#VERSIONARRAY[@]}]=`echo $PACKAGEVER | awk -F, '{ print $2 }'`
  done

  #Output the packages to the DEBUGFILE
  if [ "${DEBUG}" ];then
    echo "" >> $DEBUGFILE
    echo "Final package order" >> $DEBUGFILE
    cat $TMPFILE >> $DEBUGFILE
  fi
else
  #If there aren't any packages to remove, just set PACKAGES to empty.
  PACKAGES=""
fi
if [ -f "$TMPFILE" ]; then
  rm $TMPFILE
fi
}

###############################################################################
# Function: init_pkginfo
#
# Description: 
#
# Input : None
#
# Output: None
#
# Note  : None

init_pkginfo ()
{
###############################################################################
#Determine which packaging software to use.
PACKAGESOUT="/tmp/ttulistpackages.out"
if [ -f "/usr/sbin/installp" ]; then
  ########################This is for AIX
  PLATFORM=$NAME_AIX
  PKGTYPE="installp"
  PKGINFO="/bin/lslpp_r -R ALL -Lc" #-c returns a single colon separated line
  PKGFULLINFO="/bin/lslpp_r -R ALL -L"
  $PKGINFO 2>/dev/null 1> $PACKAGESOUT
  PACKAGES=`cat $PACKAGESOUT | grep -i $PKGSTRING | awk -F: '{ print $2 }'`
  NPAXSMOD=`cat $PACKAGESOUT | grep -i -w npaxsmod | awk -F: '{ print $2 }' | sort | head -1`
  SQLPP=`cat $PACKAGESOUT | grep -i -w sqlpp | awk -F: '{ print $2 }' | sort | head -1`
elif [ -f "/bin/rpm" ]; then
  ########################This is for Linux RPM
  PLATFORM=$NAME_LINUX
  PKGTYPE="rpm"
  PKGINFO="/bin/rpm -qa"
  PKGFULLINFO="/bin/rpm -qi"
  $PKGINFO --queryformat='%{NAME}-%{VERSION} %{SUMMARY}\n' > $PACKAGESOUT
  PACKAGES=`cat $PACKAGESOUT | grep -i $PKGSTRING | grep -v 'teradata-' | grep -v -w 'pde' | awk '{print $1}'`
  NPAXSMOD=`cat $PACKAGESOUT | grep -i -w npaxsmod | awk '{print $1}' | sort | head -1`
  SQLPP=`cat $PACKAGESOUT | grep -i -w sqlpp | awk '{print $1}' | sort | head -1`
elif [ -f "/usr/sbin/swinstall" ]; then
  ########################This is for HP-UX
  PLATFORM=$NAME_HPUX
  PKGTYPE="swinstall"
  PKGINFO="/usr/sbin/swlist"
  PKGFULLINFO="/usr/sbin/swlist"
  $PKGINFO > $PACKAGESOUT
  PACKAGES=`cat $PACKAGESOUT | grep -i $PKGSTRING | awk '{ print $1 }' | sort -A`
  NPAXSMOD=`cat $PACKAGESOUT | grep -i npaxsmod | awk '{ print $1 }' | sort | head -1`
  SQLPP=`cat $PACKAGESOUT | grep -i sqlpp | awk '{ print $1 }' | sort | head -1`
elif [ -f "/usr/bin/pkginfo" ] || [ -f "/usr/sbin/pkginfo" ]; then
  ########################This is for MP-RAS and Solaris Sparc/Opteron
  PLATFORM=$NAME_SOLARIS
  PKGTYPE="pkgadd"
  PKGINFO="pkginfo"
  PKGFULLINFO="pkginfo -l"
  $PKGINFO > $PACKAGESOUT
  PACKAGES=`cat $PACKAGESOUT | grep -i $PKGSTRING | awk '{ print $2 }'`
  NPAXSMOD=`cat $PACKAGESOUT | grep -i -w npaxsmod | awk '{ print $2 }' | sort | head -1`
  SQLPP=`cat $PACKAGESOUT | grep -i -w sqlpp | awk '{ print $2 }' | sort | head -1`
elif [ -f "/usr/bin/dpkg" ]; then
  ########################This is for Ubuntu dpkg
  PLATFORM=$NAME_UBUNTU
  PKGTYPE="dpkg"
  PKGINFO="/usr/bin/dpkg"
  PKGFULLINFO="/usr/bin/dpkg -s"
  $PKGINFO -l > $PACKAGESOUT
  ALL_TERADATA_PACKAGES=`cat $PACKAGESOUT | grep -i $PKGSTRING | awk '{ print $2 }'`
  for installed_pkg in $ALL_TERADATA_PACKAGES
  do
    INSTALLED_STATUS=`$PKGFULLINFO $installed_pkg | grep ^Status | awk -F: '{ print $2 }' | tr -d " "`
    # List package only if it is installed OK.
    if [ "${INSTALLED_STATUS}" = "installokinstalled" ]; then
      PACKAGES="$installed_pkg $PACKAGES"
    fi
  done
fi

###############################################################################
#This is because the "Title" for Named Pipes Access Module doesn't have
#Teradata in it and neither does SQLPP: Pre TTU12.0

echo $PACKAGES > $PACKAGESOUT

if [ "${NPAXSMOD}" ] && [ "$(grep -c "npaxsmod" $PACKAGESOUT)" = 0 ]; then
    #Adding $NPAXSMOD...
    PACKAGES="$NPAXSMOD $PACKAGES"
fi
if [ "${SQLPP}" ] && [ "$(grep -c "sqlpp" $PACKAGESOUT)" = 0 ]; then
    #Adding $SQLPP...
    PACKAGES="$SQLPP $PACKAGES"
fi

#Remove leading whitespace
echo $PACKAGES | sed 's/^[ ]*//' > $PACKAGESOUT
PACKAGES=`cat $PACKAGESOUT`
rm $PACKAGESOUT
}

###############################################################################
# Function: cleanup
#
# Description: Cleanup files before exiting
#
# Input : None
#
# Output: None
#
# Note  : None

cleanup ()
{
#Clean up TMPFILE
  if [ -f "$TMPFILE" ]; then
    rm $TMPFILE
  fi
  if [ -f "$SYSTEMPACKAGESOUT" ]; then
    rm $SYSTEMPACKAGESOUT
  fi
}

###############################################################################
# Start initial script beginning
###############################################################################

echo "TTUListProducts                                                   v.$SCRIPTVER"  
echo "Copyright ${CRYEAR} Teradata. All rights reserved."

SwitchVersionEnabled="yes"
#Loop through passed variables and set values
while [ $# -gt 0 ]
do
  case "$1" in
    h|help)
        display_usage
        cleanup
        exit 1
    ;;
    disable_version_switch)
        SwitchVersionEnabled="no"
    ;;
    debug)
        echo "*** debug option set."
        DEBUG=1
    ;;
  esac
  shift
done

###############################################################################
#Initialise some main variables
PKGSTRING="Teradata"

TMPFILE="/tmp/ttulistproductstmp.out"
DEBUGFILE="/tmp/ttulistproducts.debug"

NAME_AIX="AIX"
NAME_HPUX="HPUX"
NAME_LINUX="Linux"
NAME_SOLARIS="Solaris"
NAME_UBUNTU="Ubuntu"

###############################################################################
#Setup the packaging variables and fill in the PACKAGES variable
init_pkginfo

#Order the packages, also validate packages
order_packages 

#The variable PACKAGES should have a list of packages in it, if it doesn't
#then just exit.  There's nothing more to be done here.
if [ "${PACKAGES}" ]; then
  echo ""
  display_active_release
  echo "The following packages are installed:"
  display_packages
  if [ "$SwitchVersionEnabled" = "yes" ]; then
    switch_active_versions
  fi
else
  echo "No Teradata Tools and Utilities packages installed."
fi

chmod 777 /tmp/ttulistproducts* 2>/dev/null
cleanup

