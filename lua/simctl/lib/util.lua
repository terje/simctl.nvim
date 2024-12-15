local M = {}

local config = require("simctl.config")

M.merge = function(args, defaults)
	args = args or {}
	defaults = defaults or {}
	return vim.tbl_deep_extend("force", {}, defaults, args)
end

M.notify = function(message, level)
	if not config.options.notify then
		return
	end

	level = level or vim.log.levels.INFO
	vim.notify("iOS Simulator: " .. message, level)
end

local simulatorAppStatus = function(callback)
	vim.system({
		"sh",
		"-c",
		"ps aux | grep -c Simulator.app",
	}, { text = true }, function(result)
		callback(result.code == 1)
	end)
end

M.openSimulatorApp = function()
	simulatorAppStatus(function(isSimulatorRunning)
		if not isSimulatorRunning then
			vim.system({ "open", "-a", "Simulator.app" })
		end
	end)
end

M.isValidKey = function(key, table)
	if type(table) ~= "table" then
		return false
	end

	for _, v in pairs(table) do
		if v == key then
			return true
		end
	end
	return false
end

M.trim = function(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

M.defaultCallback = function(success, result)
	if not success then
		M.notify(result, vim.log.levels.ERROR)
	end
end

return M
