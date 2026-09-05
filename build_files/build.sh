#!/bin/bash

set -ouex pipefail

arch=$(uname -m)

dnf install -y dbus-daemon

# Codecs
dnf install -y \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf config-manager setopt fedora-cisco-openh264.enabled=1 -y
dnf update -y --refresh
dnf swap -y ffmpeg-free ffmpeg --allowerasing
if [ $arch  == "x86_64" ]; then
        dnf install -y intel-media-driver libva-intel-driver powerstat \
        mesa-vulkan-drivers vulkan-loader
fi
dnf install -y rpmfusion-free-release-tainted
dnf install -y libdvdcss

dnf copr -y enable ublue-os/packages
dnf install -y uupd
dnf copr -y disable ublue-os/packages
systemctl enable uupd.timer

# Batteries from uBlue
dnf install -y -x google-noto-sans-cjk-vf-fonts -x default-fonts-cjk-sans -x fedora-third-party\
        alsa-firmware apr apr-util distrobox fdk-aac ffmpeg-libs ffmpegthumbnailer flatpak-spawn fuse \
        fzf google-noto-sans-balinese-fonts google-noto-sans-cjk-fonts google-noto-sans-javanese-fonts \
        google-noto-sans-sundanese-fonts grub2-tools-extra heif-pixbuf-loader just libavcodec-freeworld \
        libcamera libcamera-gstreamer libcamera-ipa libheif libcamera-tools libimobiledevice-utils libratbag-ratbagd \
        libva-utils lshw net-tools nvme-cli openrgb-udev-rules openssl pam-u2f pam_yubico pamu2fcfg \
        pipewire-plugin-libcamera smartmontools squashfs-tools symlinks tcpdump tmux traceroute \
        usbmuxd wireguard-tools wl-clipboard xhost xorg-x11-xauth yubikey-manager zstd gvfs-nfs ibus-unikey ibus-mozc \
        --setopt=install_weak_deps=False

# Random crap
dnf install -y fastfetch distrobox make

# Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Apps
if [ $arch  == "x86_64" ]; then
        dnf install -y k3b solaar solaar-udev akmod-VirtualBox VirtualBox --setopt=install_weak_deps=False
fi
rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | tee /etc/yum.repos.d/vscode.repo > /dev/null
dnf install -y --refresh code

# Themeing
dnf install -y adw-gtk3-theme

# Wallpapers
dnf remove -y f*-backgrounds f*-backgrounds-*
cp -r /ctx/shared/gnome-background-properties /usr/share

# Extensions
dnf remove -y gnome-shell-extension-*
dnf install -y \
  gnome-shell-extension-blur-my-shell \
  gnome-shell-extension-gsconnect \
  nautilus-python nautilus-extensions
  # Install Panel Workspace Scroll, GNOME Fuzzy App Search, Rounded Window Corners Reborn, Static Workspace Background,
  # Tailscale, Window Is Ready - Notification Remover
/tmp/scripts/run_module.sh 'gnome-extensions' \
    '{"type":"gnome-extensions","install":["6523","3956","7048","8505","10017","1007"]}'

# Schemas
rm -rf /usr/share/glib-2.0/schemas/org.gnome.shell.gschema.override
cp -r /ctx/shared/schemas /usr/share/glib-2.0
#if [ $arch  == "x86_64" ]; then
        #cp -r /ctx/x86/schemas /usr/share/glib-2.0
#elif [ $arch == "aarch64" ]; then
        #cp -r /ctx/arm/schemas /usr/share/glib-2.0
#fi
rm -rf /usr/share/glib-2.0/schemas/gschemas.compiled
glib-compile-schemas /usr/share/glib-2.0/schemas

# Flatpaks
cp -r /ctx/shared/flatpak /usr/share
if [ $arch  == "x86_64" ]; then
        cp -r /ctx/x86/flatpak /usr/share
elif [ $arch == "aarch64" ]; then
       # cp -r /ctx/arm/flatpak /usr/share
       echo "Nothing yet :D"
fi
cp -r /ctx/lib /usr
rm -rf /usr/lib/systemd/system/flatpak-add-fedora-repos.service
mkdir -p /etc/flatpak/remotes.d/
curl --retry 3 -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo
systemctl enable flatpak-add-flathub-repos
systemctl enable flatpak-preinstall

# Debloat
dnf remove -y gnome-tour gnome-system-monitor gnome-software gnome-software* firefox firefox* yelp
echo "NoDisplay=true" >> /usr/share/applications/gcdmaster.desktop
echo "NoDisplay=true" >> /usr/share/applications/org.freedesktop.MalcontentControl.desktop
echo "NoDisplay=true" >> /usr/share/applications/org.gnome.Extensions.desktop

# Set the default boot screen
dnf install -y plymouth-theme-spinner plymouth --setopt=install_weak_deps=False
plymouth-set-default-theme bgrt

# Rebuild kernel just in case
QUALIFIED_KERNEL="$(dnf5 repoquery --installed --queryformat='%{evr}.%{arch}' "kernel")"
/usr/bin/dracut --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible --zstd -v --add ostree --add fido2 --add plymouth -f "/usr/lib/modules/$QUALIFIED_KERNEL/initramfs.img"
chmod 0600 /usr/lib/modules/"$QUALIFIED_KERNEL"/initramfs.img
