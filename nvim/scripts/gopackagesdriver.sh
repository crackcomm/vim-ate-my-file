#!/usr/bin/env bash

# If BAZEL_WRAPPER is not defined - exit with an error message
if [ -z "$BAZEL_WRAPPER" ]; then
  echo "Error: BAZEL_WRAPPER is not defined. Please run this script from within a Bazel build environment."
  exit 1
fi

GOPACKAGESDRIVER_BIN=bazel-bin/external/rules_go+/go/tools/gopackagesdriver/gopackagesdriver_/gopackagesdriver

if [ ! -x $GOPACKAGESDRIVER_BIN ]; then
  exec bazel run -- @io_bazel_rules_go//go/tools/gopackagesdriver "${@}" || true
else
  export BUILD_WORKSPACE_DIRECTORY=$(pwd)
  export BUILD_WORKING_DIRECTORY=$(pwd)
  exec $GOPACKAGESDRIVER_BIN "${@}" || true
fi
