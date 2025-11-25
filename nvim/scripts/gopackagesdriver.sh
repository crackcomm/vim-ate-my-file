#!/usr/bin/env bash

this_script_dir="$(dirname $(realpath "$0"))"
export BAZEL_WRAPPER="$this_script_dir/bazel_wrapper.sh"

exec bazel run -- @io_bazel_rules_go//go/tools/gopackagesdriver "${@}" || true
