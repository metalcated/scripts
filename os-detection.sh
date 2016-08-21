#!/bin/bash
#####################################################################
##
## Title:       Detect OS Distro and Version
## Author:      metalcated
## Date:        04/25/2015
## Version:     0.3
##
## Changelog:   0.1 - Initial Release
##              0.2 - Added arch detection
##              0.3 - rebuilt detection based on lsb_release
##
######################################################################

# exit if not root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit $?
fi

# install lsb_release depending on os
if [[ -z $(rpm -qa|grep redhat-lsb) ]]; then
        # install lsb_release
        if [[ -f /usr/bin/dnf ]]; then
                /usr/bin/dnf install redhat-lsb-core
        elif [[ -f /usr/bin/yum ]]; then
                /usr/bin/yum install redhat-lsb-core
        elif [[ -f /usr/sbin/up2date ]]; then
                /usr/sbin/up2date -i -f redhat-lsb
        fi
fi

# distro
export os=$(lsb_release -si)
if [[ -n $(echo $os|grep Red) ]]; then
        os="RHEL"
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
