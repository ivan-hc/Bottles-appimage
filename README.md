Unofficial AppImage of "Bottles", an app to run Windows software and games on Linux, built on top of JuNest.

This is not ready jet, needs to be studied to made it work normally. Until then, rely on the official Flatpak.

# How to improve this AppImage
1. Download the last release from https://github.com/ivan-hc/Bottles-appimage/releases
2. Extract the AppImage
```
./*AppImage --appimage-extract
cd ./squashfs-root
```
3. Edit the AppRun and test it until the app will work for you. To test the AppRun do
```
./AppRun
```
# Credits
This repository creates and distributes the unofficial Appimage of Bottles built on top of JuNest (the lightweight Arch Linux based distro that runs, without root privileges, on top of any other Linux distro).

- JuNest https://github.com/fsquillace/junest
- ArchImage https://github.com/ivan-hc/ArchImage

# Sources
This "ArchImage" is built from AUR, package's source at https://aur.archlinux.org/packages/bottles
