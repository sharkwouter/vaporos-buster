# VaporOS Buster

Valve hasn't released SteamOS based on Buster yet, so here is a test to see if it can be done without their help.

## Generating the ISO

Generating the ISO can be done with ``./gen.sh``. It will tell you if you are missing any dependencies.

The ``gen.sh`` script downloads the base iso, extracts it, makes some changes and repackages it. It can be modified to work with any Debian based distribution.

## Testing the base installation

To test if the installer would succeed in the base installation the ``create-chroot.sh`` script can be run. This creates a chroot based on the buildroot directory. Make sure you run ``gen.sh`` before running this script. It has to be run as root.

## Currently implemented features

Currently the following features have been implemented:

- An ISO can be genereated with gen.sh
- Firmware files are included on the disk

## Deviations from SteamOS

These are deviations from SteamOS which have been made on purpose:

 - The amdgpu-pro-firmware package hasn't been included yet. It isn't available in the Debian repository.
 - The libtxc-dxtn-s2tc0 package hasn't been included yet. It isn't available in the Debian repository.
 - The lightdm package will need to be moved to the default.preseed. It causes debootstrap to fail otherwise.
 - The i965-va-driver package will need to be moved to the defauld.preseed. It causes debootstrap to fail otherwise.
 - The dkms package will need to be moved to the default.preseed. It causes debootstrap to fail otherwise. This one I don't understand, I've had build which worked with this one.
 - The broadcom-sta-dkms package will need to be moved to the default.preseed. It causes debootstrap to fail otherwise. This one I don't understand, I've had build which worked with this one.

These deviations may change in the future, depending on the reason behind them. Assume all other differences from SteamOS haven't been looked into yet or are still being worked on.

These packages have no use for VaporOS and will not be included at all:

 - actkbd
 - valve-wallpapers
 - valve-archive-keyring

## Packages which will need porting

For this project to work out a number of packages will need to be ported to VaporOS Buster. This part contains per source which package those are.

### base\_include

- plymouth-themes-steamos
- steamos-base-files
- steamos-compositor
- steamos-modeswitch-inhibitor
