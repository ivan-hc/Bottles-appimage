### Unofficial AppImage of "Bottles", an app to run Windows software and games on Linux.

This repository creates and distributes the unofficial Appimage of Bottles built on top of JuNest (the lightweight Arch Linux based distro that runs, without root privileges, on top of any other Linux distro) and Debian Stable.


# How I've built it
This AppImage is a mix of two of my projects:
- AppImaGen, from here I provided a base of packages from Debian Stable for better hardware compatibility;
- ArchImage, from here I've built the missing packages from the AUR, then merged with the base.

This is the hybrid AppImaGen/Archimage script I use to build Bottles:
- https://github.com/ivan-hc/Bottles-appimage/blob/main/bottles.sh

In brief, I've used JuNest (Arch Linux) only to compile the few essential packages, including Bottles itself (from [here](https://aur.archlinux.org/packages/bottles)), then a classic AppImage construction as a Base gives the correct compatibility with the system's drivers, including old Nvidia GPUs.

---------------------------------

# Credits

- @mirkobrombin for all the patience and availability shown to me
- ArchImaGen https://github.com/ivan-hc/AppImaGen
- JuNest https://github.com/fsquillace/junest
- ArchImage https://github.com/ivan-hc/ArchImage

---------------------------------

## Install and update it with ease

I wrote two bash scripts to install and manage the applications: [AM](https://github.com/ivan-hc/AM-Application-Manager) and [AppMan](https://github.com/ivan-hc/AppMan). Their dual existence is based on the needs of the end user.

| [**"AM" Application Manager**](https://github.com/ivan-hc/AM-Application-Manager) |
| -- |
| <sub>***If you want to install system-wide applications on your GNU/Linux distribution in a way that is compatible with [Linux Standard Base](https://refspecs.linuxfoundation.org/lsb.shtml) (all third-party apps must be installed in dedicated directories under `/opt` and their launchers and binaries in `/usr/local/*` ...), just use ["AM" Application Manager](https://github.com/ivan-hc/AM-Application-Manager). This app manager requires root privileges only to install / remove applications, the main advantage of this type of installation is that the same applications will be available to all users of the system.***</sub>
[![Readme](https://img.shields.io/github/stars/ivan-hc/AM-Application-Manager?label=%E2%AD%90&style=for-the-badge)](https://github.com/ivan-hc/AM-Application-Manager/stargazers) [![Readme](https://img.shields.io/github/license/ivan-hc/AM-Application-Manager?label=&style=for-the-badge)](https://github.com/ivan-hc/AM-Application-Manager/blob/main/LICENSE)

| [**"AppMan"**](https://github.com/ivan-hc/AppMan)
| --
| <sub>***If you don't want to put your app manager in a specific path but want to use it portable and want to install / update / manage all your apps locally, download ["AppMan"](https://github.com/ivan-hc/AppMan) instead. With this script you will be able to decide where to install your applications (at the expense of a greater consumption of resources if the system is used by more users). AppMan is portable, all you have to do is write the name of a folder in your `$HOME` where you can install all the applications available in [the "AM" database](https://github.com/ivan-hc/AM-Application-Manager/tree/main/programs), and without root privileges.***</sub>
[![Readme](https://img.shields.io/github/stars/ivan-hc/AppMan?label=%E2%AD%90&style=for-the-badge)](https://github.com/ivan-hc/AppMan/stargazers) [![Readme](https://img.shields.io/github/license/ivan-hc/AppMan?label=&style=for-the-badge)](https://github.com/ivan-hc/AppMan/blob/main/LICENSE)
