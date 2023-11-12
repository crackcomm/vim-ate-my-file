#!/bin/bash

set -eu

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <URL> <Expected_SHA256> [--install] [--install-dir]"
  exit 1
fi

url="$1"
expected_sha256="$2"
install=false
install_dir=~/.local/bin

# Check if --install flag is provided
if [ "$#" -eq 3 ] && [ "$3" == "--install" ]; then
  install=true
fi

# Check if --install-dir flag is provided
if [ "$#" -eq 4 ] && [ "$3" == "--install-dir" ]; then
  install=true
  install_dir="$4"
fi

# Temporary file for downloading
downloaded_file="/tmp/$(basename "$url")"

# Download the file with curl
wget -O "$downloaded_file" "$url"

# Check if the download was successful
if [ $? -ne 0 ]; then
  echo "Download failed"
  exit 1
fi

# Calculate the SHA256 checksum of the downloaded file
calculated_sha256=$(sha256sum "$downloaded_file" | cut -d ' ' -f 1)

# Verify the checksum
if [ "$calculated_sha256" != "$expected_sha256" ]; then
  echo "Checksum verification failed. Checksum was $calculated_sha256 expected $expected_sha256."
  exit 1
fi

# Perform installation (extraction) if the --install flag is present
if $install; then
  mkdir -p $install_dir

  if file --mime-type "$downloaded_file" | grep -q "application/gzip"; then
    tar -xzf "$downloaded_file" -C $install_dir
  elif file --mime-type "$downloaded_file" | grep -q "application/x-tar"; then
    tar -xf "$downloaded_file" -C $install_dir
  elif file --mime-type "$downloaded_file" | grep -q "application/zip"; then
    unzip -q "$downloaded_file" -d $install_dir
  elif file --mime-type "$downloaded_file" | grep -q "application/vnd.debian.binary-package"; then
    dpkg -i "$downloaded_file"
  elif file --mime-type "$downloaded_file" | grep -q "application/x-sharedlib"; then
    mv "$downloaded_file" $install_dir
  else
    echo "Unknown archive format or not an archive. Skipping extraction."
  fi

  # Remove the downloaded archive
  rm -f "$downloaded_file"
else
  echo "Download completed. Use the --install flag to extract and install the contents."
fi
