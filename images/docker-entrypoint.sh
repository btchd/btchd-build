#! /bin/sh
set -e

# build dest dir
BUILD_DIR=/workspace_build/$BUILD_HOST
mkdir -p $BUILD_DIR && cd $BUILD_DIR || exit 1

# for custom depends build
DEPENDS_DIR=/workspace_build/depends
export CONFIG_SITE=/workspace/depends/$BUILD_HOST/share/config.site
make -C /workspace/depends -j$BUILD_THREADS \
    HOST=$BUILD_HOST \
    SOURCES_PATH=$DEPENDS_DIR/sources \
    WORK_PATH=$DEPENDS_DIR/work \
    BASE_CACHE=$DEPENDS_DIR/built \
    SDK_PATH=$DEPENDS_DIR/SDKs \
    FALLBACK_DOWNLOAD_PATH=https://download.bitcoinabc.org/depends-sources || exit 1

# build
/workspace/autogen.sh && /workspace/configure $BUILD_ARGS || exit 1
make clean && make -j$BUILD_THREADS || exit 1

# deploy
if [ "$(echo $BUILD_HOST | grep mingw32)" != "" ]; then
    # for windows
    ## fixes nsi
    sed -i "s/\/workspace\/release/\/workspace_build\/$BUILD_HOST\/release/g" $BUILD_DIR/share/setup.nsi || exit 1
    sed -i "s/\/workspace\/BitcoinHD/\/workspace_build\/$BUILD_HOST\/BitcoinHD/g" $BUILD_DIR/share/setup.nsi || exit 1
    make -j$BUILD_THREADS DESTDIR=$BUILD_DIR/release install || exit 1
fi
if [ "$(echo $BUILD_HOST | grep linux)" != "" ]; then
    # for linux like
    make -j$BUILD_THREADS DESTDIR=$BUILD_DIR/release install || exit 1
    $BUILD_HOST-strip $BUILD_DIR/release/bin/btchd*
else
    make -j$BUILD_THREADS deploy || exit 1
fi
