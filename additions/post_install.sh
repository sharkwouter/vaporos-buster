#! /bin/sh
# script runs after debian installer has done its thing

chroot /target adduser --gecos "" --disabled-password steam
chroot /target usermod -a -G desktop,audio,dip,video,plugdev,netdev,bluetooth,pulse-access steam
chroot /target usermod -a -G pulse-access desktop

# Configure the display manager
echo "/usr/sbin/lightdm" > /target/etc/X11/default-display-manager
chroot /target ln -sf /lib/systemd/system/lightdm.service /etc/systemd/system/display-manager.service
cat - > /target/usr/share/lightdm/lightdm.conf.d/20_steamos.conf << 'EOF'
[Seat:*]
pam-service=lightdm-autologin
autologin-user=steam
autologin-user-timeout=0
autologin-session=gnome
EOF

chroot /target date > /target/etc/skel/.imageversion
cp /target/etc/skel/.imageversion /target/home/steam/.imageversion

#
# Add post-logon configuration script
#
cat - > /target/usr/bin/post_logon.sh << 'EOF'
#! /bin/bash
if [[ "$UID" -ne "0" ]]
then
  #
  # Wait up to 10 seconds and see if we have a connection. If not, pop the network dialog
  #
  nm-online -t 10 -q
  if [ "$?" -ne "0" ]; then
    while true;
    do
      zenity --info --title="SteamOS Install" --text="SteamOS cannot connect to the internet. An internet connection is required to continue installation. If you have a wireless network, configure it now."
      nm-connection-editor --type=802-11-wireless --show
      nm-online -t 30
      if [ "$?" -eq "0" ]; then 
        break
      fi
      echo "Still waiting for internet connection..."
    done
  fi

  gnome-terminal --hide-menubar -- sudo /usr/bin/install_steam.sh

  # Wait for the steam installation to finish
  while [ -f /usr/bin/install_steam.sh ]; do
    sleep 1
  done

  # dummy file to skip the Steam Install Agreement dialog
  touch ~/.steam/steam_install_agreement.txt
  # pass -exitsteam so steam doesn't actually run after bootstrapping
  steam -exitsteam
  rm ~/.steam/starting
  cp ~/.local/share/Steam/steam_install_agreement.txt ~/.steam/steam_install_agreement.txt
  sudo /usr/bin/post_logon.sh
  exit
fi
# Disable apparmor, otherwise nothing works
systemctl disable --now apparmor.service
dbus-send --system --type=method_call --print-reply --dest=org.freedesktop.Accounts /org/freedesktop/Accounts/User1000 org.freedesktop.Accounts.User.SetXSession string:gnome
dbus-send --system --type=method_call --print-reply --dest=org.freedesktop.Accounts /org/freedesktop/Accounts/User1001 org.freedesktop.Accounts.User.SetXSession string:steamos
systemctl enable build-dkms
(for i in `dkms status | cut -d, -f1-2 | tr , / | tr -d ' '`; do sudo dkms remove $i --all; done) | zenity --progress --no-cancel --pulsate --auto-close --text="Configuring Kernel Modules" --title="SteamOS Installation"
update-grub
grub-set-default 0
passwd --delete desktop
sed -i '/autologin-session/d' /usr/share/lightdm/lightdm.conf.d/20_steamos.conf
rm /etc/sudoers.d/post_logon
rm /usr/bin/post_logon.sh && reboot
rm /home/steam/.config/autostart/post_logon.desktop
EOF
chmod +x /target/usr/bin/post_logon.sh

#
# Enable anyone to sudo the post logon script
#
echo ALL ALL=NOPASSWD: /usr/bin/post_logon.sh > /target/etc/sudoers.d/post_logon

#
# Add steam installation script
#
cat - > /target/usr/bin/install_steam.sh << 'EOF'
#! /bin/bash
echo "Installing Steam.."
apt-get update && \
apt-get install -y steam && \
rm /etc/sudoers.d/install_steam && \
rm /usr/bin/install_steam.sh
EOF
chmod +x /target/usr/bin/install_steam.sh

#
# Enable anyone to sudo the steam installation script
#
echo ALL ALL=NOPASSWD: /usr/bin/install_steam.sh > /target/etc/sudoers.d/install_steam

#
# Set post logon to run at the first logon
#
mkdir -p /target/home/steam/.config/autostart/
cat - > /target/home/steam/.config/autostart/post_logon.desktop << 'EOF'
[Desktop Entry]
Type=Application
Exec=/usr/bin/post_logon.sh
X-GNOME-Autostart-enabled=true
Name=postlogon
EOF

#
# Boot splash screen and GRUB configuration
#
if test `/target/bin/grep -A10000 "### BEGIN /etc/grub.d/30_os-prober ###" /target/boot/grub/grub.cfg | /target/bin/grep -B10000 "### END /etc/grub.d/30_os-prober ###" | wc -l` -gt 4; then
ISDUALBOOT=Y
else
ISDUALBOOT=N
fi
cat - > /target/etc/default/grub << EOF
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.
# For full documentation of the options in this file, see:
#   info -f grub -n 'Simple configuration'

GRUB_DEFAULT=saved
GRUB_HIDDEN_TIMEOUT_QUIET=true
GRUB_DISTRIBUTOR=\`lsb_release -i -s 2> /dev/null || echo Debian\`
GRUB_CMDLINE_LINUX=""
GRUB_DISABLE_LINUX_RECOVERY="true"
GRUB_GFXMODE=auto
EOF
if test "${ISDUALBOOT}" = N; then
echo "GRUB_TIMEOUT=0" >> /target/etc/default/grub
echo "GRUB_HIDDEN_TIMEOUT=1" >> /target/etc/default/grub
else
echo "GRUB_TIMEOUT=5" >> /target/etc/default/grub
fi


if test -d /sys/firmware/efi/; then
ISEFI=Y
else
ISEFI=N
fi

# enable splash and set framebuffer size to 1024x768x24 for non-efi systems
if test "${ISEFI}" = "Y"; then
echo "GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash\"" >> /target/etc/default/grub
else
echo "GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash vga=0x0318\"" >> /target/etc/default/grub
fi
