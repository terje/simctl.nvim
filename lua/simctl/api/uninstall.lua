local M = {}

local util = require("simctl.lib.util")
local simctl = require("simctl.lib.simctl")
local aw = require("simctl.lib.async")
local pickers = require("simctl.lib.pickers")
local config = require("simctl.config")

--- Uninstall app on a running or a specific iOS Simulator(s)
-- @param args Table containing the following keys:
-- @param args.appId string The application identifier of the app to uninstall
-- @param args.deviceId string The simulator identifier
-- @param callback function The function to call upon completion. Optional
M.uninstall = function(args, callback)
  callback = callback or function(_, _, _) end
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

    if args.appId == nil and config.options.appPicker then
      args.appId = aw.await(function(appPickerCallback)
        pickers.pickApp(args.deviceId, appPickerCallback)
      end)
    end

    if args.appId == nil then
      util.notify("appId is required", vim.log.levels.ERROR)
      callback(nil)
      return
    end

    simctl.execute({ "uninstall", args.deviceId, args.appId }, function(return_val, humane, stdout, stderr)
      if return_val ~= 0 then
        local message = humane or stderr
        util.notify(message)
      end

      callback(return_val == 0, nil, stdout, stderr)
    end)
  end)
end

return M
