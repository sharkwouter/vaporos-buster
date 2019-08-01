#!/bin/bash
###############
# Script Info #
###############
# Author: Wouter Wijsman aka sharkwouter
# Description:
# This script can be used to generate modified versions of the SteamOS ISO with different packages.

##########
# Script #
##########
# Make sure we're running in the correct directory
cd "$(dirname "$0")"

###################
# Basic variables #
###################
# Directories:
WORKDIR="${PWD}"
CHROOTDIR="${WORKDIR}/chroot"
IMAGENAME="vaporos-buster-base"

#############
# Execution #
#############
# Make sure we are running as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Make sure the chroot directory exists
if [ ! -d ${CHROOTDIR} ]; then
	echo "Error: ${CHROOTDIR} directory doesn't exist. Make sure you have run the create-chroot.sh script before trying to create the docker image"
	exit 1
fi

# Create base docker image
tar -C ${CHROOTDIR} -c . | docker import - ${IMAGENAME}
