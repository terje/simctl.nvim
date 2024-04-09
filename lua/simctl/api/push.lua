local M = {}

local util = require("simctl.lib.util")
local simctl = require("simctl.lib.simctl")
local aw = require("simctl.lib.async")
local pickers = require("simctl.lib.pickers")
local config = require("simctl.config")

--- Send a test push notification to an iOS Simulator(s)
-- @param args table containing the following keys:
-- @param args.deviceId string ID of the simulator to affect
-- @param args.appId string the bundle ID of the app to notify
-- @param callback function indicating success or failure
M.push = function(args, callback)
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

    simctl.execute({ "push", args.deviceId, args.appId, args.payload }, function(return_val, humane, stdout, stderr)
      if return_val ~= 0 then
        local message = humane or stderr
        util.notify(message)
      end

      callback(return_val == 0, nil, stdout, stderr)
    end)
  end)
end

return M
