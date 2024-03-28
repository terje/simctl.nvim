local M = {}

local util = require("simctl.lib.util")
local simctl = require("simctl.lib.simctl")

--- Erase (reset) all or a specific iOS Simulator(s)
-- @param args.deviceId string ID of the simulator to affect, or "all" for all Simulators
-- @param callback function app ID of the app to launch
M.erase = function(args, callback)
	callback = callback or function() end

	if args.deviceId == nil then
		util.notify("No deviceId provided", vim.log.levels.ERROR)
		callback(false)
		return
	end

	simctl.execute({ "erase", args.deviceId }, function(return_val, humane, stdout, stderr)
		if return_val ~= 0 then
			local message = humane or stderr
			util.notify(message)
		end

		callback(return_val == 0, nil, stdout, stderr)
	end)
end

return M
