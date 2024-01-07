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
  wget http://linorg.usp.br/archlinux/iso/latest/archlinux-bootstrap-x86_64.tar.gz -q
  printf "\033[A\033[K"
  echo -e '\e[1;32m✓\e[m Arch Linux rootfs downloaded!'
  extract
}

extract() {
  echo -e '\e[1;33mExtracting Arch Linux rootfs\e[m'
  tar -zxvf archlinux-bootstrap-x86_64.tar.gz &>/dev/null
  printf "\033[A\033[K"
  echo -e '\e[1;32m✓\e[m Extract Arch Linux rootfs!'
  configure
}

configure() {
  echo -e '\e[1;33mSetting up a few basic things in bootstrap\e[m'
  sudo cp wsl.conf root.x86_64/etc/wsl.conf
  sudo cp bash_profile root.x86_64/root/.bash_profile
  sudo curl "https://archlinux.org/mirrorlist/?country=US&protocol=https&ip_version=4&use_mirror_status=on" &>/dev/null | cut -c 2- >root.x86_64/etc/pacman.d/mirrorlist
  printf "\033[A\033[K"
  echo -e '\e[1;32m✓\e[m Complete setup!'
  compress
}

compress() {
  echo -e '\e[1;33mBuilding bootstrap\e[m'

  sudo tar -czvf ArchWSLBootstrap.tar.gz -C root.x86_64 . &>/dev/null
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
