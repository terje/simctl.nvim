local M = {}

local util = require("simctl.lib.util")
local simctl = require("simctl.lib.simctl")
local aw = require("simctl.lib.async")
local pickers = require("simctl.lib.pickers")
local config = require("simctl.config")

--- Shut down a booted or a specific iOS Simulator(s)
-- @param args Table containing the following keys:
-- @param args.deviceId string The simulator identifier. Optional
-- @param callback function to call when command finishes, indicating success or failure
M.shutdown = function(args, callback)
  callback = callback or function() end
  args = args or {}

  aw.async(function()
    if args.deviceId == nil and config.options.devicePicker then
      args.deviceId = aw.await(pickers.pickDevice)
    end

    if config.options.defaultToBootedDevice then
      args = util.merge(args, {
        deviceId = "booted",
      })
    end

    if args.deviceId == nil then
      util.notify("No device selected", vim.log.levels.ERROR)
      callback(false)
      return
    end

    simctl.execute({ "shutdown", args.deviceId }, function(return_val, humane, stdout, stderr)
      if return_val ~= 0 then
        local message = humane or stderr
        util.notify(message)
      end

      callback(return_val == 0, nil, stdout, stderr)
    end)
  end)
end

return M
