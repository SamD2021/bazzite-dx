#!/bin/bash

set -ouex pipefail

### Setup things
echo -e '[composefs]\nenabled = yes\n\n[root]\ntransient = true' >/usr/lib/ostree/prepare-root.conf && ostree container commit

mkdir -p /nix && ostree container commit

curl -Lo /etc/yum.repos.d/_copr_ryanabx-cosmic.repo "https://copr.fedorainfracloud.org/coprs/ryanabx/cosmic-epoch/repo/fedora-$(rpm -E %fedora)/ryanabx-cosmic-epoch-fedora-$(rpm -E %fedora).repo" &&
  curl -Lo /etc/yum.repos.d/_copr_sneexy-zen-browser.repo "https://copr.fedorainfracloud.org/coprs/sneexy/zen-browser/repo/fedora-$(rpm -E %fedora)/sneexy-zen-browsder-fedora-$(rpm -E %fedora).repo" &&
  ostree container commit

rpm --import https://repo.cider.sh/RPM-GPG-KEY &&
  cat >/etc/yum.repos.d/cider.repo <<'EOF'
[cidercollective]
name=Cider Collective Repository
baseurl=https://repo.cider.sh/rpm/RPMS
enabled=1
gpgcheck=1
gpgkey=https://repo.cider.sh/RPM-GPG-KEY
EOF

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y screen \
  zsh \
  cosmic-desktop \
  kitty \
  virt-manager \
  neovim \
  nmap \
  blueman \
  pasystray \
  network-manager-applet \
  pcsc-lite \
  Cider

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
systemctl disable sddm && systemctl enable cosmic-greeter && ostree container commit
