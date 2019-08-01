#!/bin/bash
###############
# Script Info #
###############
# Author: Wouter Wijsman aka sharkwouter
# Description:
# This script can be used to create a chroot based on the buildroot created when running gen.sh.
# It is an easy way to test if the base system will install with the generated ISO as well.

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
BUILD="${WORKDIR}/buildroot"
CHROOTPATH="${WORKDIR}/chroot"

# Other info:
DEPS="debootstrap"

#############
# Functions #
#############
#Show how to use gen.sh
usage ( )
{
	cat <<EOF
	$0 [OPTION]
	-h		  Print this message
EOF
}

checkroot ( ) {
# Make sure we are running as root
	if [ "$EUID" -ne 0 ]
	  then echo "Please run as root"
	  exit
	fi
}

#Check some basic dependencies this script needs to run
deps ( ) {
	#Check dependencies
	for dep in ${DEPS}; do
		if which ${dep} >/dev/null 2>&1; then
			:
		else
			echo "Missing dependency: ${dep}"
			exit 1
		fi
	done
	if test "`expr length \"$ISOVNAME\"`" -gt "32"; then
		echo "Volume ID is more than 32 characters: ${ISOVNAME}"
		exit 1
	fi
}

#Remove the ${BUILD} directory to start from scratch
scratch ( ) {
	if [ -d "${CHROOTPATH}" ]; then
		echo "Building ${CHROOTPATH} from scratch"
		rm -fr "${CHROOTPATH}"
	fi
	
	#Create new directory
	mkdir -p ${CHROOTPATH}
}

#Build the chroot
createbasechroot ( ) {
	if [ ! -d ${BUILD} ]; then
		echo "Error: ${BUILD} directory not found, run gen.sh first"
	fi
	components=""
	for component in `cat ${BUILD}/.disk/base_components`; do
		if [ "${component}" == "main" ]; then
			components="${component}"
		else
			components="${components},${component}"
		fi
	done

	includes=""
	for include in `cat ${BUILD}/.disk/base_include`; do
		includes="${includes},${include}"
	done

	excludes=""
	for exclude in `cat ${BUILD}/.disk/base_exclude`; do
		excludes="${excludes},${exclude}"
	done

	/usr/sbin/debootstrap --components=${components} --resolve-deps --include=${includes} --exclude=${excludes} --no-check-gpg buster chroot file://${BUILD}
}

#Fininishing touches to the chroot
finishchroot ( ) {
	echo "deb http://deb.debian.org/debian/ buster main contrib non-free" > ${CHROOTPATH}/etc/apt/sources.list
	chroot ${CHROOTPATH} dpkg --add-architecture i386
	chroot ${CHROOTPATH} apt-get update
	chroot ${CHROOTPATH} apt-get autoclean
	#chroot ${CHROOTPATH} apt-get install -y locales
	#sed -i 's/#\( en_US\.UTF-8\)/\1/' ${CHROOTPATH}/etc/locale.gen
	#chroot ${CHROOTPATH} locale-gen
	echo "KEYMAP=us" > ${CHROOTPATH}/etc/vconsole.conf
}

###########
# Getopts #
###########
#Setup command line arguments
while getopts "h:" OPTION; do
        case ${OPTION} in
        h)
                usage
                exit 1
        ;;
        *)
                echo "${OPTION} - Unrecongnized option"
                usage
                exit 1
        ;;
        esac
done

#############
# Execution #
#############
#Check if the script is run as root
checkroot

#Check dependencies
deps

#Replace ${CHROOTPATH} with an empty directory
scratch

#Build the chroot
createbasechroot

#Finishing touches to the chroot
finishchroot
