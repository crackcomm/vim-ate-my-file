local R = R
local Path = require("plenary.path")
local dap = R("dap")
local dapui = R("dapui")
local log = R("crackcomm.log")
local telescope = R("telescope.builtin")
local bazel = R("crackcomm.bazel")
local bazel_python = R("crackcomm.bazel.python")
local vt = R("nvim-dap-virtual-text")

local DEFAULT_ADAPTER = {
  type = "server",
  host = "127.0.0.1",
  port = 5678, -- Port for debugpy server
}

local DEFAULT_CONFIG = {
  type = "python", -- the adapter type
  request = "attach", -- attach to a running process
  connect = {
    host = "127.0.0.1",
    port = 5678,
  },
  mode = "remote",
  name = "Attach to Bazel Debugpy",
}

local M = {}

-- vim.g.last_dap_target = nil

local bazel_build = function(target)
  if not target or not bazel.workspace_exists() then
    return
  end

  vim.g.last_dap_target = target

  local progress = R("fidget.progress")

  local handle = progress.handle.create({
    title = "Bazel build",
    message = "Building...",
    lsp_client = { name = "bazel" },
    percentage = 0,
  })

  local percentage = 0
  bazel.build(target, function(done, success)
    -- check if failed
    if done and not success then
      handle:cancel()
      return
    end

    if not done then
      percentage = math.min(percentage + 10, 60)
      handle:report({ percentage = percentage })
      return
    end

    local output_path = bazel.output_path(target)
    if not bazel_python.debug_binary(output_path) then
      handle:cancel()
      return
    end

    handle:report({ title = "Starting", message = "Launching " .. target, percentage = 70 })

    local remote_root = output_path .. ".runfiles/" .. bazel.main_module_name()

    vim.fn.jobstart({ "/usr/bin/python3", output_path }, { cwd = remote_root })

    -- Wait briefly for debugpy server to start up
    vim.defer_fn(function()
      -- Start the DAP session
      dap.run({
        type = "python",
        request = "attach",
        justMyCode = false,
        name = "Attach to debugpy",
        connect = {
          host = "127.0.0.1",
          port = 5678,
        },
        pathMappings = {
          {
            localRoot = vim.fn.getcwd(),
            remoteRoot = remote_root,
          },
        },
        env = {
          PYTHONPATH = remote_root,
        },
      }, { new = true })

      handle:report({ title = "Starting debugger", percentage = 100 })
      handle:finish()
    end, 400) -- Adjust delay as needed
  end)
end

M.bazel = function(opts)
  if type(opts) == "string" then
    bazel_build(opts)
  end
  bazel.picker(bazel_build, { auto_select = true })
end

M.run_last = function()
  if vim.g.last_dap_target then
    M.close()
    bazel_build(vim.g.last_dap_target)
  else
    vim.notify("No last target to run")
  end
end

M.setupui = function()
  vt.setup()
  local default_config = R("dapui.config")
  dapui.setup(vim.fn.extend(default_config, {
    layouts = {
      {
        elements = {
          -- "stacks",
          -- "watches",
          -- "breakpoints",
          "scopes",
          "repl",
        },
        size = 10,
        position = "bottom",
      },
    },
  }))
end

M.close = function()
  dapui.close()
  dap.disconnect()
  dap.close()
  vim.notify("Debugger closed")
  vt.refresh()
end

local function setup_python()
  R("dap-python").setup("/usr/bin/python3.10")
  dap.adapters.python = DEFAULT_ADAPTER
  table.insert(dap.configurations.python, DEFAULT_CONFIG)
end

local function setup_cpp()
  dap.adapters.codelldb = {
    type = "server",
    port = "${port}",
    executable = {
      command = "codelldb",
      args = { "--port", "${port}" },
    },
  }

  dap.configurations.cpp = {
    {
      type = "codelldb",
      -- request = "attach",
      name = "Launch codelldb",
      request = "launch", -- could also attach to a currently running process
      program = function()
        local f = bazel.current_source_output()
        return vim.fn.input("Path to executable: ", f, "file")
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
      args = {},
      runInTerminal = false,
      sourceMap = {
        ["/proc/self/cwd"] = "${workspaceFolder}",
      },
    },
  }
end

M.setup = function()
  setup_python()
  setup_cpp()

  vim.keymap.set("n", "<C-b>", dap.toggle_breakpoint, { desc = "[DAP] Toggle [B]reakpoint" })
  vim.keymap.set("n", "<C-F5>", dap.step_out, { desc = "[D]ebug Step Out" })
  vim.keymap.set("n", "<C-F6>", dap.step_over, { desc = "[D]ebug Step Over" })
  vim.keymap.set("n", "<C-F8>", dap.step_into, { desc = "[D]ebug Step Into" })
  vim.keymap.set("n", "<leader>dr", M.run_last, { desc = "[D]ebug [R]un Last" })
  vim.keymap.set("n", "<leader>db", M.bazel, { desc = "[D]ebug [B]azel" })
  vim.keymap.set("n", "<leader>dc", dap.clear_breakpoints, { desc = "[D]ebug [C]lear Breakpoints" })
  vim.keymap.set("n", "<leader>ds", dap.goto_, { desc = "[D]ebug [S]kipping [G]oto" })
  vim.keymap.set("n", "<leader>dg", dap.run_to_cursor, { desc = "[D]ebug [G]oto" })
  vim.keymap.set("n", "<leader>dq", M.close, { desc = "[D]ebug [Q]uit" })
  vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "[D]ebug [U]I" })

  vim.api.nvim_create_user_command("DapBazel", M.bazel, { nargs = 0 })
end

return M
