#!/usr/bin/env bash

# Some `bazel run` actions like `:refresh_compile_commands` need to run
# bazel itself.
BAZEL_ACTION_PATH="/usr/bin:/bin:/run/current-system/sw/bin"

env -i TERM=xterm-256color PATH="$BAZEL_ACTION_PATH" $BAZEL_REAL "$@"
