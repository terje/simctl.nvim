local M = {}

local pad = function(str, reference)
  local padLength = #reference - #str

  if padLength > 0 then
    str = str .. string.rep(" ", padLength)
  end

  return str
end

M.pickApp = function(deviceId, callback)
  if not deviceId then
    callback(nil)
    return
  end

  require("simctl.api").listapps({ deviceId = deviceId }, function(success, apps)
    if not success then
      callback(nil)
      return
    end

    table.sort(apps, function(a, b)
      if a.ApplicationType == b.ApplicationType then
        return a.CFBundleDisplayName < b.CFBundleDisplayName
      else
        return a.ApplicationType == "User"
      end
    end)

    local selectApps = {}
    for _, app in pairs(apps) do
      table.insert(
        selectApps,
        pad(app.ApplicationType, "System") .. "\t" .. app.CFBundleDisplayName .. " - " .. app.CFBundleIdentifier
      )
    end

    vim.schedule(function()
      vim.ui.select(selectApps, { prompt = "Select an app" }, function(selected)
        if selected == nil then
          callback(nil)
          return
        end

        callback(selected:match(".*%s%-%s(.*)"))
      end)
    end)
  end)
end

M.pickDevice = function(callback)
  require("simctl.api").list(function(success, devices, _, _)
    if not success then
      callback(nil)
      return
    end

    table.sort(devices, function(a, b)
      if a.state ~= b.state then
        return a.state == "Booted"
      end

      if a.os ~= b.os then
        return a.os > b.os
      end

      return a.name < b.name
    end)

    local selectDevices = {}
    for _, device in pairs(devices) do
      table.insert(
        selectDevices,
        pad(device.state, "Shutdown") .. " - " .. device.os .. ": " .. device.name .. " - " .. device.udid
      )
    end

    vim.schedule(function()
      vim.ui.select(selectDevices, { prompt = "Select a device" }, function(selected)
        if selected == nil then
          callback(nil)
          return
        end

        callback(selected:match(".*%s%-%s(.*)"))
      end)
    end)
  end)
end

M.pickTableValue = function(prompt, values, callback)
  vim.ui.select(values, { prompt = prompt }, function(selected)
    callback(selected)
  end)
end

return M
