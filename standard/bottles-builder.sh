#!/bin/sh

APP=bottles
BIN="$APP" #CHANGE THIS IF THE NAME OF THE BINARY IS DIFFERENT FROM "$APP" (for example, the binary of "obs-studio" is "obs")
DEPENDENCES="cabextract faudio gobject-introspection-runtime imagemagick libgirepository p7zip procps-ng python python-gobject python-yaml tar zimg"
BASICSTUFF="binutils gzip"
COMPILERS="meson ninja blueprint-compiler"
VERSION=$(wget -q https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=$APP -O - | grep pkgver | head -1 | cut -c 8-)

# CREATE AND ENTER THE TEMPORARY DIRECTORY AND MADE IT A TEMPORARY $HOME
mkdir -p tmp
cd tmp
HOME="$(dirname "$(readlink -f $0)")" 

# DOWNLOAD APPIMAGETOOL
if test -f ./appimagetool; then
	echo " appimagetool already exists" 1> /dev/null
else
	echo " Downloading appimagetool..."
	wget -q https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage -O appimagetool
fi
chmod a+x appimagetool

# INSTALL, UPDATE AND CONFIGURE JUNEST
if test -d ./.junest; then
	echo " JuNest already exists" 1> /dev/null
else
	git clone https://github.com/fsquillace/junest.git ~/.local/share/junest
	wget -q --show-progress https://github.com/ivan-hc/junest/releases/download/continuous/junest-x86_64.tar.gz
	./.local/share/junest/bin/junest setup -i junest-x86_64.tar.gz
	rm -f junest-x86_64.tar.gz
	echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> ./.junest/etc/pacman.conf

	_custom_mirrorlist(){
		COUNTRY=$(curl -i ipinfo.io | grep country | cut -c 15- | cut -c -2)
		rm -R ./.junest/etc/pacman.d/mirrorlist
		wget -q https://archlinux.org/mirrorlist/?country="$(echo $COUNTRY)" -O - | sed 's/#Server/Server/g' >> ./.junest/etc/pacman.d/mirrorlist
	}
	_custom_mirrorlist

	sed -i 's/#SigLevel/SigLevel/g' ./.junest/etc/pacman.conf
	sed -i 's/Required DatabaseOptional/Never/g' ./.junest/etc/pacman.conf
	./.local/share/junest/bin/junest -- sudo pacman -Syy
	./.local/share/junest/bin/junest -- sudo pacman --noconfirm -Syu
	./.local/share/junest/bin/junest -- yay -Syy
	./.local/share/junest/bin/junest -- gpg --keyserver keyserver.ubuntu.com --recv-key C01E1CAD5EA2C4F0B8E3571504C367C218ADD4FF
fi

# INSTALL THE APP
./.local/share/junest/bin/junest -- yay --noconfirm -S gnu-free-fonts $(echo "$BASICSTUFF $COMPILERS $DEPENDENCES $APP")
echo y | ./.local/share/junest/bin/junest -- yay --answerclean All --answerdiff All --noconfirm -S $APP patool


# CREATE THE APPDIR
mkdir -p ./$APP.AppDir/etc ./$APP.AppDir/usr/bin ./$APP.AppDir/usr/lib ./$APP.AppDir/usr/share

# ...ADD THE ICON AND THE DESKTOP FILE AT THE ROOT OF THE APPDIR...
rm -R -f ./*.desktop
LAUNCHER=$(grep -iRl $BIN ./.junest/usr/share/applications/* | grep ".desktop" | head -1)
cp -r "$LAUNCHER" ./$APP.AppDir/
ICON=$(cat $LAUNCHER | grep "Icon=" | cut -c 6-)
cp -r ./.junest/usr/share/icons/hicolor/22x22/apps/*$ICON* ./$APP.AppDir 2>/dev/null
cp -r ./.junest/usr/share/icons/hicolor/24x24/apps/*$ICON* ./$APP.AppDir 2>/dev/null
cp -r ./.junest/usr/share/icons/hicolor/32x32/apps/*$ICON* ./$APP.AppDir 2>/dev/null
cp -r ./.junest/usr/share/icons/hicolor/48x48/apps/*$ICON* ./$APP.AppDir 2>/dev/null
cp -r ./.junest/usr/share/icons/hicolor/64x64/apps/*$ICON* ./$APP.AppDir 2>/dev/null
cp -r ./.junest/usr/share/icons/hicolor/128x128/apps/*$ICON* ./$APP.AppDir 2>/dev/null
cp -r ./.junest/usr/share/icons/hicolor/192x192/apps/*$ICON* ./$APP.AppDir 2>/dev/null
cp -r ./.junest/usr/share/icons/hicolor/256x256/apps/*$ICON* ./$APP.AppDir 2>/dev/null
cp -r ./.junest/usr/share/icons/hicolor/512x512/apps/*$ICON* ./$APP.AppDir 2>/dev/null
cp -r ./.junest/usr/share/icons/hicolor/scalable/apps/*$ICON* ./$APP.AppDir 2>/dev/null
cp -r ./.junest/usr/share/pixmaps/*$ICON* ./$APP.AppDir 2>/dev/null

# CUSTOMIZE THE APPRUN
rm -R -f ./$APP.AppDir/AppRun
cat >> ./$APP.AppDir/AppRun << 'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "${0}")")"
export UNION_PRELOAD="${HERE}"
#export LD_PRELOAD="${HERE}/libunionpreload.so"
export PATH="${HERE}"/usr/bin/:"${HERE}"/usr/sbin/:"${HERE}"/usr/games/:"${HERE}"/bin/:"${HERE}"/sbin/:"${PATH}"
export LD_LIBRARY_PATH="${HERE}"/usr/lib/:"${HERE}"/usr/lib32/:"${HERE}"/usr/lib/i386-linux-gnu/:"${HERE}"/usr/lib/x86_64-linux-gnu/:"${HERE}"/lib/:"${HERE}"/lib/i386-linux-gnu/:"${HERE}"/lib/x86_64-linux-gnu/:"${LD_LIBRARY_PATH}"
#export LD_LIBRARY_PATH=/lib/:/lib64/:/lib/x86_64-linux-gnu/:/usr/lib/:"${HERE}"/usr/lib/:"${HERE}"/usr/lib/i386-linux-gnu/:"${HERE}"/usr/lib/x86_64-linux-gnu/:"${HERE}"/lib/:"${HERE}"/lib/i386-linux-gnu/:"${HERE}"/lib/x86_64-linux-gnu/:"${LD_LIBRARY_PATH}"
export PYTHONPATH="${HERE}"/usr/share/pyshared/:"${PYTHONPATH}"
export PYTHONHOME="${HERE}"/usr/
export XDG_DATA_DIRS="${HERE}"/usr/share/:"${XDG_DATA_DIRS}"
export PERLLIB="${HERE}"/usr/share/perl5/:"${HERE}"/usr/lib/perl5/:"${PERLLIB}"
export GSETTINGS_SCHEMA_DIR="${HERE}"/usr/share/glib-2.0/schemas/:"${GSETTINGS_SCHEMA_DIR}"
export QT_PLUGIN_PATH="${HERE}"/usr/lib/qt4/plugins/:"${HERE}"/usr/lib/i386-linux-gnu/qt4/plugins/:"${HERE}"/usr/lib/x86_64-linux-gnu/qt4/plugins/:"${HERE}"/usr/lib32/qt4/plugins/:"${HERE}"/usr/lib64/qt4/plugins/:"${HERE}"/usr/lib/qt5/plugins/:"${HERE}"/usr/lib/i386-linux-gnu/qt5/plugins/:"${HERE}"/usr/lib/x86_64-linux-gnu/qt5/plugins/:"${HERE}"/usr/lib32/qt5/plugins/:"${HERE}"/usr/lib64/qt5/plugins/:"${QT_PLUGIN_PATH}"
EXEC=$(grep -e '^Exec=.*' "${HERE}"/*.desktop | head -n 1 | cut -d "=" -f 2- | sed -e 's|%.||g')
exec ${EXEC} "$@"
EOF
	
# MADE THE APPRUN EXECUTABLE
chmod a+x ./$APP.AppDir/AppRun

# EXTRACT PACKAGE CONTENT
mkdir base
tar fx .junest/var/cache/pacman/pkg/$APP*.zst -C ./base/
tar fx .cache/yay/$APP/$APP*.zst -C ./base/

# OTHER TO EXTRACT
PYTHONVERSION=$(wget -q https://gitlab.archlinux.org/archlinux/packaging/packages/python/-/raw/main/PKGBUILD -O - | grep "pkgver=" | cut -c 8-)
tar fx .junest/var/cache/pacman/pkg/python-"$PYTHONVERSION"*.zst -C ./base/
tar fx .junest/var/cache/pacman/pkg/python-gobject*.zst -C ./base/
tar fx .junest/var/cache/pacman/pkg/python-yaml*.zst -C ./base/
tar fx .cache/yay/patool/patool*.zst -C ./base/

mkdir deps

ARGS=$(echo "$DEPENDENCES" | tr " " "\n")
for arg in $ARGS; do
	for var in $arg; do
 		tar fx .junest/var/cache/pacman/pkg/$arg*.zst -C ./deps/
		cat ./deps/.PKGINFO | grep "depend = " | grep -v "makedepend = " | cut -c 10- | grep -v "=\|>\|<" > depdeps
	done
done

DEPS=$(cat ./base/.PKGINFO | grep "depend = " | grep -v "makedepend = " | cut -c 10- | grep -v "=\|>\|<")
for arg in $DEPS; do
	for var in "$arg"; do
 		tar fx .junest/var/cache/pacman/pkg/"$arg"*.zst -C ./deps/
 		cat ./deps/.PKGINFO | grep "depend = " | grep -v "makedepend = " | cut -c 10- | grep -v "=\|>\|<" > depdeps
	done
done

DEPS2=$(cat ./depdeps | uniq)
for arg in $DEPS2; do
	for var in "$arg"; do
 		tar fx .junest/var/cache/pacman/pkg/"$arg"*.zst -C ./deps/
 		cat ./deps/.PKGINFO | grep "depend = " | grep -v "makedepend = " | cut -c 10- | grep -v "=\|>\|<" > depdeps2
 	done
done

DEPS3=$(cat ./depdeps2 | uniq)
for arg in $DEPS3; do
	for var in "$arg"; do
 		tar fx .junest/var/cache/pacman/pkg/"$arg"*.zst -C ./deps/
 		cat ./deps/.PKGINFO | grep "depend = " | grep -v "makedepend = " | cut -c 10- | grep -v "=\|>\|<" > depdeps3
 	done
done

DEPS4=$(cat ./depdeps3 | uniq)
for arg in $DEPS4; do
	for var in "$arg"; do
 		tar fx .junest/var/cache/pacman/pkg/"$arg"*.zst -C ./deps/
 		cat ./deps/.PKGINFO | grep "depend = " | grep -v "makedepend = " | cut -c 10- | grep -v "=\|>\|<" > depdeps4
 	done
done

# IN THE NEXT 4 STEPS WE WILL TRY TO LIGHTEN THE FINAL APPIMAGE PACKAGE
# WE WILL MOVE EXCESS CONTENT TO BACKUP FOLDERS (STEP 1)
# THE AFFECTED DIRECTORIES WILL BE /usr/bin (STEP 2), /usr/lib (STEP 3) AND /usr/share (STEP 4)

BINSAVED="certificates cut grep patool py rm wine xz" # Enter here keywords to find and save in /usr/bin
SHARESAVED="certificates adwaita appstream gio gnome gtk icons themes xml" # Enter here keywords or file/folder names to save in both /usr/share and /usr/lib
LIBSAVED="pk p11 alsa jack pipewire python pulse adwaita appstream cairo d3d decor gio gnome gtk libgraphene lzo module repository selinux stemmer xml" # Enter here keywords or file/folder names to save in /usr/lib

# STEP 1, CREATE A BACKUP FOLDER WHERE TO SAVE THE FILES TO BE DISCARDED (USEFUL FOR TESTING PURPOSES)
mkdir -p ./junest-backups/usr/bin
mkdir -p ./junest-backups/usr/lib/dri
mkdir -p ./junest-backups/usr/share

# TEMPORARILY MOVE 32 BIT LIBRARIES
mv ./.junest/usr/lib32 ./lib32

# STEP 2, FUNCTION TO SAVE THE BINARIES IN /usr/bin THAT ARE NEEDED TO MADE JUNEST WORK, PLUS THE MAIN BINARY/BINARIES OF THE APP
# IF YOU NEED TO SAVE MORE BINARIES, LIST THEM IN THE "BINSAVED" VARIABLE. COMMENT THE LINE "_savebins" IF YOU ARE NOT SURE.
_savebins(){
	mkdir save
	mv ./.junest/usr/bin/*$BIN* ./save/
	mv ./.junest/usr/bin/bash ./save/
 	mv ./.junest/usr/bin/bwrap ./save/
	mv ./.junest/usr/bin/env ./save/
	mv ./.junest/usr/bin/sh ./save/
 	mv ./.junest/usr/bin/tr ./save/
	for arg in $BINSAVED; do
		for var in $arg; do
 			mv ./.junest/usr/bin/*"$arg"* ./save/
		done
	done
	mv ./.junest/usr/bin/* ./junest-backups/usr/bin/
	mv ./save/* ./.junest/usr/bin/
 	rsync -av ./base/usr/bin/* ./$APP.AppDir/usr/bin/
 	rmdir save
}
_savebins 2> /dev/null

# STEP 3, MOVE UNNECESSARY LIBRARIES TO A BACKUP FOLDER (FOR TESTING PURPOSES)
mkdir save

_binlibs(){
	readelf -d ./.junest/usr/bin/* | grep .so | sed 's:.* ::' | cut -c 2- | sed 's/\(^.*so\).*$/\1/' | uniq >> ./list
	mv ./.junest/usr/lib/ld-linux-x86-64.so* ./save/
	mv ./.junest/usr/lib/*$APP* ./save/
	mv ./.junest/usr/lib/*$BIN* ./save/
	mv ./.junest/usr/lib/libdw* ./save/
	mv ./.junest/usr/lib/libelf* ./save/
	for arg in $SHARESAVED; do
		for var in $arg; do
 			mv ./.junest/usr/lib/*"$arg"* ./save/
		done
	done
	ARGS=$(tail -n +2 ./list | sort -u | uniq)
	for arg in $ARGS; do
		for var in $arg; do
			mv ./.junest/usr/lib/$arg* ./save/
			find ./.junest/usr/lib/ -name $arg -exec cp -r --parents -t save/ {} +
		done 
	done
	rm -R -f $(find ./save/ | sort | grep ".AppDir" | head -1)
	rm list
}


_libkeywords(){
	for arg in $LIBSAVED; do
		for var in $arg; do
 			mv ./.junest/usr/lib/*"$arg"* ./save/
		done
	done
}

_liblibs(){
	readelf -d ./save/* | grep .so | sed 's:.* ::' | cut -c 2- | sed 's/\(^.*so\).*$/\1/' | uniq >> ./list
	readelf -d ./save/*/* | grep .so | sed 's:.* ::' | cut -c 2- | sed 's/\(^.*so\).*$/\1/' | uniq >> ./list
	readelf -d ./save/*/*/* | grep .so | sed 's:.* ::' | cut -c 2- | sed 's/\(^.*so\).*$/\1/' | uniq >> ./list
	readelf -d ./save/*/*/*/* | grep .so | sed 's:.* ::' | cut -c 2- | sed 's/\(^.*so\).*$/\1/' | uniq >> ./list
	readelf -d ./save/*/*/*/*/* | grep .so | sed 's:.* ::' | cut -c 2- | sed 's/\(^.*so\).*$/\1/' | uniq >> ./list
 	readelf -d ./base/* | grep .so | sed 's:.* ::' | cut -c 2- | sed 's/\(^.*so\).*$/\1/' | uniq >> ./list
	readelf -d ./base/*/* | grep .so | sed 's:.* ::' | cut -c 2- | sed 's/\(^.*so\).*$/\1/' | uniq >> ./list
	readelf -d ./base/*/*/* | grep .so | sed 's:.* ::' | cut -c 2- | sed 's/\(^.*so\).*$/\1/' | uniq >> ./list
	readelf -d ./base/*/*/*/* | grep .so | sed 's:.* ::' | cut -c 2- | sed 's/\(^.*so\).*$/\1/' | uniq >> ./list
	readelf -d ./base/*/*/*/*/* | grep .so | sed 's:.* ::' | cut -c 2- | sed 's/\(^.*so\).*$/\1/' | uniq >> ./list
  	readelf -d ./deps/* | grep .so | sed 's:.* ::' | cut -c 2- | sed 's/\(^.*so\).*$/\1/' | uniq >> ./list
	readelf -d ./deps/*/* | grep .so | sed 's:.* ::' | cut -c 2- | sed 's/\(^.*so\).*$/\1/' | uniq >> ./list
	readelf -d ./deps/*/*/* | grep .so | sed 's:.* ::' | cut -c 2- | sed 's/\(^.*so\).*$/\1/' | uniq >> ./list
	readelf -d ./deps/*/*/*/* | grep .so | sed 's:.* ::' | cut -c 2- | sed 's/\(^.*so\).*$/\1/' | uniq >> ./list
	readelf -d ./deps/*/*/*/*/* | grep .so | sed 's:.* ::' | cut -c 2- | sed 's/\(^.*so\).*$/\1/' | uniq >> ./list
	readelf -d ./lib32/* | grep .so | sed 's:.* ::' | cut -c 2- | sed 's/\(^.*so\).*$/\1/' | uniq >> ./list
	readelf -d ./lib32/*/* | grep .so | sed 's:.* ::' | cut -c 2- | sed 's/\(^.*so\).*$/\1/' | uniq >> ./list
	readelf -d ./lib32/*/*/* | grep .so | sed 's:.* ::' | cut -c 2- | sed 's/\(^.*so\).*$/\1/' | uniq >> ./list
	readelf -d ./lib32/*/*/*/* | grep .so | sed 's:.* ::' | cut -c 2- | sed 's/\(^.*so\).*$/\1/' | uniq >> ./list
	readelf -d ./lib32/*/*/*/*/* | grep .so | sed 's:.* ::' | cut -c 2- | sed 's/\(^.*so\).*$/\1/' | uniq >> ./list
	readelf -d ./.junest/usr/lib/dri/* | grep .so | sed 's:.* ::' | cut -c 2- | sed 's/\(^.*so\).*$/\1/' | uniq >> ./list
	ARGS=$(tail -n +2 ./list | sort -u | uniq)
	for arg in $ARGS; do
		for var in $arg; do
			mv ./.junest/usr/lib/"$arg"* ./save/
			find ./.junest/usr/lib/ -name "$arg" -exec cp -r --parents -t save/ {} +
		done 
	done
	rsync -av ./save/.junest/usr/lib/* ./$APP.AppDir/usr/lib/
 	rm -R -f $(find ./save/ | sort | grep ".AppDir" | head -1)
	rm list
}

_mvlibs(){
	mv ./.junest/usr/lib/* ./junest-backups/usr/lib/
	mv ./save/* ./.junest/usr/lib/
 	rsync -av ./base/usr/lib/* ./$APP.AppDir/usr/lib/
 }

_binlibs 2> /dev/null

_libkeywords 2> /dev/null

_liblibs 2> /dev/null
_liblibs 2> /dev/null
_liblibs 2> /dev/null
_liblibs 2> /dev/null
_liblibs 2> /dev/null

_mvlibs 2> /dev/null

rmdir save

# STEP 4, SAVE ONLY SOME DIRECTORIES CONTAINED IN /usr/share
# IF YOU NEED TO SAVE MORE FOLDERS, LIST THEM IN THE "SHARESAVED" VARIABLE. COMMENT THE LINE "_saveshare" IF YOU ARE NOT SURE.
_saveshare(){
	mkdir save
	mv ./.junest/usr/share/*$APP* ./save/
 	mv ./.junest/usr/share/*$BIN* ./save/
	mv ./.junest/usr/share/fontconfig ./save/
	mv ./.junest/usr/share/glib-* ./save/
	mv ./.junest/usr/share/locale ./save/
	mv ./.junest/usr/share/mime ./save/
	mv ./.junest/usr/share/wayland ./save/
	mv ./.junest/usr/share/X11 ./save/
	for arg in $SHARESAVED; do
		for var in $arg; do
 			mv ./.junest/usr/share/*"$arg"* ./save/
		done
	done
	mv ./.junest/usr/share/* ./junest-backups/usr/share/
	mv ./save/* ./.junest/usr/share/
 	rsync -av ./base/usr/share/* ./$APP.AppDir/usr/share/
 	rmdir save
}
_saveshare 2> /dev/null

# RSYNC DEPENDENCES
rsync -av ./base/etc/* ./$APP.AppDir/etc/
rsync -av ./deps/etc/* ./$APP.AppDir/etc/
rsync -av ./base/usr/* ./$APP.AppDir/usr/
rsync -av ./deps/usr/* ./$APP.AppDir/usr/

# RESTORE 32-BIT LIBRARIES
mkdir ./.junest/usr/lib32
rsync -av ./lib32/* ./$APP.AppDir/usr/lib32/

# CREATE THE APPIMAGE
ARCH=x86_64 ./appimagetool -n ./$APP.AppDir
mv ./*AppImage ./Bottles_"$VERSION"_Unofficial-Experimental-pre1-x86_64.AppImage
