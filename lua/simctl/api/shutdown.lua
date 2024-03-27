local M = {}

local util = require("simctl.lib.util")
local simctl = require("simctl.lib.simctl")

--- Shut down all or a specific iOS Simulator(s)
---@param simulatorId string ID of the simulator to affect, or "all" for all Simulators
---@param callback function to call when command finishes, indicating success or failure
M.shutdown = function(simulatorId, callback)
	-- TODO: Change from simulatorId to args
	callback = callback or function() end

	if simulatorId == nil then
		util.notify("No simulatorId provided", vim.log.levels.ERROR)
		callback(false)
		return
	end

	simctl.execute({ "shutdown", simulatorId }, function(return_val, humane, stdout, stderr)
		if return_val ~= 0 then
			local message = humane or stderr
			util.notify(message)
		end

		callback(return_val == 0, nil, stdout, stderr)
	end)
end

return M
