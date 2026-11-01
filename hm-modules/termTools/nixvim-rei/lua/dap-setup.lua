-- DAP: adapters come from extraPackages, codelldb path from vim.g above.
local dap = require("dap")
local dapui = require("dapui")

dapui.setup({})
dap.listeners.after.event_initialized["dapui"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui"] = function()
  dapui.close()
end

dap.adapters.python = {
  type = "executable",
  command = "python3",
  args = { "-m", "debugpy.adapter" },
}
dap.adapters.delve = {
  type = "server",
  port = "${port}",
  executable = { command = "dlv", args = { "dap", "-l", "127.0.0.1:${port}" } },
}
dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = { command = vim.g.codelldb_path, args = { "--port", "${port}" } },
}

dap.configurations.python = {
  { type = "python", request = "launch", name = "Launch file", program = "${file}" },
}
dap.configurations.go = {
  { type = "delve", request = "launch", name = "Debug file", program = "${file}" },
  { type = "delve", request = "launch", name = "Debug test", mode = "test", program = "${file}" },
}
dap.configurations.rust = {
  {
    type = "codelldb",
    request = "launch",
    name = "Launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
  },
}
