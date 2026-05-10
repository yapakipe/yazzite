#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y \
    gparted \
    blivet-gui


# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket

#
# Terra packages
#

terra_repo_path="/etc/yum.repos.d/terra.repo"
if ( ! grep -q "enabled=0" "$terra_repo_path" ); then  # if not matches found
    echo 'Terra Repository is already enabled, skipping.'
else
    echo 'Enabling Terra Repository.'
    sudo sed -i 's@enabled=0@enabled=1@g' "$terra_repo_path"
fi

terra_packages=("coolercontrol" "liquidctl")
echo "Installing: ${packages[*]}"
dnf5 -y install ${packages[*]}

terra_services=("coolercontrold")
echo "Enabling services: ${terra_services[*]}"
for service in ${terra_services[@]}; do
    systemctl enable "$service"
done