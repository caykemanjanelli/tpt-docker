#!/bin/bash

# 16.20.01.00 11272017 PK186046 CLNTINS-8780 - Renaming RPM-GPG-KEY-TTU-CLIENT to RPM-GPG-KEY-teradata

if [ -z "$1" ]; then
  echo "The path to RPM-GPG-KEY-teradata is required."
  exit 1
fi

signing_dir=$1
ttukey=`rpm -q gpg-pubkey --qf '%{NAME}-%{VERSION}-%{RELEASE}\t%{SUMMARY}\n' | grep TTU-Client-Signing-Key`
if [ -z "$ttukey" ]; then
  if [ -f "${signing_dir}/RPM-GPG-KEY-teradata" ]; then
     echo "Importing RPM-GPG-KEY-teradata"

     rpm --import ${signing_dir}/RPM-GPG-KEY-teradata
     worked=`rpm -q gpg-pubkey --qf '%{NAME}-%{VERSION}-%{RELEASE}\t%{SUMMARY}\n' | grep TTU-Client-Signing-Key`
     if [ -z "$worked"  ]; then
       echo "The import of RPM-GPG-KEY-teradata failed."
     else
       echo "RPM-GPG-KEY-teradata was imported."
     fi
  else
    echo "RPM-GPG-KEY-teradata was not found in $signing_dir"
  fi
else
  echo "RPM-GPG-KEY-teradata is already imported."
fi

