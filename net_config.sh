#!/bin/bash
#######################################################################
##
## Title:       Automated Network Configuration Change Script
## Author:      Mike Gomon aka metalcated
## Date:        03/25/2015
## Version:     0.2
##
## Changelog:   0.1 - Initial Release
##              0.2 - Added changes for resolv.conf
##
#######################################################################

# what to change (manual edit required)
ip_addr="192.168.128.55"
netmask="255.255.255.0"
gateway="192.168.128.1"
dns1="10.0.0.1"
dns2="10.0.0.2"

# log location
logfile="/var/log/net-config.log"

#######################################################################
### Do not change anything below unless you know what you are doing ###
#######################################################################

# get active network adapter
active_nic=$(/sbin/route -n | grep "^0.0.0.0" | rev | cut -d' ' -f1 | rev)

# set eth# config
active_conf=/etc/sysconfig/network-scripts/ifcfg-${active_nic}

# location of resolv.conf
resolv_conf=/etc/resolv.conf

# make a backup of the existing configs
\cp -rp $active_conf ${active_conf}_backup
\cp -rp $resolv_conf ${resolv_conf}_backup

# make changes to config now that backup exists
ls ${active_conf}_backup > /dev/null 2>&1
if [[ "$?" = 1 ]]; then
        echo "$(date)\nBackup of ${active_conf}_backup failed, ending script.\n" >> $logfile
        status="Failed"
        exit 0
else
        echo -e "$(date)\nBackup of ${active_conf}_backup suceeded, making changes.\n" >> $logfile
        # change ip address
        if [[ "$ip_addr" != "" ]]; then
                sed -ri "s/(IPADDR=)[^=]*$/\1${ip_addr}/" $active_conf
        fi
        # add netmask and remove prefix if exists
        if [[ "$netmask" != "" ]]; then
                grep "PREFIX=" $active_conf > /dev/null 2>&1
                if [[ "$?" = 0 ]]; then
                        sed -i 's/PREFIX/NETMASK/g' $active_conf
                        sed -ri "s/(NETMASK=)[^=]*$/\1${netmask}/" $active_conf
                else
                        sed -ri "s/(NETMASK=)[^=]*$/\1${netmask}/" $active_conf
                fi
        fi
        # changes gateway
        if [[ "$gateway" != "" ]]; then
                sed -ri "s/(GATEWAY=)[^=]*$/\1${gateway}/" $active_conf
        fi
        # change DNS1
        if [[ "$dns1" != "" ]]; then
                sed -ri "s/(DNS1=)[^=]*$/\1${dns1}/" $active_conf
        fi
        # change DNS2
        if [[ "$dns2" != "" ]]; then
                sed -ri "s/(DNS2=)[^=]*$/\1${dns2}/" $active_conf
        fi
        # change domain
        if [[ "$domain" != "" ]]; then
                sed -ri "s/(DOMAIN=)[^=]*$/\1${domain}/" $active_conf
        fi
        cat $active_conf >> $logfile
        status="Suceeded"
fi

# change resolv.conf
ls ${resolv_conf}_backup > /dev/null 2>&1
if [[ "$?" = 1 ]]; then
        echo "$(date)\nBackup of ${resolv_conf}_backup failed, ending script.\n" >> $logfile
        status="Failed"
        exit 0
else
        echo -e "$(date)\nBackup of ${resolv_conf}_backup suceeded, making changes.\n" >> $logfile
        # change domain
        if [[ "$domain" != "" ]]; then
                sed -ri "s/(search)[^=]*$/\1 ${domain}/" $resolv_conf
        fi
        # change DNS1
        if [[ "$dns1" != "" ]]; then
                sed -ri "s/(nameserver)[^=]*$/\1 ${dns1}/" $resolv_conf
        fi
        # change DNS2
        if [[ "$dns2" != "" ]]; then
                sed -ri "s/(nameserver)[^=]*$/\1 ${dns2}/" $resolv_conf
        fi
        status="Suceeded"
fi

# remove cronjob
if [[ "$status" = "Suceeded" ]]; then
        rm -rf /etc/cron.d/net-config
        ls /etc/cron.d/net-config > /dev/null 2>&1
        if [[ "$?" = 1 ]]; then
                echo "Cron job: /etc/cron.d/net-config removed" >> $logfile
        else
                echo "Cron job: /etc/cron.d/net-config failed" >> $logfile
        fi
fi

# send status to log
echo -e "\nNetwork changes to ${active_conf}: $status\n" >> $logfile
echo -e "\nNetwork changes to ${resolv_conf}: $status\n" >> $logfile
# end script
