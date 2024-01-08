echo -e '\e[1;33mInitializing keyring\e[m'
pacman-key --init
pacman-key --populate archlinux
pacman -Syu
pacman -S base
clear

echo -e '\e[1;33mInstalling reflector to get fastest mirrors\e[m'
pacman -Sy reflector --noconfirm
clear

echo -e '\e[1;33mSetting up the best mirros with reflector\e[m'
reflector --latest 10 --protocol http,https --sort rate --save /etc/pacman.d/mirrorlist
clear

echo -e '\e[1;33mUpdating the system base\e[m'
pacman -Rns reflector --noconfirm
pacman -Syu --noconfirm
yes | pacman -Sccc
rm /root/.bash_profile
clear
echo -e '\e[1;32mAll done.\e[m'