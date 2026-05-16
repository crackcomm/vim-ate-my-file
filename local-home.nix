{ ... }: {
  # Programming
  local.bazel.enable = true;
  local.common-libs.enable = false;
  local.common-tools.enable = true;
  local.cpp.enable = false;
  local.lua.enable = true;
  local.nodejs.enable = false;
  local.python.enable = false; # true;
  local.rust.enable = false;
}
