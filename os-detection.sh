#!/bin/bash
#####################################################################
##
## Title:       Detect OS Distro and Version
## Author:      metalcated
## Date:        08/20/2015
## Version:     0.6
##
## Changelog:   0.1 - Initial Release
##              0.2 - Added arch detection
##              0.3 - rebuilt detection based on lsb_release
##              0.4 - added version output
##              0.5 - updated package name for redhat-lsb
##              0.6 - updated to support OEL (Oracle EL)
##
######################################################################
ver=0.6

# exit if not root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit $?
fi

while getopts v opt; do
  case $opt in
    v) echo ${ver};exit $? ;;
    *) echo -e "\ninvalid or missing argument\n";exit $? ;;
  esac
done

# install lsb_release depending on os
if [[ -z $(which lsb_release) ]]; then
        # install lsb_release
        if [[ -f /usr/bin/dnf ]]; then
                /usr/bin/dnf install redhat-lsb -y
        elif [[ -f /usr/bin/yum ]]; then
                /usr/bin/yum install redhat-lsb -y
        elif [[ -f /usr/sbin/up2date ]]; then
                /usr/sbin/up2date -i -f redhat-lsb
        fi
fi

# distro
export os=$(lsb_release -si)
if [[ -n $(echo $os|grep 'Red\|EnterpriseEnterpriseServer') ]]; then
        export os="RHEL"
elif [[ -n $(echo $os|grep -i 'OEL\|Oracle') ]]; then
        export os="OracleLinux"
fi

# version
export os_ver=$(lsb_release -sr|cut -d. -f1)
# arch
if [[ -n $(lsb_release -s|grep amd64) ]]; then
        export arch="x86_64"
else
        export arch="i386"
fi

# uncomment to see results
#echo $os $os_ver $arch
