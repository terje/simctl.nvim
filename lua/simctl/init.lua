local M = {}

local util = require("simctl.util")

--- Quit app on all running or a specific iOS Simulator(s)
-- @param appId the app ID of the app to quit
-- @param callback function to call when command finishes
-- @param simulatorId the ID of the simulator to affect. Defaults to "booted"
M.terminate = function(appId, callback, simulatorId)
	simulatorId = simulatorId or "booted"
	util.execute("xcrun simctl terminate " .. simulatorId .. " " .. appId, callback)
end

--- Uninstall app on all running or a specific iOS Simulator(s)
-- @param appId the app ID of the app to uninstall
-- @param callback function to call when command finishes
-- @param simulatorId the ID of the simulator to affect. Defaults to "booted"
M.uninstall = function(appId, callback, simulatorId)
	simulatorId = simulatorId or "booted"
	util.execute("xcrun simctl uninstall " .. simulatorId .. " " .. appId, callback)
end

return M
