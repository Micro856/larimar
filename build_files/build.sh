#!/bin/bash

set -ouex pipefail

arch=$(uname -m)

# Codecs
dnf install -y \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf config-manager setopt fedora-cisco-openh264.enabled=1 -y
dnf swap -y ffmpeg-free ffmpeg --allowerasing
dnf update -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
if [ $arch  == "x86_64" ]; then
        dnf install -y intel-media-driver libva-intel-driver
fi
dnf install -y rpmfusion-free-release-tainted libdvdcss

# Helium - Web browser
dnf copr enable -y imput/helium
dnf install -y helium-bin
dnf copr disable -y imput/helium

# Themeing
dnf install -y adw-gtk3-theme

# Extensions
dnf remove -y gnome-shell-extension-*
dnf install -y \
  gnome-shell-extension-blur-my-shell \
  gnome-shell-extension-dash-to-dock \
  gnome-shell-extension-gsconnect \
  gnome-shell-extension-appindicator
