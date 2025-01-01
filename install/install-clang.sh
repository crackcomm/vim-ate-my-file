#!/usr/bin/env bash

set -e

CLANG_VERSION=19
CLANG_PRIORITY=190
UBUNTU_CODENAME=$(awk -F= '/UBUNTU_CODENAME/{print $2}' /etc/os-release)

# LLVM/Clang: https://apt.llvm.org/
apt-key adv --fetch-keys https://apt.llvm.org/llvm-snapshot.gpg.key

# Set up custom sources
cat >/etc/apt/sources.list.d/custom.list <<SOURCES

# LLVM/Clang repository
deb http://apt.llvm.org/${UBUNTU_CODENAME}/ llvm-toolchain-${UBUNTU_CODENAME}-${CLANG_VERSION} main
deb-src http://apt.llvm.org/${UBUNTU_CODENAME}/ llvm-toolchain-${UBUNTU_CODENAME}-${CLANG_VERSION} main
SOURCES

apt-get update
apt-get install -y --no-install-recommends \
  llvm-${CLANG_VERSION} \
  clang-${CLANG_VERSION} \
  lld-${CLANG_VERSION} \
  clangd-${CLANG_VERSION} \
  clang-format-${CLANG_VERSION}

update-alternatives --remove clangd /usr/bin/clangd
update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-${CLANG_VERSION} ${CLANG_PRIORITY}

update-alternatives --remove clang-format /usr/bin/clang-format
update-alternatives \
  --install /usr/bin/clang-format clang-format /usr/bin/clang-format-${CLANG_VERSION} ${CLANG_PRIORITY} \
  --slave /usr/bin/clang-format-diff clang-format-diff /usr/bin/clang-format-diff-${CLANG_VERSION}

update-alternatives --remove clang /usr/bin/clang
update-alternatives \
  --install /usr/bin/clang clang /usr/bin/clang-${CLANG_VERSION} ${CLANG_PRIORITY} \
  --slave /usr/bin/clang++ clang++ /usr/bin/clang++-${CLANG_VERSION} \
  --slave /usr/bin/asan_symbolize asan_symbolize /usr/bin/asan_symbolize-${CLANG_VERSION} \
  --slave /usr/bin/clang-cpp clang-cpp /usr/bin/clang-cpp-${CLANG_VERSION}

update-alternatives --remove lld /usr/bin/lld
update-alternatives \
  --install /usr/bin/lld lld /usr/bin/lld-${CLANG_VERSION} ${CLANG_PRIORITY} \
  --slave /usr/bin/ld.lld ld.lld /usr/bin/lld-${CLANG_VERSION}

update-alternatives --remove llvm-config /usr/bin/llvm-config
update-alternatives \
  --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-${CLANG_VERSION} ${CLANG_PRIORITY} \
  --slave /usr/bin/llvm-ar llvm-ar /usr/bin/llvm-ar-${CLANG_VERSION} \
  --slave /usr/bin/llvm-as llvm-as /usr/bin/llvm-as-${CLANG_VERSION} \
  --slave /usr/bin/llvm-bcanalyzer llvm-bcanalyzer /usr/bin/llvm-bcanalyzer-${CLANG_VERSION} \
  --slave /usr/bin/llvm-cov llvm-cov /usr/bin/llvm-cov-${CLANG_VERSION} \
  --slave /usr/bin/llvm-diff llvm-diff /usr/bin/llvm-diff-${CLANG_VERSION} \
  --slave /usr/bin/llvm-dis llvm-dis /usr/bin/llvm-dis-${CLANG_VERSION} \
  --slave /usr/bin/llvm-dwarfdump llvm-dwarfdump /usr/bin/llvm-dwarfdump-${CLANG_VERSION} \
  --slave /usr/bin/llvm-extract llvm-extract /usr/bin/llvm-extract-${CLANG_VERSION} \
  --slave /usr/bin/llvm-link llvm-link /usr/bin/llvm-link-${CLANG_VERSION} \
  --slave /usr/bin/llvm-mc llvm-mc /usr/bin/llvm-mc-${CLANG_VERSION} \
  --slave /usr/bin/llvm-nm llvm-nm /usr/bin/llvm-nm-${CLANG_VERSION} \
  --slave /usr/bin/llvm-objdump llvm-objdump /usr/bin/llvm-objdump-${CLANG_VERSION} \
  --slave /usr/bin/llvm-ranlib llvm-ranlib /usr/bin/llvm-ranlib-${CLANG_VERSION} \
  --slave /usr/bin/llvm-readobj llvm-readobj /usr/bin/llvm-readobj-${CLANG_VERSION} \
  --slave /usr/bin/llvm-rtdyld llvm-rtdyld /usr/bin/llvm-rtdyld-${CLANG_VERSION} \
  --slave /usr/bin/llvm-size llvm-size /usr/bin/llvm-size-${CLANG_VERSION} \
  --slave /usr/bin/llvm-stress llvm-stress /usr/bin/llvm-stress-${CLANG_VERSION} \
  --slave /usr/bin/llvm-symbolizer llvm-symbolizer /usr/bin/llvm-symbolizer-${CLANG_VERSION} \
  --slave /usr/bin/llvm-tblgen llvm-tblgen /usr/bin/llvm-tblgen-${CLANG_VERSION}

apt-get clean
rm -rf /var/lib/apt/lists/*
