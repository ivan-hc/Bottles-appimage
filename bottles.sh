#!/usr/bin/env bash

APP=bottles

# CREATE A TEMPORARY DIRECTORY
mkdir -p tmp
cd tmp

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
EOF

# DOWNLOAD ALL THE NEEDED PACKAGES AND COMPILE THE APPDIR
./pkg2appimage ./recipe.yml

# DOWNLOAD BOTTLES AND PATCH THE APPDIR
package=$(wget -q https://builds.garudalinux.org/repos/chaotic-aur/x86_64/ -O - | grep -Po '(?<=href=")[^"]*' | grep bottles | head -1)
wget https://builds.garudalinux.org/repos/chaotic-aur/x86_64/$package
tar xf ./*tar.zst -C ./$APP/$APP.AppDir/
rm -R -f ./*.zst

rm -R -f ./$APP/$APP.AppDir/*.desktop
cp ./$APP/$APP.AppDir/usr/share/applications/*bottles* ./

# DOWNLOAD FVS AND PATCH THE APPDIR
package=$(wget -q https://builds.garudalinux.org/repos/chaotic-aur/x86_64/ -O - | grep -Po '(?<=href=")[^"]*' | grep fvs | head -1)
wget https://builds.garudalinux.org/repos/chaotic-aur/x86_64/$package
tar xf ./*tar.zst -C ./$APP/$APP.AppDir/
rm -R -f ./*.zst

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

# EXPORT THE APP TO AN APPIMAGE
ARCH=x86_64 ./appimagetool -n ./$APP/$APP.AppDir
cd ..
mv ./tmp/*.AppImage .
chmod a+x *.AppImage
