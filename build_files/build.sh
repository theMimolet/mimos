#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux 

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket

# Remove gaming packages
echo "Removing unnecessary gaming packages..."
rpm-ostree override remove \
    waydroid \
    waydroid-selinux \
    cage \
    wlr-randr \
    steam \
    lutris \
    sunshine \
    || true  # Continue même si certains packages n'existent pas

# Add your custom packages
echo "Installing custom packages..."
rpm-ostree install \
    gnome-tweaks

rpm-ostree install adw-gtk3-theme

## Installation of mandatory Gnome Extensions
rpm-ostree install gnome-shell-extension-dash-to-panel \
                   gnome-shell-extension-drive-menu

rpm-ostree override remove \
                   gnome-shell-extension-restart-to \
                   gnome-shell-extension-just-perfection \
                   gnome-shell-extension-blur-my-shell \
                   gnome-shell-extension-bazzite-menu \

# Remove Steam and Lutris from blocklist so they appear in Bazaar
sed -i '/com.valvesoftware.Steam/d' /usr/share/ublue-os/bazaar/blocklist.txt
sed -i '/net.lutris.Lutris/d' /usr/share/ublue-os/bazaar/blocklist.txt
sed -i '/dev.lizardbyte.app.Sunshine/d' /usr/share/ublue-os/bazaar/blocklist.txt


echo "MimOS customization complete!"
echo "Note: Some programs like Steam and Lutris have been removed. Users can install Flatpak versions."