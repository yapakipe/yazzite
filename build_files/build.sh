#!/bin/bash

set -ouex pipefail


install_packages() {
    local repo_name=$1
    local packages=$2[@]

    local packages_array=("${!packages}")

    echo "Installing packages from $repo_name repos: ${packages_array[*]}"
    dnf5 -y install ${packages_array[*]}
}

enable_services() {
    local repo_name=$1
    local services=$2[@]

    local services_array=("${!services}")

    echo "Enabling services installed from $repo_name repos: ${services_array[*]}"
    for service in ${services_array[@]}; do
        systemctl enable "$service"
    done
}

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

#
# Install Fedora packages
#

fedora_packages=("gparted" "blivet-gui")
install_packages "Fedora" fedora_packages

fedora_services=("podman.socket")
enable_services "Fedora" fedora_services

#
# Install Terra packages
#

terra_repo_path="/etc/yum.repos.d/terra.repo"
if ( ! grep -q "enabled=0" "$terra_repo_path" ); then  # if not matches found
    echo 'Terra Repository is already enabled, skipping.'
else
    echo 'Enabling Terra Repository.'
    sudo sed -i 's@enabled=0@enabled=1@g' "$terra_repo_path"
fi

terra_packages=("coolercontrol" "liquidctl")
install_packages "Terra" terra_packages

terra_services=("coolercontrold")
enable_services "Terra" terra_services

#
# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging