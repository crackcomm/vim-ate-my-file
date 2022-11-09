#!/bin/bash
set -eux

SAVE_TO="${1:-"$(mktemp)"}"

curl -s https://apod.nasa.gov/apod/astropix.html \
  | grep -Po '(?<=<a href=").*(?=")' | head -n2 | tail -n1 \
  | xargs -I {} curl -o "${SAVE_TO}" -L "https://apod.nasa.gov/apod/"{}


COLOR_SCHEME=$(gsettings get org.gnome.desktop.interface color-scheme)

if [[ "${COLOR_SCHEME}" == "'prefer-dark'" ]]; then
  gsettings set org.gnome.desktop.background picture-uri-dark "${SAVE_TO}"
else
  gsettings set org.mate.background picture-filename "${SAVE_TO}"
fi
