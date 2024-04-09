local M = {}

local util = require("simctl.lib.util")
local simctl = require("simctl.lib.simctl")
local aw = require("simctl.lib.async")
local pickers = require("simctl.lib.pickers")
local config = require("simctl.config")

local function filterAppsByType(parentTbl, appType)
  local filteredApps = {}
  for key, subTbl in pairs(parentTbl) do
    if subTbl.ApplicationType == appType then
      filteredApps[key] = subTbl
    end
  end
  return filteredApps
end

M.AppType = {
  User = "User",
  System = "System",
}

--- List installed apps
-- @param args.appType string Optional type of app to filter by, User or System
-- @param callback function indicating success or failure and a table of apps
M.listapps = function(args, callback)
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

    simctl.execute({ "listapps", args.deviceId }, function(return_val, humane, stdout, stderr)
      if return_val ~= 0 then
        local message = humane or stderr
        util.notify(message)

        callback(false, nil, stdout, stderr)
        return
      end

      vim.schedule(function()
        local tmpFilePath = os.tmpname()
        local file = io.open(tmpFilePath, "w")
        if file then
          file:write(stdout)
          file:close()
        else
          callback(false)
          return
        end

        local command = string.format('plutil -convert json -o - "%s"', tmpFilePath)
        local jsonOutput = vim.fn.system(command)

        if vim.v.shell_error ~= 0 then
          callback(false, nil, jsonOutput, nil)
          os.remove(tmpFilePath)
          return
        end

        local keyValueApps = vim.json.decode(jsonOutput)
        if not keyValueApps then
          callback(false, nil, jsonOutput, nil)
          os.remove(tmpFilePath)
          return
        end

        local apps = {}
        for _, value in pairs(keyValueApps) do
          table.insert(apps, value)
        end

        if args.appType then
          apps = filterAppsByType(apps, args.appType)
        end

        os.remove(tmpFilePath)

        callback(true, apps)
      end)
    end)
  end)
end

return M
