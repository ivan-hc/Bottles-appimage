### Unofficial AppImage of "Bottles", an app to run Windows software and games on Linux.
This repository creates and distributes the unofficial Appimage of [Bottles](https://usebottles.com/) built on top of JuNest (the lightweight Arch Linux based distro that runs, without root privileges, on top of any other Linux distro) and Debian Stable.

You can download it from https://github.com/ivan-hc/Bottles-appimage/releases/tag/continuous

This uses the more recent Type3 AppImage model, so you don't need `libfuse2` installed on your system.

# System requirements to run it
- `imagemagick` must be installed from your package manager
- `glibc` version of [Debian Stable](https://packages.debian.org/stable/source/glibc) or newer (so this should work well on newer distributions)

Jump to [Build requirements](build-requirements) if you wish to improve it... or keep read.

# How I've built it
This AppImage is a mix of two of my projects:
- [AppImaGen](https://github.com/ivan-hc/AppImaGen), from here I provided a base of packages from Debian Stable for better hardware compatibility;
- [ArchImage](https://github.com/ivan-hc/ArchImage), from here I've built the missing packages from the AUR, then merged with the base.

This is the hybrid AppImaGen/Archimage script I use to build Bottles:
- https://github.com/ivan-hc/Bottles-appimage/blob/main/bottles.sh

The first part (function "`_archimage`") is needed to compile the packages only available on the AUR (being Bottles only available as a official Flatpak and, for now, its still available in AUR, at https://aur.archlinux.org/packages/bottles ).

The second part uses [pkg2appimage](https://github.com/AppImageCommunity/pkg2appimage) to compile a base that gives the correct compatibility with the system's drivers, including old Nvidia GPUs.

This is because ArchImage is a Arch Linux container (named [JuNest](https://github.com/fsquillace/junest)) into an AppImage. Being this a container, it works isolated from the host system, so it can't see the host's drivers (so there is no hardware accelleration support in ArchImages).

However, only Bottles and few libraries are needed, the Debian base and the clasic AppImage scructure are a guarantee of compatibility.

# Build requirements
I've used Debian Stable as a base for the [pkg2appimage](https://github.com/AppImageCommunity/pkg2appimage)'s recipe because Bottles is built on the Python version available for Arch Linux that (for now) is the same (see [python](https://archlinux.org/packages/core/x86_64/python/)).

If you wish to made it work for Linux distros older but still supported, you need:
### on your side
- to know how to use [pkg2appimage](https://github.com/AppImageCommunity/pkg2appimage) or at least how to compile a newer version of Python on old distributions;
- to know the use of BASH scripting.

### on the software side
- Python version equal to the one available for Arch Linux in its official repository, being Bottles only available as AUR package;
- `libcurl` version updated to the one compiled for `pycurl` in Arch Linux (see [curl](https://archlinux.org/packages/core/x86_64/curl/)), also this must be in "`LD_PRELOAD`" to made it work over the one installed system wide. Or at least you need to compile `pycurl` by yourself by including the `openssl` support.

That said, just read and learn the [bottles.sh](https://github.com/ivan-hc/Bottles-appimage/blob/main/bottles.sh) script I wrote to understand the various steps. Each step has an "header" in English. If you wish, you can run it into a dedicated directory on your PC. In case of errors, just read the logs and try to understand what your system lacks to made it work.

If you want an idea on how the logs are, go to https://github.com/ivan-hc/Bottles-appimage/actions and read the workflows run.

## Inbuilt packages
- from Debian 12: ca-certificates, cabextract, curl, gamescope, libadwaita-1-dev, libcurl4, libffi-dev, libgtk-4-dev, libgtksourceview-5-dev, patool, python3, python3-chardet, python3-gi, python3-icoextract, python3-pathvalidate, python3-pycurl, python3-requests, python3-yaml
- from Arch Linux: "bottles" and "fvs" from (AUR), patool, python-steamgriddb, vkbasalt-cli, python-gobject, python-orjson, python-pycurl (for TLS support), /usr/share/glib-2.0/*, "setuptools" and "lib-dynload/_socket*" from /usr/lib/python*

---------------------------------
# Credits

- @mirkobrombin for all the patience and availability shown to me
- AppImaGen https://github.com/ivan-hc/AppImaGen
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
