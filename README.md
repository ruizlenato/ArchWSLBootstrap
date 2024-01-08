# Arch Linux WSL Bootstrap | [![Distro tar generator](https://github.com/ruizlenato/ArchWSLBootstrap/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/ruizlenato/ArchWSLBootstrap/actions/workflows/build.yml)
**A simple script that generates modified Arch Linux bootstraps to run on Windows Subsystem for Linux 2 (WSL2).**

## How do I install it?
**Make sure you have Windows Subsystem for Linux 2 (WSL2) correctly installed.**</br>
If you haven't installed WSL2, copy the following commands into powershell and restart your machine after you've finished: 
```sh
wsl --install --no-distribution
wsl --set-default-version 
```

After you have ensured that WSL2 is correctly installed and configured, just do the following:
```sh
wsl --import Arch path\to\virtualdisk path\to\archbootstrap.tar.gz
```
> Replace **path\to\virtualdisk** with the absolute path where you want to create the virtual hard disk of the distro and replace **path\to\archbootstrap.tar.gz** with the absolute path to the downloaded bootstrap.

**Exemple**: I particularly like to save inside the `C:\Users\MYUSER\AppData\Roaming\Arch` folder, so I run the following command: 
```sh
wsl --import Arch $env:LOCALAPPDATA\Arch $env:HOMEPATH\Downloads\ArchWSLBootstrap*.tar.gz
```
> `$env:HOMEPATH\Downloads` is the folder where the downloaded bootstrap is located and `$env:LOCALAPPDATA\Arch` is where the virtual hard disk of the distro will be created.

**Now you can run Arch Linux:** `wsl -d Arch`

## Setup after install
* To **create a new user** (already added to the wheel group) just run the following command:
```sh
useradd -m -G wheel {username}
```
> Replace **{username}** with the username you want.

* To **set the password for the root and the user created**
```sh
passwd
```
To **set up the password of the user you have created**, just use the command `passwd {username}`.

### To activate SystemD and set Arch's default user:
* To activate SystemD you need to change `false` to `true` in the `/etc/wsl.conf` file, like this:
```sh
[boot]
systemd=true
```
> You can use the following command which will do this automatically `sed -i -e "s/systemd=false/systemd=true/" /etc/wsl.conf`

* To set a default Arch user, you will also need to edit the `/etc/wsl.conf` file, just uncomment the `[user]` section and set your username after `default=`, **like this:**
```sh
[user]
default={username}
```
> Replace **{username}** with the username you want.

**You need root permission to edit the /etc/wsl.conf file**

