#!/bin/bash

## Source Common Functions
curl -s "https://raw.githubusercontent.com/linuxautomations/scripts/master/common-functions.sh" >/tmp/common-functions.sh
source /root/scripts/common-functions.sh

## Checking Root User or not.
CheckRoot

## Checking SELINUX Enabled or not.
CheckSELinux

## Checking Firewall on the Server.
CheckFirewall

## Downloading Java
DownloadJava 8

## Installing Java
yum localinstall $JAVAFILE -y &>/dev/null
if [ $? -eq 0 ]; then 
	success "JAVA Installed Successfully"
else
	error "JAVA Installation Failure!"
	exit 1
fi

## Downloading Nexus
yum install html2text -y &>/dev/null
URL=$(curl -s https://help.sonatype.com/display/NXRM3/Download | html2text | grep unix.tar.gz | sed -e 's/>//g' -e 's/<//g' | grep ^http)
NEXUSFILE=$(echo $URL | awk -F '/' '{print $NF}')
NEXUSDIR=$(echo $NEXUSFILE|awk -F . '{print $1}')
NEXUSFILE="/opt/$NEXUSFILE"
wget $URL -O $NEXUSFILE &>/dev/null
if [ $? -eq 0  ]; then 
	success "NEXUS Downloaded Successfully"
else
	error "NEXUS Downloading Failure"
	exit 1
fi

## Adding Nexus User
id nexus &>/dev/null
if [ $? -ne  0 ]; then 
	useradd nexus
	if [ $? -eq 0 ]; then 
		success "Added NEXUS User Successfully"
	else
		error "Adding NEXUS User Failure"
		exit 1
	fi
fi

## Extracting Nexus
if [ ! -f "/home/nexus/$NEXUSDIR" ]; then 
su nexus &>/dev/null <<EOF
cd /home/nexus
tar xf $NEXUS
EOF
fi
success "Extracted NEXUS Successfully"
## Setting Nexus starup
