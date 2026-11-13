#!/bin/bash

set -ouex pipefail

#
### Get and display version
#

echo_major_version_number() {
    local major_version_number="$(sh -c '. /usr/lib/os-release ; echo $VERSION_ID')"
    echo $major_version_number
}

MAJOR_VERSION_NUMBER=$(echo_major_version_number)
echo "MAJOR_VERSION_NUMBER: $MAJOR_VERSION_NUMBER"

#
### Functions
#

install_packages() {
    local repo_name=$1
    local packages=$2[@]

    local packages_array=("${!packages}")

    echo "Installing packages from $repo_name repos: ${packages_array[*]}"
    dnf5 -y install ${packages_array[*]}
}

install_packages_enable_repo() {
    local repo_name=$1
    local packages=$2[@]

    local packages_array=("${!packages}")

    echo "Installing packages from $repo_name repos: ${packages_array[*]}"
    dnf5 --enable-repo=$repo_name -y install ${packages_array[*]}
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

install_packages_and_services() {
    local repo_name=$1
    local packages=$2[@]
    local services=$3[@]

    local packages_array=("${!packages}")
    local services_array=("${!services}")

    install_packages $repo_name packages_array
    enable_services $repo_name services_array
}

install_fedora_packages() {
    local fedora_packages=("gparted" "blivet-gui" "android-file-transfer" "clamav" "clamav-freshclam" "toolbox")
    local fedora_services=("podman.socket")
    install_packages_and_services "fedora" fedora_packages fedora_services
}

install_docker_packages() {
    # Code copied from bazzite-dx's 20-install-apps.sh

    local docker_repo="docker-ce-stable"

    dnf5 config-manager addrepo --from-repofile="https://download.docker.com/linux/fedora/docker-ce.repo"
    dnf5 config-manager setopt ${docker_repo}.enabled=0

    local docker_packages=(
        containerd.io
        docker-buildx-plugin
        docker-ce
        docker-ce-cli
        docker-compose-plugin
    )
    install_packages_enable_repo "${docker_repo}" docker_packages

    local docker_services=("docker.socket")
    enable_services "${docker_repo}" docker_services
}

#
# List available repos - helps figuring out why things don't work during a build...
#
list_repos() {
    echo
    echo Repos short list:
    dnf5 repo list
    echo
    echo Repos details:
    dnf5 repo info
    echo
    echo Contents of /etc/yum.repos.d/:
    ls -l /etc/yum.repos.d/
    echo
}

add_fusion_repos() {
    dnf5 -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
    dnf5 -y install rpmfusion-free-release-tainted
}

install_vlc_packages() {
    dnf5 -y install libbluray libaacs vlc ffmpeg vlc-plugins-base vlc-plugin-ffmpeg vlc-plugins-all libdvdcss vlc-plugins-extra

    # Uninstall VLC flatpak if present
    flatpak uninstall -y org.videolan.VLC || true
}

#
# Copy the contents of system_files/ of the git repo to /
#

cp -avf "/ctx/system_files"/. /

#
# Setup repos
#

echo === Initial repos ===
list_repos

add_fusion_repos

echo === Update repos ===
list_repos

#
### Install packages
#

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1


install_fedora_packages
install_docker_packages
install_vlc_packages

#
# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging
