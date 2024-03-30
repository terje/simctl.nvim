local M = {}

local simctl = require("simctl.lib.simctl")
local util = require("simctl.lib.util")
local pickers = require("simctl.lib.pickers")
local aw = require("simctl.lib.async")
local config = require("simctl.config")

M.DataNetworkType = {
  HIDE = "hide",
  WIFI = "wifi",
  ["3G"] = "3g",
  ["4G"] = "4g",
  LTE = "lte",
  LTEA = "lte-a",
  LTEPLUS = "lte+",
  ["5G"] = "5g",
  ["5GPLUS"] = "5g+",
  ["5GUWB"] = "5g-uwb",
  ["5GUC"] = "5g-uc",
}

M.WifiMode = {
  SEARCHING = "searching",
  FAILED = "failed",
  ACTIVE = "active",
}

M.CellularMode = {
  NOTSUPPORTED = "notSupported",
  SEARCHING = "searching",
  FAILED = "failed",
  ACTIVE = "active",
}

M.BatteryState = {
  CHARGING = "charging",
  CHARGED = "charged",
  DISCHARGING = "discharging",
}

M.StatusbarFlag = {
  TIME = "time",
  DATA_NETWORK = "dataNetwork",
  WIFI_MODE = "wifiMode",
  WIFI_BARS = "wifiBars",
  CELLULAR_MODE = "cellularMode",
  CELLULAR_BARS = "cellularBars",
  OPERATOR_NAME = "operatorName",
  BATTERY_STATE = "batteryState",
  BATTERY_LEVEL = "batteryLevel",
}

function containsStatusBarFlagKeys(suppliedTable)
  for _, flagValue in pairs(M.StatusbarFlag) do
    if suppliedTable[flagValue] ~= nil then
      return true
    end
  end
  return false
end

M.statusbar = function(args, callback)
  callback = callback or util.defaultCallback
  args = args or {}

  aw.async(function()
    if args.deviceId == nil and config.options.devicePicker then
      args.deviceId = aw.await(pickers.pickDevice)
    end

    args = util.merge(args, {
      deviceId = "booted",
    })

    local commandArgs = { "status_bar", args.deviceId }
    if args.clear then
      table.insert(commandArgs, "clear")
    elseif containsStatusBarFlagKeys(args) then
      table.insert(commandArgs, "override")
      for key, value in pairs(args) do
        if key ~= "deviceId" then
          table.insert(commandArgs, "--" .. key)
          table.insert(commandArgs, value)
        end
      end
    else
      table.insert(commandArgs, "list")
    end

    simctl.execute(commandArgs, function(return_val, humane, stdout, stderr)
      if return_val ~= 0 then
        local message = humane or stderr
        util.notify(message)
      end

      callback(return_val == 0, stdout, stdout, stderr)
    end)
  end)
end

return M
