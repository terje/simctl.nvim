local M = {}

local util = require("simctl.lib.util")
local simctl = require("simctl.lib.simctl")
local aw = require("simctl.lib.async")
local pickers = require("simctl.lib.pickers")
local config = require("simctl.config")

M.ContentSizeModifier = {
  INCREMENT = "increment",
  DECREMENT = "decrement",
}

M.ContentSize = {
  EXTRA_SMALL = "extra-small",
  SMALL = "small",
  MEDIUM = "medium",
  LARGE = "large",
  EXTRA_LARGE = "extra-large",
  EXTRA_EXTRA_LARGE = "extra-extra-large",
  EXTRA_EXTRA_EXTRA_LARGE = "extra-extra-extra-large",
  ACCESSIBILITY_MEDIUM = "accessibility-medium",
  ACCESSIBILITY_LARGE = "accessibility-large",
  ACCESSIBILITY_EXTRA_LARGE = "accessibility-extra-large",
  ACCESSIBILITY_EXTRA_EXTRA_LARGE = "accessibility-extra-extra-large",
  ACCESSIBILITY_EXTRA_EXTRA_EXTRA_LARGE = "accessibility-extra-extra-extra-large",
}

local orderedContentSizes = {
  M.ContentSize.EXTRA_SMALL,
  M.ContentSize.SMALL,
  M.ContentSize.MEDIUM,
  M.ContentSize.LARGE,
  M.ContentSize.EXTRA_LARGE,
  M.ContentSize.EXTRA_EXTRA_LARGE,
  M.ContentSize.EXTRA_EXTRA_EXTRA_LARGE,
  M.ContentSize.ACCESSIBILITY_MEDIUM,
  M.ContentSize.ACCESSIBILITY_LARGE,
  M.ContentSize.ACCESSIBILITY_EXTRA_LARGE,
  M.ContentSize.ACCESSIBILITY_EXTRA_EXTRA_LARGE,
  M.ContentSize.ACCESSIBILITY_EXTRA_EXTRA_EXTRA_LARGE,
}

--- Get the content size of a running or a specific iOS Simulator(s)
-- @param args Table containing the following keys:
-- @param args.deviceId string The id of the device to affect
M.contentSize = function(args, callback)
  callback = callback or util.defaultCallback
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

    simctl.execute({ "ui", args.deviceId, "content_size" }, function(return_val, humane, stdout, stderr)
      if return_val ~= 0 then
        local message = humane or stderr
        util.notify(message)

        callback(false, nil, stdout, stderr)
        return
      end

      callback(return_val == 0, util.trim(stdout), stdout, stderr)
    end)
  end)
end

--- Set the content size of a running or a specific iOS Simulator(s)
-- @param args Table containing the following keys:
-- @param args.deviceId string The id of the device to affect
-- @param args.size string The new size of the content
M.setContentSize = function(args, callback)
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

    local isValidContentSize = util.isValidKey(args.size, M.ContentSize)
    local isValidContentSizeModifier = util.isValidKey(args.size, M.ContentSizeModifier)

    if args.size and not isValidContentSize and not isValidContentSizeModifier then
      util.notify(args.size .. " is not a valid content size", vim.log.levels.ERROR)
      callback(false)
      return
    end

    if not args.size then
      local sizeOptions = {}
      for _, size in pairs(M.ContentSize) do
        table.insert(sizeOptions, size)
      end
      args.size = aw.await(function(cb)
        pickers.pickTableValue("Pick a content size", sizeOptions, cb)
      end)
    end

    simctl.execute({ "ui", args.deviceId, "content_size", args.size }, function(return_val, humane, stdout, stderr)
      if return_val ~= 0 then
        local message = humane or stderr
        util.notify(message)

        callback(false, nil, stdout, stderr)
        return
      end

      callback(return_val == 0, stdout, stdout, stderr)
    end)
  end)
end

local nextSizeUp = function(currentSize)
  for i, size in ipairs(orderedContentSizes) do
    if size == currentSize then
      return orderedContentSizes[i + 1]
    end
  end

  return nil
end

local nextSizeDown = function(currentSize)
  for i, size in ipairs(orderedContentSizes) do
    if size == currentSize then
      return orderedContentSizes[i - 1]
    end
  end

  return nil
end

M.increaseContentSize = function(args, callback)
  callback = callback or function() end
  args = args or {}

  M.contentSize(args, function(success, result)
    if not success then
      callback(false)
      return
    end

    local newSize = nextSizeUp(result)
    if not newSize then
      callback(false)
      return
    end

    args.size = newSize

    M.setContentSize(args, callback)
  end)
end

M.decreaseContentSize = function(args, callback)
  callback = callback or function() end
  args = args or {}

  M.contentSize(args, function(success, result)
    if not success then
      callback(false)
      return
    end

    local newSize = nextSizeDown(result)

    if not newSize then
      callback(false)
      return
    end

    args.size = newSize

    M.setContentSize(args, callback)
  end)
end

M.Appearance = {
  LIGHT = "light",
  DARK = "dark",
}

M.appearance = function(args, callback)
  callback = callback or util.defaultCallback
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

    simctl.execute({ "ui", args.deviceId, "appearance" }, function(return_val, humane, stdout, stderr)
      if return_val ~= 0 then
        local message = humane or stderr
        util.notify(message)

        callback(false, nil, stdout, stderr)
        return
      end

      callback(return_val == 0, util.trim(stdout), stdout, stderr)
    end)
  end)
end

--- Set the appearance of all running or a specific iOS Simulator(s)
-- @param args Table containing the following keys:
-- @param args.deviceId string The id of the device to affect
-- @param args.size string The appearance. Returns the current appearance if not supplied.
M.setAppearance = function(args, callback)
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

    local isValidAppearance = util.isValidKey(args.appearance, M.Appearance)

    if args.appearance and not isValidAppearance then
      util.notify(args.appearance .. " is not a valid appearance", vim.log.levels.ERROR)
      callback(false)
      return
    end

    if not args.appearance then
      local appearanceOptions = {}
      for _, appearance in pairs(M.Appearance) do
        table.insert(appearanceOptions, appearance)
      end
      args.appearance = aw.await(function(cb)
        pickers.pickTableValue("Pick an appearance", appearanceOptions, cb)
      end)
    end

    simctl.execute(
      { "ui", args.deviceId, "appearance", args.appearance },
      function(return_val, humane, stdout, stderr)
        if return_val ~= 0 then
          local message = humane or stderr
          util.notify(message)

          callback(false, nil, stdout, stderr)
          return
        end

        callback(return_val == 0, util.trim(stdout), stdout, stderr)
      end
    )
  end)
end

M.toggleAppearance = function(args, callback)
  callback = callback or util.defaultCallback
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

    local appearance = aw.await(function(cb)
      M.appearance(args, function(success, result)
        cb(result)
      end)
    end)

    -- Toggle appearance
    args.appearance = appearance == M.Appearance.LIGHT and M.Appearance.DARK or M.Appearance.LIGHT

    M.setAppearance(args, callback)
  end)
end

M.increaseContrast = function(args, callback)
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

    if args.enabled and not type(args.enabled) == "boolean" then
      util.notify(args.enabled .. " is not a boolean", vim.log.levels.ERROR)
      callback(false)
      return
    end

    local enabled
    if args.enabled ~= nil then
      enabled = args.enabled and "enabled" or "disabled"
    end

    simctl.execute(
      { "ui", args.deviceId, "increase_contrast", enabled },
      function(return_val, humane, stdout, stderr)
        if return_val ~= 0 then
          local message = humane or stderr
          util.notify(message)

          callback(false, nil, stdout, stderr)
          return
        end

        local result
        if args.enabled == nil then
          result = string.find(stdout, "enabled", 1, true) ~= nil
        end

        callback(return_val == 0, result, stdout, stderr)
      end
    )
  end)
end

return M
