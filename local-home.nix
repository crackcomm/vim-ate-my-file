{ ... }: {
  # Programming
  local.bazel.enable = false; # true;
  local.common-libs.enable = false;
  local.common-tools.enable = false; # true;
  local.cpp.enable = false;
  local.lua.enable = false; # true;
  local.nodejs.enable = false;
  local.python.enable = false; # true;
  local.rust.enable = false;
}
