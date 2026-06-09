#!/usr/bin/env bash

this_script_dir="$(dirname $(realpath "$0"))"
export BAZEL_WRAPPER="$this_script_dir/bazel_wrapper.sh"

GOPACKAGESDRIVER_BIN=bazel-bin/external/rules_go+/go/tools/gopackagesdriver/gopackagesdriver_/gopackagesdriver

if [ ! -x $GOPACKAGESDRIVER_BIN ]; then
	exec bazel run -- @io_bazel_rules_go//go/tools/gopackagesdriver "${@}" || true
else
	export BUILD_WORKSPACE_DIRECTORY=$(pwd)
	export BUILD_WORKING_DIRECTORY=$(pwd)
	exec $GOPACKAGESDRIVER_BIN "${@}" || true
fi
