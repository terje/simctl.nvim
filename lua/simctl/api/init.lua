local M = {}

local util = require("simctl.util")
local simctl = require("simctl.api.simctl")

--- Launch app on all running or a specific iOS Simulator(s)
-- @param args Table containing the following keys:
-- @param args.appId string The application identifier of the app to launch
-- @param args.simulatorId string The simulator identifier. Optional, defaults to "booted"
-- @param callback function The function to call upon completion. Optional
M.launch = function(args, callback)
	callback = callback or function(_, _, _) end

	if args.appId == nil then
		util.notify("No appId provided", vim.log.levels.ERROR)
		callback(false)
		return
	end

	args = util.merge(args, {
		simulatorId = "booted",
	})

	simctl.execute({ "launch", args.simulatorId, args.appId }, function(return_val, humane, stdout, stderr)
		if return_val ~= 0 then
			local message = humane or stderr
			util.notify(message)
		end

		callback(return_val == 0, stdout, stderr)
	end)
end

--- Quit app on all running or a specific iOS Simulator(s)
-- @param args Table containing the following keys:
-- @param args.appId string The application identifier of the app to quit
-- @param args.simulatorId string The simulator identifier. Optional, defaults to "booted"
-- @param callback function The function to call upon completion. Optional
M.terminate = function(args, callback)
	callback = callback or function(_, _, _) end

	if args.appId == nil then
		util.notify("No appId provided", vim.log.levels.ERROR)
		callback(false)
		return
	end

	args = util.merge(args, {
		simulatorId = "booted",
	})

	simctl.execute({ "terminate", args.simulatorId, args.appId }, function(return_val, humane, stdout, stderr)
		if return_val ~= 0 then
			local message = humane or stderr
			util.notify(message)
		end

		callback(return_val == 0, stdout, stderr)
	end)
end

--- Uninstall app on all running or a specific iOS Simulator(s)
-- @param args Table containing the following keys:
-- @param args.appId string The application identifier of the app to uninstall
-- @param args.simulatorId string The simulator identifier. Optional, defaults to "booted"
-- @param callback function The function to call upon completion. Optional
M.uninstall = function(args, callback)
	callback = callback or function(_, _, _) end

	if args.appId == nil then
		util.notify("No appId provided", vim.log.levels.ERROR)
		callback(false)
		return
	end

	args = util.merge(args, {
		simulatorId = "booted",
	})

	simctl.execute({ "uninstall", args.simulatorId, args.appId }, function(return_val, humane, stdout, stderr)
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

		callback(return_val == 0, stdout, stderr)
	end)
end

--- Erase (reset) all or a specific iOS Simulator(s)
---@param simulatorId string ID of the simulator to affect, or "all" for all Simulators
---@param callback function app ID of the app to launch
M.erase = function(simulatorId, callback)
	callback = callback or function() end

	if simulatorId == nil then
		util.notify("No simulatorId provided", vim.log.levels.ERROR)
		callback(false)
		return
	end

	simctl.execute({ "erase", simulatorId }, function(return_val, humane, stdout, stderr)
		if return_val ~= 0 then
			local message = humane or stderr
			util.notify(message)
		end

		callback(return_val == 0, stdout, stderr)
	end)
end

return M
