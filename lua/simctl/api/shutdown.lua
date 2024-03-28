local M = {}

local util = require("simctl.lib.util")
local simctl = require("simctl.lib.simctl")

--- Shut down all or a specific iOS Simulator(s)
-- @param args Table containing the following keys:
-- @param args.deviceId string The simulator identifier. Optional, defaults to "booted"
---@param callback function to call when command finishes, indicating success or failure
M.shutdown = function(deviceId, callback)
	callback = callback or function() end

	if args.deviceId == nil then
		util.notify("No deviceId provided", vim.log.levels.ERROR)
		callback(false)
		return
	end

	args = util.merge(args, {})

	simctl.execute({ "shutdown", deviceId }, function(return_val, humane, stdout, stderr)
		if return_val ~= 0 then
			local message = humane or stderr
			util.notify(message)
		end

		callback(return_val == 0, nil, stdout, stderr)
	end)
end

return M
