#!/bin/bash
################################################################################
##
## Title: Oracle Java Installer
##
## Date: 03/27/2015
## Author: Mike G. aka metalcated and partially forked from n0ts
## Version: 0.2
##
## Changelog: 0.1 - Initial Release
##            0.2 - Fixed dupe download issue
##
## Usage: ./install_java.sh <jre|jdk_version> <rpm|tar>
##
## Defaults: jre|jdk_version: 8 / rpm
##
################################################################################

ADMIN_EMAIL=""
# type can be jre or jdk
JAVA_TYPE="jre"
JAVA_VERSION="8"
EXT="rpm"

# set default if suggested
if [[ -n "$1" ]]; then
  if [[ "$1" == "7" ]]; then
   JAVA_VERSION="7"
  fi
fi

# set download extension
if [[ -n "$2" ]]; then
  if [[ "$2" == "tar" ]]; then
    EXT="tar.gz"
  fi
fi

# set base download location
URL="http://www.oracle.com"
DOWNLOAD_URL1="${URL}/technetwork/java/javase/downloads/index.html"
DOWNLOAD_URL2=$(curl -s $DOWNLOAD_URL1 | egrep -o "\/technetwork\/java/\javase\/downloads\/${JAVA_TYPE}${JAVA_VERSION}-downloads-.*\.html" | head -1)

# check to make sure we got to oracle
if [[ -z "$DOWNLOAD_URL2" ]]; then
  echo "Could not to oracle - $DOWNLOAD_URL1"
  exit 1
fi

# set download url
DOWNLOAD_URL3="$(echo ${URL}${DOWNLOAD_URL2}|awk -F\" {'print $1'})"
DOWNLOAD_URL4=$(curl -s "$DOWNLOAD_URL3" | egrep -o "http\:\/\/download.oracle\.com\/otn-pub\/java\/jdk\/[7-8]u[0-9]+\-(.*)+\/${JAVA_TYPE}-[7-8]u[0-9]+(.*)linux-x64.${EXT}"|tail -n1)

# check to make sure url exists
if [[ -z "$DOWNLOAD_URL4" ]]; then
  echo "Could not get ${JAVA_TYPE} download url - $DOWNLOAD_URL4"
  exit 1
fi
# set download file name
JAVA_INSTALL=$(basename $DOWNLOAD_URL4)

if [[ "$EXT" == "rpm" ]]; then

        # download java
        echo -e "\n\e[32mDownloading\e[0m: $DOWNLOAD_URL4"
        while true;
        do echo -n .;sleep 1;done &
        cd /tmp; wget -q --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" $DOWNLOAD_URL4 -O $JAVA_INSTALL > /dev/null 2>&1
        kill $!; trap 'kill $!' SIGTERM;
        # install rpm
        echo -e "\n\e[32mInstalling\e[0m: $JAVA_INSTALL\r"
        while true;
        do echo -n .;sleep 1;done &
        rpm -Uvh /tmp/$JAVA_INSTALL > /dev/null 2>&1
        kill $!; trap 'kill $!' SIGTERM;
        echo -e "\n\e[32mInstall\e[0m Complete\n"
        # get dirname
        JAVA_DIR=$(ls -tr /usr/java/|grep ${JAVA_TYPE}|head -n 1)
        # set temp env var
        export JAVA_HOME=/usr/java/${JAVA_DIR}
        # set perm env var
        echo "export JAVA_HOME=/usr/java/${JAVA_DIR}" >> /etc/environment
        # set if jdk is used
        if [[ "$JAVA_TYPE" = "jdk" ]]; then
                # set temp env var
                export JRE_HOME=/usr/java/${JAVA_DIR}/jre
                # set perm env var
                echo "export JRE_HOME=/usr/java/${JAVA_DIR}/${JAVA_TYPE}" >> /etc/environment
        fi
        # make sure java installed
        ls /usr/java/${JAVA_DIR} > /dev/null 2>&1
        if [[ "$?" != 0  ]]; then
                echo -e "\n\e[31mError\e[0m: Java does not seem to be installed correctly,\nPlease try again or email admin: ${ADMIN_EMAIL}\n"
                exit 1
        fi

elif [[ "$EXT" == "tar" || "$EXT" == "tar.gz" ]]; then

        # download java
        echo -e "\n\e[32mDownloading\e[0m: $DOWNLOAD_URL4"
        while true;
        do echo -n .;sleep 1;done &
        cd /opt; wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" $DOWNLOAD_URL4  -O $JAVA_INSTALL > /dev/null 2>&1
        kill $!; trap 'kill $!' SIGTERM;
        # extract the tar
        echo -e "\n\e[32mExtracting\e[0m: $JAVA_INSTALL\r"
        while true;
        do echo -n .;sleep 1;done &
        tar xzf $JAVA_INSTALL > /dev/null 2>&1
        kill $!; trap 'kill $!' SIGTERM;
        echo -e "\n\e[32mInstall\e[0m Complete\n"
        # get dirname
        JAVA_DIR=$(ls -tr /opt/|grep ${JAVA_TYPE}|head -n 1)
        # set default java
        alternatives --install /usr/bin/java java /opt/${JAVA_DIR}/bin/java 1
        alternatives --install /usr/bin/javac javac /opt/${JAVA_DIR}/bin/javac 1
        alternatives --install /usr/bin/jar jar /opt/${JAVA_DIR}/bin/jar 1
        # set temp env vars
        export JAVA_HOME=/opt/${JAVA_DIR}
        export PATH=$PATH:/opt/${JAVA_DIR}/bin:/opt/${JAVA_DIR}/${JAVA_TYPE}/bin
        # set perm env vars
        echo "export JAVA_HOME=/opt/${JAVA_DIR}" >> /etc/environment
        echo "export PATH=$PATH:/opt/${JAVA_DIR}/bin:/opt/${JAVA_DIR}/${JAVA_TYPE}/bin" >> /etc/environment
        # set if jdk is used
        if [[ "$JAVA_TYPE" = "jdk" ]]; then
                # set temp env var
                export JRE_HOME=/opt/${JAVA_DIR}/${JAVA_TYPE}
                # set perm env var
                echo "export JRE_HOME=/opt/${JAVA_DIR}/${JAVA_TYPE}" >> /etc/environment
        fi
        # make sure java installed
        ls /opt/${JAVA_DIR} > /dev/null 2>&1
        if [[ "$?" != 0  ]]; then
                echo -e "\n\e[31mError\e[0m: Java does not seem to be installed correctly,\nPlease try again or email admin: ${ADMIN_EMAIL}\n"
                exit 1
        fi
fi
# end script
