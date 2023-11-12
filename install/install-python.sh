#!/usr/bin/env bash

set -e

add-apt-repository -y ppa:deadsnakes/ppa
apt-get install -y --no-install-recommends \
  python3.12

curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12

update-alternatives --install /usr/bin/python3 python3 $(which python3.12) 312
update-alternatives --install /usr/bin/pip pip $(which pip3.12) 312

apt-get clean
rm -rf /var/lib/apt/lists/*
