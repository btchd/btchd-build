#! /bin/bash

# Check dependency
if [ "$(command -v zip)" == "" ]; then
    echo 'Missing zip. Please use "apt-get install zip"'
    exit 1
fi
if [ "$(command -v tar)" == "" ]; then
    echo 'Missing tar. Please use "apt-get install tar"'
    exit 1
fi

# Run build script on working dir
WORKING_DIR=$(pwd)

# Basic version from configure.ac
APP_VER_MAJOR=`head -n 15 "$WORKING_DIR/configure.ac" | sed -n 's/define(_CLIENT_VERSION_MAJOR,\ \([0-9]*\))/\1/p'`
APP_VER_MINOR=`head -n 15 "$WORKING_DIR/configure.ac" | sed -n 's/define(_CLIENT_VERSION_MINOR,\ \([0-9]*\))/\1/p'`
APP_VER_REVISION=`head -n 15 "$WORKING_DIR/configure.ac" | sed -n 's/define(_CLIENT_VERSION_REVISION,\ \([0-9]*\))/\1/p'`
APP_VER_BUILD=`head -n 15 "$WORKING_DIR/configure.ac" | sed -n 's/define(_CLIENT_VERSION_BUILD,\ \([0-9]*\))/\1/p'`
APP_VER_RC=`head -n 15 "$WORKING_DIR/configure.ac" | sed -n 's/define(_CLIENT_VERSION_RC,\ \([0-9]*\))/\1/p'`
APP_VER=$APP_VER_MAJOR.$APP_VER_MINOR.$APP_VER_REVISION
[ $APP_VER_RC -ge 1 ] && APP_VER="${APP_VER}rc$APP_VER_RC"
APP_VER_SHORTSTR=v$APP_VER
APP_VER_FULLSTR=v$APP_VER-`git rev-parse --short HEAD`

BUILD_ROOT_DIR="$WORKING_DIR/../$(basename $WORKING_DIR)_build"
BUILD_DIST_DIR="$BUILD_ROOT_DIR/release/${APP_VER_SHORTSTR}"
BUILD_HOSTS="x86_64-w64-mingw32 i686-w64-mingw32 x86_64-apple-darwin14 x86_64-linux-gnu arm-linux-gnueabihf aarch64-linux-gnu riscv64-linux-gnu"
BUILD_USE_THREADS=$(nproc)

[ "x$HOSTS" != "x" ] && BUILD_HOSTS=$HOSTS
[ "x$BUILD_NUMBER" != "x" ] && BUILD_DIST_DIR="${BUILD_DIST_DIR}_build$BUILD_NUMBER"

echo "===================================="
echo "         Version: $APP_VER_FULLSTR"
echo "     Working Dir: $WORKING_DIR"
echo "      Output Dir: $BUILD_DIST_DIR"
echo "           Hosts: $BUILD_HOSTS"
echo "             CPU: $BUILD_USE_THREADS"
echo "===================================="

for host in $BUILD_HOSTS; do
    echo "==================  Building <$host>  =================="
    BUILD_TEMP_DIR="$BUILD_ROOT_DIR/$host"
    rm -rf "$BUILD_TEMP_DIR" || exit 1

    docker run --rm -v "$WORKING_DIR":/workspace \
        -v "$BUILD_ROOT_DIR":/workspace_build \
        -e BUILD_THREADS=$BUILD_USE_THREADS \
        btchd.org/btchd-build:0.0.1-bionic-$host \
        || exit 1

    echo "================== Installing <$host> =================="
    mkdir -p $BUILD_DIST_DIR || exit 1
    if [ "$host" == "x86_64-w64-mingw32" ]; then # Windows x86_64. => xxx.zip
        mv "$BUILD_TEMP_DIR/BitcoinHD-$APP_VER-win64-setup.exe" "$BUILD_DIST_DIR/bhd-$APP_VER_SHORTSTR-win64-setup.exe" || exit 1
        zip -j "$BUILD_DIST_DIR/bhd-$APP_VER_FULLSTR-win64.zip" "$BUILD_DIST_DIR/bhd-$APP_VER_SHORTSTR-win64-setup.exe" || exit 1
        rm "$BUILD_DIST_DIR/bhd-$APP_VER_SHORTSTR-win64-setup.exe" || exit 1
    elif [ "$host" == "i686-w64-mingw32" ]; then # Windows x86. => xxx.zip
        mv "$BUILD_TEMP_DIR/BitcoinHD-$APP_VER-win32-setup.exe" "$BUILD_DIST_DIR/bhd-$APP_VER_SHORTSTR-win32-setup.exe" || exit 1
        zip -j "$BUILD_DIST_DIR/bhd-$APP_VER_FULLSTR-win32.zip" "$BUILD_DIST_DIR/bhd-$APP_VER_SHORTSTR-win32-setup.exe" || exit 1
        rm "$BUILD_DIST_DIR/bhd-$APP_VER_SHORTSTR-win32-setup.exe" || exit 1
    elif [ "$host" == "x86_64-apple-darwin14" ]; then # macOS. => xxx-osx.dmg
        mv "$BUILD_TEMP_DIR/BitcoinHD-Core.dmg" "$BUILD_DIST_DIR/bhd-$APP_VER_FULLSTR-osx.dmg" || exit 1
    else # Unix. => xxx-$host.tar.gz
        rm -rf "$BUILD_TEMP_DIR/release/bhd-$APP_VER_SHORTSTR" && mkdir -p "$BUILD_TEMP_DIR/release/bhd-$APP_VER_SHORTSTR" || exit 1
        cp -r "$BUILD_TEMP_DIR/release/bin" "$BUILD_TEMP_DIR/release/bhd-$APP_VER_SHORTSTR" || exit 1
        cp -r "$BUILD_TEMP_DIR/release/include" "$BUILD_TEMP_DIR/release/bhd-$APP_VER_SHORTSTR" || exit 1
        cp -r "$BUILD_TEMP_DIR/release/lib" "$BUILD_TEMP_DIR/release/bhd-$APP_VER_SHORTSTR" || exit 1
        cp -r "$BUILD_TEMP_DIR/release/share" "$BUILD_TEMP_DIR/release/bhd-$APP_VER_SHORTSTR" || exit 1
        if [ -f "$BUILD_TEMP_DIR/release/bhd-$APP_VER_SHORTSTR/bin/btchd-cli" ]; then
            printf '#! /bin/sh\n./bin/btchd-cli -datadir=./data/ "$@"' > "$BUILD_TEMP_DIR/release/bhd-$APP_VER_SHORTSTR/btchd-cli.sh"
            chmod +x "$BUILD_TEMP_DIR/release/bhd-$APP_VER_SHORTSTR/btchd-cli.sh"
        fi
        if [ -f "$BUILD_TEMP_DIR/release/bhd-$APP_VER_SHORTSTR/bin/btchdd" ]; then
            printf '#! /bin/sh\n./bin/btchdd -datadir=./data/ "$@"' > "$BUILD_TEMP_DIR/release/bhd-$APP_VER_SHORTSTR/start-btchdd.sh"
            printf '#! /bin/sh\n./bin/btchd-cli -datadir=./data/ "$@" stop' > "$BUILD_TEMP_DIR/release/bhd-$APP_VER_SHORTSTR/stop-btchdd.sh"
            chmod +x "$BUILD_TEMP_DIR/release/bhd-$APP_VER_SHORTSTR/start-btchdd.sh"
            chmod +x "$BUILD_TEMP_DIR/release/bhd-$APP_VER_SHORTSTR/stop-btchdd.sh"
        fi
        if [ -f "$BUILD_TEMP_DIR/release/bhd-$APP_VER_SHORTSTR/bin/btchd-qt" ]; then
            printf '#! /bin/sh\n./bin/btchd-qt -datadir=./data/ "$@"' > "$BUILD_TEMP_DIR/release/bhd-$APP_VER_SHORTSTR/start-btchd-qt.sh"
            chmod +x "$BUILD_TEMP_DIR/release/bhd-$APP_VER_SHORTSTR/start-btchd-qt.sh"
        fi
        mkdir -p "$BUILD_TEMP_DIR/release/bhd-$APP_VER_SHORTSTR/data" || exit 1
        tar -zcvf "$BUILD_DIST_DIR/bhd-$APP_VER_FULLSTR-$host.tar.gz" -C "$BUILD_TEMP_DIR/release" bhd-$APP_VER_SHORTSTR || exit 1
        rm -rf "$BUILD_TEMP_DIR/release/bhd-$APP_VER_SHORTSTR"
    fi
    echo "=============== Build <$host> complete ==============="
    echo ""
done
