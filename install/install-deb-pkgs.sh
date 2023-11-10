#!/usr/bin/env bash

set -e

apt-get update
apt-get install -y --no-install-recommends \
  gnupg ca-certificates apt-transport-https software-properties-common \
  file git curl wget unzip \
  lbzip2 xz-utils patch m4 \
  make cmake \
  libssl-dev \
  zlib1g-dev \
  gfortran-11 \
  libstdc++-11-dev \
  libffi-dev

if [ -n "$DISPLAY" ]; then
  apt install -qy --no-install-recommends \
    x11-xkb-utils \
    slop
fi

# Typically, sys/sysctl.h is found in the /usr/include/sys directory on Unix-based systems.
#
#   hwloc/hwloc/topology.c:49:10: fatal error: sys/sysctl.h: No such file or directory
mkdir -p /usr/include/sys
ln -s /usr/include/linux/sysctl.h /usr/include/sys/sysctl.h

apt-get clean
rm -rf /var/lib/apt/lists/*
