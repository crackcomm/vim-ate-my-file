#!/usr/bin/env bash

podman build \
  --build-arg UNAME=$(whoami) \
  --build-arg UID=$(id -u) \
  --build-arg GID=$(id -g) \
  -f containers/Dockerfile -t crackcomm/dev:latest .
