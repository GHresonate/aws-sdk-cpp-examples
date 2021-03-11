#!/bin/bash
set -e
set -o pipefail

_DEP_NAME="$1"
_INSTALL_PATH=${INSTALL_PATH:-"/usr/local/"}

_DEP_PATH=$(find . -maxdepth 1 -type d -name "$_DEP_NAME"*)
_CMAKE_BUILD_ARGS="$CMAKE_BUILD_ARGS"
_CMAKE_INSTALL_ARGS="$CMAKE_INSTALL_ARGS"
cmake -S "$_DEP_PATH" -B "${_DEP_PATH}/build" \
    -DCMAKE_PREFIX_PATH=/usr/share/cmake -DCMAKE_INSTALL_PREFIX=/usr/share/cmake \
    -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_LIBDIR=/usr/share/cmake/lib $_CMAKE_BUILD_ARGS
cmake --build "${_DEP_PATH}/build" --target install $_CMAKE_INSTALL_ARGS
