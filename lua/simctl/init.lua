local M = {}

local config = require("simctl.config")
local util = require("simctl.util")
local Job = require("plenary.job")

--- Launch app on all running or a specific iOS Simulator(s)
-- @param appId the app ID of the app to launch
-- @param callback function to call when command finishes
-- @param simulatorId the ID of the simulator to affect. Defaults to "booted"
M.launch = function(appId, callback, simulatorId)
  simulatorId = simulatorId or "booted"
  util.execute("xcrun simctl launch " .. simulatorId .. " " .. appId, callback)
end

--- Quit app on all running or a specific iOS Simulator(s)
-- @param appId the app ID of the app to quit
-- @param opts simulatorId the ID of the simulator to affect. Defaults to "booted"
-- @param callback function to call when command finishes
M.terminate = function(appId, opts, callback)
  callback = callback or function() end
  opts = vim.tbl_deep_extend("force", {}, {
    simulatorId = "booted",
  }, opts or {})

  local outputBuffer = {}

  Job:new({
    command = "xcrun",
    args = { "simctl", "terminate", opts.simulatorId, appId },
    on_exit = function(_, return_val)
      if return_val == 0 then
        util.notify("Application terminated!")
      else
        local stderr = table.concat(outputBuffer, "\n")
        if util.errorCode(stderr) == 3 then
          util.notify(
            "iOS Simulator: Could not find the app " .. appId .. " to terminate it",
            vim.log.levels.ERROR
          )
        else
          util.notify(
            "iOS Simulator: An unknown error occurred when attempting to terminate app (" .. stderr .. ")",
            vim.log.levels.ERROR
          )
        end
      end

      callback(return_val == 0)
    end,
    on_stderr = function(_, data)
      if data ~= "" then
        table.insert(outputBuffer, data)
      end
    end,
  }):start()
end

--- Uninstall app on all running or a specific iOS Simulator(s)
-- @param appId the app ID of the app to uninstall
-- @param callback function to call when command finishes
-- @param simulatorId the ID of the simulator to affect. Defaults to "booted"
M.uninstall = function(appId, callback, simulatorId)
  simulatorId = simulatorId or "booted"
  util.execute("xcrun simctl uninstall " .. simulatorId .. " " .. appId, callback)
end

--- Launch app on all running or a specific iOS Simulator(s)
-- @param appId the app ID of the app to launch
-- @param callback function to call when command finishes
-- @param simulatorId the ID of the simulator to affect. Defaults to "booted"
M.erase = function(callback, simulatorId)
  simulatorId = simulatorId or "booted"
  util.execute("xcrun simctl erase " .. simulatorId, callback)
end

-- @param opts nil|table
M.setup = function(opts)
  config.setup(opts)
end

return M
