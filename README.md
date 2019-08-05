# VaporOS Buster

SteamOS hasn't been updated to make use of the new features offered by new Debian releases. That's why I'm porting the SteamOS experience to the latest Debian release, Debian Buster. I call it VaporOS Buster.

VaporOS Buster is still very early in development. That's why no release yet. Stay tuned!

# Features

VaporOS Buster offers the following features:
- Steam launches automatically, just like in SteamOS
- Makes all games look full screen
- No keyboard and mouse needed
- Easy automated installation
- Switch to desktop mode from Steam
- All the features of Debian Buster

## How to install

In the future, releases will be listed under [releases](https://github.com/sharkwouter/vaporos-buster/releases), but VaporOS Buster is not quite ready yet. Watch this repo to see when it has been released.

If you can't wait and want to test right now, scroll further and read how to build VaporOS Buster today.

## Building VaporOS Buster

Building an ISO which can be used for the installation of VaporOS Buster requires a couple of steps. Currently this only works on Debian based systems, like Debian, Ubuntu and VaporOS.

The first time the ISO is created the following steps will need to be taken:

 - ``sudo apt-get update``
 - ``sudo apt-get install debootstrap lftp rsync reprepro p7zip-full xorriso git``
 - ``git clone https://github.com/sharkwouter/vaporos-buster.git``
 - ``cd vaporos-buster``
 - ``./add-packages.sh && /gen.sh``

Executing the add-packages.sh and gen.sh scripts can take a while. The add-packages.sh script uses sudo to create and use a chroot.

A second time ``./gen.sh`` should be the only command necessary. The ``./add-packages.sh`` command could be run again to if any changes are made to packages in the default.preseed or base_include files.

## Developer information

The previous parts of this document were also useful to developers, but from here on we'll dig a bit deeper into what has happened, what needs to happen and how things work.

The most important thing to know is that this project works by downloading the network installation ISO of Debian Buster, extracts it and puts it back together with our configuation. This sometimes works really well and sometimes it breaks horribly, that's what testing is for.

### Files and directories

What do the files and directories in this project do? Good question! Here you'll find the answer.

#### Scripts

Within the root of this repo there are 3 script files:

- gen.sh
- add-packages.sh
- create-chroot.sh

After cloning this repo, the first out of these scripts you'll use will be add-packages.sh. This script downloads all packages needed for the project. It gets these from the default.preseed and base_include files and a variable in the script. It puts creates a packages directory to put the packages in. It uses sudo to create a chroot to be able to download all dependencies

Out of these, gen.sh is the most important one. It builds the complete iso. It used packages from the packages directory to do so!

The create-chroot.sh can be used for testing. It creates a chroot environment which matches the base system the ISO you just generated will install. The other steps in the installation process are not tested, you'll need to do the installation for that. The add-packages.sh script also uses this script.

#### The additions directory

The content of the additions directory will be copied on the ISO which gen.sh builds. It contains the bootloader configuration for the ISO and the following configuration files:

- default.preseed
- post_install.sh
- .disk/base_include (press ctrl+h in nautilus to be able to see this directory)
- .disk/base_components (same ^)

The default.preseed facilitates the automated installation. It also adds some packages to the system.

The post_install.sh script is executed during the automated installation. It does some configuration and sets up some scripts to execute on the first boot.

The base_include file contains a list of packages which will be installed in the first step of the installation process. Don't just add anything you like to this, this step is really bad at dependency resolution so a lot of packages will fail the installer here. Test with create-chroot.sh before running the full installation.

The base_components tells the installed it is allowed to install packages which come from contrib or non-free. Don't change.

Side note, BIOS systems use ISOLINUX and UEFI systems use grub to boot, I think.

#### Other files

The firmware.txt file contains which firmware files should be loaded when the ISO is booted.

The vaporos-archive-keyring.gpg file contains the public key of the VaporOS Buster repository. Chroots created with create-chroot.sh have access to it.

The isohdpfx.bin file is used for generating the iso. You need it, otherwise the ISO might not boot.

### Testing the base installation

To test if the installer would succeed in the installing the base system the ``create-chroot.sh`` script can be run. This creates a chroot based on the buildroot directory. Make sure you run ``gen.sh`` before running this script. It has to be run as root.

Installing the base system is only the very first step in the installation process, though. It only installs the packages listed in the .disk/base_install file. After that the installer uses tasksel to install the desktop environment and the pkgsel line in the default.preseed file to install the rest of the packages.

This way is nice to test, since the dependency resolution of the base installer isn't very good and fails to install most things you'll throw at it.

### Deviations from SteamOS

VaporOS currently has some deviations from SteamOS which have one reason or another. Here is a list:

- Steam is installed on first boot. The Debian package asks a question which requires user input
- The broadcom networking drivers break the installer, so they aren't included yet
- SteamOS would make a backup of the system right after installation. This has been removed because the clonezilla image is too big for github
- Some packages used to be in base_include, but are now in default.preseed because of bad dependency resolution for what's in base_include
- GDM is installed, because excluding it isn't possible
- VaporOS Buster uses the Debian repository for all packages except for a couple VaporOS specific ones. For those there is a repository. This gives users access to more packages and it is a lot easier to set up, but has a chance of causing headaches in the future

These deviations may change in the future, depending on the reason behind them. Assume all other differences from SteamOS haven't been looked into yet or are still being worked on, but do report them please.

### Packages which will need porting

For this project to work out a number of packages will need to be ported to VaporOS Buster:

- steamos-autoupdate

### Known issues

Currently there are some problems which are known:

- Apparmor is disabled. It would prevent steamos-session from starting correctly
- During the installation the screen will go black. It continues regardless, though, just wait it out
- The installation crashes in Virtualbox

### Not worth the effort

There are also some packages which don't seem to be very useful to me and probably will not be included:

- actkbd (Used for switching back to steam from the desktop, otherwise it doesn't do anything. Logging out works too)
- valve-wallpapers
- valve-archive-keyring (won't work)
- libtxc-dxtn-s2tc0 (Mesa has support for this now, so it shouldn't be needed anymore)
- plymouth-themes-steamos
- patches to gnome which made the text huge and enabled desktop icons

I'm not a big fan of the astetic packages. I'd prefer VaporOS Buster to look more like standard Debian than like SteamOS. That way people can see the difference.
