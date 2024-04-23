local M = {}

local util = require("simctl.lib.util")
local simctl = require("simctl.lib.simctl")
local aw = require("simctl.lib.async")
local pickers = require("simctl.lib.pickers")
local config = require("simctl.config")

local KEY = 'com.apple.BiometricKit.enrollmentChanged'

--- Set biometric enrollment state
-- @param args table containing the following keys:
-- @param args.deviceId string ID of the simulator to affect
-- @param args.enrolled boolean The enrollment state to set
-- @param callback function indicating success or failure
M.setEnrollment = function(args, callback)
  callback = callback or util.defaultCallback
  args = args or {}

  if type(args.enrolled) ~= 'boolean' then
    util.notify("Missing args.enrollment true/false", vim.log.levels.ERROR)
    callback(false)
    return
  end

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

    aw.await(function()
      local enrollment = args.enrolled and '1' or '0'
      simctl.execute({ "spawn", args.deviceId, "notifyutil", "-s", KEY, enrollment },
        function(return_val, humane, stdout, stderr)
          if return_val ~= 0 then
            local message = humane or stderr
            util.notify(message)

            callback(false, nil, stdout, stderr)
            return
          end

          callback(return_val == 0, util.trim(stdout), stdout, stderr)
        end)
    end)

    aw.await(function()
      simctl.execute({ "spawn", args.deviceId, "notifyutil", "-p", KEY },
        function(return_val, humane, stdout, stderr)
          if return_val ~= 0 then
            local message = humane or stderr
            util.notify(message)

            callback(false, nil, stdout, stderr)
            return
          end

          callback(return_val == 0, util.trim(stdout), stdout, stderr)
        end)
    end)
  end)
end

--- Get biometric enrollment state
-- @param args table containing the following keys:
-- @param args.deviceId string ID of the simulator to affect
-- @param callback function indicating success or failure, and the enrollment state
M.isEnrolled = function(args, callback)
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

    simctl.execute({ "spawn", args.deviceId, "notifyutil", "-g", KEY },
      function(return_val, humane, stdout, stderr)
        if return_val ~= 0 then
          local message = humane or stderr
          util.notify(message)

          callback(false, nil, stdout, stderr)
          return
        end

        local value = stdout:match("%d+$")
        local result = value == "1" and true or false

        callback(return_val == 0, result, stdout, stderr)
      end)
  end)
end

--- Toggle biometric enrollment state
-- @param args table containing the following keys:
-- @param args.deviceId string ID of the simulator to affect
-- @param callback function indicating success or failure, and the new enrollment state
M.toggleEnrollment = function(args, callback)
  callback = callback or util.defaultCallback
  args = args or {}

  aw.async(function()
    local enrolled = aw.await(function(cb)
      M.isEnrolled(args, function(success, enrolled)
        if not success then
          enrolled = nil
        end
        cb(enrolled)
      end)
    end)

    if enrolled == nil then
      callback(false, nil)
      return
    end

    args.enrolled = not enrolled

    M.setEnrollment(args, function(success, _, stdout, stderr)
      vim.schedule(function()
        callback(success, success and args.enrolled or nil, stdout, stderr)
      end)
    end)
  end)
end

--- Biometric authentication, matching or non-matching
-- @param args table containing the following keys:
-- @param args.deviceId string ID of the simulator to affect
-- @param args.match boolean whether to simulate a match or non-match
-- @param callback function indicating success or failure, and the new enrollment state
M.authenticate = function(args, callback)
  callback = callback or util.defaultCallback
  args = args or {}
  args.match = args.match or true

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

    local key = "com.apple.BiometricKit_Sim.fingerTouch." .. (args.match and "match" or "nomatch")

    simctl.execute({ "spawn", args.deviceId, "notifyutil", "-p", key },
      function(return_val, humane, stdout, stderr)
        if return_val ~= 0 then
          local message = humane or stderr
          util.notify(message)

          callback(false, nil, stdout, stderr)
          return
        end

        local value = stdout:match("%d+$")
        local result = value == "1" and true or false

        callback(return_val == 0, result, stdout, stderr)
      end)
  end)
end

return M
