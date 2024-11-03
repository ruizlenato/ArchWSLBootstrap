#!/usr/bin/env bash
# Copyright (C) 2024 Luiz Renato
# SPDX-License-Identifier: GPL-3.0-only

# Script configuration
readonly ROOTFS_URL="https://mirror.rackspace.com/archlinux/iso/latest/archlinux-bootstrap-x86_64.tar.zst"
readonly ROOTFS_FILE="archlinux-bootstrap-x86_64.tar.zst"
readonly ROOTFS_DIR="root.x86_64"
readonly PKGLIST_FILE="pkglist.x86_64.txt"
readonly OUTPUT_FILE="ArchWSLBootstrap-$(date -u +%Y-%m-%d).tar.gz"

# Color codes
readonly RED='\e[1;31m'
readonly GREEN='\e[1;32m'
readonly YELLOW='\e[1;33m'
readonly NC='\e[m' # No Color

clear

# Dependency check
check_dependencies() {
        local deps=("wget" "zstd")
        for dep in "${deps[@]}"; do
                if ! dpkg -s "$dep" >/dev/null 2>&1; then
                        sudo apt-get install -y "$dep"
                fi
        done
}

start() {
        check_dependencies
        echo -e "${RED}Building bootstrap${NC}"
        download
}

download() {
        echo -e "${YELLOW}Downloading Arch Linux rootfs${NC}"
        wget "$ROOTFS_URL" -q
        printf "\033[A\033[K"
        echo -e "${GREEN}✓${NC} Arch Linux rootfs downloaded!"
        extract
}

extract() {
        echo -e "${YELLOW}Extracting Arch Linux rootfs${NC}"
        sudo tar --xattrs --xattrs-include="security.capability" -I zstd -xpf "$ROOTFS_FILE" &>/dev/null
        printf "\033[A\033[K"
        echo -e "${GREEN}✓${NC} Extract Arch Linux rootfs!"
        configure
}

clean_pacman_cache() {
        yes | sudo chroot "$ROOTFS_DIR" /usr/bin/pacman -Scc &>/dev/null
}

update_mirrorlist() {
        sudo curl "https://archlinux.org/mirrorlist/?country=US&protocol=https&ip_version=4" \
                -o "$ROOTFS_DIR/etc/pacman.d/mirrorlist" &>/dev/null
        sudo sed -i -e "s/#Server/Server/g" "$ROOTFS_DIR/etc/pacman.d/mirrorlist"
}

update_system() {
        sudo cp -f /etc/resolv.conf "$ROOTFS_DIR/etc/resolv.conf"
        sudo chroot "$ROOTFS_DIR" /usr/bin/pacman -Syu --noconfirm &>/dev/null
}

setup_locale() {
        sudo sed -i -e "s/#en_US.UTF-8/en_US.UTF-8/" "$ROOTFS_DIR/etc/locale.gen"
        sudo sh -c 'echo "LANG=en_US.UTF-8" > "$ROOTFS_DIR/etc/locale.conf"'
        sudo ln -sf /etc/locale.conf "$ROOTFS_DIR/etc/default/locale"
}

setup_network() {
        sudo rm -rf "$ROOTFS_DIR/etc/resolv.conf"
        sudo sh -c 'echo "LANG=en_US.UTF-8" > "$ROOTFS_DIR/etc/locale.conf"'
        sudo cp -f /etc/resolv.conf "$ROOTFS_DIR/etc/resolv.conf"
}

copy_config_files() {
        sudo cp wsl.conf "$ROOTFS_DIR/etc/wsl.conf"
        sudo cp bash_profile "$ROOTFS_DIR/root/.bash_profile"
}

cleanup_system_files() {
        local files=(
                "/etc/machine-id"
                "/usr/lib/systemd/system/sysinit.target.wants/systemd-firstboot.service"
        )

        for file in "${files[@]}"; do
                sudo rm -rf "${ROOTFS_DIR}${file}"
        done
}

configure() {
        echo -e "${YELLOW}Setting up a few basic things in bootstrap${NC}"

        clean_pacman_cache
        update_mirrorlist
        copy_config_files
        setup_locale
        setup_network
        cleanup_system_files
        update_system

        printf "\033[A\033[K"
        echo -e "${GREEN}✓${NC} Complete setup!"
        compress
        cleanup
}

compress() {
        echo -e "${YELLOW}Building bootstrap${NC}"
        sudo tar --xattrs --xattrs-include="security.capability" \
                -zcpf "$OUTPUT_FILE" -C "$ROOTFS_DIR" .
        sudo chown root:root "$OUTPUT_FILE"
        printf "\033[A\033[K"
        echo -e "${GREEN}✓${NC} Building bootstrap!"
}

cleanup() {
        sudo rm -rf "$ROOTFS_FILE" "$ROOTFS_DIR" "$PKGLIST_FILE"
        echo -e "${GREEN}All done.${NC}"
}

start