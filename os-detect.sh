#!/bin/bash
#####################################################################
##
## Title:       Detect OS Distro and Version
## Author:      Mike Gomon <michael.gomon@iii.com>
## Date:        04/25/2015
## Version:     0.3
##
## Changelog:   0.1 - Initial Release
##              0.2 - Added arch detection
##              0.3 - Better detection for RedHat
##
######################################################################
 
# get OS information and run applicable function
if [[ -f /etc/lsb-release && -f /etc/debian_version ]]; then
        export os=$(lsb_release -s -d|head -1|awk {'print $1'})
        export os_ver=$(lsb_release -s -d|head -1|awk {'print $2'}|cut -d "." -f 1)
elif [[ -f /etc/debian_version ]]; then
        export os="$(cat /etc/issue|head -n 1|awk {'print $1'})"
        export os_ver="$(cat /etc/debian_version|head -1|awk {'print $1'}|cut -d "." -f 1)"
elif [[ -f /etc/redhat-release ]]; then
        if [[ "$os" = "Red" && $(grep -i enterprise /etc/redhat-release) != "" ]]; then
                export os="Red Hat Enterprise"
                export os_ver=$(cat /etc/redhat-release|head -1|awk {'print $7'}|cut -d "." -f 1)
        elif [[ "$os" = "Red" ]]; then
                export os="Red Hat"
                export os_ver=$(cat /etc/redhat-release|head -1|awk {'print $6'}|cut -d "." -f 1)
        else
                export os=$(cat /etc/redhat-release|head -1|awk {'print $1'})
                export os_ver=$(cat /etc/redhat-release|head -1|grep -oP "[0-9]+[\.]+[0-9]"|cut -d "." -f 1)
 
                if [[ "$os_ver" = "release" ]]; then
                        export os_ver=$(cat /etc/redhat-release|head -1|awk {'print $4'}|cut -d "." -f 1)
                fi
        fi
else
        export os=$(uname -s -r|head -1|awk {'print $1'})
        export os_ver=$(uname -s -r|head -1|awk {'print $2'}|cut -d "." -f 1)
fi
# detect arch
export arch=$(uname -a|grep -o 'x86_64\|386'|head -n1)
