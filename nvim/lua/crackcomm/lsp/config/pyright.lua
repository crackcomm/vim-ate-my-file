local util = require("lspconfig/util")

local path = util.path

-- Source: https://github.com/neovim/nvim-lspconfig/issues/500#issuecomment-851247107
local function get_python_path(workspace)
  -- Use activated virtualenv.
  if vim.env.VIRTUAL_ENV then
    return path.join(vim.env.VIRTUAL_ENV, "bin", "python")
  end

  -- Find and use virtualenv in workspace directory.
  for _, pattern in ipairs({ "*", ".*" }) do
    local match = vim.fn.glob(path.join(workspace, pattern, "pyvenv.cfg"))
    if match ~= "" then
      return path.join(path.dirname(match), "bin", "python")
    end
  end

  return "/usr/bin/python"
end

local function get_bazel_python_paths(workspace)
  return vim.fn.globpath(workspace, "bazel-*/external/pip_deps_*/site-packages", false, 1)
end

return {
  settings = {
    python = {
      analysis = {
        autoImportCompletions = true,
      },
    },
  },
  before_init = function(_, config)
    if config.root_dir ~= nil then
      config.settings.python.pythonPath = get_python_path(config.root_dir)

      -- Add Bazel paths to extraPaths
      local extra_paths = get_bazel_python_paths(config.root_dir)
      config.settings.python.analysis.extraPaths = extra_paths
    end
  end,
}
