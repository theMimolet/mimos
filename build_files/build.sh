#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

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
    || true

### Clear any caches ###
rm -rf /var/cache/bazaar || true
rm -rf /var/cache/flatpak || true

# Remove Steam files
rm -rf /usr/bin/steam* || true
rm -rf /usr/bin/bazzite-steam* || true
rm -rf /usr/share/applications/steam*.desktop || true
rm -rf /usr/lib/steam || true
rm -rf /etc/skel/.config/autostart/steam.desktop || true
rm -rf /etc/xdg/autostart/steam.desktop || true

# Remove Lutris files
rm -rf /usr/bin/lutris* || true
rm -rf /usr/share/applications/*lutris*.desktop || true
rm -rf /usr/share/lutris || true

# Remove Waydroid files
rm -rf /usr/bin/waydroid* || true
rm -rf /usr/share/applications/Waydroid || true
rm -rf /usr/share/applications/waydroid*.desktop || true
rm -rf /usr/share/waydroid || true
rm -rf /usr/lib/waydroid || true


rm -rf /usr/share/applications/discourse.desktop || true

# Add your custom packages
echo "Installing custom packages..."
dnf5 install -y adw-gtk3-theme gnome-tweaks

## Installation of mandatory Gnome Extensions
echo "Installing gnome extensions..."
dnf5 install -y  gnome-shell-extension-dash-to-panel \
                   gnome-shell-extension-drive-menu

echo "Removing unnecessary gnome extensions..."
rpm-ostree override remove \
                   gnome-shell-extension-restart-to \
                   gnome-shell-extension-just-perfection \
                   gnome-shell-extension-blur-my-shell \
                   gnome-shell-extension-bazzite-menu \

# Remove Steam and Lutris from blocklist so they appear in Bazaar
#echo "Unblocking gaming software from Bazaar..."
#sed -i '/com.valvesoftware.Steam/d' /usr/share/ublue-os/bazaar/blocklist.txt
#sed -i '/net.lutris.Lutris/d' /usr/share/ublue-os/bazaar/blocklist.txt
#sed -i '/dev.lizardbyte.app.Sunshine/d' /usr/share/ublue-os/bazaar/blocklist.txt

### Modify Bazaar blocklist ###
echo "Modifying Bazaar blocklist..."

# Show before
echo "BEFORE:"
cat /usr/share/ublue-os/bazaar/blocklist.txt | grep -E "(Steam|Lutris)" || echo "No Steam/Lutris found"

# Remove from blocklist
sed -i '/com.valvesoftware.Steam/d' /usr/share/ublue-os/bazaar/blocklist.txt
sed -i '/net.lutris.Lutris/d' /usr/share/ublue-os/bazaar/blocklist.txt

# Show after
echo "AFTER:"
cat /usr/share/ublue-os/bazaar/blocklist.txt | grep -E "(Steam|Lutris)" || echo "Steam/Lutris removed from blocklist!"


echo "MimOS customization complete!"
echo "Note: Some programs like Steam and Lutris have been removed. Users can install the Flatpak versions."