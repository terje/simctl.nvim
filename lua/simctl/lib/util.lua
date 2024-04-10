local M = {}

local config = require("simctl.config")
local Job = require("plenary.job")

M.merge = function(args, defaults)
  args = args or {}
  defaults = defaults or {}
  return vim.tbl_deep_extend("force", {}, defaults, args)
end

M.notify = function(message, level)
  if not config.options.notify then
    return
  end

  level = level or vim.log.levels.INFO
  vim.notify("iOS Simulator: " .. message, level)
end

local simulatorAppStatus = function(callback)
  Job:new({
    command = "ps",
    args = { "aux", "|", "grep", "-v", "grep", "|", "grep", "-c", "Simulator.app" },
    on_exit = function(j, return_val)
      callback(return_val == 1)
    end,
    on_stderr = function(j, data)
      callback(false)
    end,
  }):start()
end

M.openSimulatorApp = function()
  simulatorAppStatus(function(isSimulatorRunning)
    if not isSimulatorRunning then
      os.execute("open -a Simulator.app")
    end
  end)
end

M.trim = function(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

M.defaultCallback = function(success, result)
  if not success then
    M.notify(result, vim.log.levels.ERROR)
  end
end

return M
