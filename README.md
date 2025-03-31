This repository creates and distributes the unofficial Appimage of [Bottles](https://usebottles.com/).

This AppImage is a new generation one, so you don't need `libfuse2` installed on your system to use it.

![Istantanea_2024-02-28_14-48-48 png](https://github.com/Portable-Linux-Apps/Portable-Linux-Apps.github.io/assets/88724353/b710774a-b412-439d-a90c-db576db3ce12)

---------------------------------
# INDEX

[Disclaim](#disclaim)

[Motivation](#motivation)

[Construction methods](#construction-methods)
 - [JuNest](#junest)
 - [Conty (old method)](#conty)

[Download](#download)

[Troubleshot](#troubleshot)

[Credits](#credits)

[Install and update it with ease](#install-and-update-it-with-ease)

---------------------------------
## Disclaim
The official Bottles package is only available as a Flatpak.

All build methods are based on the unofficial AUR package, at https://aur.archlinux.org/packages/bottles

**As a packager I can only go by what I upstream or unofficial developers gave to me.**

---------------------------------

## Motivation
Developers and packagers are two completely opposite categories:
- the developer creates the program
- the packager bundles and distributes it (as deb, rpm, flatpak, snap, appimage...) for the platform of competence.

The developer certainly has an interest in seeing his application work everywhere, so if a package works or not on a platform, it is the responsibility of the packager to make it compatible.

The biggest obstacle in the Bottles project are some collaborators who, in order to support Flatpak as the only packaging format, give a firm NO to every request or proposal to use an alternative packaging format. Having met some of them has served as an incentive to continue doing the opposite of what they said.

I thank the developer of Bottles, @mirkobrombin, for helping me build the AppImage after many attempts by telling me tips and tricks. Grazie Mirko!

---------------------------------

## Construction methods
I have tried many times to allow non-Flatpak users to use Bottles in an alternative way, and not without difficulty.

There are currently two main methods supported in this repository, and both are based on a portable Arch Linux containers: [JuNest](https://github.com/fsquillace/junest) and [Conty](https://github.com/Kron4ek/Conty)

**As of January 26, 2025, JuNest has replaced Conty as the base.** In short:
- to compile Conty you need root privileges, in case of errors you have to repeat the whole process from the beginning and cleaning up unnecessary files is much more difficult. You can extract the container, but you can't test the changes on the fly nor can you regroup it easily.
- on the contrary, JuNest is a rootless solution, in case of errors while compiling you can resume from a specific point, finally, you can choose to include everything or only what is necessary. The final AppImages are therefore smaller and easier to analyze, as well as quick to extract and repackage in a few seconds.

Between the two, the most powerful solution is definitely Conty, but it is not suitable to be assembled in an AppImage, also because Conty is a real filesystem, like AppImages, and the result is that the application is mounted twice. JuNest is lighter and more flexible instead.

---------------------------------

### JuNest

JuNest, at https://github.com/fsquillace/junest, is an Arch Linux container that can integrate with the host system using three modes: BubbleWrap (uses Linux Namespaces), PROOT (the most portable) and CHROOT.

JuNest is the basis of the Archimage project, as its scripts exploit the flexibility of JuNest by searching, selecting and importing into the final package only what the user has decided.

Archimages allow the use of the AppImage package even on systems with Namespace restrictions, such as Ubuntu, thanks to its AppRun, able to start the application with BubbleWrap or PROOT, depending on the need.

The content of an Archimage resembles a $HOME directory
```
|---- AppRun
|---- com.usebottles.bottles.desktop
|---- com.usebottles.bottles.svg
|---- .local
|---- .junest
```

1. The AppRun is the core script of the AppImage
2. The .desktop file of Bottles
3. The icon of Bottles
4. Directories .local and .junest are hidden.

Points 1, 2 and 3 are the essential elements of any AppImage.

The directory named ".junest" contains the structure of the Arch Linux filesystem, or better, that part needed to made the app working as it should.

JuNest is unmatched in flexibility, as you can extract the AppImage and remove files, or add new ones, simply by extracting an Arch Linux package into the .junest directory, then running the AppRun. And when you're done testing, you can export the directory back into an AppImage. The support for hardware acceleration in Archimages instead is also thanks to the developer of Conty, who contributed a lot too. In fact, both Conty and Archimage can share the same directory for drivers.

**For more details on how to create your own Archimages, visit https://github.com/ivan-hc/ArchImage**

---------------------------------

### Conty

Conty, at https://github.com/Kron4ek/Conty, has long been the primary method for creating Bottles and Steam AppImage packages. Its replacement occurred only because it is less easy to manage, both as a simple AppImage and as an application in itself, to be "shrinked". But if you want to use it as an alternative to an AppImage, it is a great independent solution.

<details>
  <summary>Click here to know more about the Conty-based AppImage</summary>

While JuNest is just a set of files, Conty is a full-fledged filesystem, and requires root privileges to build, ensuring its security **for its use case**.

On the contrary of JuNest, Conty has builtin functions able to recognize and compile Nvidia drivers on the fly if a user needs them.

This is the content of a Conty-based AppImage:
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

The script "conty.sh" (4) is the big one among the elements of this AppImage.

</details>

---------------------------------

## Download
You can download the latest AppImage from https://github.com/ivan-hc/Bottles-appimage/releases/latest

---------------------------------

## Troubleshot

### ◆ Add programs to the desktop / `bottles-cli` usage
Create a symlink "`bottles-cli`" for this Appimage and add it to a $PATH, so when you add a program to the desktop you will be able to launch it from the menu with the related icon. This feature is already available if you install "bottles" using "AM" and "AppMan".

---------------------------------

## Credits

- @mirkobrombin for all the patience and availability shown to me
- JuNest https://github.com/fsquillace/junest
- Conty https://github.com/Kron4ek/Conty

------------------------------------------------------------------------

## Install and update it with ease

### *"*AM*" Application Manager* 
#### *Package manager, database & solutions for all AppImages and portable apps for GNU/Linux!*

[![Istantanea_2024-06-26_17-00-46 png](https://github.com/ivan-hc/AM/assets/88724353/671f5eb0-6fb6-4392-b45e-af0ea9271d9b)](https://github.com/ivan-hc/AM)

[![Readme](https://img.shields.io/github/stars/ivan-hc/AM?label=%E2%AD%90&style=for-the-badge)](https://github.com/ivan-hc/AM/stargazers) [![Readme](https://img.shields.io/github/license/ivan-hc/AM?label=&style=for-the-badge)](https://github.com/ivan-hc/AM/blob/main/LICENSE)

*"AM"/"AppMan" is a set of scripts and modules for installing, updating, and managing AppImage packages and other portable formats, in the same way that APT manages DEBs packages, DNF the RPMs, and so on... using a large database of Shell scripts inspired by the Arch User Repository, each dedicated to an app or set of applications.*

*The engine of "AM"/"AppMan" is the "APP-MANAGER" script which, depending on how you install or rename it, allows you to install apps system-wide (for a single system administrator) or locally (for each user).*

*"AM"/"AppMan" aims to be the default package manager for all AppImage packages, giving them a home to stay.*

*You can consult the entire **list of managed apps** at [**portable-linux-apps.github.io/apps**](https://portable-linux-apps.github.io/apps).*

## *Go to *https://github.com/ivan-hc/AM* for more!*

------------------------------------------------------------------------

| [***Install "AM"***](https://github.com/ivan-hc/AM) | [***See all available apps***](https://portable-linux-apps.github.io) | [***Support me on ko-fi.com***](https://ko-fi.com/IvanAlexHC) | [***Support me on PayPal.me***](https://paypal.me/IvanAlexHC) |
| - | - | - | - |

------------------------------------------------------------------------

