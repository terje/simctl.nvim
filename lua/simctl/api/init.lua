local M = {}

local util = require("simctl.util")
local simctl = require("simctl.api.simctl")

--- Launch app on all running or a specific iOS Simulator(s)
---@param appId string the app ID of the app to launch
---@param simulatorId string the ID of the simulator to affect. Defaults to "booted"
---@param callback function to call when command finishes
M.launch = function(appId, simulatorId, callback)
	simulatorId = simulatorId or "booted"
	callback = callback or function() end

	simctl.execute({ "launch", simulatorId, appId }, function(return_val, humane, stdout, stderr)
		if return_val ~= 0 then
			local message = humane or stderr
			util.notify(message)
		end

		callback(return_val == 0, stdout, stderr)
	end)
end

--- Quit app on all running or a specific iOS Simulator(s)
---@param appId string the app ID of the app to quit
---@param simulatorId string the ID of the simulator to affect. Defaults to "booted"
---@param callback function to call when command finishes, indicating success or failure
M.terminate = function(appId, simulatorId, callback)
	simulatorId = simulatorId or "booted"
	callback = callback or function() end

	simctl.execute({ "terminate", simulatorId, appId }, function(return_val, humane, stdout, stderr)
		if return_val ~= 0 then
			local message = humane or stderr
			util.notify(message)
		end

		callback(return_val == 0, stdout, stderr)
	end)
end

--- Uninstall app on all running or a specific iOS Simulator(s)
---@param appId string the app ID of the app to uninstall
---@param simulatorId string the ID of the simulator to affect
---@param callback function to call when command finishes, indicating success or failure
M.uninstall = function(appId, simulatorId, callback)
	simulatorId = simulatorId or "booted"
	callback = callback or function() end

	simctl.execute({ "uninstall", simulatorId, appId }, function(return_val, humane, stdout, stderr)
		if return_val ~= 0 then
			local message = humane or stderr
			util.notify(message)
		end

		callback(return_val == 0, stdout, stderr)
	end)
end

--- Shut down all or a specific iOS Simulator(s)
---@param simulatorId string ID of the simulator to affect, or "all" for all Simulators
---@param callback function to call when command finishes, indicating success or failure
M.shutdown = function(simulatorId, callback)
	callback = callback or function() end

	simctl.execute({ "shutdown", simulatorId }, function(return_val, humane, stdout, stderr)
		if return_val ~= 0 then
			local message = humane or stderr
			util.notify(message)
		end

		callback(return_val == 0, stdout, stderr)
	end)
end

--- Erase (reset) all or a specific iOS Simulator(s)
---@param simulatorId string ID of the simulator to affect, or "all" for all Simulators
---@param callback function app ID of the app to launch
M.erase = function(simulatorId, callback)
	callback = callback or function() end

	simctl.execute({ "erase", simulatorId }, function(return_val, humane, stdout, stderr)
		if return_val ~= 0 then
			local message = humane or stderr
			util.notify(message)
		end

		callback(return_val == 0, stdout, stderr)
	end)
end

return M
