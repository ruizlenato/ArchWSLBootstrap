#!/usr/bin/env bash

# Copyright (C) 2024 Luiz Renato
# SPDX-License-Identifier: GPL-3.0-only

# Clear shell
clear

# Dependency check
if ! dpkg -s wget >/dev/null 2>&1; then
  sudo apt-get install get
fi

start() {
  echo -e '\e[1;31mBuilding bootstrap\e[m'
  download
}

download() {
  echo -e '\e[1;33mDownloading Arch Linux rootfs\e[m'
  wget https://mirrors.edge.kernel.org/archlinux/iso/latest/archlinux-bootstrap-x86_64.tar.gz -q
  printf "\033[A\033[K"
  echo -e '\e[1;32m✓\e[m Arch Linux rootfs downloaded!'
  extract
}

extract() {
  echo -e '\e[1;33mExtracting Arch Linux rootfs\e[m'
  sudo tar --xattrs --xattrs-include="security.capability" -zxpf archlinux-bootstrap-x86_64.tar.gz &>/dev/null
  printf "\033[A\033[K"
  echo -e '\e[1;32m✓\e[m Extract Arch Linux rootfs!'
  configure
}

configure() {
  echo -e '\e[1;33mSetting up a few basic things in bootstrap\e[m'
  sudo curl "https://archlinux.org/mirrorlist/?country=US&protocol=https&ip_version=4" -o root.x86_64/etc/pacman.d/mirrorlist &>/dev/null
  sudo sed -i -e "s/#Server/Server/g" root.x86_64/etc/pacman.d/mirrorlist
  sudo cp wsl.conf root.x86_64/etc/wsl.conf
  sudo cp bash_profile root.x86_64/root/.bash_profile
  sudo sed -i -e "s/#en_US.UTF-8/en_US.UTF-8/" root.x86_64/etc/locale.gen
  echo "LANG=en_US.UTF-8" | sudo tee root.x86_64/etc/locale.conf
  sudo ln -sf /etc/locale.conf root.x86_64/etc/default/locale
  sudo rm -rf root.x86_64/etc/resolv.conf
  echo "# This file was automatically generated by WSL." | sudo tee root.x86_64/etc/resolv.conf
  printf "\033[A\033[K"
  echo -e '\e[1;32m✓\e[m Complete setup!'
  compress
}

compress() {
  echo -e '\e[1;33mBuilding bootstrap\e[m'
  sudo tar --xattrs --xattrs-include="security.capability" -zcpf ArchWSLBootstrap-$(date -u +%Y-%m-%d).tar.gz -C root.x86_64 .
  sudo chown root:root ArchWSLBootstrap-$(date -u +%Y-%m-%d).tar.gz
  printf "\033[A\033[K"
  echo -e '\e[1;32m✓\e[m Building bootstrap!'
  cleanup
}

cleanup() {
  sudo rm -rf archlinux-bootstrap-x86_64.tar.gz root.x86_64/
  clear
  echo -e '\e[1;32mAll done.\e[m'
}

start
