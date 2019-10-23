#!/usr/bin/env bash

# build.sh
#
# We need a custom build script so we can use experimental docker build features

# https://stackoverflow.com/a/21188136/3793499
_abspath() {
  local filename=$1
  local parentdir=$(dirname "${filename}")

  if test -d "${filename}" ; then
      echo "$(cd "${filename}" && pwd)"
  elif test -d "${parentdir}" ; then
    echo "$(cd "${parentdir}" && pwd)/$(basename "${filename}")"
  fi
}

# Use absolute paths so we can call this script from anywhere
THIS_DIR="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"
SRC_DIR="$(_abspath "${THIS_DIR}/../..")"

# Enable experimental docker features so we can take advantage of caching
export DOCKER_BUILDKIT=1

# Make a temp context so we can reach outside of our current directory

docker build --build-arg SRC_DIR='.' -f "platforms/docker/Dockerfile.v8" \
             -t plv8:build-v8 ${SRC_DIR} \
    && exit 0

exit 1
