#!/bin/bash
if [ -z "$GITHUB_WORKSPACE" ];then
    echo "GITHUB_WORKSPACE environemnt variable not set!"
    exit 1
fi
if [ "$#" -ne 1 ];then
    echo "Usage: ${0} [x86|x86_64|armhf|aarch64]"
    echo "Example: ${0} x86_64"
    exit 1
fi
set -e
set -o pipefail
set -x
source $GITHUB_WORKSPACE/build/lib.sh
init_lib "$1"

build_cannelloni() {
    fetch "https://github.com/mguentner/cannelloni.git" "${BUILD_DIRECTORY}/cannelloni" git
    cd "${BUILD_DIRECTORY}/cannelloni"
    git clean -fdx
    git fetch --tags
    git checkout tags/v1.1.0 -b tmpbranch
    cp $GITHUB_WORKSPACE/patches/cannelloni/CMakeLists.txt .
    mkdir -p build
    cd build
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_FLAGS="${GCC_OPTS}" \
        -DCMAKE_CXX_FLAGS="${GXX_OPTS}" \
        -DCMAKE_INSTALL_PREFIX="${BUILD_DIRECTORY}/cannelloni/install"
    make -j4
    make install
    strip "${BUILD_DIRECTORY}/cannelloni/install/bin/cannelloni"
}

main() {
    build_cannelloni
    cp "${BUILD_DIRECTORY}/cannelloni/install/bin/cannelloni" "${OUTPUT_DIRECTORY}/cannelloni-1.1.0-${CURRENT_ARCH}"
    echo "[+] Finished building Cannelloni ${CURRENT_ARCH}"

    echo "PACKAGED_NAME=cannelloni-1.1.0-${CURRENT_ARCH}" >> $GITHUB_OUTPUT
    echo "PACKAGED_NAME_PATH=${OUTPUT_DIRECTORY}/*" >> $GITHUB_OUTPUT
    echo "PACKAGED_VERSION=1.1.0" >> $GITHUB_OUTPUT
}

main
