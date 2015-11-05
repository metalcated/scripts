#!/bin/bash
###################################################################################
##
## Title:       Spacewalk Nightly Database Backup Script
## Author:      metalcated <metalcated at gm@il com>
## Date:        11/05/2015
## Version:     0.1
##
## Changelog:   0.1 - Initial Release
###################################################################################

# how many days to keep backups for
dayskeep="7"

# define spacewalk schema
schema="rhnschema"

# define backup dir and file
backupdir="/var/lib/pgsql/backups"
dbfile="${schema}.postgres.`date -I`.backup"

echo -e "\n[\e[32mSpacewalk Backup\e[0m]: stopping spacewalk services"
# stop spacewalk services
/usr/sbin/spacewalk-service stop
echo -e "[\e[32mSpacewalk Backup\e[0m]: starting postgresql service"
# start postgresql service
/etc/init.d/postgresql start

# check if backup dir exists
if [[ ! -d $backupdir ]]; then
        echo -e "[\e[31mSpacewalk Backup\e[0m]: faild to find target backup directory: $backupdir"
        mkdir -p $backupdir
        if [[ -d $backupdir ]]; then
                echo -e "[\e[32mSpacewalk Backup\e[0m]: $backupdir created"
        else
                echo -e "[\e[32mSpacewalk Backup\e[0m]: $backupdir failed to create, ending script"
                exit 0
        fi
fi

# make db backups
echo -e "[\e[32mSpacewalk Backup\e[0m]: running postgresql db backups"
su - postgres -c "touch ${backupdir}/${dbfile}"
su - postgres -c "pg_dump ${schema} > ${backupdir}/${dbfile}"

rpm -qa|grep pigz > /dev/null 2>&1
if [[ "$?" != 0 ]]; then
        echo -e "[\e[32mSpacewalk Backup\e[0m]: installing pigz compression tool"
        $(which yum) install pigz -y
fi
# compress backups
echo -e "[\e[32mSpacewalk Backup\e[0m]: compressing postgresql db backup"
$(which pigz) --fast ${backupdir}/${dbfile}

echo -e "[\e[32mSpacewalk Backup\e[0m]: starting spacewalk services"
# restart all of the services
/usr/sbin/spacewalk-service start

echo -e "[\e[32mSpacewalk Backup\e[0m]: cleaning up backups older than $dayskeep days"
# cleanup backups older than x days
find ${backupdir} -type f -mtime +${dayskeep} -exec rm -f {} \;
#find ${backupdir}/${dbfile} -name "*.backup" -mtime +7 -exec rm -f {} \;
wait

# if file exists and is not blank else
if [[ -f ${backupdir}/${dbfile}.gz && -s ${backupdir}/${dbfile}.gz ]]; then
        echo -e "\n[\e[32mSpacewalk Backup\e[0m]: \e[32msucessful backup made: ${backupdir}/${dbfile}.gz\e[0m, exiting PostgreSQL backup script.\n"
else
        echo -e "\n[\e[31mSpacewalk Backup\e[0m]: \e[31mbackup failed\e[0m, exiting PostgreSQL backup script.\n"
fi
