local M = {}

local util = require("simctl.lib.util")
local simctl = require("simctl.lib.simctl")

--- Launch app on all running or a specific iOS Simulator(s)
-- @param args Table containing the following keys:
-- @param args.appId string The application identifier of the app to launch
-- @param args.deviceId string The simulator identifier. Optional, defaults to "booted"
-- @param callback function The function to call upon completion. Optional
M.launch = function(args, callback)
	callback = callback or function(_, _, _) end

	if args.appId == nil then
		util.notify("No appId provided", vim.log.levels.ERROR)
		callback(false)
		return
	end

	args = util.merge(args, {
		deviceId = "booted",
	})

	simctl.execute({ "launch", args.deviceId, args.appId }, function(return_val, humane, stdout, stderr)
		if return_val ~= 0 then
			local message = humane or stderr
			util.notify(message)
		end

		callback(return_val == 0, nil, stdout, stderr)
	end)
end

return M
