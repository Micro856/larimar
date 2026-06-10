#!/bin/bash

set -ouex pipefail

arch=$(uname -m)

# Codecs
dnf install -y \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf config-manager setopt fedora-cisco-openh264.enabled=1 -y
dnf update -y --refresh
dnf swap -y ffmpeg-free ffmpeg --allowerasing
if [ $arch  == "x86_64" ]; then
        dnf install -y intel-media-driver libva-intel-driver
fi
dnf install -y rpmfusion-free-release-tainted
dnf install -y libdvdcss

# Apps
dnf install -y k3b --setopt=install_weak_deps=False
rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
dnf install -y --refresh code

# Themeing
dnf install -y adw-gtk3-theme

# Wallpapers
dnf remove -y f*-backgrounds f*-backgrounds-*

# Extensions
dnf remove -y gnome-shell-extension-*
dnf install -y \
  gnome-shell-extension-blur-my-shell \
  gnome-shell-extension-dash-to-dock \
  gnome-shell-extension-gsconnect \
  gnome-shell-extension-appindicator \
  nautilus-python nautilus-extensions
git clone https://github.com/Tudmotu/gnome-shell-extension-clipboard-indicator.git /usr/share/gnome-shell/extensions/clipboard-indicator@tudmotu.com
  # Workspace scroll extension
git clone https://github.com/PolyMeilex/gnome-shell-extension-panel-workspace-scroll.git /tmp/gnome-shell-extension-panel-workspace-scroll
cp -r /tmp/gnome-shell-extension-panel-workspace-scroll/panel-workspace-scroll@polymeilex.github.io /usr/share/gnome-shell/extensions/
cd /

# Random crap
dnf install -y fastfetch

# Debloat
sudo dnf remove -y gnome-tour gnome-system-monitor gnome-software gnome-software* firefox firefox* yelp
echo "NoDisplay=true" >> /usr/share/applications/gcdmaster.desktop
echo "NoDisplay=true" >> /usr/share/applications/org.freedesktop.MalcontentControl.desktop
echo "NoDisplay=true" >> /usr/share/applications/org.gnome.Extensions.desktop
