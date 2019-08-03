# VaporOS Buster

Valve hasn't released SteamOS based on Buster yet, so here is a test to see if it can be done without Valve.

## Generating the ISO

Generating the ISO from the git repo consists of multiple steps. You need to be on Debian Buster or VaporOS Buster to be able to do this.

The first time the ISO is created the following steps will need to be taken:

 - ``sudo apt-get update``
 - ``sudo apt-get install debootstrap lftp rsync reprepro p7zip-full xorriso git``
 - ``git clone https://github.com/sharkwouter/vaporos-buster.git``
 - ``cd vaporos-buster``
 - ``./add-packages.sh && /gen.sh``

Executing the add-packages.sh and gen.sh scripts can take a while. The add-packages.sh script uses sudo to create and use a chroot.

A second time ``./gen.sh`` should be the only command necessary. The ``./add-packages.sh`` command could be run again to if any changes are made to packages in the default.preseed or base_include files.

## Testing the base installation

To test if the installer would succeed in the base installation the ``create-chroot.sh`` script can be run. This creates a chroot based on the buildroot directory. Make sure you run ``gen.sh`` before running this script. It has to be run as root.

## Currently implemented features

Currently the following features have been implemented:

- An ISO can be genereated with gen.sh
- Firmware files are included on the disk

## Deviations from SteamOS

These are deviations from SteamOS which have been made on purpose:

 - The amdgpu-pro-firmware package hasn't been included yet. It isn't available in the Debian repository.
 - The lightdm package will need to be moved to the default.preseed. It causes debootstrap to fail otherwise.
 - The i965-va-driver package will need to be moved to the defauld.preseed. It causes debootstrap to fail otherwise.
 - The dkms package will need to be moved to the default.preseed. It causes debootstrap to fail otherwise. This one I don't understand, I've had build which worked with this one.
 - The broadcom-sta-dkms package will need to be moved to the default.preseed. It causes debootstrap to fail otherwise. This one I don't understand, I've had build which worked with this one.

These deviations may change in the future, depending on the reason behind them. Assume all other differences from SteamOS haven't been looked into yet or are still being worked on.

These packages have no use for VaporOS and will not be included at all:

 - actkbd
 - valve-wallpapers
 - valve-archive-keyring
 - libtxc-dxtn-s2tc0

## Packages which will need porting

For this project to work out a number of packages will need to be ported to VaporOS Buster. This part contains per source which package those are.

### base\_include

- plymouth-themes-steamos
- steamos-base-files
- steamos-compositor
- steamos-modeswitch-inhibitor

## Current issues

Issues which need to be resolved:

 - The steam package doesn't install, because it asks a question.
