#!/bin/bash
# This packages the built binaries with all their dll dependencies.
# Adjust line 12 when building locally!
set -e # exit on any failure

SCRIPTS_DIR=$(dirname $(readlink -f $0)) # this file's location (/path/to/qimgv/scripts)
SRC_DIR=$(dirname $SCRIPTS_DIR)
BUILD_DIR=$SRC_DIR/build
EXT_DIR=$SRC_DIR/_external


if [[ -z "$RUNNER_TEMP" ]]; then
    MSYS_DIR="E:/Programs/msys64/mingw64"
else
    MSYS_DIR="$(cd "$RUNNER_TEMP" && pwd)/msys64/mingw64"
fi

# ------------------------------------------------------------------------------
echo "PACKAGING"
# 0 - prepare dir
cd $SRC_DIR
BUILD_NAME=qimgv-x64_$(git describe --tags)
PACKAGE_DIR=$BUILD_DIR/$BUILD_NAME
rm -rf $PACKAGE_DIR
mkdir $PACKAGE_DIR

# 1 - copy qimgv build
cp $BUILD_DIR/qimgv/qimgv.exe $PACKAGE_DIR
mkdir $PACKAGE_DIR/plugins
cp $BUILD_DIR/plugins/player_mpv/player_mpv.dll $PACKAGE_DIR/plugins
cp -r $BUILD_DIR/qimgv/translations/ $PACKAGE_DIR/

# 2 - copy qt plugin dlls
cd $MSYS_DIR/share/qt5/plugins/
cp -r iconengines imageformats printsupport styles $PACKAGE_DIR
mkdir $PACKAGE_DIR/platforms
cp platforms/qwindows.dll $PACKAGE_DIR/platforms

# 3 - copy dep dlls + mpv.exe

# 3.1 - optionally extract deps
if [[ "$1" == "-d" ]]; then
  # TODO: test
  echo "Extracting deps..."
  depends.exe /oc $SCRIPTS_DIR/dep.txt $BUILD_DIR/qimgv/qimgv.exe
  depends.exe /oc $SCRIPTS_DIR/dep_mpv.txt $MSYS_DIR/bin/mpv.exe
  until [ -f "$SCRIPTS_DIR/dep_mpv.txt" ] && [ -f "$SCRIPTS_DIR/dep.txt" ]; do
      sleep 1
  done
  echo "Extraction done."
else
  echo "Skipping deps extraction."
fi

# the mpv dll is loaded dynamically, so its deps can’t be automatically extracted from the qimgv binary

BIN_PATH=$(echo "$MSYS_DIR/bin" | sed 's/\//\\\\/g')
DEPS=$(rg "${BIN_PATH}\\\\\\K(.*\\.dll)" $SCRIPTS_DIR/dep.txt -ioP | awk '{print tolower($0)}' | sed 's/\n/ /')
DEPS_MPV=$(rg "${BIN_PATH}\\\\\\K(.*\\.dll)" $SCRIPTS_DIR/dep_mpv.txt -ioP | awk '{print tolower($0)}' | sed 's/\n/ /')
MSYS_DLLS=$(cat $SCRIPTS_DIR/msys2-dll-deps.txt | sed 's/\n/ /')
cd $MSYS_DIR/bin
cp $MSYS_DLLS $PACKAGE_DIR
cp $DEPS $PACKAGE_DIR
cp $DEPS_MPV $PACKAGE_DIR

# 4 - copy imageformats
cp $EXT_DIR/qt-jpegxl-image-plugin/build/bin/imageformats/libqjpegxl*.dll $PACKAGE_DIR/imageformats
cp $EXT_DIR/qt-avif-image-plugin/build/bin/imageformats/libqavif*.dll $PACKAGE_DIR/imageformats
cp $EXT_DIR/qt-heif-image-plugin/build/bin/imageformats/libqheif.dll $PACKAGE_DIR/imageformats
cp $EXT_DIR/QtApng/build/plugins/imageformats/qapng.dll $PACKAGE_DIR/imageformats
cp $EXT_DIR/qtraw/build/src/imageformats/qtraw.dll $PACKAGE_DIR/imageformats

# 6 - misc
mkdir $PACKAGE_DIR/cache
mkdir $PACKAGE_DIR/conf
mkdir $PACKAGE_DIR/thumbnails
cp -r $SRC_DIR/qimgv/distrib/mimedata/data $PACKAGE_DIR

cd $SRC_DIR
echo "PACKAGING DONE"