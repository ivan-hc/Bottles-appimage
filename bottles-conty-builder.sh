#!/bin/sh

set -u
APP=bottles

# CREATE A TEMPORARY DIRECTORY
mkdir -p tmp && cd tmp || exit 1

# DOWNLOADING APPIMAGETOOL
if test -f ./appimagetool; then
	echo " appimagetool already exists" 1> /dev/null
else
	echo " Downloading appimagetool..."
	wget -q https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage -O appimagetool
fi
chmod a+x ./appimagetool

# CREATE AND ENTER THE APPDIR
mkdir -p "$APP".AppDir && cd "$APP".AppDir || exit 1

# ICON
if ! test -f ./*.svg; then
	wget -q https://raw.githubusercontent.com/bottlesdevs/Bottles/main/data/icons/hicolor/scalable/apps/com.usebottles.bottles.svg
fi

# LAUNCHER
echo "[Desktop Entry]
Name=Bottles
Comment=Run Windows Software
Icon=com.usebottles.bottles
Exec=AppRun
TryExec=bottles
Terminal=false
Type=Application
Categories=Utility;GNOME;GTK;
StartupNotify=true
StartupWMClass=bottles
MimeType=x-scheme-handler/bottles;application/x-ms-dos-executable;application/x-msi;application/x-ms-shortcut;application/x-wine-extension-msp;
Keywords=wine;windows;
X-GNOME-UsesNotifications=true" > com.usebottles.bottles.desktop

# APPRUN
rm -f ./AppRun
cat >> ./AppRun << 'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "${0}")")"
export UNION_PRELOAD="${HERE}"
case "$1" in
	'') "${HERE}"/conty.sh -- bottles;;
	*) "${HERE}"/conty.sh -- bottles-cli "$@";;
esac
EOF
chmod a+x ./AppRun

# DOWNLOAD CONTY
if ! test -f ./*.sh; then
	conty_download_url=$(curl -Ls https://api.github.com/repos/ivan-hc/Conty/releases | sed 's/[()",{} ]/\n/g' | grep -oi "https.*bottles.*sh$" | head -1)
	echo " Downloading Conty..."
	if wget --version | head -1 | grep -q ' 1.'; then
		wget -q --no-verbose --show-progress --progress=bar "$conty_download_url"
	else
		wget "$conty_download_url"
	fi
	chmod a+x ./conty.sh
fi

# EXIT THE APPDIR
cd .. || exit 1

# EXPORT THE APPDIR TO AN APPIMAGE
VERSION=$(curl -Ls https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=bottles | grep "^pkgver=" | cut -c 8-)
ARCH=x86_64 ./appimagetool --comp zstd --mksquashfs-opt -Xcompression-level --mksquashfs-opt 1 \
	-u "gh-releases-zsync|$GITHUB_REPOSITORY_OWNER|Bottles-appimage|continuous|*x86_64.AppImage.zsync" \
	./"$APP".AppDir ./Bottles-"$VERSION"-x86_64.AppImage
cd .. && mv ./tmp/*.AppImage* ./ || exit 1

