#!/bin/bash
#-----------------------------------------------------------------------------------------------------------------
# File     : mkrepo.sh
# Purpose  : Setup and add TTU YUM repositories on local host
#
# Copyright 2016-2019. Teradata Corporation. All Rights Reserved.
# TERADATA CONFIDENTIAL AND TRADE SECRET.
# 
# This shell script helps customers to setup Teradata YUM repository on their web server
# This also helps to add ttu repo file to client YUM configuration
# Usage:
#	mkrepo.sh [-u server -n <destination>] [-u client -n <repourl>]
#
# History:
# 16.00.00.00	pk186048    CLNTINS-6977
# 16.10.01.00   PK186046    CLNTINS-7648  update mkrepo.sh to create the apt-get repo for Ubuntu
# 16.20.00.00   PK186048    CLNTINS-8637  Enable gpgkey verification for TTU YUM Repository
# 16.20.00.04   RM185040    CLNTINS-8883  Improve the usage information and correct spelling mistakes
# 17.00.00.00   MS186163    CLNTINS-11832 mkrepo.sh needs to include the ttupublickey rpm
# 17.00.10.00   PK186046    CLNTINS-11966 Removing errors while creating Ubuntu repository
#-------------------------------------------------------------------------------------------------------------------

###############################################################################
# Function: display_usage
# Description: Displays the usage for this script.
# Input : None
# Output: Displays how to use this script.
# Note  : None
display_usage ()
{
  echo ""
  echo "Usage: $script_name [-u server -n <destination>] [-u client -n <repourl>] [-h]"
  echo "Parameters:"
  echo ""
  
  echo "[-u server -n <destination>]"
  echo "-u server        : Script will setup TTU $repo repository on local server."
  echo "-n <destination> : Denotes absolute path of the destination folder to copy TTU packages."
  echo "                   This <destination> must be the root folder of the web server or it should have a symbolic link created to the root folder."
  echo "                   Example Web server: /var/www/html"

  echo ""
  echo "[-u client -n <repourl>]"
  echo "-u client        : Script will add existing TTU repository to $repo configuration."
  echo "-n <repourl>     : Denotes web URL from which $repo can download TTU packages."
  echo "                   Here assumption is that TTU repository is available for download on the web server."
  echo "                   Example <repourl>: http://server-address/17.00/Linux/x8664/BASE"  
  
  echo ""
  echo "If no input is given, script assumes that a TTU Bundle is copied and extracted to the local machine."
  echo "So, script adds local TTU repository to $repo configuration."
  echo
}

###############################################################################
# Function: create_server_repo
# Description: Copies TTU packages and repodata folder to user given destination
# Input : None
# Output: NA
# Note  : None
create_server_repo ()
{
   if [ -z "${dest_baseurl}" ]; then
       echo ""
       echo "ERROR: Please provide a valid destination path to copy TTU packages."
       display_usage
       exit 1
   fi
  
   #Check if destination is a remote directory
   if [[ "${dest_baseurl}" == *"@"* ]]; then
        echo ""
        echo "ERROR: Destination cannot be a remote folder while copying packages." 
        echo "       Please provide a local path as input."
        exit 1
   fi
  
  #check if apache web server is running
  service_status=`ps -A | grep 'apache2\|httpd'`
  if [ "$service_status" = "" ]; then
      echo ""
      echo "ERROR: Unable to detect Apache web server running on local host." 
      echo "       Please make sure your web server is up and running before setting up the repository."
  fi
   
  #Check if given destination is available or not, if not create it
  if [ ! -d "${dest_baseurl}" ]; then
      mkdir -p ${dest_baseurl} 
  fi
 
  mkdir -p "${dest_baseurl}/17.00/$PLATFORM/x8664/BASE"
     
  #copy ttu packages to user given detination
  copy_status="$(cp -R ${PWD}/* ${dest_baseurl}/17.00/$PLATFORM/x8664/BASE)"
  if [ "$?" != "0" ]; then
      echo "ERROR: Copy $packages packages from ${PWD} to destination:${dest_baseurl}/17.00/$PLATFORM/x8664/BASE failed."
      echo "Reason: ${copy_status}"
      exit 1
  fi

  echo "Successfully copied $packages packages from ${PWD} to destination: ${dest_baseurl}/17.00/$PLATFORM/x8664/BASE"
  echo "Please refresh your web server URL to check if $packages packages are available for download."
  echo "Example URL: http://server-address/"
  echo "Example RPM location: http://server-address/17.00/$PLATFORM/x8664/BASE"
  exit 0
}

###############################################################################
# Function: configure_repo_file
# Description: Adds TTU repo file to YUM configuration
# Input : None
# Output: NA
# Note  : None
configure_repo_file ()
{
  CHIP=`uname -i`
  OUT_REPO=/tmp/"ttu-foundation-1700.repo"

  if [ -d /etc/yum.repos.d ]; then
      echo "Use the following YUM repository file:"
      echo ""
      echo "Filename: /etc/yum.repos.d/ttu-foundation-1700.repo"
  fi

  if [ -d /etc/zypp/repos.d ]; then
      echo "Use the following Zypper repository file:"
      echo ""
      echo "Filename: /etc/zypp/repos.d/ttu-foundation-1700.repo"
  fi

  if [ -f /etc/apt/sources.list ]; then
      echo "Use the following Apt repository file:"
      echo ""
      echo "Filename: /etc/apt/sources.list"
  fi

  if [ -d /etc/yum.repos.d ] || [ -d /etc/zypp/repos.d ]; then
      echo "-----------------------------------------------------------------"
      echo "[ttu-foundation-1700]" > $OUT_REPO
      echo "name=TTU Foundation 1700 x8664" >> $OUT_REPO
      echo "baseurl=${dest_url}" >> $OUT_REPO
      echo "enabled=1" >> $OUT_REPO
      echo "gpgcheck=1" >> $OUT_REPO
      echo "gpgkey=https://access.teradata.com/resources/html/RPM-GPG-KEY-teradata" >> $OUT_REPO
      cat $OUT_REPO
      echo "-----------------------------------------------------------------"
      chmod 644 $OUT_REPO
  fi

  if [ -d /etc/yum.repos.d ]; then
      printf "Copy $OUT_REPO to /etc/yum.repos.d? [y/n]: "
      read input
      if [ "$input" = "y" ] || [ "$input" = "Y" ]; then
          cp $OUT_REPO /etc/yum.repos.d
      fi
  fi

  if [ -d /etc/zypp/repos.d ]; then
      printf "Copy $OUT_REPO to /etc/zypp/repos.d? [y/n]: "
      read input
      if [ "$input" = "y" ] || [ "$input" = "Y" ]; then
          cp $OUT_REPO /etc/zypp/repos.d
      fi
  fi

  if [ -f /etc/apt/sources.list ]; then
      printf "Copy $dest_url to /etc/apt/sources.list? [y/n]: "
      read input
      if [ "$input" = "y" ] || [ "$input" = "Y" ]; then
          check_repo_exists=`grep "deb \[trusted=yes\] $dest_url ./" /etc/apt/sources.list`
          if [ ! -z "$check_repo_exists" ]; then
              echo "This repo already exists in /etc/apt/sources.list file."
          else
              echo "deb [trusted=yes] $dest_url ./" >> /etc/apt/sources.list
          fi
      fi
  fi
}

###############################################################################
# Function: create_client_repo
# Description: Adds TTU repo file to YUM configuration
#              Here script assumes that TTU repository is configured on a web server
#               and adds that repo information to YUM configuration
# Input : None
# Output: NA
# Note  : None
create_client_repo ()
{
   if [ -z "${dest_baseurl}" ]; then
       echo "Error: Please provide server base URL to configure $repo repository on the local host."     
       display_usage
       exit 1
   fi

   echo "Adding $dest_baseurl to $repo configuration..."
   dest_url=$dest_baseurl
   configure_repo_file
}

#######################################################################################
# Function: create_client_repo
# Description: Adds TTU repo file to YUM configuration.  
#			   Here script assumes that TTU Bundle is available on local host
# Input : None
# Output: NA
# Note  : None
create_local_repo ()
{
  echo 
  echo "-------------------------------------------------------------------------------------"
  echo "No inputs have been provided to the $script_name script."
  echo "So, assuming that a TTU Bundle (along with the $repo repo) is available on the local host."
  echo "$repo repo will be configured locally. Would you like to continue:(y/N)? "
  read ans

  if [ $ans = "y" ] || [ $ans = "Y" ]; then
      dest_url="file://${PWD}"
      configure_repo_file
      if [ $PLATFORM = "Linux" ]; then
          if [ -f ${PWD}/signing/importkey.sh ]; then
              echo "Executing importkey.sh"
              ${PWD}/signing/importkey.sh ${PWD}/signing
          else
              echo "importkey.sh is not found in ${PWD}"
          fi
      fi
  else
      exit 1
  fi

}

###############################################################################
# Main script starts here
###############################################################################
#Get the script name for display_usage
script_name=$0

res=$(find . -type f -name *.deb)
if [ -n "$res" ]; then
    PLATFORM="Ubuntu"
    repo="apt-get"
    packages="debian"
else
    PLATFORM="Linux"
    repo="rpm"
    packages="rpm"
fi
  
url_type="local"
while getopts :u:n:h setup_args
do
  case $setup_args in
    u) url_type=$OPTARG
       ;;
    n) dest_baseurl=$OPTARG
       ;;
    h) display_usage
       exit 1
       ;;
    ?) display_usage
       exit 1
       ;;
  esac
done
shift $(($OPTIND -1))

if [ "$url_type" = "server" ]; then
    create_server_repo
elif [ "$url_type" = "client" ]; then
    create_client_repo
else
    display_usage
    create_local_repo
fi

