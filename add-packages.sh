#!/bin/bash
###############
# Script Info #
###############
# Author: Wouter Wijsman aka sharkwouter
# Description:
#T his script downloads packages with their dependencies for vaporos

##########
# Script #
##########
#Change directory to the directory of this script
cd "$(dirname "$0")"

###################
# Basic variables #
###################
# Directories:
WORKDIR="${PWD}"
TEMPDIR="${WORKDIR}/output"
TARGETDIR="${WORKDIR}/packages"

#############
# Functions #
#############
#Show how to use gen.sh
usage ( ) {
	cat <<EOF
Usage: $0 pkg1 [pkg2 ...]

This script allows you to download specific packages and their dependencies into VaporOS.
EOF
}

###################
# Getopts #
###################
PACKAGES="${@}"

#Stop the program if we don't know which packages the user wants
if [ -z "${PACKAGES}" ];then
    usage
    exit 1
fi

#############
# Execution #
#############
# Make sure we are running as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

#Make the target directory if needed
mkdir -p ${TARGETDIR} 2>/dev/null

#Make the directory which will be added to the container
mkdir -p ${TEMPDIR}

#Run container
docker run --rm -ti -v ${TEMPDIR}:/home/builder/share vaporos-buster-base apt-get install -d -o dir::cache=/home/builder/share -o Debug::NoLocking=1 -y ${PACKAGES}

#Move 
mv ${TEMPDIR}/archives/*deb ${TARGETDIR}
rm -rf ${TEMPDIR}

#Set owner back to the owner of project directory
owner="$(ls -dl ${WORKDIR}|cut -d' ' -f3)"
group="$(ls -dl ${WORKDIR}|cut -d' ' -f4)"
chown -R ${owner}:${group} ${TARGETDIR}
