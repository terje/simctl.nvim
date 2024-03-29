local M = {}

local util = require("simctl.lib.util")
local simctl = require("simctl.lib.simctl")
local aw = require("simctl.lib.async")
local pickers = require("simctl.lib.pickers")
local config = require("simctl.config")

--- Open a URL on an iOS Simulator(s)
-- @param args.deviceId string ID of the simulator to affect
-- @param args.url string the URL to open. Required
-- @param callback function indicating success or failure
M.openurl = function(args, callback)
	callback = callback or function() end
	args = args or {}

	if args.url == nil then
		util.notify("No url provided", vim.log.levels.ERROR)
		callback(false)
		return
	end

	aw.async(function()
		if args.deviceId == nil and config.options.devicePicker then
			args.deviceId = aw.await(pickers.pickDevice)
		end

		args = util.merge(args, {
			deviceId = "booted",
		})

		simctl.execute({ "openurl", args.deviceId, args.url }, function(return_val, humane, stdout, stderr)
			if return_val ~= 0 then
				local message = humane or stderr
				util.notify(message)
			end

			callback(return_val == 0, nil, stdout, stderr)
		end)
	end)
end

return M
