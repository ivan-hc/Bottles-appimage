#!/usr/bin/env bash

APP=bottles

# CREATE A TEMPORARY DIRECTORY
mkdir -p tmp
cd tmp

function _archimage(){
	DEPENDENCES="fvs"
	BASICSTUFF="binutils gzip"
	COMPILERS="meson ninja blueprint-compiler"
	if ! test -f ./appimagetool; then
		wget -q https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage -O appimagetool
		chmod a+x appimagetool
	fi
	mkdir archlinux-junest
	cd archlinux-junest
	# SET APPDIR AS A TEMPORARY $HOME DIRECTORY, THIS WILL DO ALL WORK INTO THE APPDIR
	HOME="$(dirname "$(readlink -f $0)")" 
	# DOWNLOAD AND INSTALL JUNEST (DON'T TOUCH THIS)
	git clone https://github.com/fsquillace/junest.git ~/.local/share/junest
	wget -q --show-progress https://github.com/ivan-hc/junest/releases/download/continuous/junest-x86_64.tar.gz
	./.local/share/junest/bin/junest setup -i junest-x86_64.tar.gz
	rm -f junest-x86_64.tar.gz
	# ENABLE MULTILIB (optional)
	echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> ./.junest/etc/pacman.conf
	# CUSTOM MIRRORLIST
	rm -R ./.junest/etc/pacman.d/mirrorlist
	wget -q https://archlinux.org/mirrorlist/all/ -O - | awk NR==2 RS= | sed 's/#Server/Server/g' >> ./.junest/etc/pacman.d/mirrorlist # ENABLES WORLDWIDE MIRRORS
	# BYPASS SIGNATURE CHECK LEVEL
	sed -i 's/#SigLevel/SigLevel/g' ./.junest/etc/pacman.conf
	sed -i 's/Required DatabaseOptional/Never/g' ./.junest/etc/pacman.conf
	# UPDATE ARCH LINUX IN JUNEST
	./.local/share/junest/bin/junest -- sudo pacman -Syy
	./.local/share/junest/bin/junest -- sudo pacman --noconfirm -Syu
	# INSTALL THE PROGRAM USING YAY
	./.local/share/junest/bin/junest -- yay -Syy
	./.local/share/junest/bin/junest -- gpg --keyserver keyserver.ubuntu.com --recv-key C01E1CAD5EA2C4F0B8E3571504C367C218ADD4FF # UNCOMMENT IF YOU USE THE AUR
	./.local/share/junest/bin/junest -- yay --noconfirm -S gnu-free-fonts $(echo "$BASICSTUFF $COMPILERS $DEPENDENCES $APP-git")
	echo y | ./.local/share/junest/bin/junest -- yay --answerclean All --answerdiff All --noconfirm -Sa $APP-git patool
	cd ..
}

if ! test -d ./archlinux-junest; then
	_archimage
fi

# DOWNLOADING THE DEPENDENCIES
if test -f ./appimagetool; then
	echo " appimagetool already exists" 1> /dev/null
else
	echo " Downloading appimagetool..."
	wget -q https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage -O appimagetool
fi
if test -f ./pkg2appimage; then
	echo " pkg2appimage already exists" 1> /dev/null
else
	echo " Downloading pkg2appimage..."
	wget -q https://raw.githubusercontent.com/ivan-hc/AM-application-manager/main/tools/pkg2appimage
fi
chmod a+x ./appimagetool ./pkg2appimage
rm -f ./recipe.yml

# CREATING THE HEAD OF THE RECIPE
cat >> recipe.yml << 'EOF'
app: bottles
binpatch: true

ingredients:

  dist: stable
  sources:
    - deb http://ftp.debian.org/debian/ stable main contrib non-free
    - deb http://security.debian.org/debian-security/ stable-security main contrib non-free
    - deb http://ftp.debian.org/debian/ stable-updates main contrib non-free
  packages:
    - python3
    - python3-gi
    - libgtk-4-dev
    - libadwaita-1-dev
    - libgtksourceview-5-dev
    - python3-yaml
    - libffi-dev
    - python3-chardet
    - python3-pathvalidate
    - python3-icoextract
    - python3-pycurl
    - python3-requests
    - patool
    - ca-certificates
    - cabextract
    - network-manager
    - gamescope
EOF

# DOWNLOAD ALL THE NEEDED PACKAGES AND COMPILE THE APPDIR
./pkg2appimage ./recipe.yml

# PATCH THE APPDIR WITH YAY PACKAGES
tar xf ./archlinux-junest/.cache/yay/bottles-git/*tar.zst -C ./$APP/$APP.AppDir/
VERSION=$(cat ./$APP/$APP.AppDir/.PKGINFO | grep pkgver | cut -c 10- | sed 's@.*:@@')

tar xf ./archlinux-junest/.cache/yay/fvs/*tar.zst -C ./$APP/$APP.AppDir/
tar xf ./archlinux-junest/.cache/yay/patool/*tar.zst -C ./$APP/$APP.AppDir/
tar xf ./archlinux-junest/.cache/yay/python-steamgriddb/*tar.zst -C ./$APP/$APP.AppDir/
tar xf ./archlinux-junest/.cache/yay/vkbasalt-cli/*tar.zst -C ./$APP/$APP.AppDir/
tar xf ./archlinux-junest/.junest/var/cache/pacman/pkg/python-orjson-*tar.zst -C ./$APP/$APP.AppDir/
tar xf ./archlinux-junest/.junest/var/cache/pacman/pkg/python-pycurl-*tar.zst -C ./$APP/$APP.AppDir/
rsync -av ./archlinux-junest/.junest/usr/share/glib-2.0/* ./$APP/$APP.AppDir/usr/share/glib-2.0/

rm -f ./$APP/$APP.AppDir/usr/lib/x86_64-linux-gnu/*libcurl*
rsync -av  ./archlinux-junest/.junest/usr/lib/*libcurl* ./$APP/$APP.AppDir/usr/lib/x86_64-linux-gnu/

# LIBUNIONPRELOAD
wget https://github.com/project-portable/libunionpreload/releases/download/amd64/libunionpreload.so
chmod a+x libunionpreload.so
mv ./libunionpreload.so ./$APP/$APP.AppDir/

# COMPILE SCHEMAS
glib-compile-schemas ./$APP/$APP.AppDir/usr/share/glib-2.0/schemas/ || echo "No ./usr/share/glib-2.0/schemas/"

# CUSTOMIZE THE APPRUN
rm -R -f ./$APP/$APP.AppDir/AppRun
cat >> ./$APP/$APP.AppDir/AppRun << 'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "${0}")")"
export UNION_PRELOAD="${HERE}"
export LD_PRELOAD="${HERE}"/libunionpreload.so
export LD_LIBRARY_PATH=/lib/:/lib64/:/lib/x86_64-linux-gnu/:/usr/lib/:"${HERE}"/usr/lib/:"${HERE}"/usr/lib/i386-linux-gnu/:"${HERE}"/usr/lib/x86_64-linux-gnu/:"${HERE}"/lib/:"${HERE}"/lib/i386-linux-gnu/:"${HERE}"/lib/x86_64-linux-gnu/:"${LD_LIBRARY_PATH}"
export PATH="${HERE}"/usr/bin/:"${HERE}"/usr/sbin/:"${HERE}"/usr/games/:"${HERE}"/bin/:"${HERE}"/sbin/:"${PATH}"
PYVER=$(find $HERE/usr/lib -name *site-packages* | sort | grep -Eo [0-9].[0-9][0-9])
export PYTHONPATH="${HERE}"/usr/lib/python"$PYVER"/site-packages/:"${PYTHONPATH}"
export PYTHONHOME="${HERE}"/usr/
export XDG_DATA_DIRS="${HERE}"/usr/share/:"${XDG_DATA_DIRS}"
export PERLLIB="${HERE}"/usr/share/perl5/:"${HERE}"/usr/lib/perl5/:"${PERLLIB}"
export GSETTINGS_SCHEMA_DIR="${HERE}"/usr/share/glib-2.0/schemas/:"${GSETTINGS_SCHEMA_DIR}"
EXEC=$(grep -e '^Exec=.*' "${HERE}"/*.desktop | head -n 1 | cut -d "=" -f 2- | sed -e 's|%.||g')
exec ${EXEC} "$@"
EOF
	
# MADE THE APPRUN EXECUTABLE
chmod a+x ./$APP/$APP.AppDir/AppRun
# END OF THE PART RELATED TO THE APPRUN, NOW WE WELL SEE IF EVERYTHING WORKS ----------------------------------------------------------------------

# IMPORT THE LAUNCHER AND THE ICON TO THE APPDIR IF THEY NOT EXIST
if test -f ./$APP/$APP.AppDir/*.desktop; then
	echo "The desktop file exists"
else
	echo "Trying to get the .desktop file"
	cp ./$APP/$APP.AppDir/usr/share/applications/*$(ls . | grep -i $APP | cut -c -4)*desktop ./$APP/$APP.AppDir/ 2>/dev/null
fi

ICONNAME=$(cat ./$APP/$APP.AppDir/*desktop | grep "Icon=" | head -1 | cut -c 6-)
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/22x22/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/24x24/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/32x32/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/48x48/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/64x64/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/128x128/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/256x256/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/512x512/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/scalable/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/applications/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null

# DEBLOAT PACKAGE
rm -R -f ./$APP/$APP.AppDir/usr/lib/gcc
rm -R -f ./$APP/$APP.AppDir/.*

# EXPORT THE APP TO AN APPIMAGE
ARCH=x86_64 ./appimagetool -n ./$APP/$APP.AppDir
cd ..
mv ./tmp/*.AppImage ./Bottles-"$VERSION"-x86_64.AppImage
chmod a+x *.AppImage
