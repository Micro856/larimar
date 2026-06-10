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
  gnome-shell-extension-appindicator
