This repository creates and distributes the unofficial Appimage of [Bottles](https://usebottles.com/).

---------------------------------

## Disclaim
The official Bottles package is only available as a Flatpak.

All build methods are based on the unofficial AUR package, at https://aur.archlinux.org/packages/bottles

**Any complaints are due to this mental closure only!**

As a packager I can only go by what I upstream or unofficial developers gave to me.

---------------------------------

## Motivation
Developers and packagers are two completely opposite categories:
- the developer creates the program
- the packager bundles and distributes it (as deb, rpm, flatpak, snap, appimage...) for the platform of competence.

The developer certainly has an interest in seeing his application work everywhere, so if a package works or not on a platform, it is the responsibility of the packager to make it compatible.

The biggest obstacle in the Bottles project are some collaborators who, in order to support Flatpak as the only packaging format, give a firm NO to every request or proposal to use an alternative packaging format. Having met some of these arrogant people has served as an incentive to continue doing the opposite of what they said.

I thank the developer of Bottles, @mirkobrombin, for helping me build the AppImage after many attempts by telling me tips and tricks. Grazie Mirko!

---------------------------------

## Construction method
I have tried many times to allow non-Flatpak users to use Bottles in an alternative way, and not without difficulty.

At this time, the only method that works with certainty is via [Conty](https://github.com/Kron4ek/Conty):
- "Conty" project, at https://github.com/Kron4ek/Conty
- my fork, at https://github.com/ivan-hc/Conty

My fork can be used to try to reduce its size.

Currently, the AppImage I produced contains the following structure:
```
|---- AppRun
|---- com.usebottles.bottles.desktop
|---- com.usebottles.bottles.svg
|---- conty.sh
```
1. The AppRun is the core script of the AppImage
2. The .desktop file of Bottles
3. The icon of Bottles
4. The Arch Linux container named "conty.sh", it contains Bottles, WINE and grafic drivers

Points 1, 2 and 3 are the essential elements of any AppImage.

---------------------------------

## Why Conty?
Conty is a portable Arch Linux container with its own resources.

Its the only solution that installs its own copy of Nvidia drivers, if not available in the container itself (see picture below).

![running conty](https://github.com/user-attachments/assets/5038abc2-36c3-4891-ab0a-6da012b7b240)

The drivers are installed in the ~/.local/share/Conty directory and can take up to 700 MB of space.

Considering that Bottles, at first start, downloading the necessary libraries and creating profiles for WINE, reaches about 1.4 GB of space in ~/.local/share/bottles, I would say that the size is more than acceptable.

![disk usage](https://github.com/user-attachments/assets/73ccd625-9731-408e-ac7d-30f76fa81d55)

It's a bit like installing a Flatpak runtime. But only one. The rest of the files are stored in Conty itself.

---------------------------------

## Why Conty into an AppImage?
Wrapping Conty into an AppImage allows it to be isolated (via bubblewrap sandbox) using my package manager "[AM](https://github.com/ivan-hc/AM)".

This AppImage is a new generation one (Type3 AppImage), so you don't need `libfuse2` installed on your system to use it.

---------------------------------

## Download
You can download the AppImage from https://github.com/ivan-hc/Bottles-appimage/releases/tag/continuous

---------------------------------

## Previous alternative methods
Having few resources available is what pushed me to proceed by trial and error, more or less effective, within the limits of my possibilities.

The use of Conty is only the latest in a long series.

Old building scripts are available in the directories of this repository:
- "[legacy](https://github.com/ivan-hc/Bottles-appimage/tree/main/legacy)" contains experimental scripts to build the AppImage on top of JuNest, but it lack of hardware accelleration (see https://github.com/ivan-hc/ArchImage/issues/20)
- "[hybrid](https://github.com/ivan-hc/Bottles-appimage/tree/main/hybrid)" was the one that worked thanks to a mix between my two projects [AppImaGen](https://github.com/ivan-hc/AppImaGen) and [ArchImage](https://github.com/ivan-hc/ArchImage), a mix of Arch Linux and Debian packages. It worked only for newer distros and until newer changes into an assential Arch Linux package (python) that was not good to keep maintain this method. Its still possible to download the only available release son of this method, at https://github.com/ivan-hc/Bottles-appimage/releases/tag/51.11-2

---------------------------------

## Known issues
The AppImage is 1,2 GB of size due to the internal Conty script that can't be compressed, being itself a filesystem, like the AppImage that contains it. If you want to reduce size, go to https://github.com/ivan-hc/Conty and help me improve my fork. 

---------------------------------

## Credits

- @mirkobrombin for all the patience and availability shown to me
- Conty https://github.com/Kron4ek/Conty

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
