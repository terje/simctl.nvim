local M = {}

local util = require("simctl.lib.util")
local simctl = require("simctl.lib.simctl")
local aw = require("simctl.lib.async")
local pickers = require("simctl.lib.pickers")
local config = require("simctl.config")

M.Action = {
  GRANT = "grant",
  REVOKE = "revoke",
  RESET = "reset",
}

M.Service = {
  ALL = "all",
  CALENDAR = "calendar",
  CONTACTS_LIMITED = "contacts-limited",
  CONTACTS = "contacts",
  LOCATION = "location",
  LOCATION_ALWAYS = "location-always",
  PHOTOS_ADD = "photos-add",
  PHOTOS = "photos",
  MEDIA_LIBRARY = "media-library",
  MICROPHONE = "microphone",
  MOTION = "motion",
  REMINDERS = "reminders",
  SIRI = "siri",
}

local executePrivacyAction = function(args, action, service, callback)
  callback = callback or util.defaultCallback
  args = args or {}

  aw.async(function()
    if args.deviceId == nil and config.options.devicePicker then
      args.deviceId = aw.await(pickers.pickDevice)
    end

    if not util.isValidKey(action, M.Action) then
      callback(false, "Invalid action: " .. action)
      return
    end

    if not util.isValidKey(service, M.Service) then
      callback(false, "Invalid service: " .. service)
      return
    end

    if args.appId == nil and config.options.appPicker and action ~= M.Action.RESET then
      args.appId = aw.await(function(appPickerCallback)
        pickers.pickApp(args.deviceId, appPickerCallback)
      end)
    end

    if not args.appId and action ~= M.Action.RESET then
      callback(false, "Missing appId")
      return
    end

    local privacyAction = {
      "privacy",
      args.deviceId,
      action,
      service,
      args.appId,
    }

    simctl.execute(privacyAction, function(return_val, humane, stdout, stderr)
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

M.grant = function(args, service, callback)
  executePrivacyAction(args, M.Action.GRANT, service, callback)
end

M.revoke = function(args, service, callback)
  executePrivacyAction(args, M.Action.REVOKE, service, callback)
end

M.reset = function(args, service, callback)
  executePrivacyAction(args, M.Action.RESET, service, callback)
end

return M
